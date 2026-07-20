part of 'tracking_bloc.dart';

class TrackingState extends Equatable {
  const TrackingState({
    required this.isLoading,
    required this.isTracking,
    required this.locations,
    this.batteryPercentage,
    this.errorMessage,
  });

  const TrackingState.initial()
    : isLoading = true,
      isTracking = false,
      locations = const [],
      batteryPercentage = null,
      errorMessage = null;

  final bool isLoading;
  final bool isTracking;
  final List<LocationRecord> locations;
  final int? batteryPercentage;
  final String? errorMessage;

  TrackingState copyWith({
    bool? isLoading,
    bool? isTracking,
    List<LocationRecord>? locations,
    int? batteryPercentage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
      locations: locations ?? this.locations,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isTracking,
    locations,
    batteryPercentage,
    errorMessage,
  ];
}
