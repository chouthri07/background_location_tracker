import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/location_record.dart';
import 'local_storage_service.dart';

class BackgroundTrackingService {
  static const Duration trackingInterval = Duration(seconds: 60);

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart,
        autoStart: false,
        autoStartOnBoot: true,
        isForegroundMode: true,
        initialNotificationTitle: 'Location tracking',
        initialNotificationContent: 'Recording location every 60 seconds',
        foregroundServiceNotificationId: 101,
        foregroundServiceTypes: const [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onServiceStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<bool> isRunning() {
    return FlutterBackgroundService().isRunning();
  }

  Future<void> start() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
    }
  }

  Future<void> stop() async {
    FlutterBackgroundService().invoke('stopTracking');
  }

  Stream<void> get locationSaved {
    return FlutterBackgroundService().on('locationSaved').map((_) {});
  }
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await LocalStorageService.openBoxes();

  Timer? timer;

  Future<void> recordLocation() async {
    final storage = LocalStorageService();
    final sessionId = storage.getActiveSessionId();
    if (sessionId == null) return;

    final session = storage.getSession(sessionId);
    if (session == null || !session.isActive) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final now = DateTime.now();
    final record = LocationRecord(
      id: now.microsecondsSinceEpoch.toString(),
      sessionId: sessionId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: now,
    );

    await storage.saveLocation(record);
    // ignore: avoid_print
    print("#####------locationSaved----${record.id}");

    if (service is AndroidServiceInstance) {
      await service.setForegroundNotificationInfo(
        title: 'Location tracking',
        content:
            'Last location saved at ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      );
    }

    service.invoke('locationSaved');
  }

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
  }

  service.on('stopTracking').listen((_) async {
    timer?.cancel();
    await service.stopSelf();
  });

  await recordLocation();
  timer = Timer.periodic(BackgroundTrackingService.trackingInterval, (_) {
    recordLocation();
  });
}
