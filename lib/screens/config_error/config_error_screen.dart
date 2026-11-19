import 'package:flutter/material.dart';

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Pasang Firebase CLI',
      'Jalankan firebase login',
      'Jalankan dart pub global activate flutterfire_cli',
      'Jalankan flutterfire configure --project=ID_PROJECT_ANDA',
      'Jalankan ulang aplikasi',
    ];

    return MaterialApp(
      title: 'Firebase belum dikonfigurasi',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Presensi Digital')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Firebase belum dikonfigurasi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text('Selesaikan langkah berikut untuk melanjutkan:'),
                    const SizedBox(height: 12),
                    for (var index = 0; index < steps.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${index + 1}. ${steps[index]}'),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Detail: $error',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
