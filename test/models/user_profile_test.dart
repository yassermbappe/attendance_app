import 'package:attendance_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserProfile serializes and deserializes', () {
    final profile = UserProfile(
      id: 'user-1',
      email: 'pengguna@example.com',
      fullName: 'Pengguna',
      createdAt: DateTime(2026, 11, 12, 8),
    );

    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.id, profile.id);
    expect(restored.email, profile.email);
    expect(restored.fullName, profile.fullName);
    expect(restored.createdAt, profile.createdAt);
    expect(restored.role, 'Pengguna');
  });
}
