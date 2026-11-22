
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../cart/cart_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  final String menuType;

  const SubscriptionPlansScreen({
    super.key,
    this.menuType = 'diet',
  });

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends State<SubscriptionPlansScreen> {
  static const Color green = Color(0xFF008747);

  static const Color background = Color(0xFFF7F9F7);

  final List<Color> cardColors = const [
    Color(0xFFDCEEFF),
    Color(0xFFD9F4E5),
    Color(0xFFFFEED2),
    Color(0xFFE9DEFA),
  ];

  List<Map<String, dynamic>> plans = [];

  bool loading = true;
  String error = '';

  // =====================================
  // INITIALIZE
  // =====================================
  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  // =====================================
  // LOAD SUBSCRIPTION PLANS FROM API
  // =====================================
  Future<void> loadPlans() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result =
      await ApiService.getSubscriptionPlans();

      if (!mounted) return;

      setState(() {
        plans = result;
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
  // PLAN HELPERS
  // =====================================
  String planName(Map<String, dynamic> plan) {
    return (plan['name'] ??
        plan['title'] ??
        'Subscription Plan')
        .toString();
  }

  int duration(Map<String, dynamic> plan) {
    return int.tryParse(
      '${plan['duration_days'] ?? plan['days'] ?? 0}',
    ) ??
        0;
  }

  double price(Map<String, dynamic> plan) {
    return double.tryParse(
      '${plan['price'] ?? 0}',
    ) ??
        0;
  }

  String get selectedMenuName {
    switch (widget.menuType.toLowerCase()) {
      case 'diet':
        return 'Diet Menu';

      case 'gym':
        return 'Gym Menu';

      case 'sugar':
      case 'sugar_control':
        return 'Sugar Control';

      case 'tiffin':
        return 'Tiffin Menu';

      default:
        return widget.menuType;
    }
  }

  // =====================================
  // OPEN CART SCREEN
  // =====================================
  void selectPlan(Map<String, dynamic> plan) {
    final planId = int.tryParse('${plan['id']}');

    if (planId == null || planId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid subscription plan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedPlan =
    Map<String, dynamic>.from(plan);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          subscriptionPlan: selectedPlan,
          menuType: widget.menuType,
        ),
      ),
    );
  }

  // =====================================
  // PLAN CARD
  // =====================================
  Widget buildPlanCard(
      Map<String, dynamic> plan,
      int index,
      ) {
    final days = duration(plan);
    final amount = price(plan);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColors[index % cardColors.length],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '$days Days',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            planName(plan),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'Per Person',
            style: TextStyle(
              fontSize: 14,
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => selectPlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Select Plan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // SUBSCRIPTION BENEFITS
  // =====================================
  Widget buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.delivery_dining,
              color: green,
            ),
            title: Text(
              'Daily Fresh Delivery',
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.restaurant_menu,
              color: green,
            ),
            title: Text(
              'Custom & Category Wise Menu',
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.pause_circle,
              color: green,
            ),
            title: Text(
              'Pause or Skip Days',
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.payment,
              color: green,
            ),
            title: Text(
              'COD & Online Payment',
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // ERROR SCREEN
  // =====================================
  Widget buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 15),

            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadPlans,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // EMPTY STATE
  // =====================================
  Widget buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 16,
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 65,
            color: Colors.grey,
          ),

          SizedBox(height: 15),

          Text(
            'No subscription plans available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          'Subscription Plans',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: loading ? null : loadPlans,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Plans',
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
          ? buildErrorScreen()
          : RefreshIndicator(
        color: green,
        onRefresh: loadPlans,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Fresh & Healthy Food Delivered Daily',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Selected Menu: $selectedMenuName',
              style: const TextStyle(
                color: green,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // =====================================
            // SUBSCRIPTION PLANS GRID
            // =====================================
            if (plans.isEmpty)
              buildEmptyState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      (constraints.maxWidth - 12) /
                          2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: plans.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent:
                      cardWidth < 180
                          ? 230
                          : 250,
                    ),
                    itemBuilder:
                        (context, index) {
                      return buildPlanCard(
                        plans[index],
                        index,
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 35),

            // =====================================
            // SUBSCRIPTION BENEFITS
            // =====================================
            buildBenefits(),

            const SizedBox(height: 25),
          ],
        ),
      ),

      // =====================================
      // COMMON BOTTOM NAVIGATION BAR
      // =====================================
      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
