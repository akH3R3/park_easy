import 'package:flutter/material.dart';
import '../models/parking_space.dart';
import '../providers/dashboard_stat.dart';

class DashboardHeader extends StatelessWidget {
  final List<ParkingSpace> spaces;
  final TextStyle subtitleStyle;

  const DashboardHeader({
    super.key,
    required this.spaces,
    required this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    int totalSlots = spaces.fold(0, (sum, s) => sum + s.availableSpots);
    int totalReviews = spaces.fold(0, (sum, s) => sum + s.reviews.length);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardStat(
              label: "Spaces",
              value: spaces.length.toString(),
              icon: Icons.local_parking,
              textStyle: subtitleStyle,
            ),
            DashboardStat(
              label: "Slots",
              value: totalSlots.toString(),
              icon: Icons.event_seat,
              textStyle: subtitleStyle,
            ),
            DashboardStat(
              label: "Reviews",
              value: totalReviews.toString(),
              icon: Icons.star,
              textStyle: subtitleStyle,
            ),
          ],
        ),
      ),
    );
  }
}
