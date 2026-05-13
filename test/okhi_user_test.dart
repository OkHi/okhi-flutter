import 'package:flutter_test/flutter_test.dart';
import 'package:okhi_flutter/models/okhi_user.dart';

void main() {
  test('OkHiUser.toString does not leak token', () {
    final user = OkHiUser(
      phone: '2348012345678',
      firstName: 'Ada',
      lastName: 'Lovelace',
      id: 'user-123',
      email: 'ada@example.com',
      appUserId: 'app-user-456',
      token: 'secret-token',
    );

    final value = user.toString();

    expect(value, contains('"phone":"2348012345678"'));
    expect(value, contains('"firstName":"Ada"'));
    expect(value, contains('"lastName":"Lovelace"'));
    expect(value, contains('"appUserId":"app-user-456"'));
    expect(value, isNot(contains('secret-token')));
    expect(value, isNot(contains('"token"')));
  });
}
