import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoCapture extends StatefulWidget {
  const VideoCapture({Key? key}) : super(key: key);

  @override
  State<VideoCapture> createState() => _VideoCaptureState();
}

class _VideoCaptureState extends State<VideoCapture> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;
  bool playing = false;
  bool muted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _previewVideo()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.white,
            onPressed: () async {
              final XFile? file = await _picker.pickVideo(
                  source: ImageSource.camera,
                  maxDuration: const Duration(minutes: 10));
              setState(() {});
              _playVideo(file);
              ("Video Path ${file!.path}");
            },
            child: const Icon(Icons.video_call_rounded, color: Colors.black),
          ),
          FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.white,
            onPressed: () async {
              setState(() {
                playing = !playing;
                !playing ? _controller!.pause() : _controller!.play();
              });
            },
            child: !playing
                ? const Icon(Icons.play_arrow, color: Colors.black)
                : const Icon(Icons.pause, color: Colors.black),
          ),
          FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.white,
              onPressed: () async {
                setState(() {
                  muted = !muted;
                  muted
                      ? _controller!.setVolume(0)
                      : _controller!.setVolume(100);
                });
              },
              child: !muted
                  ? const Icon(
                      Icons.volume_up,
                      color: Colors.black,
                    )
                  : const Icon(Icons.volume_mute, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _previewVideo() {
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 50),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _controller = controller;

      await controller.initialize();
      await controller.setLooping(true);
      setState(() {});
    } else {
      const ScaffoldMessenger(
          child: AlertDialog(
        title: Text('Error Loading Video'),
      ));
    }
  }

  Future<void> _disposeVideoController() async {
    _controller = null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
