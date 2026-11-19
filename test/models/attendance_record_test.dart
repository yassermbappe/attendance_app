import 'package:attendance_app/models/attendance_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkIn = DateTime(2026, 11, 12, 8, 15);

  AttendanceRecord record({DateTime? checkOutTime}) {
    return AttendanceRecord(
      id: 'record-1',
      userId: 'user-1',
      checkInTime: checkIn,
      checkOutTime: checkOutTime,
      date: DateTime(2026, 11, 12),
      checkInPhotoPath: '/photo/checkin.jpg',
    );
  }

  test('JSON round-trip preserves fields and date uses YYYY-MM-DD', () {
    final original = record(checkOutTime: DateTime(2026, 11, 12, 16, 15));
    final json = original.toJson();
    final restored = AttendanceRecord.fromJson(json);

    expect(json['date'], '2026-11-12');
    expect(restored.id, original.id);
    expect(restored.userId, original.userId);
    expect(restored.checkInTime, original.checkInTime);
    expect(restored.checkOutTime, original.checkOutTime);
    expect(restored.checkInPhotoPath, original.checkInPhotoPath);
  });

  test('copyWith can add a checkout time', () {
    final updated = record().copyWith(
      checkOutTime: DateTime(2026, 11, 12, 16, 15),
    );
    expect(updated.checkOutTime, DateTime(2026, 11, 12, 16, 15));
  });

  test('totalHours is null before checkout and measures exact duration', () {
    expect(record().totalHours, isNull);
    expect(
      record(checkOutTime: DateTime(2026, 11, 12, 16, 15)).totalHours,
      const Duration(hours: 8),
    );
    expect(
      record(checkOutTime: DateTime(2026, 11, 12, 16, 45)).totalHours,
      const Duration(hours: 8, minutes: 30),
    );
  });
}
