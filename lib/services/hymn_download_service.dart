import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HymnDownloadService {
  static final HymnDownloadService _instance = HymnDownloadService._internal();
  factory HymnDownloadService() => _instance;
  HymnDownloadService._internal();

  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String? _currentHymnNumber;

  Future<String?> getLocalPath(String hymnNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadsJson = prefs.getString('hymn_downloads');
    if (downloadsJson == null) return null;
    final Map<String, dynamic> downloads = jsonDecode(downloadsJson);
    return downloads[hymnNumber]?['path'];
  }

  Future<bool> isDownloaded(String hymnNumber) async {
    final path = await getLocalPath(hymnNumber);
    if (path == null) return false;
    return await File(path).exists();
  }

  Stream<double> downloadAudio(String hymnNumber, String url) async* {
    if (_currentHymnNumber == hymnNumber && _cancelToken != null) return;

    _cancelToken = CancelToken();
    _currentHymnNumber = hymnNumber;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'hymn_${hymnNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    int existingLength = 0;
    if (await file.exists()) existingLength = await file.length();

    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers:
              existingLength > 0 ? {'Range': 'bytes=$existingLength-'} : {},
        ),
        cancelToken: _cancelToken,
      );

      final sink = file.openWrite(mode: FileMode.append);
      int totalReceived = existingLength;
      int totalSize = existingLength;

      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        totalSize = existingLength + int.parse(contentLength);
      }

      await for (final List<int> chunk in response.data.stream) {
        sink.add(chunk);
        totalReceived += chunk.length;
        if (totalSize > 0) {
          final double progress = totalReceived / totalSize; // explicit double
          yield progress;
        }
      }
      await sink.close();

      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString('hymn_downloads');
      final Map<String, dynamic> downloads =
          existing != null ? jsonDecode(existing) : {};
      downloads[hymnNumber] = {
        'path': filePath,
        'url': url,
        'downloaded_at': DateTime.now().toIso8601String()
      };
      await prefs.setString('hymn_downloads', jsonEncode(downloads));

      _currentHymnNumber = null;
      _cancelToken = null;
      yield 1.0;
    } catch (e) {
      _currentHymnNumber = null;
      _cancelToken = null;
      rethrow;
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _currentHymnNumber = null;
    _cancelToken = null;
  }
}
