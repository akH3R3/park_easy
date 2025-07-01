import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shimmer_owner_dashboard.dart';
import '../models/parking_space.dart';
import '../services/parking_service.dart';
import 'add_parking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:showcaseview/showcaseview.dart';
import 'slot_analytics_screen.dart';
import 'package:provider/provider.dart';
import '/providers/slot_provider.dart';
import '/fun.dart';
import '../widgets/dashboard_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/edit_parking_dialog.dart';
import '/widgets/text_styles.dart';
import '/widgets/delete_dialog.dart';
import '/widgets/owner_end_drawer.dart';
import '/services/owner_checks.dart';


class OwnerDashboardScreen extends StatefulWidget {
  final User user;

  const OwnerDashboardScreen({super.key, required this.user});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ParkingService _parkingService = ParkingService();
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final LocalAuthentication auth = LocalAuthentication();
  final GlobalKey _profileAvatarKey = GlobalKey();
  final GlobalKey _analyticsKey = GlobalKey();
  final GlobalKey _editKey = GlobalKey();
  File? _profileImage;

  Widget showcaseWrapper({
    required GlobalKey key,
    required Widget child,
    required String description,
  }) {
    return Showcase(
      key: key,
      description: description,
      descTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      tooltipBackgroundColor: Colors.blueAccent,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    _loadProfileImage();
  }
  Future<void> _initializeScreen() async {
    await OwnerChecks.checkAndShowShowcase(
      context: context,
      profileAvatarKey: _profileAvatarKey,
      analyticsKey: _analyticsKey,
      editKey: _editKey,
    );
  }

  void _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('owner_profile_image');
    if (imagePath != null && mounted) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  void _showDeleteConfirmationDialog(String spaceId) {
    showDeleteConfirmationDialog(
      context: context,
      onConfirm: () async {
        await _parkingService.deleteParkingSpace(spaceId);
        setState(() {});
      },
    );
  }

  bool load = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: ShimmerOwnerDashboard());
    }
    return Builder(
      builder:
          (context) => Scaffold(
        key: _scaffoldKey,
        endDrawer: OwnerEndDrawer(
          user: widget.user,
          profileImage: _profileImage,
        ),

        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.manage_accounts,
              color: Colors.blue,
              size: 30,
            ),
          ),
          title: const Text(
            'Owner Dashboard',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            Builder(
              builder:
                  (context) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  child: showcaseWrapper(
                    key: _profileAvatarKey,
                    description:
                    'Tap here to open your profile and settings.',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child:
                        _profileImage != null
                            ? Image.file(
                          _profileImage!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/images/default_profile.jpg',
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FancyFAB(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder:
                    (_, animation, __) => FadeTransition(
                  opacity: animation,
                  child: AddParkingScreen(ownerId: widget.user.uid),

                ),
              ),
            );

            if (result != null && result is Map) {
              print('New parking slot data: $result');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parking slot added successfully'),
                ),
              );
              setState(() {});
            }
          },
        ),

        body: StreamBuilder<List<ParkingSpace>>(
          stream: _parkingService.getParkingSpacesByOwnerStream(
            widget.user.uid,
          ),


          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(child: ShimmerOwnerDashboard());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!load) {
                  setState(() {
                    load = true;
                  });
                }
              });
              return Center(
                child: Text(
                  'No records found',
                  style: subtitleStyle,
                ),
              );
            }
            final spaces = snapshot.data!;
            return Column(
              children: [
                DashboardHeader(spaces: spaces, subtitleStyle: subtitleStyle),
                Expanded(
                  child: ListView.builder(
                    itemCount: spaces.length,
                    itemBuilder: (context, idx) {
                      final space = spaces[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              // Left Image or Icon
                              space.photoUrl.isNotEmpty
                                  ? ClipRRect(
                                borderRadius:
                                BorderRadius.circular(8),
                                child: Image.network(
                                  space.photoUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Icon(
                                Icons.local_parking,
                                size: 40,
                                color: Colors.blue,
                              ),

                              const SizedBox(width: 10),

                              // Middle Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      space.address,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    space.availableSpots > 1 ?
                                    Text(
                                      '₹${space.pricePerHour}/hr • ${space.availableSpots} slots',
                                      style: subtitleStyle,
                                    ) : Text(
                                      '₹${space.pricePerHour}/hr • ${space.availableSpots} slot',
                                      style: subtitleStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          space.reviews.isNotEmpty
                                              ? (space.reviews
                                              .map(
                                                (r) =>
                                            r.rating,
                                          )
                                              .reduce(
                                                (
                                                a,
                                                b,
                                                ) =>
                                            a +
                                                b,
                                          ) /
                                              space
                                                  .reviews
                                                  .length)
                                              .toStringAsFixed(
                                            1,
                                          )
                                              : 'No rating',
                                          style:
                                          GoogleFonts.poppins(
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: space.availableSpots <= 9 ? 8 : 4),
                                    Text(
                                      '(${space.reviews.length} reviews)',
                                      style: smallGreyStyle,
                                    ),
                                  ],
                                ),
                              ),

                              // Trailing buttons
                              Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  idx == 0
                                      ? showcaseWrapper(
                                    key: _editKey,
                                    description:
                                    'Tap here to edit this parking slot.',
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        bool isAuth = await OwnerChecks.authenticate(context);

                                        if (isAuth) {
                                          showEditParkingDialog(context, space, () {
                                            setState(() {});
                                          });

                                        }
                                      },
                                    ),
                                  )
                                      : IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      bool isAuth = await OwnerChecks.authenticate(context);

                                      if (isAuth) {
                                        showEditParkingDialog(context, space, () {
                                          setState(() {});
                                        });

                                      }
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      bool isAuth = await OwnerChecks.authenticate(context);

                                      if (isAuth) {
                                        _showDeleteConfirmationDialog(
                                          space.id,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  idx == 0
                                      ? showcaseWrapper(
                                    key: _analyticsKey,
                                    // <-- make sure this GlobalKey is defined
                                    description:
                                    'Tap here to view analytics of this parking slot.',
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                context,
                                                ) => ChangeNotifierProvider(
                                              create:
                                                  (_) =>
                                                  SlotProvider(),
                                              child:
                                              SlotAnalyticsScreen(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.bar_chart,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'View Analytics',
                                            style: TextStyle(
                                              color:
                                              Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                              context,
                                              ) => ChangeNotifierProvider(
                                            create:
                                                (_) =>
                                                SlotProvider(),
                                            child:
                                            SlotAnalyticsScreen(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'View Analytics',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}