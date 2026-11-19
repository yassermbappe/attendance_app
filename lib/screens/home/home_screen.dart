import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import '../../services/storage_services.dart';
import 'widgets/action_button.dart';
import 'widgets/attendance_card.dart';
import 'widgets/camera_button.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userId,
    this.authServices,
    this.attendanceService,
    this.photoStorage,
  });

  final String userId;
  final AuthServices? authServices;
  final AttendanceService? attendanceService;
  final PhotoStorage? photoStorage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final AuthServices _authServices = widget.authServices ?? AuthServices();
  late final AttendanceService _attendanceService =
      widget.attendanceService ?? AttendanceService();
  late final PhotoStorage _photoStorage =
      widget.photoStorage ?? StorageServices();

  StreamSubscription<AttendanceRecord?>? _subscription;
  AttendanceRecord? _record;
  Object? _streamError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForTodayRecord();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _listenForTodayRecord();
  }

  void _listenForTodayRecord() {
    unawaited(_subscription?.cancel());
    _subscription = _attendanceService
        .getTodayRecordStream(widget.userId)
        .listen(
          (record) {
            if (!mounted) return;
            setState(() {
              _record = record;
              _streamError = null;
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted) return;
            setState(() => _streamError = error);
          },
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<String?> _activeUserId() async {
    final user = _authServices.currentUser;
    if (user != null) return user.uid;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    return null;
  }

  Future<void> _checkIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final userId = await _activeUserId();
      if (userId == null || !mounted) return;
      final photoPath = await CameraButton.capturePhoto(
        context,
        _photoStorage,
        'checkin',
      );
      if (photoPath == null || !mounted) return;

      final now = DateTime.now();
      final record = AttendanceRecord(
        id: '',
        userId: userId,
        checkInTime: now,
        date: DateTime(now.year, now.month, now.day),
        checkInPhotoPath: photoPath,
      );
      await _attendanceService.createAttendanceRecord(record);
      if (mounted) _showMessage('Presensi masuk berhasil disimpan.');
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan presensi masuk: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkOut() async {
    if (_isLoading) return;
    final todayRecord = _record;
    if (todayRecord == null) return;
    setState(() => _isLoading = true);
    try {
      final userId = await _activeUserId();
      if (userId == null || !mounted) return;
      final photoPath = await CameraButton.capturePhoto(
        context,
        _photoStorage,
        'checkout',
      );
      if (photoPath == null || !mounted) return;

      final updatedRecord = todayRecord.copyWith(
        checkOutTime: DateTime.now(),
        checkOutPhotoPath: photoPath,
      );
      await _attendanceService.updateAttendanceRecord(updatedRecord);
      if (mounted) _showMessage('Presensi pulang berhasil disimpan.');
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan presensi pulang: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    if (!await showLogoutDialog(context) || !mounted) return;
    try {
      await _authServices.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage('Gagal keluar: ${error.message ?? error.code}');
    } catch (error) {
      if (mounted) _showMessage('Gagal keluar: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _authServices.currentUser;
    final complete = _record?.checkOutTime != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Digital')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileCard(email: user?.email ?? ''),
            const SizedBox(height: 8),
            if (_streamError != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Status presensi gagal dimuat. Periksa penyimpanan perangkat dan coba lagi.',
                  ),
                ),
              ),
            AttendanceCard(record: _record),
            const SizedBox(height: 16),
            if (!complete)
              CameraButton(
                label: _record == null ? 'Masuk' : 'Pulang',
                onPressed: _isLoading
                    ? null
                    : () => _record == null ? _checkIn() : _checkOut(),
                isLoading: _isLoading,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Riwayat',
                    icon: Icons.history,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HistoryScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 54),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
