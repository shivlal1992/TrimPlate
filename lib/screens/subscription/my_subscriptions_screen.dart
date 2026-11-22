
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class MySubscriptionsScreen extends StatefulWidget {
  const MySubscriptionsScreen({super.key});

  @override
  State<MySubscriptionsScreen> createState() =>
      _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState
    extends State<MySubscriptionsScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF7F9F7);

  List<Map<String, dynamic>> subscriptions = [];

  bool loading = true;
  String error = '';
  String selectedFilter = 'Active';

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  // =====================================
  // LOAD SUBSCRIPTIONS
  // =====================================
  Future<void> loadSubscriptions() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await ApiService.getSubscriptions();

      if (!mounted) return;

      setState(() {
        subscriptions = result;
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
  // SUBSCRIPTION STATUS
  // =====================================
  String getStatus(
      Map<String, dynamic> subscription,
      ) {
    return (subscription['status'] ?? 'pending')
        .toString()
        .toLowerCase()
        .trim();
  }

  // =====================================
  // FILTER SUBSCRIPTIONS
  // =====================================
  bool matchesFilter(
      Map<String, dynamic> subscription,
      ) {
    final status = getStatus(subscription);

    switch (selectedFilter) {
      case 'Active':
        return ['active', 'pending'].contains(status);

      case 'Past':
        return ['completed', 'expired'].contains(status);

      case 'Cancelled':
        return ['cancelled', 'canceled'].contains(status);

      default:
        return false;
    }
  }

  // =====================================
  // FORMAT DATE
  // =====================================
  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  // =====================================
  // FORMAT MONEY
  // =====================================
  String money(dynamic value) {
    final amount = double.tryParse('$value') ?? 0;

    return '₹${amount.toStringAsFixed(2)}';
  }

  // =====================================
  // GET PLAN
  // =====================================
  Map<String, dynamic> getPlan(
      Map<String, dynamic> subscription,
      ) {
    final raw = subscription['plan'] ??
        subscription['subscription_plan'];

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return {};
  }

  // =====================================
  // PLAN NAME
  // =====================================
  String planName(
      Map<String, dynamic> subscription,
      ) {
    final plan = getPlan(subscription);

    return (plan['name'] ??
        plan['title'] ??
        subscription['plan_name'] ??
        'Subscription Plan')
        .toString();
  }

  // =====================================
  // PLAN DURATION
  // =====================================
  int planDays(
      Map<String, dynamic> subscription,
      ) {
    final plan = getPlan(subscription);

    return int.tryParse(
      '${plan['duration_days'] ?? plan['days'] ?? subscription['duration_days'] ?? 0}',
    ) ??
        0;
  }

  // =====================================
  // SUBSCRIPTION AMOUNT
  // =====================================
  double subscriptionAmount(
      Map<String, dynamic> subscription,
      ) {
    final amount = subscription['total_amount'] ??
        subscription['total'] ??
        subscription['amount'];

    if (amount != null) {
      return double.tryParse('$amount') ?? 0;
    }

    final plan = getPlan(subscription);

    final price =
        double.tryParse('${plan['price'] ?? 0}') ?? 0;

    final persons = int.tryParse(
      '${subscription['persons'] ?? subscription['quantity'] ?? 1}',
    ) ??
        1;

    return price * persons;
  }

  // =====================================
  // STATUS COLOR
  // =====================================
  Color statusColor(String status) {
    switch (status) {
      case 'active':
        return green;

      case 'pending':
        return const Color(0xFFF39C12);

      case 'completed':
      case 'expired':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =====================================
  // DETAIL ROW
  // =====================================
  Widget detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // SUBSCRIPTION CARD
  // =====================================
  Widget subscriptionCard(
      Map<String, dynamic> subscription,
      ) {
    final status = getStatus(subscription);
    final days = planDays(subscription);

    final persons = subscription['persons'] ??
        subscription['quantity'] ??
        1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE2E8E3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F3E8),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: green,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  planName(subscription),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status)
                      .withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),

          detailRow(
            'Subscription ID',
            '#${subscription['id'] ?? '-'}',
          ),

          detailRow(
            'Menu Type',
            (subscription['menu_type'] ?? '-')
                .toString()
                .replaceAll('_', ' ')
                .toUpperCase(),
          ),

          if (days > 0)
            detailRow(
              'Duration',
              '$days Days',
            ),

          detailRow(
            'Persons',
            '$persons',
          ),

          detailRow(
            'Start Date',
            formatDate(subscription['start_date']),
          ),

          detailRow(
            'End Date',
            formatDate(subscription['end_date']),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                money(
                  subscriptionAmount(subscription),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================
  // FILTER BUTTON
  // =====================================
  Widget filterButton(String filter) {
    final selected = selectedFilter == filter;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedFilter = filter;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? green : Colors.white,
              borderRadius:
              BorderRadius.circular(30),
            ),
            child: Text(
              filter,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // EMPTY STATE
  // =====================================
  Widget emptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'No ${selectedFilter.toLowerCase()} subscriptions',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
              size: 50,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            Text(
              error,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: loadSubscriptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // MAIN SCREEN
  // =====================================
  @override
  Widget build(BuildContext context) {
    final filtered = subscriptions
        .where(matchesFilter)
        .toList();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'My Subscriptions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        actions: [
          IconButton(
            tooltip: 'Refresh subscriptions',
            onPressed:
            loading ? null : loadSubscriptions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // =====================================
      // BODY
      // =====================================
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                filterButton('Active'),
                filterButton('Past'),
                filterButton('Cancelled'),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            )
                : error.isNotEmpty
                ? errorState()
                : RefreshIndicator(
              color: green,
              onRefresh: loadSubscriptions,
              child: filtered.isEmpty
                  ? emptyState()
                  : ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.all(16),
                itemCount:
                filtered.length,
                itemBuilder:
                    (context, index) {
                  return subscriptionCard(
                    filtered[index],
                  );
                },
              ),
            ),
          ),
        ],
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
