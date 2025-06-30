import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/image_picker_helper.dart';

class ProfileAvatar extends StatelessWidget {
  final bool enabled;
  const ProfileAvatar({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: provider.profileImage != null
                ? FileImage(provider.profileImage!)
                : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: enabled ? GestureDetector(
              onTap: () {
                ImagePickerHelper.showImageSourceActionSheet(
                  context: context,
                  onImageSelected: (file) => provider.updateProfileImage(file),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: enabled ? const Icon(Icons.camera_alt, color: Colors.white, size: 18) : null,
              ),
            ) : Container(),
          )
        ],
      ),
    );
  }
}
