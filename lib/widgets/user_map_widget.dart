import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map_provider.dart';

class UserMapWidget extends StatelessWidget {
  const UserMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return SizedBox(
      height: mapProvider.mapHeight,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: mapProvider.center, zoom: 14),
          markers: mapProvider.markers,
          onMapCreated: (controller) {
            mapProvider.mapController = controller;
            if (mapProvider.searchCenter != null) {
              mapProvider.mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(mapProvider.searchCenter!, 14),
              );
              mapProvider.fetchParkingLots(mapProvider.searchCenter!.latitude, mapProvider.searchCenter!.longitude);
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}
