Dokumen untuk agent pengembang • Flutter / Dart • Versi 1.0

# 1. Ringkasan

**Attendance App** (nama paket: attendance\_app , nama tampilan: *Presensi Digital)* adalah aplikasi mobile Android untuk mencatat kehadiran pribadi: pengguna mendaftar atau masuk, menekan **Masuk** saat tiba dan **Pulang** saat selesai (keduanya dengan foto), lalu melihat riwayat miliknya sendiri.

Repositori ini adalah **repositori awal untuk pembelajaran** (proyek ketiga kelas Flutter setelah News App). Ia dibaca, dijalankan, dimodifikasi bertahap, lalu dikembangkan siswa ke cloud (Firestore) pada sesi berikutnya. Artinya:

Struktur, nama file, nama kelas, dan perilaku **harus mengikuti dokumen ini,** karena modul praktikum merujuk ke nama-nama tersebut.

Kode harus mudah dibaca dan dijelaskan oleh pemula: jelas, terpisah per tanggung jawab, tanpa abstraksi berlebihan, komentar singkat berbahasa Indonesia pada bagian penting.

Cakupan sengaja **kecil.** Jangan menambah fitur di luar dokumen ini.

# 2. Keputusan yang sudah dikunci

| Topik | Keputusan |
|---|---|
| Cakupan | Sesuai modul: akun, presensi masuk/pulang, foto, riwayat. Tanpa GPS, QR, admin, atau antikecurangan. |
| Foto | **Wajib** pada Masuk dan Pulang (bukan opsional). |
| Auth | Firebase Authentication (email/password) dengan kode sudah tertulis lengkap. Aplikasi tetap bisa dibangun dan dibuka sebelum Firebase dikonfigurasi (lihat bagian 6). |

| Topik | Keputusan |
|---|---|
| Data presensi | Lokal: cache memori + SharedPreferences. Belum ada Firestore. |
| Foto | Disimpan lokal di perangkat. Firebase Storage **tidak dipakai** (tidak ada billing). Penyimpanan foto di balik antarmuka yang bisa ditukar. |
| Platform | Android saja. Web/desktop/iOS di luar cakupan. |
| Bahasa UI | Bahasa Indonesia. Istilah netral: pengguna, akun, presensi, masuk, pulang. Jangan memakai istilah khusus siswa/karyawan. |

# 3. Tujuan dan non-tujuan

**Tujuan:** versi lokal yang rapi dan teruji, siap dihubungkan ke Firebase dengan mengganti sedikit file (terutama attendance\_service.dart , storage\_services.dart , main.dart ).

**Non-tujuan (jangan dibuat):** dashboard admin, rekap semua pengguna, GPS/geofence, verifikasi wajah, penggajian, ekspor laporan, shift, persetujuan izin, pembuktian waktu tahan manipulasi, form pengisian location / notes , profil Firestore, sinkronisasi cloud, antrean retry, notifikasi, mode gelap khusus, multi-bahasa.

# 4. Teknologi dan batasan

Flutter stable terbaru dengan Dart \^3.9.2 . Material 3.

Dependensi yang diizinkan: firebase\_core , firebase\_auth , shared\_preferences , image\_picker , permission\_handler , flutter\_image\_compress , path\_provider , path , intl .

**Jangan menambah:** cloud\_firestore , firebase\_storage , firebase\_database , state management eksternal (Provider, Riverpod, Bloc, GetX), codegen (freezed, json\_serializable), atau router eksternal. Gunakan StatefulWidget , StreamBuilder / StreamSubscription , dan Navigator bawaan.

Versi paket: gunakan rilis stabil terbaru yang kompatibel, jangan menebak versi dari ingatan; jalankan flutter pub add agar resolusinya benar.

applicationId Android: com.example.attendance\_app . Tuliskan di README karena siswa mendaftarkan app Android di Firebase dengan ID ini.

Izin Android: CAMERA pada AndroidManifest.xml .

