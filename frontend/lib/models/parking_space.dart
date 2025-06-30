import 'package:park_easy/models/review.dart';

class ParkingSpace {
  final String id;
  final String ownerId;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final int availableSpots;
  final String photoUrl;
  final String upiId;
  final List<Review> reviews;

  ParkingSpace({
    required this.id,
    required this.ownerId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.availableSpots,
    required this.photoUrl,
    required this.upiId,
    this.reviews = const [],
  });

  factory ParkingSpace.fromMap(Map<String, dynamic> map) {
    return ParkingSpace(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      availableSpots: map['availableSpots'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      upiId: map['upiId'] ?? '',
      reviews: map['reviews'] != null && map['reviews'] is List
          ? List<Review>.from(
          (map['reviews'] as List).map((x) => Review.fromMap(Map<String, dynamic>.from(x))))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerHour': pricePerHour,
      'availableSpots': availableSpots,
      'photoUrl': photoUrl,
      'upiId': upiId,
      'reviews': reviews.map((x) => x.toMap()).toList(),
    };
  }
}