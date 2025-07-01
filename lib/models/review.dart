class Review {
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}