**Jangan membuat atau menambahkan** google-services.json , kredensial, atau project ID Firebase apa pun. Itu dibuat siswa lewat flutterfire configure .

# 5. Struktur proyek (wajib dipertahankan)

Nama file dan kelas di bawah dipakai modul. Subfolder boleh disesuaikan bila perlu, tetapi nama file tidak boleh berubah.

lib/

main.dart

firebase\_options.dart    # STUB (lihat bagian 6); ditimpa

FlutterFire CLI

models/

attendance\_record.dart\
user\_profile.dart\
services/

auth\_services.dart    # AuthServices

attendance\_service.dart    # AttendanceService

firestore\_service.dart    # FirestoreService (adapter ke

AttendanceService)

storage\_services.dart    # StorageServices (foto lokal)

permission\_service.dart    # PermissionService

wrapper/

auth\_wrapper.dart    # AuthWrapper

screens/

config\_error/config\_error\_screen.dart\
auth/

login\_screen.dart\
register\_screen.dart\
widgets/auth\_text\_field.dart\
home/

home\_screen.dart\
widgets/

attendance\_card.dart\
action\_button.dart\
profile\_card.dart\
camera\_button.dart\
photo\_viewer.dart\
history/

history\_screen.dart\
widgets/record\_card.dart

test/

models/attendance\_record\_test.dart\
models/user\_profile\_test.dart\
widgets/logout\_dialog\_test.dart\
README.md

# 6. Perilaku saat Firebase belum dikonfigurasi (wajib)

Repositori ini **tidak berisi konfigurasi Firebase.** Aplikasi harus tetap bisa dibangun dan dibuka, lalu mengarahkan pengguna menyelesaikan setup, tanpa crash dan tanpa menelan error.

1\. Buat lib/firebase\_options.dart berisi **stub** dengan nama kelas yang sama dengan file hasil FlutterFire CLI:

class DefaultFirebaseOptions dengan static FirebaseOptions get currentPlatform yang melempar UnsupportedError('Firebase belum dikonfigurasi. Jalankan: flutterfire configure -- project\=ID\_PROJECT\_ANDA') .

Beri komentar di atas file: *"File ini hanya placeholder. flutterfire configure akan menimpanya."*

2\. main() memanggil WidgetsFlutterBinding.ensureInitialized() , lalu Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform) di dalam try/catch .

3\. Bila inisialisasi **gagal** (termasuk karena stub), jalankan runApp dengan ConfigErrorScreen yang menampilkan: judul "Firebase belum dikonfigurasi", langkah singkat berurutan (pasang Firebase CLI, firebase login , dart pub global activate flutterfire\_cli , flutterfire configure --project\=ID\_PROJECT\_ANDA , jalankan ulang aplikasi), serta pesan error aslinya dalam teks kecil.

4\. Bila berhasil, jalankan AttendanceApp .

5\. **Dilarang:** mengisi FirebaseOptions manual di main.dart , melanjutkan aplikasi setelah inisialisasi gagal, atau mengaktifkan appVerificationDisabledForTesting .

Setelah siswa menjalankan flutterfire configure , stub tertimpa dan aplikasi langsung berjalan normal tanpa mengubah kode lain.

# 7. Arsitektur dan antarmuka

Alur: **Layar → Service → penyimpanan.** Layar tidak boleh memanggil FirebaseAuth , SharedPreferences , atau image\_picker untuk logika data secara langsung kecuali yang dinyatakan di bawah.

Login/Register → AuthServices → Firebase Authentication → AuthWrapper → Home Home → AttendanceService → cache memori + SharedPreferences → stream → Home/History

CameraButton → image\_picker → StorageServices (kompres + simpan lokal) → path di AttendanceRecord → PhotoViewer

7\.1 Kontrak AttendanceService (publik, jangan diubah namanya)

Siswa nanti mengganti **isi file ini** dengan versi Firestore, sehingga signature harus stabil:

Stream\<List\<AttendanceRecord\>\> getAttendanceRecords(String userId)

Stream\<AttendanceRecord?\> getTodayRecordStream(String userId)

