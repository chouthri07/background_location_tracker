import 'package:equatable/equatable.dart';

class TrackingSession extends Equatable {
  const TrackingSession({
    required this.id,
    required this.startedAt,
    this.stoppedAt,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? stoppedAt;

  bool get isActive => stoppedAt == null;

  TrackingSession copyWith({DateTime? stoppedAt}) {
    return TrackingSession(
      id: id,
      startedAt: startedAt,
      stoppedAt: stoppedAt ?? this.stoppedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'stoppedAt': stoppedAt?.toIso8601String(),
    };
  }

  factory TrackingSession.fromMap(Map<dynamic, dynamic> map) {
    return TrackingSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      stoppedAt: map['stoppedAt'] == null
          ? null
          : DateTime.parse(map['stoppedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, startedAt, stoppedAt];
}
