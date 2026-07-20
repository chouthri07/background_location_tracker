import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> requestPermission() async {
    await _requestNotificationPermission();

    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
