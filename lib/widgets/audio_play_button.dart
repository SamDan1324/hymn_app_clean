import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class AudioPlayButton extends StatelessWidget {
  final String hymnNumber;
  final String audioUrl;

  const AudioPlayButton({required this.hymnNumber, required this.audioUrl});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isLoading = audioProvider.isLoading;
        final isPlaying = audioProvider.playingHymnNumber == hymnNumber;

        if (audioUrl.isEmpty) {
          return Tooltip(
            message: 'No audio available',
            child: Icon(Icons.music_off, color: Colors.grey.shade400),
          );
        }

        if (isLoading && isPlaying) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        return IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => audioProvider.togglePlay(hymnNumber, audioUrl),
        );
      },
    );
  }
}
