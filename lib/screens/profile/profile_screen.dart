
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';

import '../auth/welcome_screen.dart';
import '../orders/my_orders_screen.dart';
import '../subscription/my_subscriptions_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF6F9F6);

  bool loading = true;
  bool loggingOut = false;
  String error = '';

  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // =====================================
  // LOAD USER PROFILE
  // =====================================
  Future<void> loadProfile() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await ApiService.profile();

      if (!mounted) return;

      if (result['success'] == false) {
        throw Exception(
          result['message'] ?? 'Unable to load profile',
        );
      }

      final data = result['data'];

      setState(() {
        user = data is Map
            ? Map<String, dynamic>.from(
          data['user'] is Map
              ? data['user']
              : data,
        )
            : result['user'] is Map
            ? Map<String, dynamic>.from(
          result['user'],
        )
            : {};

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        loading = false;
      });
    }
  }

  // =====================================
  // USER DETAILS
  // =====================================
  String get name {
    final value = user['name']?.toString().trim();

    return value == null || value.isEmpty
        ? 'TrimPlate User'
        : value;
  }

  String get phone {
    return (user['phone'] ?? user['mobile'] ?? '')
        .toString();
  }

  String get email {
    final value = user['email']?.toString().trim();

    return value == null || value.isEmpty
        ? 'Not added'
        : value;
  }

  // =====================================
  // OPEN PAGE
  // =====================================
  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // =====================================
  // EDIT PROFILE
  // =====================================
  Future<void> openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: user,
        ),
      ),
    );

    if (updated == true && mounted) {
      await loadProfile();
    }
  }

  // =====================================
  // LOGOUT CONFIRMATION
  // =====================================
  Future<void> confirmLogout() async {
    if (loggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      loggingOut = true;
    });

    try {
      await ApiService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================
  // PROFILE OPTION
  // =====================================
  Widget profileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 5,
      ),
      leading: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F3E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: green,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // =====================================
  // SECTION CARD
  // =====================================
  Widget sectionCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // =====================================
  // PROFILE HEADER
  // =====================================
  Widget profileHeader() {
    final displayPhone = phone.isEmpty
        ? 'Mobile not available'
        : phone.startsWith('+91')
        ? phone
        : '+91 $phone';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 43,
            backgroundColor: Color(0xFFE5F3E8),
            child: Icon(
              Icons.person,
              size: 48,
              color: green,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            displayPhone,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // HELP & SUPPORT
  // =====================================
  void showHelpSupport() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Support contact details will be available soon.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // =====================================
  // ABOUT TRIMPLATE
  // =====================================
  void showAboutTrimPlate() {
    showAboutDialog(
      context: context,
      applicationName: 'TrimPlate',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Healthy food delivery',
    );
  }

  // =====================================
  // ERROR STATE
  // =====================================
  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 50,
            ),

            const SizedBox(height: 15),

            Text(
              error,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // PROFILE CONTENT
  // =====================================
  Widget profileContent() {
    return RefreshIndicator(
      color: green,
      onRefresh: loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // USER PROFILE
          profileHeader(),

          const SizedBox(height: 22),

          // MY ACCOUNT TITLE
          const Text(
            'My Account',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // MY ACCOUNT OPTIONS
          sectionCard([
            profileOption(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your personal details',
              onTap: openEditProfile,
            ),

            const Divider(height: 1),

            profileOption(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {
                openPage(
                  const MyOrdersScreen(),
                );
              },
            ),

            const Divider(height: 1),

            profileOption(
              icon: Icons.card_membership,
              title: 'My Subscriptions',
              onTap: () {
                openPage(
                  const MySubscriptionsScreen(),
                );
              },
            ),
          ]),

          const SizedBox(height: 22),

          // SUPPORT TITLE
          const Text(
            'Support & Settings',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // SUPPORT OPTIONS
          sectionCard([
            profileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: showHelpSupport,
            ),

            const Divider(height: 1),

            profileOption(
              icon: Icons.info_outline,
              title: 'About TrimPlate',
              onTap: showAboutTrimPlate,
            ),
          ]),

          const SizedBox(height: 24),

          // LOGOUT BUTTON
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed:
              loggingOut ? null : confirmLogout,
              icon: loggingOut
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
                  : const Icon(Icons.logout),
              label: Text(
                loggingOut
                    ? 'Logging out...'
                    : 'Logout',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'TrimPlate v1.0.0',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =====================================
  // MAIN SCREEN
  // =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =====================================
      // APP BAR
      // =====================================
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed:
            loading || loggingOut ? null : loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // =====================================
      // BODY
      // =====================================
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: green,
        ),
      )
          : error.isNotEmpty
          ? errorState()
          : profileContent(),

      // =====================================
      // COMMON BOTTOM NAVIGATION BAR
      // =====================================
      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}
