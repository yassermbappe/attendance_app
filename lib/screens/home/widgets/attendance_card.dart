import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import 'photo_viewer.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key, required this.record});

  final AttendanceRecord? record;

  @override
  Widget build(BuildContext context) {
    final currentRecord = record;
    if (currentRecord == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Belum ada presensi hari ini')),
        ),
      );
    }

    final checkOutTime = currentRecord.checkOutTime;
    final complete = checkOutTime != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complete ? 'Presensi selesai' : 'Sudah masuk',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _timeRow('Jam masuk', currentRecord.checkInTime),
            if (complete) ...[
              const SizedBox(height: 8),
              _timeRow('Jam pulang', checkOutTime),
              const SizedBox(height: 8),
              Text('Durasi: ${_formatDuration(currentRecord.totalHours!)}'),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _photoTile(
                  context,
                  'Foto masuk',
                  currentRecord.checkInPhotoPath,
                ),
                if (complete)
                  _photoTile(
                    context,
                    'Foto pulang',
                    currentRecord.checkOutPhotoPath,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeRow(String label, DateTime? time) {
    return Text(
      '$label: ${time == null ? 'Belum pulang' : DateFormat('HH:mm', 'id_ID').format(time)}',
    );
  }

  Widget _photoTile(BuildContext context, String label, String? photoPath) {
    return InkWell(
      onTap: () => PhotoViewer.open(context, photoPath),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: PhotoThumbnail(photoPath: photoPath),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours jam $minutes menit';
  }
}
