import 'package:camera/camera.dart';
import 'package:classificador_fotos/screens/captura_foto_screen.dart';
import 'package:classificador_fotos/screens/classificador_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.cameras,
  }) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classificador de imagens',
      theme: ThemeData.dark().copyWith(),
      home: CapturaFotoScreen(cameras: cameras),
      // initialRoute: '/captura_foto',
      // routes: _buildRoutes(),
    );
  }

  _buildRoutes() {
    return {
      '/captura_foto': (context) => CapturaFotoScreen(cameras: cameras),
      // '/classificador': (context) => const ClassificadorScreen(),
    };
  }
}
