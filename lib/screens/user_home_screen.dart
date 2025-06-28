import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:park_easy/widgets/parking_list.dart';
import 'package:park_easy/widgets/search_bar.dart';
import 'package:park_easy/widgets/user_app_bar.dart';
import 'package:park_easy/widgets/user_bottom_navbar.dart';
import 'package:park_easy/widgets/user_profile_drawer.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/map_provider.dart';
import '../widgets/filters_section.dart';

class UserHomeScreen extends StatelessWidget {
  final String email;
  UserHomeScreen({required this.email, super.key});

  final TextEditingController _searchController = TextEditingController();
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
        key: _scaffoldKey,
        appBar: UserAppBar(
          scaffoldKey: _scaffoldKey,
          profileImage: provider.profileImage,
          profileAvatarKey: _profileAvatarKey,
        ),
        body: Column(
          children: [
            SearchBarWidget(
              searchBoxKey: _searchBoxKey,
              searchController: _searchController,
            ),
            FiltersSection(
              filterKey: _filterKey,
            ),
            Expanded(
              flex: 2,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: provider.center, zoom: 14),
                markers: provider.markers,
                onMapCreated: (controller) => provider.setMapController(controller),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            Expanded(
              flex: 1,
              child: ParkingList(),
            ),
          ],
        ),
        bottomNavigationBar: UserBottomNavBar(
          scaffoldKey: _scaffoldKey,
          historyKey: _historyKey,
        ),
        endDrawer: UserProfileDrawer(
          email: email,
          profileImage: provider.profileImage,
        ),
        endDrawerEnableOpenDragGesture: false,
      ),
    );
  }
}



