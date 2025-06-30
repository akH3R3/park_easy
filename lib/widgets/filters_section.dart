import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class FiltersSection extends StatelessWidget {
  const FiltersSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final maxPrice = mapProvider.maxPrice;
    final maxDistance = mapProvider.maxDistance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            InkWell(
              onTap: () {
                double tempMaxDistance = maxDistance;
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 350),
                          padding: const EdgeInsets.all(16),
                          child: StatefulBuilder(
                            builder: (context, setStateDialog) => Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Max distance to Park: ${(tempMaxDistance / 1000).toInt()} km',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Slider(
                                  value: tempMaxDistance,
                                  min: 500,
                                  max: 100000,
                                  divisions: 19,
                                  label:
                                  '${(tempMaxDistance / 1000).toStringAsFixed(1)} km',
                                  onChanged: (val) {
                                    setStateDialog(() => tempMaxDistance = val);
                                  },
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      mapProvider.setMaxDistance(tempMaxDistance);
                                      //mapProvider.setMaxPrice(tempMaxPrice);
                                      if (mapProvider.searchCenter != null) {
                                        mapProvider.fetchParkingLots(mapProvider.searchCenter!.latitude, mapProvider.searchCenter!.longitude);
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      "Apply Filters",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.straighten,
                    color: Colors.blueAccent, size: 28),
              ),
            ),
            SizedBox(height: 5),
            Text('Distance',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ],
        ),
        Column(
          children: [
            InkWell(
              onTap: () {
                double tempMaxPrice = maxPrice;
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 350),
                          padding: const EdgeInsets.all(16),
                          child: StatefulBuilder(
                            builder: (context, setStateDialog) => Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Max Price for Parking: ₹${tempMaxPrice.toInt()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Slider(
                                  value: tempMaxPrice,
                                  min: 0,
                                  max: 200,
                                  divisions: 20,
                                  label: tempMaxPrice.round().toString(),
                                  onChanged: (val) {
                                    setStateDialog(() => tempMaxPrice = val);
                                  },
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      mapProvider.setMaxPrice(tempMaxPrice);
                                      if (mapProvider.searchCenter != null) {
                                        mapProvider.fetchParkingLots(mapProvider.searchCenter!.latitude, mapProvider.searchCenter!.longitude);
                                      }
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      "Apply Filters",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee,
                    color: Colors.green, size: 24),
              ),
            ),
            SizedBox(height: 5),
            Text('Price',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ],
        ),
        Column(
          children: [
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Rating sorting pressed",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rate_sharp,
                    color: Color(0xFFF9A825), size: 24),
              ),
            ),
            SizedBox(height: 5),
            Text('Rating',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ],
        ),
      ],
    );
  }
}
