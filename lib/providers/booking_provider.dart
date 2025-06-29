import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../models/review.dart';
import '../services/parking_functions.dart';

class BookingProvider with ChangeNotifier {
  final ParkingFunctions _parkingService = ParkingFunctions();

  List<Booking> _bookings = [];
  String? _userId;

  List<Booking> get ongoingBookings =>
      _bookings.where((b) => b.status == 'active').toList();

  List<Booking> get pastBookings =>
      _bookings.where((b) => b.status == 'completed').toList();

  Future<void> fetchBookings() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) {
      _bookings = [];
    } else {
      _bookings = await _parkingService.getBookingsByUser(_userId!);
    }
    notifyListeners();
  }

  String? get userId => _userId;

  Future<bool> hasReviewed(String parkingSpaceId) async {
    if (_userId == null) return false;
    return await _parkingService.hasUserReviewed(parkingSpaceId, _userId!);
  }

  Future<void> addReview(String parkingSpaceId, double rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _parkingService.addReviewToParkingSpace(
      parkingSpaceId,
      Review(
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        rating: rating,
        comment: comment,
        date: DateTime.now(),
      ),
    );
    await fetchBookings(); // Refresh data
  }
}
