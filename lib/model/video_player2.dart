import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer2 extends StatefulWidget {
  final String uri;
  final String asset;

  const VideoPlayer2({
    super.key,
    required this.uri,
    required this.asset,
  });

  @override
  State<VideoPlayer2> createState() => _VideoPlayer2State();
}

class _VideoPlayer2State extends State<VideoPlayer2> {
  late FlickManager flickManager;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(uri: widget.uri, asset: widget.asset);
  }

  Future<void> _initializeVideoPlayer(
      {required String uri, required String asset}) async {
    try {
      VideoPlayerController controller;

      if (uri.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(uri));
      } else if (asset.isNotEmpty) {
        controller = VideoPlayerController.asset(asset);
      } else {
        throw Exception("No video source provided");
      }

      await controller.initialize();

      flickManager = FlickManager(
        videoPlayerController: controller,
        autoPlay: true, // Explicitly enable auto-play
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing video player: $e");
      // You might want to show an error to the user here
    }
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text(
            "Zurück",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 60,
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 107, 69, 106),
        ),
        body: _isInitialized
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: FlickVideoPlayer(
                  flickManager: flickManager,
                  flickVideoWithControls: const FlickVideoWithControls(
                    controls: FlickPortraitControls(
                      iconSize: 30,
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
