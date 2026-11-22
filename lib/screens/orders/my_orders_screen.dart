
import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';

import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() =>
      _MyOrdersScreenState();
}

class _MyOrdersScreenState
    extends State<MyOrdersScreen> {
  static const Color green = Color(0xFF008747);

  late Future<List<OrderModel>> orders;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() {
    orders = OrderService.getOrders();
  }

  Future<void> refreshOrders() async {
    setState(loadOrders);

    try {
      await orders;
    } catch (_) {
      // FutureBuilder displays errors.
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return green;

      case 'cancelled':
        return Colors.red;

      case 'confirmed':
        return Colors.blue;

      case 'preparing':
        return Colors.orange;

      case 'out_for_delivery':
        return Colors.deepPurple;

      default:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
      ),

      body: FutureBuilder<List<OrderModel>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load orders\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          setState(loadOrders),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: refreshOrders,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final order = list[index];
                final color =
                statusColor(order.status);

                return Card(
                  margin:
                  const EdgeInsets.only(bottom: 14),
                  color: const Color(0xFFF1F6F1),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsScreen(
                                orderId: order.id,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderNumber,
                                  style:
                                  const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  order.status
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                  ),
                                ),
                                backgroundColor:
                                color.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            order.createdAt.isEmpty
                                ? 'Date unavailable'
                                : order.createdAt
                                .replaceFirst(
                                'T', ' ')
                                .split('.')
                                .first,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const Divider(height: 24),

                          Row(
                            children: [
                              Text(
                                '₹${order.totalAmount.toStringAsFixed(2)}',
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  color: green,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'View Details',
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
