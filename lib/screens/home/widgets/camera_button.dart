import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/permission_service.dart';
import '../../../services/storage_services.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  static final _imagePicker = ImagePicker();
  static final _permissionService = PermissionService();

  static Future<String?> capturePhoto(
    BuildContext context,
    PhotoStorage photoStorage,
    String photoType,
  ) async {
    while (true) {
      final permission = await _permissionService.requestCameraPermission();
      if (!context.mounted) return null;
      if (permission.isGranted) break;

      if (permission.isPermanentlyDenied || permission.isRestricted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Izin kamera diperlukan'),
            content: const Text(
              'Aktifkan izin kamera di pengaturan agar foto presensi dapat diambil.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _permissionService.openAppSettings();
                },
                child: const Text('Buka pengaturan'),
              ),
            ],
          ),
        );
        return null;
      }

      final retry = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Izin kamera diperlukan'),
          content: const Text(
            'Kamera dibutuhkan untuk mengambil foto presensi. Berikan izin untuk melanjutkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
      if (retry != true) return null;
    }

    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    return photoStorage.savePhoto(image.path, photoType);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.camera_alt_outlined),
        label: Text(label),
      ),
    );
  }
}
