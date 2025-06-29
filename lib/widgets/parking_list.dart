import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../screens/parking_details_screen.dart';

class ParkingList extends StatelessWidget {
  const ParkingList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);

    return ListView.builder(
      itemCount: provider.parkingLots.length,
      itemBuilder: (context, index) {
        final lot = provider.parkingLots[index];
        final isBooked = lot.availableSpots == 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.address,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${lot.pricePerHour}/hr • ${lot.availableSpots} spots',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isBooked
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParkingDetailsScreen(
                          parkingSpace: lot,
                          userLat: provider.searchCenter?.latitude ?? provider.center.latitude,
                          userLng: provider.searchCenter?.longitude ?? provider.center.longitude,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBooked ? Colors.grey[600] : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Book", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
