import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<void> requestPermission() async {
    const permission = Permission.camera;

    if (await permission.isDenied) {
      final result = await permission.request();
      if (result.isGranted) {
        // Permission is granted
      } else if (result.isDenied) {
        // Permission is denied
      } else if (result.isPermanentlyDenied) {
        // Permission is permanently denied
      }
    }
  }
  // // Solicitar permiso de cámara
  // Future<bool> requestCameraPermission() async {
  //   final status = await Permission.camera.request();
  //   if (status == PermissionStatus.permanentlyDenied) {
  //     openAppSettings(); // Redirigir a la configuración si está permanentemente denegado
  //   }
  //   return status == PermissionStatus.granted;
  // }

  // // Solicitar permiso de almacenamiento
  // Future<bool> requestStoragePermission() async {
  //   final status = await Permission.storage.request(); // Para Android
  //   if (status == PermissionStatus.permanentlyDenied) {
  //     openAppSettings(); // Redirigir a la configuración si está permanentemente denegado
  //   }
  //   return status == PermissionStatus.granted;
  // }

  // // Solicitar permisos de cámara y almacenamiento (para Android)
  // Future<bool> requestCameraAndGalleryPermissions() async {
  //   final cameraStatus = await Permission.camera.request();
  //   final storageStatus = await Permission.storage.request(); // Para Android

  //   if (cameraStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
  //     openAppSettings(); // Redirigir a configuración si algún permiso está permanentemente denegado
  //   }

  //   return cameraStatus.isGranted && (storageStatus.isGranted);
  // }
}
