import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart'; // Assuming ApiService is correctly set up
import 'package:flutter/foundation.dart'; // For debugPrint

// Keep the existing settings and helper functions
final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100, // Update every 100 meters
);

/// Determine if we have location permissions and location services enabled.
Future<void> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Consider informing the user more gracefully in the UI layer
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Consider informing the user more gracefully in the UI layer
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Consider informing the user more gracefully and maybe guiding them to settings
    throw Exception('Location permissions are permanently denied.');
  }
}

/// Send the given [position] to the API.
Future<void> _sendPosition(Position position) async {
  try {
    // Ensure ApiService is initialized or accessible here
    // This might need adjustment based on how ApiService is implemented (singleton, DI, etc.)
    await ApiService().post('location/', {
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    debugPrint('Position sent: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    debugPrint('Error sending position: $e');
    // Handle API errors appropriately, maybe log them or show a non-blocking notification
  }
}

// Holds the stream subscription for cancellation
StreamSubscription<Position>? _positionStreamSubscription;

/// Starts the location service: checks permissions, sends initial location,
/// and listens for location updates.
/// Throws exceptions if permissions are denied or services disabled.
Future<void> startLocationService() async {
  try {
    await _determinePosition(); // Check permissions first

    // Send initial location
    // Using high accuracy for the initial fix might take longer. Consider desiredAccuracy.
    Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _sendPosition(initialPosition);

    // Cancel existing stream if any before starting a new one
    await stopLocationService();

    // Set up the stream listener to send updated locations
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        if (position != null) {
          await _sendPosition(position);
        }
      },
      onError: (error) {
        // Handle stream errors (e.g., location service turned off during operation)
        debugPrint('Error in location stream: $error');
        // Optionally try to restart the service or inform the user via the UI layer
        stopLocationService(); // Stop listening if the stream errors out
      },
      cancelOnError: false, // Decide if stream should stop on error
    );
     debugPrint('Location service started successfully.');
  } catch (e) {
    debugPrint('Failed to start location service: $e');
    // Rethrow the exception so the calling UI can handle it (e.g., show a message)
    rethrow;
  }
}

/// Stops the location service stream listener.
Future<void> stopLocationService() async {
  await _positionStreamSubscription?.cancel();
  _positionStreamSubscription = null;
  debugPrint('Location service stopped.');
}
