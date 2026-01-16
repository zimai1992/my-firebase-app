import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.notification].request();
  }
}
