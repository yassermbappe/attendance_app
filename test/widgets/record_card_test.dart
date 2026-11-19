import 'package:attendance_app/models/attendance_record.dart';
import 'package:attendance_app/screens/history/widgets/record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('record card with photo renders without container assertion', (
    tester,
  ) async {
    final record = AttendanceRecord(
      id: 'record-1',
      userId: 'user-1',
      checkInTime: DateTime(2026, 11, 12, 8, 15),
      date: DateTime(2026, 11, 12),
      checkInPhotoPath: '/photo/checkin.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecordCard(record: record)),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Foto Masuk'), findsOneWidget);
  });
}
