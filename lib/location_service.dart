import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationFetchStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationResult {
  final LocationFetchStatus status;
  final Position? position;

  const LocationResult({required this.status, this.position});
}

class LocationService {
  // Get current position
  static Future<Position?> getCurrentLocation() async {
    final result = await getCurrentLocationWithStatus(
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
    return result.position;
  }

  static Future<LocationResult> getCurrentLocationWithStatus({
    LocationAccuracy accuracy = LocationAccuracy.low,
    Duration timeLimit = const Duration(seconds: 5),
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          status: LocationFetchStatus.serviceDisabled,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            status: LocationFetchStatus.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationFetchStatus.permissionDeniedForever,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );

      return LocationResult(
        status: LocationFetchStatus.success,
        position: position,
      );
    } catch (e) {
      print('Error in getCurrentLocationWithStatus: $e');
      return const LocationResult(status: LocationFetchStatus.error);
    }
  }

  // Convert latitude & longitude to city name
  static Future<String?> getCityName(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Geocoding request timed out');
              return [];
            },
          );

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? placemarks.first.administrativeArea;
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
    }
    return null;
  }
}
