import 'package:flutter/material.dart';
import 'package:park_easy/widgets/parking_list.dart';
import 'package:park_easy/widgets/search_bar.dart';
import 'package:park_easy/widgets/user_app_bar.dart';
import 'package:park_easy/widgets/user_bottom_navbar.dart';
import 'package:park_easy/widgets/user_map_widget.dart';
import 'package:park_easy/widgets/user_profile_drawer.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/map_provider.dart';
import '../widgets/filters_section.dart';

class UserHomeScreen extends StatelessWidget {
  final String email;

  UserHomeScreen({required this.email, super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _profileAvatarKey = GlobalKey();
  final GlobalKey _searchBoxKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: UserAppBar(
          scaffoldKey: _scaffoldKey,
          profileImage: provider.profileImage,
          profileAvatarKey: _profileAvatarKey,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Showcase(
                key: _searchBoxKey,
                description: "Search for a location here.",
                child: SearchBarWidget(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Showcase(
                key: _filterKey,
                description: 'Adjust filters to find suitable parking.',
                child: FiltersSection(),
              ),
            ),
            SizedBox(height: 10),
            UserMapWidget(),
            NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    final scrollDelta = notification.scrollDelta ?? 0;
                    provider.handelScroll(scrollDelta);
                  }
                  return false;
                },
                child: Expanded(flex: 1, child: ParkingList())),
          ],
        ),
        bottomNavigationBar: UserBottomNavBar(
          scaffoldKey: _scaffoldKey,
          historyKey: _historyKey,
        ),
        endDrawer: UserProfileDrawer(
          email: email,
          profileImage: provider.profileImage,
          name: provider.userName ?? "John Doe",
        ),
        endDrawerEnableOpenDragGesture: false,
      ),
    );
  }
}