import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hymn.dart';

class HymnService {
  List<Hymn> _allHymns = [];

  Future<List<Hymn>> loadHymns(BuildContext context) async {
    if (_allHymns.isNotEmpty) return _allHymns;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/hymns_all.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _allHymns = jsonList.map((item) => Hymn.fromJson(item)).toList();
      return _allHymns;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading hymns: $e'),
            backgroundColor: Colors.red),
      );
      return [];
    }
  }

  List<Hymn> searchHymns(List<Hymn> hymns, String query) {
    if (query.isEmpty) return hymns;
    final lowerQuery = query.toLowerCase();
    return hymns.where((hymn) {
      return hymn.number.toLowerCase().contains(lowerQuery) ||
          hymn.title.toLowerCase().contains(lowerQuery) ||
          hymn.fullLyricsText.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
