import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black12,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple, width: 1.5),
              ),
              child: TextField(
                controller: mapProvider.searchController,
                style: const TextStyle(fontSize: 16),
                onSubmitted: (val) => mapProvider.searchLocation(val),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  hintText: "Search location...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => mapProvider.searchLocation(
                      mapProvider.searchController.text,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search, color: Colors.deepPurple),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide
                        .none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none, // same here
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blue, size: 26),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
