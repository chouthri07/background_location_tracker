import 'package:flutter/services.dart';

class BatteryService {
  static const MethodChannel _channel = MethodChannel(
    'background_location_tracker/battery',
  );

  Future<int?> getBatteryPercentage() async {
    final value = await _channel.invokeMethod<int>('getBatteryPercentage');
    return value;
  }
}
