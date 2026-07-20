import 'package:equatable/equatable.dart';

class LocationRecord extends Equatable {
  const LocationRecord({
    required this.id,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationRecord.fromMap(Map<dynamic, dynamic> map) {
    return LocationRecord(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  List<Object> get props => [
    id,
    sessionId,
    latitude,
    longitude,
    accuracy,
    timestamp,
  ];
}
