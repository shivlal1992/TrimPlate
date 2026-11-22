
import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/orders/my_orders_screen.dart';
import '../screens/subscription/my_subscriptions_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFEDF4EF);

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;

      case 1:
        screen = const MyOrdersScreen();
        break;

      case 2:
        screen = const MySubscriptionsScreen();
        break;

      case 3:
        screen = const ProfileScreen();
        break;

      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: background,
      indicatorColor: const Color(0xFFD4EEDB),
      elevation: 0,
      height: 76,
      labelBehavior:
      NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        _navigate(context, index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: green,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(
            Icons.shopping_bag,
            color: green,
          ),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.card_membership_outlined),
          selectedIcon: Icon(
            Icons.card_membership,
            color: green,
          ),
          label: 'Subscription',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(
            Icons.person,
            color: green,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
