// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:test_app/views/home_view/map/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer(); // Completer to handle GoogleMapController asynchronously

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(32.4324, 35.0856), // Initial center position of the map
    zoom: 14.4746, // Initial zoom level of the map
  );

  LatLng currentLocation =
      _initialCameraPosition.target; // Variable to store current location
  final Set<Marker> _markers = {}; // Set to hold markers on the map

  @override
  void initState() {
    super.initState();
    _fetchClinicLocations(); // Fetch clinic locations when the widget initializes
  }

  Future<void> _fetchClinicLocations() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('doctors')
        .get(); // Fetch documents from Firestore collection
    final List<DocumentSnapshot> documents = result.docs;

    for (var doc in documents) {
      final data = doc.data() as Map<String, dynamic>; // Extract document data
      print('Fetched data: $data');
      if (data.containsKey('docLat') && data.containsKey('docLong')) {
        try {
          double lat =
              double.parse(data['docLat']); // Parse latitude from document data
          double lng = double.parse(
              data['docLong']); // Parse longitude from document data
          _setMarker(
            LatLng(lat, lng), // Create LatLng object from parsed coordinates
            data['docName'] ??
                'Unknown', // Clinic name, default to 'Unknown' if not provided
            data['docCategory'] ??
                'Unknown', // Clinic category, default to 'Unknown' if not provided
          );
        } catch (e) {
          print('Error parsing coordinates: $e');
        }
      } else {
        print('Missing coordinates in data: $data');
      }
    }
    setState(() {}); // Update the state to reflect new markers on the map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(
                  controller); // Complete the Completer with the created GoogleMapController
            },
            onCameraMove: (CameraPosition e) => currentLocation =
                e.target, // Update currentLocation when the camera moves
            markers: _markers, // Set of markers to display on the map
            onTap: (LatLng location) {
              _setMarker(location, 'New Marker', ''); // Add a new marker on tap
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () =>
                  _getMyLocation(), // Fetch current location on button press
              child: const Icon(Icons.gps_fixed),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 20,
        alignment: Alignment.center,
        child: Text(
            "lat: ${currentLocation.latitude}, long: ${currentLocation.longitude}"), // Display current latitude and longitude
      ),
    );
  }

  void _setMarker(LatLng location, String title, String snippet) {
    Marker newMarker = Marker(
      markerId: MarkerId(location.toString()), // Unique marker identifier
      icon: BitmapDescriptor.defaultMarker, // Default marker icon
      position: location, // Marker position
      infoWindow:
          InfoWindow(title: title, snippet: snippet), // Info window details
    );
    setState(() {
      _markers.add(newMarker); // Add the new marker to the set of markers
      print('Marker added: ${newMarker.markerId}');
    });
  }

  Future<void> _getMyLocation() async {
    LocationData myLocation = await LocationService()
        .getLocation(); // Fetch current location using LocationService
    setState(() {
      currentLocation = LatLng(
          myLocation.latitude!,
          myLocation
              .longitude!); // Update currentLocation with fetched location
      _setMarker(currentLocation, 'Current Location',
          ''); // Add a marker for the current location
    });
    _animateCamera(
        currentLocation); // Animate the camera to the current location
  }

  Future<void> _animateCamera(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: location,
      zoom: 13.00,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
