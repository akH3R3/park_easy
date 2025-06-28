import 'package:flutter/material.dart';
import 'package:park_easy/widgets/showcase_wrapper.dart';
import 'package:provider/provider.dart';

import '../providers/user_bottom_navbar.dart';
import '../screens/user_history_screen.dart';

class UserBottomNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey historyKey;

  const UserBottomNavBar({
    super.key,
    required this.scaffoldKey,
    required this.historyKey,
  });

  @override
  Widget build(BuildContext context) {
    final bottomNav = Provider.of<UserBottomNavBarProvider>(context);

    return BottomNavigationBar(
      currentIndex: bottomNav.selectedIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        bottomNav.setIndex(index);

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserHistoryScreen()),
          ).then((_) {
            bottomNav.setIndex(0);
          });
        } else if (index == 2) {
          scaffoldKey.currentState?.openEndDrawer();
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: showcaseWrapper(
            key: historyKey,
            description: 'Check your past bookings here.',
            child: const Icon(Icons.history),
          ),
          label: "History",
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
