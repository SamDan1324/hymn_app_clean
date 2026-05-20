import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../services/hymn_service.dart';
import '../widgets/audio_play_button.dart';
import 'hymn_detail_screen.dart';

class HymnListScreen extends StatefulWidget {
  @override
  _HymnListScreenState createState() => _HymnListScreenState();
}

class _HymnListScreenState extends State<HymnListScreen> {
  final HymnService _hymnService = HymnService();
  List<Hymn> _allHymns = [];
  List<Hymn> _filteredHymns = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHymns();
  }

  Future<void> _loadHymns() async {
    final hymns = await _hymnService.loadHymns(context);
    setState(() {
      _allHymns = hymns;
      _filteredHymns = hymns;
    });
  }

  void _search(String query) {
    setState(() {
      _filteredHymns = _hymnService.searchHymns(_allHymns, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Christian Hymns'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by number, title, or lyrics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: _filteredHymns.isEmpty
          ? const Center(child: Text('No hymns found'))
          : ListView.builder(
              itemCount: _filteredHymns.length,
              itemBuilder: (context, index) {
                final hymn = _filteredHymns[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(hymn.number),
                  ),
                  title: Text(hymn.title),
                  subtitle: Text(
                    hymn.lyrics.isNotEmpty
                        ? (hymn.lyrics.first.content.length > 60
                            ? '${hymn.lyrics.first.content.substring(0, 60)}...'
                            : hymn.lyrics.first.content)
                        : 'No lyrics',
                  ),
                  trailing: AudioPlayButton(
                    hymnNumber: hymn.number,
                    audioUrl: hymn.audioUrl,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HymnDetailScreen(hymn: hymn),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
