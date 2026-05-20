import 'lyric_segment.dart';

class Hymn {
  final String number; // changed from int to String
  final String title;
  final List<LyricSegment> lyrics;
  final String audioUrl;
  final String pdfUrl;

  Hymn({
    required this.number,
    required this.title,
    required this.lyrics,
    required this.audioUrl,
    required this.pdfUrl,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    var lyricsList = json['lyrics'] as List? ?? [];
    return Hymn(
      number: json['number'].toString(), // convert any type to String
      title: json['title'] ?? 'Untitled',
      lyrics: lyricsList.map((item) => LyricSegment.fromJson(item)).toList(),
      audioUrl: json['audio_url'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
    );
  }

  // For searching, we can still use number as string directly
  String get fullLyricsText {
    return lyrics.map((seg) => seg.content).join(' ');
  }
}