Future\<String\> createAttendanceRecord(AttendanceRecord record) mengembalikan ID record

Future\<void\> updateAttendanceRecord(AttendanceRecord record)

7\.2 Kontrak StorageServices dan antarmuka foto

Definisikan abstract class PhotoStorage dengan satu metode inti Future\<String\> savePhoto(String sourcePath, String photoType) yang mengembalikan nilai yang disimpan di field foto record (path lokal pada versi ini; object path cloud di versi lanjutan). photoType hanya 'checkin' atau 'checkout' ; nilai lain melempar ArgumentError .

StorageServices implements PhotoStorage adalah implementasi lokal. Pertahankan juga nama metode uploadAttendancePhoto(sourcePath, photoType) yang memanggil savePhoto , karena modul memakai nama itu. Tambahkan komentar jujur: *"Meski bernama upload, versi ini hanya menyimpan lokal."* HomeScreen mengakses foto lewat tipe PhotoStorage , bukan implementasi konkret.

7\.3 FirestoreService

Adapter tipis yang meneruskan semua pemanggilan ke AttendanceService . Beri komentar: *"Nama kelas belum berarti membaca Firestore. Versi ini hanya meneruskan ke AttendanceService."*

# 8. Model data

AttendanceRecord (immutable)

| Field Dart | Tipe | Kunci JSON | Catatan |
|---|---|---|---|
| id | String | id | wajib |
| userId | String | user\_id | wajib; UID Firebase Auth |
| checkInTime | DateTime | check\_in\_time | ISO 8601 string |
| checkOutTime | DateTime? | check\_out\_time | ISO 8601 atau null |
| date | DateTime | date | string YYYY-MM-DD |
| location | String? | location | belum ada form/GPS |
| notes | String? | notes | belum ada form |
| checkInPhotoPath | String? | check\_in\_photo\_path |  |
| checkOutPhotoPath | String? | check\_out\_photo\_path |  |

Wajib ada: toJson() , AttendanceRecord.fromJson(Map\<String, dynamic\>) , copyWith(...) , dan getter Duration? get totalHours (null sebelum pulang; selisih checkOutTime - checkInTime setelah pulang).

Format JSON **tidak boleh diubah** (string ISO untuk waktu, bukan Timestamp ), karena migrasi Firestore pertama mempertahankannya.

Meski foto wajib di UI, field foto tetap nullable di model untuk kompatibilitas JSON dan data lama.

UserProfile

Field: id , email , fullName ( full\_name ), createdAt ( created\_at ), role (default 'Pengguna' , kunci role ). Wajib ada toJson / fromJson . **Model saja:** registrasi tidak membuat profil dan tidak ada penulisan ke Firestore.

# 9. Aturan penyimpanan lokal

Kunci SharedPreferences: local\_attendance\_records\_v1 , berisi string JSON list record.

Cache memori dimuat sekali dari SharedPreferences ( \_initStorage ) dan disimpan ulang setiap perubahan ( \_persistRecords ).

ID record: DateTime.now().microsecondsSinceEpoch.toString() .

Setiap perubahan memicu \_emitUpdates . Stream harus **langsung mengirim nilai terkini saat di-subscribe,** mendukung banyak pendengar, dan bereaksi terhadap perubahan cache lokal.

**Isolasi akun:** semua pembacaan wajib difilter userId \=\= uid secara ketat. Dilarang pola userId kosong yang mengembalikan seluruh cache.

**Satu record per pengguna per tanggal:** createAttendanceRecord melempar StateError('Presensi hari ini sudah ada.') bila sudah ada record dengan userId dan date yang sama.

**Kegagalan simpan harus terlihat:** bila setString mengembalikan false atau melempar error, lemparkan exception ke pemanggil sehingga layar menampilkan pesan gagal. Jangan pernah menampilkan "berhasil" bila penyimpanan gagal. Dilarang: \_trySyncToFirestore , atau kode sinkron cloud apa pun.

# 10. Spesifikasi layar

10\.1 AuthWrapper

