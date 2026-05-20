import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/audio_player_service.dart';
import '../services/hymn_download_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _player = AudioPlayerService();
  final HymnDownloadService _download = HymnDownloadService();
  String? _currentHymnNumber;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Duration _position = Duration.zero;
  Duration? _duration;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  String? get currentHymnNumber => _currentHymnNumber;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  Duration get position => _position;
  Duration? get duration => _duration;
  // For backward compatibility with audio_play_button.dart
  String? get playingHymnNumber => _currentHymnNumber;

  AudioProvider() {
    _positionSub = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _durationSub = _player.durationStream.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> togglePlay(String hymnNumber, String audioUrl) async {
    if (audioUrl.isEmpty) throw Exception('No audio available.');

    if (_currentHymnNumber == hymnNumber && _player.isPlaying) {
      await _player.pause();
      _currentHymnNumber = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final localPath = await _download.getLocalPath(hymnNumber);
      final hasLocal = localPath != null && await File(localPath).exists();
      await _player.load(hymnNumber, audioUrl,
          localPath: hasLocal ? localPath : null);
      await _player.play();
      _currentHymnNumber = hymnNumber;
    } catch (e) {
      _currentHymnNumber = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> downloadHymn(String hymnNumber, String audioUrl) async {
    if (_isDownloading) return;
    if (await _download.isDownloaded(hymnNumber))
      throw Exception('Already downloaded.');
    if (!await _hasInternet()) throw Exception('No internet connection.');

    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      await for (final progress
          in _download.downloadAudio(hymnNumber, audioUrl)) {
        _downloadProgress = progress;
        notifyListeners();
      }
      _isDownloading = false;
      _downloadProgress = 1.0;
      notifyListeners();
    } catch (e) {
      _isDownloading = false;
      rethrow;
    }
  }

  void cancelDownload() {
    _download.cancelDownload();
    _isDownloading = false;
    _downloadProgress = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
