import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Uint8List? _decodeBase64(String value) {
  try {
    final encoded = value.startsWith('data:image/')
        ? value.substring(value.indexOf(',') + 1)
        : value;
    return base64Decode(encoded);
  } on FormatException {
    return null;
  }
}

class PhotoViewer extends StatelessWidget {
  const PhotoViewer({super.key, required this.photoPath});

  final String? photoPath;

  static Future<void> open(BuildContext context, String? photoPath) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewer(photoPath: photoPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = photoPath;
    if (value == null || value.isEmpty) return _buildScaffold(_placeholder());

    return FutureBuilder<bool>(
      future: File(value).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildScaffold(
            const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return _buildScaffold(
            InteractiveViewer(
              child: Image.file(
                File(value),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
            ),
          );
        }

        final bytes = _decodeBase64(value);
        if (bytes == null) return _buildScaffold(_placeholder());
        return _buildScaffold(
          InteractiveViewer(
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaffold(Widget child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto presensi')),
      body: Center(child: child),
    );
  }

  Widget _placeholder() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 56),
        SizedBox(height: 8),
        Text('Foto tidak tersedia'),
      ],
    );
  }
}

class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({super.key, required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final value = photoPath;
    if (value == null || value.isEmpty) return _placeholder();

    return FutureBuilder<bool>(
      future: File(value).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.data == true) {
          return Image.file(
            File(value),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(),
          );
        }

        final bytes = _decodeBase64(value);
        if (bytes == null) return _placeholder();
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(),
        );
      },
    );
  }

  Widget _placeholder() {
    return const Center(child: Icon(Icons.image_not_supported_outlined));
  }
}
