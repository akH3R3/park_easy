import 'package:firebase_database/firebase_database.dart';
import '../models/parking_space.dart';
import '../models/booking_model.dart';
import '../models/review.dart';

class ParkingFunctions {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final ref = _db.child('parking_spaces');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];
    final spaces = <ParkingSpace>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      map['id'] = child.key ?? '';
      spaces.add(ParkingSpace.fromMap(map));
    }
    return spaces;
  }

  Future<List<ParkingSpace>> getParkingSpacesByOwner(String ownerId) async {
    final ref = _db.child('parking_spaces');
    final snapshot = await ref.orderByChild('ownerId').equalTo(ownerId).get();
    if (!snapshot.exists) return [];
    final spaces = <ParkingSpace>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      map['id'] = child.key ?? '';
      spaces.add(ParkingSpace.fromMap(map));
    }
    return spaces;
  }

  Stream<List<ParkingSpace>> getParkingSpacesByOwnerStream(String ownerId) {
    final ref = _db
        .child('parking_spaces')
        .orderByChild('ownerId')
        .equalTo(ownerId);
    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value);
        map['id'] = e.key;
        return ParkingSpace.fromMap(map);
      }).toList();
    });
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    final ref = _db.child('bookings');
    final snapshot = await ref.orderByChild('userId').equalTo(userId).get();
    if (!snapshot.exists) return [];
    final bookings = <Booking>[];
    for (final child in snapshot.children) {
      final map = Map<String, dynamic>.from(child.value as Map);
      map['id'] = child.key;
      bookings.add(Booking.fromMap(map));
    }
    return bookings;
  }

  Future<void> addBooking(Booking booking) async {
    final newRef = _db.child('bookings').push();
    await newRef.set(booking.toMap());
  }

  Future<void> addParkingSpace({
    required String ownerId,
    required String address,
    required double pricePerHour,
    required int availableSpots,
    required double latitude,
    required double longitude,
    required String upiId,
    required String photoUrl,
  }) async {
    final newRef = _db.child('parking_spaces').push();
    await newRef.set({
      'id': newRef.key,
      'ownerId': ownerId,
      'address': address,
      'pricePerHour': pricePerHour,
      'availableSpots': availableSpots,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'upiId': upiId,
      'reviews': [],
    });
  }

  Future<void> updateParkingSpace(
    String parkingSpaceId, {
    double? pricePerHour,
    int? availableSpots,
    String? upiId,
  }) async {
    final updates = <String, dynamic>{};
    if (pricePerHour != null) updates['pricePerHour'] = pricePerHour;
    if (availableSpots != null) updates['availableSpots'] = availableSpots;
    if (upiId != null) updates['upiId'] = upiId;
    await _db.child('parking_spaces/$parkingSpaceId').update(updates);
  }

  Future<void> deleteParkingSpace(String parkingSpaceId) async {
    await _db.child('parking_spaces/$parkingSpaceId').remove();
  }

  Future<void> completeBooking(String bookingId) async {
    await _db.child('bookings/$bookingId').update({'status': 'completed'});
  }

  Future<List<Review>> getReviewsForParkingSpace(String parkingSpaceId) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];
    final reviews = <Review>[];
    for (final child in snapshot.children) {
      reviews.add(
        Review.fromMap(Map<String, dynamic>.from(child.value as Map)),
      );
    }
    return reviews;
  }

  Future<void> addReviewToParkingSpace(
    String parkingSpaceId,
    Review review,
  ) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews').push();
    await ref.set(review.toMap());
  }

  Future<bool> hasUserReviewed(String parkingSpaceId, String userId) async {
    final ref = _db.child('parking_spaces/$parkingSpaceId/reviews');
    final snapshot = await ref.get();
    if (!snapshot.exists) return false;
    for (final child in snapshot.children) {
      final review = Review.fromMap(
        Map<String, dynamic>.from(child.value as Map),
      );
      if (review.userId == userId) return true;
    }
    return false;
  }
}
