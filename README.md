# Presensi Digital

Aplikasi Android sederhana untuk mencatat presensi masuk dan pulang dengan foto serta melihat riwayat presensi akun aktif. Data dan foto disimpan di perangkat; belum ada sinkronisasi cloud.

## Menjalankan aplikasi

1. Pastikan Flutter tersedia dengan `flutter doctor`.
2. Ambil dependensi dengan `flutter pub get`.
3. Hubungkan perangkat dengan `flutter devices`.
4. Jalankan aplikasi dengan `flutter run`.

Sebelum konfigurasi Firebase, aplikasi menampilkan layar **Firebase belum dikonfigurasi**. Untuk mengaktifkannya, pasang Firebase CLI, jalankan `firebase login`, lalu `dart pub global activate flutterfire_cli` dan `flutterfire configure --project=ID_PROJECT_ANDA`. Jalankan ulang aplikasi setelah konfigurasi selesai. Jangan menambahkan kredensial ke repositori.

Saat mendaftarkan aplikasi Android ke Firebase, gunakan `applicationId` **com.example.attendance_app**.

## Struktur

```text
lib/
  main.dart
  firebase_options.dart
  models/
  services/
  wrapper/
  screens/
    auth/
    config_error/
    home/
    history/
test/
  models/
  widgets/
```

## Batasan

- Hanya akun email/kata sandi, presensi masuk/pulang dengan foto wajib, dan riwayat pengguna.
- Penyimpanan data masih lokal, menggunakan cache memori dan SharedPreferences; belum menggunakan Firestore atau sinkronisasi.
- Foto dikompres dan disimpan lokal di perangkat. Foto akan hilang jika data aplikasi dihapus.
- Tidak ada GPS, QR, verifikasi wajah, admin, penggajian, ekspor laporan, shift, persetujuan izin, atau bukti waktu antimanipulasi.
- Tidak ada notifikasi, mode gelap khusus, atau dukungan multi-bahasa.
- Platform dalam cakupan adalah Android; web, desktop, dan iOS tidak termasuk.
