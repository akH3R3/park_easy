import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_space.dart';

class ParkingServiceResult {
  final List<ParkingSpace> lots;
  final Set<Marker> markers;

  ParkingServiceResult({required this.lots, required this.markers});
}

class ParkingService {
  static Future<ParkingServiceResult> fetchAndFilterParkingSpaces({
    required double lat,
    required double lng,
    required double maxDistance,
    required double maxPrice,
  }) async {
    return ParkingServiceResult(lots: [], markers: {});
    final databaseRef = FirebaseDatabase.instance.ref('parking_spaces');
    final snapshot = await databaseRef.get();

    if (!snapshot.exists) return ParkingServiceResult(lots: [], markers: {});

    final data = snapshot.value as Map<dynamic, dynamic>;
    List<ParkingSpace> nearby = [];
    Set<Marker> newMarkers = {};

    for (var entry in data.entries) {
      final space = ParkingSpace.fromMap(
        Map<String, dynamic>.from(entry.value),
      );

      final distance = Geolocator.distanceBetween(
        lat,
        lng,
        space.latitude,
        space.longitude,
      );

      if (space.pricePerHour <= maxPrice && distance <= maxDistance) {
        nearby.add(space);
        final isBooked = space.availableSpots == 0;
        newMarkers.add(
          Marker(
            markerId: MarkerId('custom-${entry.key}'),
            position: LatLng(space.latitude, space.longitude),
            infoWindow: InfoWindow(
              title: space.address,
              snippet:
              '₹${space.pricePerHour}/hr • ${space.availableSpots} spots',
            ),
            icon: isBooked
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    return ParkingServiceResult(lots: nearby, markers: newMarkers);
  }
}
