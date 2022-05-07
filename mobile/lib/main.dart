import 'package:camera/camera.dart';
import 'package:classificador_fotos/screens/captura_foto_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  final PermissionStatus permission = await Permission.camera.status;
  runApp(MyApp(cameras: cameras, cameraPermission: permission));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.cameras,
    required this.cameraPermission,
  }) : super(key: key);
  final List<CameraDescription> cameras;
  final PermissionStatus cameraPermission;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classificador de imagens',
      theme: ThemeData.dark().copyWith(),
      home: _checkPermission(cameraPermission),
    );
  }

  Widget _checkPermission(PermissionStatus permission) {
    if (permission.isPermanentlyDenied) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 100),
              Text('Permissão para acessar a câmera não concedida',
                  style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      );
    } else {
      return CapturaFotoScreen(
        cameras: cameras,
      );
    }
  }
}
