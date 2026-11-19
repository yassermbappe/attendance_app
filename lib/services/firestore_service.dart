import '../models/attendance_record.dart';
import 'attendance_service.dart';

// Nama kelas belum berarti membaca Firestore. Versi ini hanya meneruskan ke AttendanceService.
class FirestoreService implements AttendanceService {
  FirestoreService({AttendanceService? attendanceService})
    : _attendanceService = attendanceService ?? AttendanceService();

  final AttendanceService _attendanceService;

  @override
  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) =>
      _attendanceService.getAttendanceRecords(userId);

  @override
  Stream<AttendanceRecord?> getTodayRecordStream(String userId) =>
      _attendanceService.getTodayRecordStream(userId);

  @override
  Future<String> createAttendanceRecord(AttendanceRecord record) =>
      _attendanceService.createAttendanceRecord(record);

  @override
  Future<void> updateAttendanceRecord(AttendanceRecord record) =>
      _attendanceService.updateAttendanceRecord(record);
}
