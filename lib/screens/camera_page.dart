import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera/flutter_camera.dart';
import 'package:videp/screens/player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late String path;
  @override
  Widget build(BuildContext context) {
    return FlutterCamera(
        color: Colors.amber,
        onVideoRecorded: (value) {
          File path = File(value.path);

          Player(path: path);
        });
  }
}
