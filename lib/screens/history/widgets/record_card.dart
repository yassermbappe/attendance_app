import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMMM y', 'id_ID').format(record.date);
    final checkOutTime = record.checkOutTime;
    final duration = record.totalHours;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Jam masuk: ${DateFormat('HH:mm').format(record.checkInTime)}',
            ),
            Text(
              checkOutTime == null
                  ? 'Jam pulang: Belum pulang'
                  : 'Jam pulang: ${DateFormat('HH:mm').format(checkOutTime)}',
            ),
            if (duration != null)
              Text(
                'Durasi: ${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit',
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _photo(context, 'Masuk', record.checkInPhotoPath),
                if (record.checkOutPhotoPath != null)
                  _photo(context, 'Pulang', record.checkOutPhotoPath),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo(BuildContext context, String label, String? photoPath) {
    return InkWell(
      onTap: () => PhotoViewer.open(context, photoPath),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.antiAlias,
            child: PhotoThumbnail(photoPath: photoPath),
          ),
          Text('Foto $label'),
        ],
      ),
    );
  }
}
