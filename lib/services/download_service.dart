import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  Future<String?> downloadAudio(String hymnNumber, String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/hymn_$hymnNumber.mp3';

      await _dio.download(url, filePath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('audio_$hymnNumber', filePath);

      return filePath;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }

  Future<String?> getLocalPath(String hymnNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('audio_$hymnNumber');
  }

  Future<bool> isDownloaded(String hymnNumber) async {
    final path = await getLocalPath(hymnNumber);
    if (path == null) return false;
    return File(path).exists();
  }
}
