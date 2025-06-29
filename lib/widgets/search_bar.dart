import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../providers/map_provider.dart';

class SearchBarWidget extends StatelessWidget {
  final GlobalKey searchBoxKey;
  final TextEditingController searchController;
  const SearchBarWidget({super.key, required this.searchBoxKey, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Showcase(
        key: searchBoxKey,
        description: 'Search for a location here.',
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Enter location",
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => mapProvider.searchLocation(searchController.text),
            ),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}