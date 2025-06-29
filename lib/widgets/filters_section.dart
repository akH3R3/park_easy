import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../providers/map_provider.dart';

class FiltersSection extends StatelessWidget {
  final GlobalKey filterKey;

  const FiltersSection({
    super.key,
    required this.filterKey,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final maxPrice = mapProvider.maxPrice;
    final maxDistance = mapProvider.maxDistance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Showcase(
        key: filterKey,
        description: 'Adjust filters to find suitable parking.',
        child: Column(
          children: [
            Row(
              children: [
                Text('Max Price: ₹${maxPrice.toInt()}'),
                Expanded(
                  child: Slider(
                    value: maxPrice,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: maxPrice.round().toString(),
                    onChanged: (value) {
                        mapProvider.updateFilters(price: value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Max Distance: ${(maxDistance / 1000).toStringAsFixed(1)} km',
                ),
                Expanded(
                  child: Slider(
                    value: maxDistance,
                    min: 500,
                    max: 100000,
                    divisions: 19,
                    label: '${(maxDistance / 1000).toStringAsFixed(1)} km',
                    onChanged: (value) {
                      mapProvider.updateFilters(distance: value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
