import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  String videoUrl;
  VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerPlus videoPlayerPlus;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    videoPlayerPlus = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.videoUrl),
        invalidateCacheIfOlderThan: const Duration(minutes: 69));

    videoPlayerPlus.initialize().then(
      (_) {
        setState(() {
          videoPlayerPlus.controller.play();
        });
      },
    );
  }

  @override
  void dispose() {
    videoPlayerPlus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          videoPlayerPlus.isInitialized
              ? VideoPlayer(videoPlayerPlus.controller)
              : const CircularProgressIndicator.adaptive(),
          Align(
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      videoPlayerPlus.controller.pause();
                    } else {
                      videoPlayerPlus.controller.play();
                    }
                    setState(() {
                      isPlaying != isPlaying;
                    });
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)))
        ],
      ),
    );
  }
}
