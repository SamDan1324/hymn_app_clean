import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentId;
  bool _isInitialized = false;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  bool get isPlaying => _player.playing;
  bool get isLoading =>
      _player.playerState.processingState == ProcessingState.loading;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> load(String id, String url, {String? localPath}) async {
    if (_currentId == id && _isInitialized) return;

    await _player.stop();

    final source = (localPath != null && await File(localPath).exists())
        ? AudioSource.file(
            localPath,
            tag: MediaItem(id: id, title: id),
          )
        : AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(id: id, title: id),
          );

    await _player.setAudioSource(source, preload: true);
    await _player.load();
    _currentId = id;
    _isInitialized = true;
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();

  Future<void> seek(Duration position) async {
    final total = _player.duration ?? Duration.zero;
    Duration clamped;
    if (position < Duration.zero) {
      clamped = Duration.zero;
    } else if (position > total) {
      clamped = total;
    } else {
      clamped = position;
    }
    await _player.seek(clamped);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentId = null;
    _isInitialized = false;
  }

  void dispose() => _player.dispose();
}
