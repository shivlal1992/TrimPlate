
import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav_bar.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.total,
  });

  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF8FAF8);

  // =====================================
  // BACK TO HOME
  // =====================================
  void backToHome(BuildContext context) {
    Navigator.of(context).popUntil(
          (route) => route.isFirst,
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
          'Order Successful',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF4EF),
        automaticallyImplyLeading: false,
      ),

      // =====================================
      // BODY
      // =====================================
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2E8E3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SUCCESS ICON
                  Container(
                    width: 125,
                    height: 125,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F3E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: green,
                      size: 100,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SUCCESS MESSAGE
                  const Text(
                    'Order Placed Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Thank you for your order! '
                        'Your food order has been received.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ORDER DETAILS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Order Number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SelectableText(
                          orderNumber,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(height: 30),

                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BACK TO HOME BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        backToHome(context);
                      },
                      icon: const Icon(
                        Icons.home_outlined,
                      ),
                      label: const Text(
                        'Back to Home',
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
                ],
              ),
            ),
          ),
        ),
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
