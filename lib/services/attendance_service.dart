import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';

class AttendanceService {
  factory AttendanceService() => instance;

  AttendanceService._();

  static final AttendanceService instance = AttendanceService._();
  static const _storageKey = 'local_attendance_records_v1';

  final List<AttendanceRecord> _records = [];
  final Map<String, Set<MultiStreamController<List<AttendanceRecord>>>>
  _listeners = {};
  late final Future<void> _initialization = _initStorage();

  Future<void> _initStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final storedRecords = preferences.getString(_storageKey);
    if (storedRecords == null) return;

    final decodedRecords = jsonDecode(storedRecords) as List<dynamic>;
    _records
      ..clear()
      ..addAll(
        decodedRecords.map(
          (record) => AttendanceRecord.fromJson(record as Map<String, dynamic>),
        ),
      );
  }

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return Stream<List<AttendanceRecord>>.multi((controller) {
      final listeners = _listeners.putIfAbsent(userId, () => {});
      listeners.add(controller);
      unawaited(
        _initialization
            .then((_) {
              if (_listeners[userId]?.contains(controller) ?? false) {
                controller.add(_recordsForUser(userId));
              }
            })
            .catchError((Object error, StackTrace stackTrace) {
              controller.addError(error, stackTrace);
            }),
      );
      controller.onCancel = () {
        listeners.remove(controller);
        if (listeners.isEmpty) _listeners.remove(userId);
      };
    });
  }

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) async* {
    await for (final records in getAttendanceRecords(userId)) {
      final today = DateTime.now();
      AttendanceRecord? todayRecord;
      for (final record in records) {
        if (record.date.year == today.year &&
            record.date.month == today.month &&
            record.date.day == today.day) {
          todayRecord = record;
          break;
        }
      }
      yield todayRecord;
    }
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    await _initialization;
    if (_records.any(
      (existing) =>
          existing.userId == record.userId &&
          existing.date.year == record.date.year &&
          existing.date.month == record.date.month &&
          existing.date.day == record.date.day,
    )) {
      throw StateError('Presensi hari ini sudah ada.');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _records.add(record.copyWith(id: id));
    try {
      await _persistRecords();
    } catch (_) {
      _records.removeWhere((savedRecord) => savedRecord.id == id);
      rethrow;
    }
    _emitUpdates();
    return id;
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _initialization;
    final index = _records.indexWhere(
      (existing) =>
          existing.id == record.id && existing.userId == record.userId,
    );
    if (index == -1) {
      throw StateError('Presensi tidak ditemukan.');
    }

    final previousRecord = _records[index];
    _records[index] = record;
    try {
      await _persistRecords();
    } catch (_) {
      _records[index] = previousRecord;
      rethrow;
    }
    _emitUpdates();
  }

  List<AttendanceRecord> _recordsForUser(String userId) => _records
      .where((record) => record.userId == userId)
      .toList(growable: false);

  Future<void> _persistRecords() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(_records.map((record) => record.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Presensi gagal disimpan di perangkat.');
    }
  }

  void _emitUpdates() {
    for (final entry in _listeners.entries) {
      final records = _recordsForUser(entry.key);
      for (final listener in entry.value.toList()) {
        listener.add(records);
      }
    }
  }
}
