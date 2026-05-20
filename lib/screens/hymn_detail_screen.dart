import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../providers/audio_provider.dart';

class HymnDetailScreen extends StatelessWidget {
  final Hymn hymn;
  const HymnDetailScreen({required this.hymn});

  Future<void> _downloadAudio(BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    if (hymn.audioUrl.isEmpty) {
      _showErrorSnackbar(context, 'No audio available to download.');
      return;
    }
    try {
      await audioProvider.downloadHymn(hymn.number, hymn.audioUrl);
      _showSuccessSnackbar(context, 'Download complete!');
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show prompt every time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎵 Tap the play button to listen to this hymn.'),
          duration: Duration(seconds: 3),
        ),
      );
    });

    final theme = Theme.of(context);
    final hasAudio = hymn.audioUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn ${hymn.number}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    hymn.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...hymn.lyrics.map((segment) {
                    final isChorus = segment.type.toLowerCase() == 'chorus';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      color: isChorus
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (segment.label.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  segment.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: isChorus
                                        ? theme.colorScheme.primary
                                        : theme.hintColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Text(
                              segment.content,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.6,
                                fontStyle: isChorus
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontWeight: isChorus
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Sticky bottom controls
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              top: false,
              child: Consumer<AudioProvider>(
                builder: (context, audioProvider, child) {
                  final isPlaying =
                      audioProvider.currentHymnNumber == hymn.number;
                  final isLoading = audioProvider.isLoading && isPlaying;
                  final isDownloading = audioProvider.isDownloading;
                  final position = audioProvider.position;
                  final duration = audioProvider.duration;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (!hasAudio) {
                                _showErrorSnackbar(context,
                                    'No audio available for this hymn.');
                                return;
                              }
                              try {
                                await audioProvider.togglePlay(
                                    hymn.number, hymn.audioUrl);
                              } catch (e) {
                                _showErrorSnackbar(context, e.toString());
                              }
                            },
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF44A6C6)),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    size: 56,
                                    color: hasAudio
                                        ? const Color(0xFF44A6C6)
                                        : Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 24),
                          if (isDownloading)
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF44A6C6)),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.download, size: 28),
                              color: hasAudio
                                  ? const Color(0xFF44A6C6)
                                  : Colors.grey,
                              onPressed: hasAudio
                                  ? () => _downloadAudio(context)
                                  : null,
                              tooltip: 'Download for offline listening',
                            ),
                        ],
                      ),
                      if (isDownloading && audioProvider.downloadProgress > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: audioProvider.downloadProgress,
                            backgroundColor: Colors.grey.shade300,
                            color: const Color(0xFF44A6C6),
                          ),
                        ),
                      if (duration != null) ...[
                        const SizedBox(height: 8),
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            audioProvider
                                .seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: const Color(0xFF44A6C6),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: theme.textTheme.bodySmall),
                              Text(_formatDuration(duration),
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