Mendengarkan authStateChanges . Menunggu: indikator loading. User null: LoginScreen . User ada: HomeScreen . **Tidak ada fallback** **local\_user** di mana pun; bila sesi null, arahkan ke login.

10\.2 LoginScreen

Field: email, kata sandi (disembunyikan, dengan tombol tampil/sembunyi), tombol **Masuk,** tautan ke **Daftar.**

Validasi: email tidak kosong, sandi tidak kosong.

Selama permintaan berlangsung \_isLoading \= true : tombol dinonaktifkan dan tampil indikator; kembalikan di blok finally .

Bila gagal, tampilkan SnackBar berisi pesan error dari FirebaseAuthException apa adanya ( e.message ) dengan awalan "Gagal masuk: ".

10\.3 RegisterScreen

Field: email, kata sandi, konfirmasi kata sandi.

Validasi: email tidak kosong, sandi minimal 6 karakter, konfirmasi harus sama. Bila konfirmasi tidak cocok, **tidak mengirim** permintaan.

Alur loading sama dengan login. Sukses: pengguna otomatis masuk (ditangani AuthWrapper ).

Pesan gagal ditampilkan apa adanya dari e.message , awalan "Gagal mendaftar: ".

10\.4 AuthServices

Membungkus FirebaseAuth : registerWithEmailAndPassword , signInWithEmailAndPassword , signOut , Stream\<User?\> authStateChanges , dan getter currentUser . **Jangan menyimpan kata sandi** di SharedPreferences atau di mana pun. Jangan ada setSettings khusus pengujian.

10\.5 HomeScreen

Menampilkan ProfileCard (email akun), AttendanceCard , ActionButton , dan tombol **Riwayat** serta **Keluar** (dialog konfirmasi: "Keluar dari akun?" dengan Batal/Keluar).

Tiga status harian, ditentukan dari record hari ini:

| Status | Kartu | Tombol |
|---|---|---|
| Belum masuk | Pesan "Belum ada presensi hari ini" | **Masuk** |
| Sudah masuk | Jam masuk, foto masuk | **Pulang** |
| Sudah pulang | Kartu selesai: jam masuk, jam pulang, durasi, foto | Tidak ada tombol |

Implementasi:

StreamSubscription ke getTodayRecordStream(uid) disimpan di State , dibatalkan di dispose , dan **dilanggan ulang** saat aplikasi kembali aktif

( WidgetsBindingObserver ) agar pergantian tanggal terbaca.

onError stream menampilkan pesan yang bisa ditindaklanjuti, bukan layar kosong. \_checkIn : ambil UID dari currentUser (bila null, kembali ke login); **ambil foto dulu;** hanya bila foto berhasil, buat AttendanceRecord ( checkInTime \= DateTime.now() , date \= tanggal hari ini tanpa jam, path foto masuk terisi), panggil createAttendanceRecord , tampilkan pesan sukses.

\_checkOut : wajib foto pula; gunakan record hari ini dan copyWith(checkOutTime: ..., checkOutPhotoPath: ...) ; pertahankan **id** **yang sama;** panggil updateAttendanceRecord . Tidak boleh membuat record kedua.

isLoading selama proses; tombol nonaktif saat loading agar tidak terketuk dua kali. Semua kegagalan (kamera, simpan, izin) menampilkan SnackBar jelas dan **tidak** membuat record.

10\.6 Foto wajib: CameraButton , PermissionService , StorageServices Alur satu kali ketuk pada Masuk atau Pulang:

1\. Minta izin kamera lewat PermissionService .

2\. Izin diberikan: buka kamera dengan image\_picker ( ImageSource.camera ).

3\. Pengguna membatalkan pengambilan foto: **hentikan,** tidak ada record, tidak ada pesan galat (cukup kembali ke beranda).

4\. Foto didapat: kompres (kualitas 75, JPEG) lalu salin ke direktori attendance\_photos di penyimpanan aplikasi, nama file memuat waktu dan jenis (misalnya 20261112\_081530\_checkin.jpg ). Kembalikan path.

