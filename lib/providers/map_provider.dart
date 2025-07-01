import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/parking_space.dart';
import '../services/geolocation_service.dart';
import '../services/parking_service.dart';
import '../services/user_profile_image.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  LatLng center = const LatLng(28.6139, 77.2090); // default to Delhi
  LatLng? searchCenter;
  Set<Marker> markers = {};
  List<ParkingSpace> customParkingLots = [];
  double maxDistance = 100000;
  double maxPrice = 100;
  File? profileImage;
  String? userName;
  bool _initialized = false;
  double mapHeight = 275;

  bool get isInitialized => _initialized;

  List<ParkingSpace> get parkingLots => customParkingLots;

  Future<void> init() async {
    await _loadProfileImage();
    await locateUser();
  }

  Future<void> _loadProfileImage() async {
    final image = await ProfileImageService.getProfileImage();
    final name = await ProfileImageService.getUserName();
    profileImage = image;
    userName = name;
    notifyListeners();
  }

  void updateProfileImage(File? profileImage) {
    this.profileImage = profileImage;
    notifyListeners();
  }

  void updateUserName(String name) {
    userName = name;
    notifyListeners();
  }

  Future<void> locateUser() async {
    final position = await GeolocationService.getUserLocation();
    if (position != null) {
      center = LatLng(position.latitude, position.longitude);
      searchCenter = center;
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(center, 14));
      await fetchParkingLots(center.latitude, center.longitude);
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchParkingLots(double lat, double lng) async {
    //final data = await ParkingService.fetchAndFilterParkingSpaces(
    //   lat: lat,
    //   lng: lng,
    //   maxDistance: maxDistance,
    //   maxPrice: maxPrice,
    // );
    // markers = data.markers;
    // customParkingLots = data.lots;
    try {
      final databaseRef = FirebaseDatabase.instance.ref('parking_spaces');
      final snapshot = await databaseRef.get();

      if (!snapshot.exists) {
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      List<ParkingSpace> nearby = [];
      Set<Marker> newMarkers =
      markers
          .where((m) => m.markerId.value == 'search-location')
          .toSet();

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
              icon:
              isBooked
                  ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              )
                  : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          );
        }
      }
      customParkingLots = nearby;
      markers = newMarkers;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void setMaxDistance(double value) {
    maxDistance = value;
    notifyListeners();
  }

  void setMaxPrice(double value) {
    maxPrice = value;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void setSearchCenter(LatLng location) {
    searchCenter = location;
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
    notifyListeners();
  }

  void addMarker(Marker marker) {
    markers.add(marker);
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        final location = LatLng(lat, lng);

        center = location;

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
        markers.removeWhere((m) => m.markerId.value == 'search-location');
        markers.add(
          Marker(
            markerId: MarkerId('search-location'),
            position: location,
            infoWindow: InfoWindow(title: 'Searched Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
        fetchParkingLots(lat, lng);
        notifyListeners();
      } else {
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  void handelScroll(double scrollDelta){
    mapHeight -= scrollDelta;
    mapHeight = mapHeight.clamp(135, 275);
    notifyListeners();
  }

  double calculateDistanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Optional: handle error
      print('Could not open Google Maps');
    }
  }

}
