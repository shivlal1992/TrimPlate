import 'package:flutter/material.dart';
import '../../services/special_menu_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../subscription/subscription_plans_screen.dart';

enum SpecialMenuType { diet, gym, sugar, tiffin }

class SpecialMenuScreen extends StatefulWidget {
  final SpecialMenuType? type;
  final String? slug;
  const SpecialMenuScreen({super.key, this.type, this.slug}) : assert(type != null || slug != null);
  String get menuSlug => slug ?? type!.name;
  @override
  State<SpecialMenuScreen> createState() => _SpecialMenuScreenState();
}

class _SpecialMenuScreenState extends State<SpecialMenuScreen> {
  static const green = Color(0xFF008747);
  late Future<Map<String, dynamic>> future;
  @override
  void initState() { super.initState(); reload(); }
  void reload() { future = SpecialMenuService.getMenu(widget.menuSlug); }
  void refresh() { setState(reload); }
  Color bannerColor(String value) {
    final hex = value.replaceAll('#', '');
    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return Color(int.parse('FF$hex', radix: 16));
    return green;
  }
  IconData iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast': return Icons.breakfast_dining;
      case 'lunch': return Icons.lunch_dining;
      case 'snacks': return Icons.fastfood;
      case 'dinner': return Icons.dinner_dining;
      default: return Icons.restaurant_menu;
    }
  }
  Widget picture(String? url, IconData icon, {double size = 60}) {
    if (url == null || url.isEmpty) return Container(width: size, height: size, decoration: BoxDecoration(color: const Color(0xFFE5F3E8), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: green, size: size * .48));
    return ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: size, height: size, color: const Color(0xFFE5F3E8), child: Icon(icon, color: green))));
  }
  void openSubscription() => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionPlansScreen(menuType: widget.menuSlug)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(title: const Text('Special Menu', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: const Color(0xFFEDF4EF), actions: [IconButton(onPressed: openSubscription, icon: const Icon(Icons.card_membership_outlined))]),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: green));
          if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Unable to load menu: ${snapshot.error}', textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: refresh, child: const Text('Retry'))]));
          final menu = snapshot.data!;
          final meals = (menu['meals'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          final categories = meals.map((m) => (m['category'] ?? '').toString()).where((e) => e.isNotEmpty).toSet().toList();
          return RefreshIndicator(onRefresh: () async { refresh(); await future; }, child: ListView(padding: const EdgeInsets.all(14), children: [
            Container(padding: const EdgeInsets.all(20), constraints: const BoxConstraints(minHeight: 150), decoration: BoxDecoration(color: bannerColor((menu['banner_color'] ?? '#008747').toString()), borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text((menu['heading'] ?? menu['name'] ?? '').toString(), style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)), if ((menu['description'] ?? '').toString().isNotEmpty) ...[const SizedBox(height: 8), Text(menu['description'].toString(), style: const TextStyle(color: Colors.white))]])), const SizedBox(width: 10), picture(menu['image_url']?.toString(), Icons.eco, size: 85)])),
            const SizedBox(height: 15),
            if (categories.isNotEmpty) GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: categories.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 55), itemBuilder: (context, i) => Container(decoration: BoxDecoration(color: const Color(0xFFFFEFD7), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(iconFor(categories[i]), color: const Color(0xFF976500)), const SizedBox(width: 8), Flexible(child: Text(categories[i], overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)))]))),
            const SizedBox(height: 22), Text('${menu['name']} - 1 Day Sample', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: meals.isEmpty ? const Padding(padding: EdgeInsets.all(20), child: Text('No meals have been added yet.')) : Column(children: [for (int i = 0; i < meals.length; i++) ...[ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), leading: picture(meals[i]['image_url']?.toString(), iconFor((meals[i]['category'] ?? '').toString())), title: Text((meals[i]['category'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${meals[i]['name'] ?? ''}\n${meals[i]['description'] ?? ''}'), isThreeLine: true), if (i < meals.length - 1) const Divider(height: 1)]])),
            const SizedBox(height: 20), const Text('Sample meals are for illustration. Actual meals may vary depending on your subscription plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 15),
          ]));
        },
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(14, 10, 14, 10), child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: openSubscription, style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Choose Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))), const AppBottomNavBar(selectedIndex: 0)]),
    );
  }
}
