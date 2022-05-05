import 'dart:async';

import 'package:camera/camera.dart';
import 'package:classificador_fotos/screens/classificador_screen.dart';
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
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
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
                    _buildButtonSwitchCamera(),
                    _buildButtonTakePicture(),
                    if (cameraIndex == 0) _buildButtonModeFlash(),
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
    return InkWell(
      onTap: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
          await _controller.setFlashMode(FlashMode.off);
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClassificadorScreen(imagePath: image.path),
            ),
          );
        } catch (e) {
          print(e);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.circle, color: Colors.white38, size: 80),
          const Icon(Icons.circle, color: Colors.white, size: 65),
        ],
      ),
    );
  }

  _buildButtonSwitchCamera() {
    return InkWell(
      onTap: () {
        if (cameraIndex == widget.cameras.length - 1) {
          cameraIndex = 0;
        } else {
          cameraIndex++;
        }
        setState(() {
          _controller = CameraController(
            widget.cameras[cameraIndex],
            ResolutionPreset.medium,
          );
          _initializeControllerFuture = _controller.initialize();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.black38,
            size: 60,
          ),
          Icon(
            cameraIndex == 1 ? Icons.camera_rear : Icons.camera_front,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  _buildButtonModeFlash() {
    return InkWell(
      onTap: () async {
        _currentFlashMode != FlashMode.off
            ? _currentFlashMode = FlashMode.off
            : _currentFlashMode = FlashMode.torch;
        await _controller.setFlashMode(_currentFlashMode);
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.circle, color: Colors.black, size: 60),
          if (_currentFlashMode == FlashMode.off)
            const Icon(Icons.flash_off, color: Colors.white)
          else
            const Icon(Icons.highlight, color: Colors.amber),
        ],
      ),
    );
  }
}
