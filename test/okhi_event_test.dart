import 'package:flutter_test/flutter_test.dart';
import 'package:okhi_flutter/models/okhi_event.dart';

void main() {
  test('success event token is not leaked by user stringification', () {
    final event = OkHiEvent.fromMap({
      'type': 'success',
      'methodCall': 'createAddress',
      'user': {
        'phone': '2348012345678',
        'firstName': 'Ada',
        'lastName': 'Lovelace',
        'email': 'ada@example.com',
        'appUserId': 'app-user-456',
        'id': 'user-123',
        'token': 'secret-token',
      },
      'location': {'id': 'location-123', 'lat': 6.5244, 'lng': 3.3792},
    });

    final user = event.user;

    expect(user, isNotNull);
    expect(user!.phone, '2348012345678');
    expect(user.token, 'secret-token');
    expect(user.toString(), isNot(contains('secret-token')));
    expect(event.location?.id, 'location-123');
  });
}
