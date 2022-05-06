import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dio/dio.dart';

const String url = 'https://classificadordeimagens.herokuapp.com/';

class ClassificadorScreen extends StatefulWidget {
  const ClassificadorScreen({Key? key, required this.imagePath})
      : super(key: key);

  final String imagePath;
  @override
  State<ClassificadorScreen> createState() => _ClassificadorScreenState();
}

class _ClassificadorScreenState extends State<ClassificadorScreen> {
  File? _pickedFile;
  File? _croppedFile;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _pickedFile = File(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _imageCard(),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: const Text('Classificar imagem'),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _image(),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 0.8 * screenWidth,
            maxHeight: 0.7 * screenHeight,
          ),
          child: Image.file(_croppedFile!));
    } else if (_pickedFile != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(_pickedFile!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: const Text("delete"),
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        if (_croppedFile == null)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              heroTag: const Text("crop"),
              onPressed: () {
                _cropImage();
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              heroTag: const Text("send"),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final response = await _postData(_croppedFile!);
                if (response == null) {
                  _showSnackBar('Algo inexperado aconteceu:(', true);
                } else if (response.statusCode == 200) {
                  _showResultadoClassificacao(
                    context,
                    response.data['predicted'],
                    response.data['precision'],
                  );
                } else if (response.data['file'] != null) {
                  _showSnackBar(response.data['file'].join('\n'), true);
                } else {
                  _showSnackBar('Algo inexperado aconteceu:(', true);
                }
                setState(() {
                  _isLoading = false;
                });
              },
              backgroundColor: Colors.green,
              tooltip: 'Continuar',
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.arrow_forward),
            ),
          )
      ],
    );
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _pickedFile!.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Recortar imagem',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      iosUiSettings: const IOSUiSettings(
        title: 'Recortar imagem',
      ),
    );
    if (croppedFile != null) {
      _croppedFile = File(croppedFile.path);
      setState(() {});
    }
  }

  _showResultadoClassificacao(context, predicted, precision) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15.0,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Sua foto foi reconhecida como: '),
                TextSpan(
                    text: predicted,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15.0,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Precisão: '),
                TextSpan(
                    text: '${(precision * 100).round()}%.',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _postData(File file) async {
    Dio dio = Dio();
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: "file.jpg"),
      });
      Response response = await dio.post(url, data: formData);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        return null;
      }
    }
  }

  _showSnackBar(message, showAction) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(message),
      action: !showAction
          ? SnackBarAction(
              label: 'Continuar',
              onPressed: () {},
            )
          : null,
      margin: const EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
