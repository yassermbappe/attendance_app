import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class PermissionService {
  Future<permission_handler.PermissionStatus> requestCameraPermission() {
    return permission_handler.Permission.camera.request();
  }

  Future<bool> openAppSettings() => permission_handler.openAppSettings();
}
