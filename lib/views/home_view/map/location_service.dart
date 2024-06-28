import 'package:location/location.dart'; // Import the location package

class LocationService {
  Future<LocationData> getLocation() async {
    Location location = Location(); // Create an instance of Location

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable location services if not already enabled
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception(
            'Location services are disabled.'); // Throw an exception if unable to enable location services
      }
    }

    // Check the permission status
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // Request location permission if not granted
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception(
            'Location permission denied.'); // Throw an exception if permission is not granted
      }
    }

    // Get the current location
    locationData = await location.getLocation();
    return locationData; // Return the fetched location data
  }
}
