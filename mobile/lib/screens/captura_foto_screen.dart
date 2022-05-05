import 'dart:async';

import 'package:camera/camera.dart';
import 'package:classificador_fotos/screens/classificador_screen.dart';
import 'package:classificador_fotos/widgets/elevated_button_camera.dart';
import 'package:flutter/material.dart';

class CapturaFotoScreen extends StatefulWidget {
  const CapturaFotoScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  CapturaFotoScreenState createState() => CapturaFotoScreenState();
}

class CapturaFotoScreenState extends State<CapturaFotoScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    _controller.setFlashMode(FlashMode.off).then((value) => null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture uma foto')),
      body: _buildBody(),
    );
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller.setExposurePoint(offset);
    _controller.setFocusPoint(offset);
  }

  _buildBody() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              CameraPreview(
                _controller,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) =>
                          onViewFinderTap(details, constraints),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButtonTakePicture(),
                    _buildButtonSwitchCamera(),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _buildButtonTakePicture() {
    return ElevatedButtonCamera(
      onPressed: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClassificadorScreen(imagePath: image.path),
            ),
          );
        } catch (e) {
          print(e);
        }
      },
      icon: const Icon(Icons.camera_alt_outlined),
      color: Colors.lightBlue,
    );
  }

  _buildButtonSwitchCamera() {
    return ElevatedButtonCamera(
      onPressed: () {
        if (cameraIndex == widget.cameras.length - 1) {
          cameraIndex = 0;
        } else {
          cameraIndex++;
        }
        setState(() {
          _controller.dispose();
          _controller = CameraController(
            widget.cameras[cameraIndex],
            ResolutionPreset.ultraHigh,
          );
          _initializeControllerFuture = _controller.initialize();
        });
      },
      icon: const Icon(Icons.cameraswitch_outlined),
      color: Colors.pink,
    );
  }
}
