import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/views/book_appointment_view/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'polyline_service.dart';

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
  LatLng? destination;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

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
      _setMarker(
        LatLng(data['latitude'], data['longitude']),
        data['docName'],
        data['docCategory'],
      );
    }
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
            polylines: _polylines,
            onTap: (LatLng location) {
              _setDestination(location);
            },
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.gps_fixed),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              LatLng origin = currentLocation;
              if (destination != null) {
                await _drawPolyline(origin, destination!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Please select a destination by tapping on the map"),
                  ),
                );
              }
            },
            child: Icon(Icons.settings_ethernet_rounded),
          ),
          FloatingActionButton(
            onPressed: () =>
                _setMarker(currentLocation, 'Current Location', ''),
            child: Icon(Icons.location_on),
          ),
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

  Future<void> _drawPolyline(LatLng from, LatLng to) async {
    try {
      // Print the coordinates of the from and to points
      print(
          "Drawing polyline from: (${from.latitude}, ${from.longitude}) to: (${to.latitude}, ${to.longitude})");

      Polyline polyline = await PolylineService().drawPolyline(from, to);
      setState(() {
        _polylines.add(polyline);
        _setMarker(from, 'Start', '');
        _setMarker(to, 'End', '');
      });
    } catch (e) {
      print("Error drawing polyline: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
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
    });
  }

  void _setDestination(LatLng location) {
    setState(() {
      destination = location;
      _setMarker(location, 'Destination', '');
    });
  }

  Future<void> _getMyLocation() async {
    LocationData _myLocation = await LocationService().getLocation();
    setState(() {
      currentLocation = LatLng(_myLocation.latitude!, _myLocation.longitude!);
    });
    _animateCamera(currentLocation);
  }

  Future<void> _animateCamera(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _cameraPosition = CameraPosition(
      target: location,
      zoom: 13.00,
    );
    print(
        "animating camera to (lat: ${location.latitude}, long: ${location.longitude}");
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }
}
