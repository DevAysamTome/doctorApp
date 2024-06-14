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
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(32.4324, 35.0856),
    zoom: 14.4746,
  );

  LatLng currentLocation = _initialCameraPosition.target;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchClinicLocations();
  }

  Future<void> _fetchClinicLocations() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('doctors').get();
    final List<DocumentSnapshot> documents = result.docs;

    for (var doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      print('Fetched data: $data');
      if (data.containsKey('docLat') && data.containsKey('docLong')) {
        try {
          double lat = double.parse(data['docLat']);
          double lng = double.parse(data['docLong']);
          _setMarker(
            LatLng(lat, lng),
            data['docName'] ?? 'Unknown',
            data['docCategory'] ?? 'Unknown',
          );
        } catch (e) {
          print('Error parsing coordinates: $e');
        }
      } else {
        print('Missing coordinates in data: $data');
      }
    }
    setState(() {}); // Ensure the map is updated with new markers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMove: (e) => currentLocation = e.target,
            markers: _markers,
            onTap: (LatLng location) {
              _setMarker(location, 'New Marker', '');
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _getMyLocation(),
            child: Icon(Icons.gps_fixed),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 20,
        alignment: Alignment.center,
        child: Text(
            "lat: ${currentLocation.latitude}, long: ${currentLocation.longitude}"),
      ),
    );
  }

  void _setMarker(LatLng location, String title, String snippet) {
    Marker newMarker = Marker(
      markerId: MarkerId(location.toString()),
      icon: BitmapDescriptor.defaultMarker,
      position: location,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    setState(() {
      _markers.add(newMarker);
      print('Marker added: ${newMarker.markerId}');
    });
  }

  Future<void> _getMyLocation() async {
    LocationData _myLocation = await LocationService().getLocation();
    setState(() {
      currentLocation = LatLng(_myLocation.latitude!, _myLocation.longitude!);
      _setMarker(currentLocation, 'Current Location', '');
    });
    _animateCamera(currentLocation);
  }

  Future<void> _animateCamera(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
      target: location,
      zoom: 13.00,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }
}
