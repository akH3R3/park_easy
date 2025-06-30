import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/owner_profile_provider.dart';
import '../services/image_picker_helper.dart';

class OwnerProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String uid;

  const OwnerProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
  });

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<OwnerProfileProvider>(context, listen: false)
          .loadOwnerData(defaultName: name, defaultEmail: email),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Consumer<OwnerProfileProvider>(
          builder: (context, provider, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Owner Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.person_2_outlined),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (provider.isEditing) {
                                ImagePickerHelper.showImageSourceActionSheet(
                                  context: context,
                                  onImageSelected: provider.updateProfileImage,
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: provider.profileImage != null
                                  ? FileImage(provider.profileImage!)
                                  : const AssetImage('assets/images/profile_placeholder.png')
                              as ImageProvider,
                            ),
                          ),
                          if (provider.isEditing)
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  ImagePickerHelper.showImageSourceActionSheet(
                                    context: context,
                                    onImageSelected: provider.updateProfileImage,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Welcome, ${provider.nameController.text}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Personal Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTextField(label: 'Name', controller: provider.nameController, enabled: provider.isEditing),
                    _buildTextField(
                        label: 'Email',
                        controller: provider.emailController,
                        enabled: false,
                        inputType: TextInputType.emailAddress),
                    _buildTextField(
                        label: 'Phone',
                        controller: provider.phoneController,
                        enabled: provider.isEditing,
                        inputType: TextInputType.phone),
                    const SizedBox(height: 24),
                    const Text('Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTextField(
                        label: 'Business Name', controller: provider.businessController, enabled: provider.isEditing),
                    _buildTextField(
                        label: 'Business Address', controller: provider.addressController, enabled: provider.isEditing),
                    _buildTextField(
                        label: 'Total Lots Owned',
                        controller: provider.lotsController,
                        enabled: provider.isEditing,
                        inputType: TextInputType.number),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: provider.toggleEditing,
                icon: Icon(provider.isEditing ? Icons.save : Icons.edit),
                label: Text(provider.isEditing ? 'Save' : 'Edit'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          },
        );
      },
    );
  }
}
