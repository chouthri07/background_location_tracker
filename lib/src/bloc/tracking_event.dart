part of 'tracking_bloc.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class TrackingStarted extends TrackingEvent {
  const TrackingStarted();
}

class TrackingStartPressed extends TrackingEvent {
  const TrackingStartPressed();
}

class TrackingStopPressed extends TrackingEvent {
  const TrackingStopPressed();
}

class TrackingRefreshRequested extends TrackingEvent {
  const TrackingRefreshRequested();
}
