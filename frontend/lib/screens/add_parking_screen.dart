import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../services/parking_service.dart';

class AddParkingScreen extends StatelessWidget {
  final String ownerId;

  AddParkingScreen({super.key, required this.ownerId});

  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _upiController = TextEditingController();

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition();
      _latController.text = pos.latitude.toString();
      _lngController.text = pos.longitude.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageUploadProvider>(context);
    final images = imageProvider.images;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          imageProvider.clearImages();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Parking Slot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 1,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purpleAccent, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Slot Photos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext ctx) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Upload From Gallery'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    imageProvider.pickMultipleImages();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Camera'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    imageProvider.captureImageFromCamera();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.cancel),
                                  title: Text('Cancel'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.camera_alt, size: 40),
                    ),
                  ),
                  images.isNotEmpty
                      ? Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: Image.file(
                                      images[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () => imageProvider.deleteImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                      : SizedBox(),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Slot Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _getCurrentLocation(context),
                icon: const Icon(Icons.location_pin),
                label: const Text("Use Current Location"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Total Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _slotsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 12',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Price per Hour", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 40',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Owner UPI ID", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _upiController,
                decoration: const InputDecoration(
                  hintText: 'e.g. example@upi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final int totalSlots = int.tryParse(_slotsController.text) ?? 0;
                    final double price = double.tryParse(_priceController.text) ?? 0.0;
                    final String upi = _upiController.text.trim();
                    final double lat = double.tryParse(_latController.text) ?? 0.0;
                    final double lng = double.tryParse(_lngController.text) ?? 0.0;
                    final String address = _addressController.text.trim();

                    if (totalSlots <= 0 || price <= 0 || upi.isEmpty || address.isEmpty || lat == 0.0 || lng == 0.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fill all details correctly to save"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    String? _parkingId = await ParkingService().addParkingSpace(
                      ownerId: ownerId,
                      address: address,
                      pricePerHour: price,
                      availableSpots: totalSlots,
                      latitude: lat,
                      longitude: lng,
                      upiId: upi,
                    );

                    Navigator.pop(context, {
                      'slots': totalSlots,
                      'price': price,
                      'upiId': upi,
                      'latitude': lat,
                      'longitude': lng,
                      'address': address,
                    });

                    imageProvider.uploadImages(
                      uid: ownerId,
                      subfolder: _parkingId!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.purple,
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save Slot", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}