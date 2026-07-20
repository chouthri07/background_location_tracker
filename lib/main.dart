import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/bloc/tracking_bloc.dart';
import 'src/repositories/tracking_repository.dart';
import 'src/services/background_tracking_service.dart';
import 'src/services/battery_service.dart';
import 'src/services/local_storage_service.dart';
import 'src/services/location_service.dart';
import 'src/ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await LocalStorageService.openBoxes();
  await BackgroundTrackingService.initialize();

  final storage = LocalStorageService();
  final repository = TrackingRepository(
    storage: storage,
    locationService: LocationService(),
    batteryService: BatteryService(),
    backgroundService: BackgroundTrackingService(),
  );

  runApp(TrackingApp(repository: repository));
}

class TrackingApp extends StatelessWidget {
  const TrackingApp({super.key, required this.repository});

  final TrackingRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider(
        create: (_) => TrackingBloc(repository)..add(const TrackingStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Background Location Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