5\. Izin ditolak biasa: dialog yang menjelaskan mengapa kamera dibutuhkan, dengan tombol coba lagi.

6\. Izin ditolak permanen: dialog dengan tombol yang memanggil openAppSettings() .

7\. Kompresi/penyimpanan gagal: **lemparkan error,** jangan diam-diam memakai path asli, sehingga layar menampilkan pesan gagal dan tidak ada record.

Kamera hanya dipakai lewat tombol (tidak ada pilihan galeri).

10\.7 PhotoViewer

Membuka foto dari path lokal dalam tampilan layar penuh dengan InteractiveViewer (zoom). Urutan cabang: file lokal, lalu Base64 (dipertahankan untuk kompatibilitas modul), lalu placeholder. **Bila file hilang atau null, tampilkan placeholder** (ikon dan teks "Foto tidak tersedia"), jangan gagal total. Beri struktur yang memudahkan penambahan satu cabang baru di bagian atas untuk object path cloud kelak.

10\.8 HistoryScreen dan RecordCard

Mengambil UID akun aktif dan berlangganan getAttendanceRecords(uid) . Urutan terbaru dulu berdasarkan checkInTime (urutkan di klien).

RecordCard menampilkan: tanggal (format Indonesia, misalnya "Kamis, 12 November 2026"), jam masuk, jam pulang (atau "Belum pulang"), durasi (misalnya "8 jam 30 menit"; kosong bila belum pulang), dan miniatur foto yang bisa diketuk ke PhotoViewer .

Daftar kosong: pesan netral "Belum ada riwayat presensi".

Error stream ditampilkan sebagai pesan, bukan dianggap daftar kosong. Akun B tidak boleh melihat catatan akun A.

# 11. Tampilan dan nada

Material 3. Definisikan **satu konstanta warna seed** di satu tempat (misalnya const kSeedColor \= ... di main.dart ), karena latihan Modul 1 meminta siswa menggantinya.

Desain bersih, kontras jelas, tombol besar mudah diketuk, teks terbaca. Jangan menambah animasi, ilustrasi, atau gambar aset.

Format tanggal dan waktu memakai intl dengan locale id\_ID (panggil initializeDateFormatting sebelum runApp ). Waktu 24 jam.

Pesan singkat, ramah, dan netral.

# 12. Pengujian (wajib)

test/models/attendance\_record\_test.dart : round-trip toJson / fromJson ; tanggal berformat YYYY-MM-DD ; copyWith melengkapi checkOutTime ; totalHours null sebelum pulang dan 8 jam untuk contoh 08.00 sampai 16.00; waktu 08.15 sampai 16.45 menghasilkan 8 jam 30 menit.

test/models/user\_profile\_test.dart : serialisasi dan deserialisasi. test/widgets/logout\_dialog\_test.dart : dialog konfirmasi keluar tampil dan tombol Batal menutupnya. Test ini **tidak boleh bergantung pada Firebase;** ekstrak dialog menjadi widget atau fungsi yang bisa diuji sendiri.

Tidak ada test yang membutuhkan Firebase, kamera, atau perangkat fisik.

Wajib dijalankan dan lolos: flutter analyze (tanpa error/warning), flutter test , dan flutter build apk --debug . **Jangan menulis "lulus" bila perintah belum benar-benar dijalankan.** Bila build tidak bisa dijalankan di lingkunganmu, tulis itu terus terang.

# 13. Kriteria penerimaan

