import 'dart:io';

import 'package:flutter/material.dart';
import 'package:park_easy/widgets/showcase_wrapper.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget{
  final GlobalKey<ScaffoldState> scaffoldKey;
  final File? profileImage;
  final GlobalKey profileAvatarKey;
  const UserAppBar({super.key,required this.scaffoldKey,required this.profileImage,required this.profileAvatarKey});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 5,
      title: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              "Nearby Slots",
              style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
              child: showcaseWrapper(
                key: profileAvatarKey,
                description: 'Tap here to open your profile and settings.',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.file(
                      profileImage!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/images/default_profile.jpg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}