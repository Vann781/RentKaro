// lib/services/location_service.dart

import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData?> getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 1. Check if location services are enabled on the device
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null; // Services are disabled
      }
    }

    // 2. Check for location permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission denied.');
        return null; // Permissions are denied
      }
    }

    // 3. If all checks pass, get the location
    print('Getting user location...');
    return await _location.getLocation();
  }
}