| # | Kasus | Hasil yang diharapkan |
|---|---|---|
| 1 | Buka aplikasi tanpa konfigurasi Firebase | ConfigErrorScreen tampil dengan langkah setup; tidak crash |
| 2 | Registrasi, konfirmasi tidak cocok | Tidak mengirim permintaan; pesan validasi tampil |
| 3 | Kredensial salah | Pesan gagal tampil; tombol aktif lagi |
| 4 | Masuk pertama hari ini | Kamera terbuka; setelah foto, satu record dengan waktu masuk terisi |
| 5 | Pulang | Foto diambil; record yang sama terbarui; durasi tampil |
| 6 | Sudah pulang | Tombol Masuk/Pulang tidak ditampilkan lagi |
| 7 | Tutup lalu buka ulang | Catatan dan foto lokal tetap terbaca |
| 8 | Ganti akun | Riwayat akun lain tidak tampil |
| 9 | Izin kamera ditolak | Dialog arahan sesuai; tidak ada record |
| 10 | Izin ditolak permanen | Dialog dengan tombol ke pengaturan aplikasi |
| 11 | Foto dibatalkan | Tidak ada foto dan tidak ada record |
| 12 | File foto dihapus manual | Placeholder tampil, aplikasi tidak error |
| 13 | Dua kali ketuk cepat pada tombol | Hanya satu record dibuat |
| 14 | Kegagalan simpan lokal | Pesan gagal tampil, bukan pesan sukses |
| 15 | Riwayat | Terbaru di atas; kosong menampilkan pesan netral |

# 14. Dilarang (kesalahan yang sengaja dihindari)

Fallback user?.uid ?? 'local\_user' .

Pola userId kosong yang mengembalikan semua catatan.

catch kosong atau error yang diabaikan (inisialisasi, simpan, foto, auth).

FirebaseOptions yang ditulis langsung di main.dart . appVerificationDisabledForTesting atau bypass pengujian apa pun pada auth. Menyimpan kata sandi di perangkat.

Menampilkan keberhasilan padahal operasi gagal.\
Mencampur path lokal dan cloud tanpa penanda.

# 15. Dibiarkan sebagai next latihan (jangan dikerjakan)

Hal-hal berikut disengaja belum ada karena menjadi tugas "Pengembangan" di modul. Jangan menambahkannya:

Validasi **format** email yang ramah (cukup cek tidak kosong).

Pemetaan FirebaseAuthException ke pesan Indonesia (cukup tampilkan e.message ).

Filter rentang tanggal dan ringkasan total durasi pada riwayat.

Status sinkron, ekspor, profil pengguna, dan pencegahan duplikasi lintas perangkat.

# 16. README (wajib)

Berisi: deskripsi singkat, cara menjalankan ( flutter doctor , flutter pub get , flutter devices , flutter run ), peta struktur folder, applicationId , penjelasan bahwa aplikasi menampilkan layar "Firebase belum dikonfigurasi" sampai flutterfire configure dijalankan, daftar batasan (poin bagian 3), dan catatan bahwa foto tersimpan lokal sehingga hilang bila data aplikasi dihapus. **Jangan menulis** kredensial atau project ID apa pun.

# 17. Urutan pengerjaan yang disarankan

Jalankan flutter analyze di akhir tiap tahap dan perbaiki sebelum lanjut.

1\. Kerangka proyek, tema, struktur folder, stub firebase\_options.dart , main.dart , ConfigErrorScreen .

2\. Model ( AttendanceRecord , UserProfile ) beserta test-nya.

3\. AuthServices , AuthWrapper , LoginScreen , RegisterScreen .

4\. AttendanceService (kontrak bagian 7.1) dan FirestoreService .

5\. PermissionService , StorageServices / PhotoStorage , CameraButton , PhotoViewer .

6\. HomeScreen dengan tiga status dan alur Masuk/Pulang berfoto.

7\. HistoryScreen , RecordCard .

8\. Test sisa, README, flutter analyze , flutter test , flutter build apk --debug .

# 18. Aturan untuk agent

Jangan menambah fitur, paket, atau layar di luar dokumen ini.

Jika ada hal yang ambigu atau bertentangan, **tanyakan dahulu;** jangan menebak. Laporkan terus terang apa yang sudah dijalankan dan apa yang belum diuji (terutama kamera dan izin yang butuh perangkat nyata).

Di akhir, berikan ringkasan: file yang dibuat, hasil flutter analyze , flutter test , dan build, serta daftar keterbatasan yang diketahui.
