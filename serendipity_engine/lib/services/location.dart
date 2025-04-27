import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

/// Determine if we have location permissions and location services enabled.
Future<void> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }
}

final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100, // Update every 100 meters
);

/// Send the given [position] to the API.
Future<void> sendPosition(Position position) async {
  await ApiService().post('/api/location', {
    'latitude': position.latitude,
    'longitude': position.longitude,
  });
}

Future<void> main() async {
  await _determinePosition();

  // Send initial location
  Position initialPosition = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
  await sendPosition(initialPosition);

  // Set up the stream listener to send updated locations
  StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
    (Position? position) async {
      if (position != null) {
        await sendPosition(position);
      }
    },
  );
}
