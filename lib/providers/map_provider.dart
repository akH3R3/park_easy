import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/parking_space.dart';
import '../services/geolocation_service.dart';
import '../services/parking_service.dart';
import '../services/user_profile_image.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng center = const LatLng(28.6139, 77.2090); // default to Delhi
  LatLng? searchCenter;
  Set<Marker> markers = {};
  List<ParkingSpace> customParkingLots = [];
  double maxDistance = 100000;
  double maxPrice = 100;
  File? profileImage;
  String? userName;
  bool _initialized = false;

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
    final data = await ParkingService.fetchAndFilterParkingSpaces(
      lat: lat,
      lng: lng,
      maxDistance: maxDistance,
      maxPrice: maxPrice,
    );
    markers = data.markers;
    customParkingLots = data.lots;
    notifyListeners();
  }

  void updateFilters({double? price, double? distance}) {
    if (price != null) maxPrice = price;
    if (distance != null) maxDistance = distance;
    if (searchCenter != null) {
      fetchParkingLots(searchCenter!.latitude, searchCenter!.longitude);
    }
  }

  void setMaxDistance(double value) {
    maxDistance = value;
    if (searchCenter != null) {
      fetchParkingLots(searchCenter!.latitude, searchCenter!.longitude);
    }
  }

  void setMaxPrice(double value) {
    maxPrice = value;
    if (searchCenter != null) {
      fetchParkingLots(searchCenter!.latitude, searchCenter!.longitude);
    }
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void setSearchCenter(LatLng location) {
    searchCenter = location;
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
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

        searchCenter = location;

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
      }
    } catch (e) {
      if (kDebugMode) {
        print('😅 $e');
      }
    }
  }
}
