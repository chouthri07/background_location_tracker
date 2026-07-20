import 'package:hive/hive.dart';

import '../models/location_record.dart';
import '../models/tracking_session.dart';

class LocalStorageService {
  static const String recordsBoxName = 'location_records';
  static const String sessionsBoxName = 'tracking_sessions';
  static const String settingsBoxName = 'settings';
  static const String activeSessionKey = 'active_session_id';

  static Future<void> openBoxes() async {
    await Hive.openBox(recordsBoxName);
    await Hive.openBox(sessionsBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Future<void> reopenBoxes() async {
    await _closeBox(recordsBoxName);
    await _closeBox(sessionsBoxName);
    await _closeBox(settingsBoxName);
    await openBoxes();
  }

  static Future<void> _closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  Box get _recordsBox => Hive.box(recordsBoxName);
  Box get _sessionsBox => Hive.box(sessionsBoxName);
  Box get _settingsBox => Hive.box(settingsBoxName);

  String? getActiveSessionId() {
    return _settingsBox.get(activeSessionKey) as String?;
  }

  Future<void> saveActiveSessionId(String sessionId) {
    return _settingsBox.put(activeSessionKey, sessionId);
  }

  Future<void> clearActiveSessionId() {
    return _settingsBox.delete(activeSessionKey);
  }

  Future<void> saveSession(TrackingSession session) {
    return _sessionsBox.put(session.id, session.toMap());
  }

  TrackingSession? getSession(String sessionId) {
    final value = _sessionsBox.get(sessionId);
    if (value == null) return null;
    return TrackingSession.fromMap(value as Map<dynamic, dynamic>);
  }

  Future<void> saveLocation(LocationRecord record) {
    return _recordsBox.put(record.id, record.toMap());
  }

  List<LocationRecord> getLocations() {
    return _recordsBox.values
        .map((value) => LocationRecord.fromMap(value as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
