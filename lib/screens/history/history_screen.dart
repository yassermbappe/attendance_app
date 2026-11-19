import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import 'widgets/record_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.userId,
    this.attendanceService,
  });

  final String userId;
  final AttendanceService? attendanceService;

  @override
  Widget build(BuildContext context) {
    final stream = (attendanceService ?? AttendanceService())
        .getAttendanceRecords(userId);
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat presensi')),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Riwayat gagal dimuat. Periksa penyimpanan perangkat dan coba lagi.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!.toList()
            ..sort((first, second) {
              return second.checkInTime.compareTo(first.checkInTime);
            });
          if (records.isEmpty) {
            return const Center(child: Text('Belum ada riwayat presensi'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) => RecordCard(record: records[index]),
          );
        },
      ),
    );
  }
}
