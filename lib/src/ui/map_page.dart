import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/location_record.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.location});

  final LocationRecord location;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(location.latitude, location.longitude);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.teal,
          leading: const BackButton(
            color: Colors.white, // Overrides default color to red
          ),
          title: const Text('Location Map' ,
              style: TextStyle(color: Colors.white))),
      body: FlutterMap(
        options: MapOptions(initialCenter: point, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.background_location_track',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 48,
                height: 48,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 42,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
