import 'package:flutter_test/flutter_test.dart';
import 'package:background_location_track/src/models/location_record.dart';

void main() {
  test('location record converts to and from map', () {
    final timestamp = DateTime(2026, 7, 20, 10, 30);
    final record = LocationRecord(
      id: '1',
      sessionId: 'session-1',
      latitude: 12.9716,
      longitude: 77.5946,
      accuracy: 8.5,
      timestamp: timestamp,
    );

    final restored = LocationRecord.fromMap(record.toMap());

    expect(restored, record);
  });
}
