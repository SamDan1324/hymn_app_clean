class LyricSegment {
  final String type;
  final String label;
  final String content;

  LyricSegment(
      {required this.type, required this.label, required this.content});

  factory LyricSegment.fromJson(Map<String, dynamic> json) {
    return LyricSegment(
      type: json['type'] ?? 'verse',
      label: json['label'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
