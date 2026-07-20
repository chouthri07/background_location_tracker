import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/location_record.dart';
import '../repositories/tracking_repository.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc(this._repository) : super(const TrackingState.initial()) {
    on<TrackingStarted>(_onStarted);
    on<TrackingStartPressed>(_onStartPressed);
    on<TrackingStopPressed>(_onStopPressed);
    on<TrackingRefreshRequested>(_onRefreshRequested);

    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(const TrackingRefreshRequested());
    });

    _locationSavedSubscription = _repository.locationSaved.listen((_) {
      add(const TrackingRefreshRequested());
    });
  }

  final TrackingRepository _repository;
  Timer? _batteryTimer;
  StreamSubscription<void>? _locationSavedSubscription;

  Future<void> _onStarted(
    TrackingStarted event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadState(emit, showLoading: true);
  }

  Future<void> _onStartPressed(
    TrackingStartPressed event,
    Emitter<TrackingState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      await _repository.startTracking();
      await _loadState(emit);
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Please allow location permission and try again.',
        ),
      );
    }
  }

  Future<void> _onStopPressed(
    TrackingStopPressed event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _repository.stopTracking();
    await _loadState(emit);
  }

  Future<void> _onRefreshRequested(
    TrackingRefreshRequested event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadState(emit);
  }

  Future<void> _loadState(
    Emitter<TrackingState> emit, {
    bool showLoading = false,
  }) async {
    if (showLoading) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    await _repository.reloadStorage();
    final battery = await _repository.getBatteryPercentage();
    final isTracking = await _repository.isTracking;
    final locations = _repository.getLocations();

    emit(
      state.copyWith(
        isLoading: false,
        isTracking: isTracking,
        locations: locations,
        batteryPercentage: battery,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _batteryTimer?.cancel();
    _locationSavedSubscription?.cancel();
    return super.close();
  }
}
