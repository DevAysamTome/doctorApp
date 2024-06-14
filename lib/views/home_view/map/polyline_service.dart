import 'dart:ui';

import 'package:emart_app/views/book_appointment_view/consts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PolylineService {
  Future<Polyline> drawPolyline(LatLng from, LatLng to) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${from.latitude},${from.longitude}'
        '&destination=${to.latitude},${to.longitude}'
        '&key=$GOOGLE_MAPS_API_KEY',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(response.body);

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final List<LatLng> polylinePoints = _decodePolyline(points);

        return Polyline(
          polylineId: const PolylineId('polyline'),
          color: const Color(0xFF42A5F5),
          width: 5,
          points: polylinePoints,
        );
      } else {
        throw Exception("No routes found");
      }
    } else {
      final data = json.decode(response.body); // Declare data here
      final errorMessage = data['error_message'] ?? 'Unknown error';
      throw Exception('Failed to load directions: $errorMessage');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}
