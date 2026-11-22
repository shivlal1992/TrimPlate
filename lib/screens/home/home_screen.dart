
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/special_menu_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../auth/welcome_screen.dart';
import '../menu/all_menu_screen.dart';
import '../menu/special_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const green = Color(0xFF008747);

  late Future<List<Map<String, dynamic>>> menusFuture;

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    menusFuture = SpecialMenuService.getMenus();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllMenuScreen(),
      ),
    );
  }

  void openSpecial(String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialMenuScreen(slug: slug),
      ),
    );
  }

  Future<void> logout() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData iconFor(String slug) {
    switch (slug.toLowerCase()) {
      case 'diet':
        return Icons.eco;
      case 'gym':
        return Icons.fitness_center;
      case 'sugar':
        return Icons.water_drop;
      case 'tiffin':
        return Icons.lunch_dining;
      default:
        return Icons.restaurant_menu;
    }
  }

  Widget tile(
      String title,
      IconData icon,
      VoidCallback onTap, {
        String? imageUrl,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5F3E8),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  imageUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    color: green,
                    size: 32,
                  ),
                ),
              )
            else
              Icon(
                icon,
                color: green,
                size: 32,
              ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          searchQuery = value.trim().toLowerCase();
        });
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search meals, diet, gym...',
        prefixIcon: const Icon(
          Icons.search,
          color: green,
        ),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController.clear();
            setState(() {
              searchQuery = '';
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: green,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget buildCategories() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: menusFuture,
      builder: (context, snapshot) {
        final menus = snapshot.data ?? [];

        final filteredMenus = menus.where((menu) {
          if (searchQuery.isEmpty) return true;

          final name =
          (menu['name'] ?? '').toString().toLowerCase();
          final slug =
          (menu['slug'] ?? '').toString().toLowerCase();
          final heading =
          (menu['heading'] ?? '').toString().toLowerCase();
          final description =
          (menu['description'] ?? '').toString().toLowerCase();

          return name.contains(searchQuery) ||
              slug.contains(searchQuery) ||
              heading.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();

        final showAllMenu = searchQuery.isEmpty ||
            'all menu'.contains(searchQuery);

        final count =
            filteredMenus.length + (showAllMenu ? 1 : 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snapshot.connectionState !=
                ConnectionState.done)
              const LinearProgressIndicator(color: green),

            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Unable to load categories: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (snapshot.connectionState ==
                ConnectionState.done &&
                !snapshot.hasError &&
                count == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No matching menu found.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                if (showAllMenu && index == 0) {
                  return tile(
                    'All Menu',
                    Icons.restaurant_menu,
                    openMenu,
                  );
                }

                final menuIndex =
                showAllMenu ? index - 1 : index;

                final menu = filteredMenus[menuIndex];

                final slug =
                (menu['slug'] ?? '').toString();

                return tile(
                  (menu['name'] ?? '').toString(),
                  iconFor(slug),
                      () => openSpecial(slug),
                  imageUrl: menu['image_url']?.toString(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> refreshMenus() async {
    final updatedFuture = SpecialMenuService.getMenus();

    setState(() {
      menusFuture = updatedFuture;
    });

    try {
      await updatedFuture;
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TrimPlate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshMenus,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Good Morning!',
              style: TextStyle(
                fontSize: 16,
                color: green,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Eat Healthy, Stay Fit.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Working search input
            buildSearchField(),

            const SizedBox(height: 25),
            const Text(
              'Choose Your Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Filtered categories
            buildCategories(),
          ],
        ),
      ),
      bottomNavigationBar:
      const AppBottomNavBar(selectedIndex: 0),
    );
  }
}
