
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/auth_storage.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState
    extends State<OrderTrackingScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF7F9F7);

  static const List<String> statuses = [
    'Order Placed',
    'Order Confirmed',
    'Preparing Food',
    'Out for Delivery',
    'Delivered',
  ];

  static const List<IconData> icons = [
    Icons.receipt_long,
    Icons.check_circle,
    Icons.restaurant,
    Icons.delivery_dining,
    Icons.home,
  ];

  bool loading = true;
  String? error;

  String orderNumber = '';
  String status = 'pending';
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    loadTracking();
  }

  // =====================================
  // LOAD ORDER TRACKING FROM LARAVEL API
  // =====================================
  Future<void> loadTracking() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again');
      }

      final response = await http
          .get(
        Uri.parse(
          '${ApiConfig.baseUrl}/orders/${widget.orderId}/track',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(
        const Duration(seconds: 20),
      );

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      if (response.statusCode != 200 ||
          decoded['success'] != true) {
        throw Exception(
          decoded['message'] ??
              'Unable to track order',
        );
      }

      final rawData = decoded['data'];

      if (rawData is! Map) {
        throw Exception(
          'Invalid order tracking data',
        );
      }

      final data = Map<String, dynamic>.from(rawData);

      final rawStep = data['current_step'];
      final parsedStep = rawStep is num
          ? rawStep.toInt()
          : int.tryParse('$rawStep') ?? -1;

      if (!mounted) return;

      setState(() {
        orderNumber =
            (data['order_number'] ?? '').toString();

        status = (data['status'] ?? 'pending')
            .toString()
            .toLowerCase()
            .trim();

        currentStep = parsedStep.clamp(
          -1,
          statuses.length - 1,
        ).toInt();

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
  // FORMAT STATUS
  // =====================================
  String formatStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .toUpperCase();
  }

  // =====================================
  // STATUS COLOR
  // =====================================
  Color getStatusColor() {
    switch (status) {
      case 'delivered':
        return green;

      case 'confirmed':
      case 'preparing':
      case 'out_for_delivery':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
      case 'failed':
        return Colors.red;

      default:
        return Colors.orange.shade800;
    }
  }

  // =====================================
  // TRACKING STEP
  // =====================================
  Widget buildTrackingStep(int index) {
    final completed = index <= currentStep;
    final isCurrent = index == currentStep;
    final isLast = index == statuses.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: completed
                  ? green
                  : Colors.grey.shade300,
              child: Icon(
                icons[index],
                color: completed
                    ? Colors.white
                    : Colors.grey.shade600,
                size: 23,
              ),
            ),

            if (!isLast)
              Container(
                width: 3,
                height: 58,
                color: index < currentStep
                    ? green
                    : Colors.grey.shade300,
              ),
          ],
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  statuses[index],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: completed
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: completed
                        ? green
                        : Colors.grey.shade600,
                  ),
                ),

                if (isCurrent)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      'Current Status',
                      style: TextStyle(
                        color: green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =====================================
  // TRACKING TIMELINE
  // =====================================
  Widget buildTrackingTimeline() {
    if (currentStep < 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 35,
            ),

            const SizedBox(height: 10),

            Text(
              'Order Status: ${formatStatus(status)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This order is not in the normal '
                  'delivery tracking sequence.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8E3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Progress',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          ...List.generate(
            statuses.length,
            buildTrackingStep,
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
              error ?? 'Unable to track order',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadTracking,
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
  // TRACKING CONTENT
  // =====================================
  Widget buildTrackingContent() {
    return RefreshIndicator(
      color: green,
      onRefresh: loadTracking,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ORDER HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8E3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_shipping,
                  color: green,
                  size: 75,
                ),

                const SizedBox(height: 15),

                Text(
                  orderNumber.isEmpty
                      ? 'Order #${widget.orderId}'
                      : orderNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor()
                        .withValues(alpha: 0.12),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatStatus(status),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TRACKING TIMELINE
          buildTrackingTimeline(),

          const SizedBox(height: 25),

          // REFRESH STATUS BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: loadTracking,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Refresh Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
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
          'Track Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        actions: [
          IconButton(
            tooltip: 'Refresh Tracking',
            onPressed: loading ? null : loadTracking,
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
          : error != null
          ? buildErrorScreen()
          : buildTrackingContent(),

      // =====================================
      // COMMON BOTTOM NAVIGATION BAR
      // =====================================
      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
