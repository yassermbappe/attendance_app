import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract class PhotoStorage {
  Future<String> savePhoto(String sourcePath, String photoType);
}

class StorageServices implements PhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, String photoType) async {
    if (photoType != 'checkin' && photoType != 'checkout') {
      throw ArgumentError.value(photoType, 'photoType');
    }

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('File foto tidak ditemukan.', sourcePath);
    }

    final applicationDirectory = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      path.join(applicationDirectory.path, 'attendance_photos'),
    );
    await photoDirectory.create(recursive: true);

    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final microseconds = now.microsecond.toString().padLeft(6, '0');
    final targetPath = path.join(
      photoDirectory.path,
      '${timestamp}_${microseconds}_$photoType.jpg',
    );
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (compressedFile == null || !await File(targetPath).exists()) {
      throw StateError('Foto gagal dikompres dan disimpan.');
    }
    return targetPath;
  }

  // Meski bernama upload, versi ini hanya menyimpan lokal.
  Future<String> uploadAttendancePhoto(String sourcePath, String photoType) {
    return savePhoto(sourcePath, photoType);
  }
}
