import '../models/location_record.dart';
import '../models/tracking_session.dart';
import '../services/background_tracking_service.dart';
import '../services/battery_service.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';

class TrackingRepository {
  TrackingRepository({
    required this.storage,
    required this.locationService,
    required this.batteryService,
    required this.backgroundService,
  });

  final LocalStorageService storage;
  final LocationService locationService;
  final BatteryService batteryService;
  final BackgroundTrackingService backgroundService;

  Future<bool> get isTracking async {
    final activeSessionId = storage.getActiveSessionId();
    if (activeSessionId == null) return false;
    return backgroundService.isRunning();
  }

  List<LocationRecord> getLocations() {
    return storage.getLocations();
  }

  Future<int?> getBatteryPercentage() {
    return batteryService.getBatteryPercentage();
  }

  Stream<void> get locationSaved {
    return backgroundService.locationSaved;
  }

  Future<void> reloadStorage() {
    return LocalStorageService.reopenBoxes();
  }

  Future<void> startTracking() async {
    final hasPermission = await locationService.requestPermission();
    if (!hasPermission) {
      throw Exception('Location permission is required');
    }

    final now = DateTime.now();
    final session = TrackingSession(
      id: now.microsecondsSinceEpoch.toString(),
      startedAt: now,
    );

    // ignore: avoid_print
    print("#####------startTracking----${session.id}");
    await storage.saveSession(session);
    await storage.saveActiveSessionId(session.id);
    await backgroundService.start();
  }

  Future<void> stopTracking() async {
    final sessionId = storage.getActiveSessionId();
    if (sessionId != null) {
      final session = storage.getSession(sessionId);
      if (session != null) {
        await storage.saveSession(session.copyWith(stoppedAt: DateTime.now()));
      }
    }

    // ignore: avoid_print
    print("#####------stopTracking----${sessionId ?? 'no-session'}");
    await storage.clearActiveSessionId();
    await backgroundService.stop();
  }
}
