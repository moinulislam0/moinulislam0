import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:jwells/features/home/presentation/view/widgets/voice_widget.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String url;
  final String? duration;

  const VoicePlayerWidget({super.key, required this.url, this.duration});

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  late AudioPlayer _audioPlayer;

  // To handle disposing listeners safely
  final List<StreamSubscription> _streams = [];

  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Static heights for waveform
  final List<double> _barHeights = List.generate(
    40,
    (index) => Random().nextDouble(),
  );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listeners
    _streams.add(
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state == PlayerState.playing;
          });
        }
      }),
    );

    _streams.add(
      _audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) setState(() => _duration = newDuration);
      }),
    );

    _streams.add(
      _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) setState(() => _position = newPosition);
      }),
    );
  }

  @override
  void dispose() {
    for (var s in _streams) s.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (_duration.inSeconds == 0 && widget.duration != null) {
      return widget.duration!;
    }
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.url));
    }
  }

  // SEEKING METHOD
  void _seekTo(double dx, double maxWidth) {
    if (_duration.inMilliseconds == 0) return;

    // Calculate percentage based on touch position
    double relative = dx / maxWidth;
    relative = relative.clamp(0.0, 1.0);

    // Calculate new position
    final newPos = Duration(
      milliseconds: (_duration.inMilliseconds * relative).round(),
    );

    _audioPlayer.seek(newPos);
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = 0.0;
    if (_duration.inMilliseconds > 0) {
      progressPercent = (_position.inMilliseconds / _duration.inMilliseconds)
          .clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: const Color(0xFF38E07B),
              size: 35,
            ),
          ),
          const SizedBox(width: 12),

          // STATIC WAVEFORM WITH SEEK/SCRUB
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  // Handle Tap seeking
                  onTapUp: (details) {
                    _seekTo(details.localPosition.dx, constraints.maxWidth);
                  },
                  // Handle Drag seeking
                  onHorizontalDragUpdate: (details) {
                    _seekTo(details.localPosition.dx, constraints.maxWidth);
                  },
                  child: SizedBox(
                    height: 30,
                    child: CustomPaint(
                      painter: WaveformPainter(
                        barHeights: _barHeights,
                        progressPercent: progressPercent,
                        playedColor: const Color(0xFF38E07B),
                        unplayedColor: Colors.white24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),
          Text(
            // Show duration logic
            isPlaying || _position.inMilliseconds > 0
                ? _formatDuration(_position)
                : (widget.duration ?? _formatDuration(_duration)),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.volume_up, color: Colors.white54, size: 18),
        ],
      ),
    );
  }
}