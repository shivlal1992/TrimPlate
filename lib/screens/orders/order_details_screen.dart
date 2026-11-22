
import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'order_tracking_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF7F9F7);

  late Future<OrderModel> orderFuture;

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  // =====================================
  // LOAD ORDER DETAILS
  // =====================================
  void loadOrder() {
    orderFuture =
        OrderService.getOrderDetails(widget.orderId);
  }

  // =====================================
  // REFRESH ORDER DETAILS
  // =====================================
  Future<void> refreshOrder() async {
    final future =
    OrderService.getOrderDetails(widget.orderId);

    setState(() {
      orderFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  // =====================================
  // OPEN ORDER TRACKING
  // =====================================
  Future<void> openTracking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(
          orderId: widget.orderId,
        ),
      ),
    );

    if (!mounted) return;

    await refreshOrder();
  }

  // =====================================
  // DETAIL ROW
  // =====================================
  Widget detailRow(
      String title,
      String value, {
        bool bold = false,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: bold ? 17 : 15,
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: bold ? 18 : 15,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // ORDER STATUS COLOR
  // =====================================
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
        return green;

      case 'confirmed':
      case 'preparing':
      case 'out_for_delivery':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
      case 'failed':
        return Colors.red;

      case 'pending':
      case 'unpaid':
        return Colors.orange.shade800;

      default:
        return Colors.grey;
    }
  }

  // =====================================
  // FORMAT STATUS
  // =====================================
  String formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .toUpperCase();
  }

  // =====================================
  // SECTION TITLE
  // =====================================
  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // =====================================
  // ORDER SUMMARY CARD
  // =====================================
  Widget buildOrderSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            Icons.receipt_long,
            size: 65,
            color: green,
          ),

          const SizedBox(height: 15),

          Text(
            order.orderNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          const Divider(),

          detailRow(
            'Order Status',
            formatStatus(order.status),
            valueColor: statusColor(order.status),
          ),

          detailRow(
            'Payment Method',
            order.paymentMethod.toUpperCase(),
          ),

          detailRow(
            'Payment Status',
            formatStatus(order.paymentStatus),
            valueColor:
            statusColor(order.paymentStatus),
          ),

          const SizedBox(height: 18),

          // =====================================
          // TRACK ORDER BUTTON
          // =====================================
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: openTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.local_shipping_outlined,
              ),
              label: const Text(
                'Track Order',
                style: TextStyle(
                  fontSize: 17,
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
  // DELIVERY DETAILS CARD
  // =====================================
  Widget buildDeliveryDetails(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          sectionTitle('Delivery Details'),

          const SizedBox(height: 12),

          detailRow(
            'Name',
            order.customerName,
          ),

          detailRow(
            'Mobile',
            order.phone,
          ),

          detailRow(
            'Address',
            order.deliveryAddress,
          ),

          detailRow(
            'Pincode',
            order.pincode,
          ),
        ],
      ),
    );
  }

  // =====================================
  // ORDERED ITEMS CARD
  // =====================================
  Widget buildOrderedItems(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          sectionTitle('Ordered Items'),

          const SizedBox(height: 12),

          if (order.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Center(
                child: Text(
                  'No items available',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...order.items.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name}  x ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '₹${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================
  // PRICE SUMMARY CARD
  // =====================================
  Widget buildPriceSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          sectionTitle('Price Summary'),

          const SizedBox(height: 12),

          detailRow(
            'Subtotal',
            '₹${order.subtotal.toStringAsFixed(2)}',
          ),

          detailRow(
            'Delivery Charge',
            '₹${order.deliveryCharge.toStringAsFixed(2)}',
          ),

          const Divider(height: 25),

          detailRow(
            'Total Amount',
            '₹${order.totalAmount.toStringAsFixed(2)}',
            bold: true,
            valueColor: green,
          ),
        ],
      ),
    );
  }

  // =====================================
  // ERROR SCREEN
  // =====================================
  Widget buildErrorScreen(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            Text(
              'Failed to load order details\n$error',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: refreshOrder,
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
  // BUILD SCREEN
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
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh Order',
            onPressed: refreshOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // =====================================
      // BODY
      // =====================================
      body: FutureBuilder<OrderModel>(
        future: orderFuture,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return buildErrorScreen(
              snapshot.error!,
            );
          }

          // NO DATA
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Order details not available',
              ),
            );
          }

          final order = snapshot.data!;

          return RefreshIndicator(
            color: green,
            onRefresh: refreshOrder,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ORDER SUMMARY
                buildOrderSummary(order),

                const SizedBox(height: 16),

                // DELIVERY DETAILS
                buildDeliveryDetails(order),

                const SizedBox(height: 16),

                // ORDERED ITEMS
                buildOrderedItems(order),

                const SizedBox(height: 16),

                // PRICE SUMMARY
                buildPriceSummary(order),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),

      // =====================================
      // COMMON BOTTOM NAVIGATION BAR
      // =====================================
      bottomNavigationBar: const AppBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
