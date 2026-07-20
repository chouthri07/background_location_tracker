import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/tracking_bloc.dart';
import '../models/location_record.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackingBloc, TrackingState>(
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.teal,
            title: const Text('Background Location Tracker', style: TextStyle(color: Colors.white),),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusPanel(state: state),
              const SizedBox(height: 16),
              Text(
                'Recorded Locations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (state.locations.isEmpty)
                const _EmptyLocations()
              else
                ...state.locations.map((location) {
                  return _LocationTile(location: location);
                }),
            ],
          ),
        );
      },
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.state});

  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TrackingBloc>();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.isTracking ? Icons.gps_fixed : Icons.gps_off,
                  color: state.isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  state.isTracking ? 'Tracking is running' : 'Tracking stopped',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Battery: ${state.batteryPercentage?.toString() ?? '--'}%'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.isTracking || state.isLoading
                        ? null
                        : () => bloc.add(const TrackingStartPressed()),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('START'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !state.isTracking || state.isLoading
                        ? null
                        : () => bloc.add(const TrackingStopPressed()),
                    icon: const Icon(Icons.stop),
                    label: const Text('STOP'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location});

  final LocationRecord location;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(location.timestamp);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => openMap(location.latitude, location.longitude),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationInfoRow(
                      icon: Icons.place,
                      iconColor: Colors.blue,
                      label: 'Lat',
                      value: location.latitude.toStringAsFixed(6),
                    ),
                    const SizedBox(height: 6),
                    _LocationInfoRow(
                      icon: Icons.explore,
                      iconColor: Colors.indigo,
                      label: 'Long',
                      value: location.longitude.toStringAsFixed(6),
                    ),
                    const SizedBox(height: 6),
                    _LocationInfoRow(
                      icon: Icons.schedule,
                      iconColor: Colors.deepOrange,
                      label: 'Time',
                      value: date,
                    ),
                    const SizedBox(height: 6),
                    _LocationInfoRow(
                      icon: Icons.my_location,
                      iconColor: Colors.green,
                      label: 'Accuracy',
                      value: '${location.accuracy.toStringAsFixed(1)} m',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openMap(double lat, double lng) async {
    Uri uri;

    if (Platform.isIOS) {
      uri = Uri.parse('http://maps.apple.com/?q=$lat,$lng');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _LocationInfoRow extends StatelessWidget {
  const _LocationInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w600,
    );

    final valueStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return Row(
      children: [
        Icon(icon, size: 17, color: iconColor),
        const SizedBox(width: 8),
        SizedBox(width: 58, child: Text(label, style: labelStyle)),
        Expanded(child: Text(value, style: valueStyle)),
      ],
    );
  }
}

class _EmptyLocations extends StatelessWidget {
  const _EmptyLocations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No locations recorded yet.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
