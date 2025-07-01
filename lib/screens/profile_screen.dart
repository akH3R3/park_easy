import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/profile_section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(provider.isEditing ? Icons.save : Icons.edit),
                onPressed: () => provider.toggleEditing(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileAvatar(enabled: provider.isEditing),
                const SizedBox(height: 16),
                ProfileSectionCard(title: 'User Info', children: [
                  ProfileTextField(label: 'Name', controller: provider.nameController, enabled: provider.isEditing),
                  ProfileTextField(label: 'Email', controller: provider.emailController, enabled: false),
                ]),
                ProfileSectionCard(title: 'Contact Info', children: [
                  ProfileTextField(label: 'Phone', controller: provider.phoneController, enabled: false),
                  ProfileTextField(label: 'Address', controller: provider.addressController, enabled: provider.isEditing),
                ]),
                ProfileSectionCard(title: 'Parking Preferences', children: [
                  ProfileTextField(label: 'Vehicle Info', controller: provider.vehicleController, enabled: provider.isEditing),
                  ProfileTextField(label: 'Preferred Time for Parking', controller: provider.timeController, enabled: provider.isEditing),
                  ProfileTextField(label: 'Preferred Zone for Parking', controller: provider.zoneController, enabled: provider.isEditing),
                ]),
                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => provider.toggleEditing(context),
            icon: Icon(provider.isEditing ? Icons.save : Icons.edit),
            label: Text(provider.isEditing ? 'Save' : 'Edit'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
