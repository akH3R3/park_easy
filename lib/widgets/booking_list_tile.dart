import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import 'review_dialog.dart';

class BookingListTile extends StatelessWidget {
  final Booking booking;
  final bool isPast;

  const BookingListTile({super.key, required this.booking, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    if (!isPast) {
      return ListTile(
        title: Text('Parked at ${booking.parkingSpaceAddress}'),
        subtitle: Text('From ${booking.startTime} to ${booking.endTime}\nStatus: ${booking.status}'),
        trailing: Text('₹${booking.cost}'),
      );
    }

    return FutureBuilder<bool>(
      future: provider.hasReviewed(booking.parkingSpaceId),
      builder: (context, snapshot) {
        final hasReviewed = snapshot.data ?? false;
        return ListTile(
          title: Text('Parked at ${booking.parkingSpaceAddress}'),
          subtitle: Text('From ${booking.startTime} to ${booking.endTime}\nStatus: ${booking.status}'),
          trailing: hasReviewed
              ? const Text('Reviewed', style: TextStyle(color: Colors.green))
              : ElevatedButton(
            onPressed: () async {
              final result = await showReviewDialog(context);
              if (result != null) {
                await provider.addReview(
                  booking.parkingSpaceId,
                  result['rating'],
                  result['comment'],
                );
              }
            },
            child: const Text('Add Review'),
          ),
        );
      },
    );
  }
}
