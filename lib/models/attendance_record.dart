class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.checkInTime,
    this.checkOutTime,
    required this.date,
    this.location,
    this.notes,
    this.checkInPhotoPath,
    this.checkOutPhotoPath,
  });

  final String id;
  final String userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final DateTime date;
  final String? location;
  final String? notes;
  final String? checkInPhotoPath;
  final String? checkOutPhotoPath;

  Duration? get totalHours => checkOutTime?.difference(checkInTime);

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'check_in_time': checkInTime.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'date': _dateOnly(date),
    'location': location,
    'notes': notes,
    'check_in_photo_path': checkInPhotoPath,
    'check_out_photo_path': checkOutPhotoPath,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] == null
          ? null
          : DateTime.parse(json['check_out_time'] as String),
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      checkInPhotoPath: json['check_in_photo_path'] as String?,
      checkOutPhotoPath: json['check_out_photo_path'] as String?,
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? userId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? date,
    String? location,
    String? notes,
    String? checkInPhotoPath,
    String? checkOutPhotoPath,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      date: date ?? this.date,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      checkInPhotoPath: checkInPhotoPath ?? this.checkInPhotoPath,
      checkOutPhotoPath: checkOutPhotoPath ?? this.checkOutPhotoPath,
    );
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
