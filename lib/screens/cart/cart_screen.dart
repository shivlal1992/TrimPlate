
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? subscriptionPlan;
  final String? menuType;

  const CartScreen({
    super.key,
    this.subscriptionPlan,
    this.menuType,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color green = Color(0xFF008747);
  static const Color lightGreen = Color(0xFFE5F3E8);
  static const Color background = Color(0xFFF8FAF8);

  int quantity = 1;
  DateTime startDate = DateTime.now();

  String paymentMethod = 'cod';
  bool placingOrder = false;

  final cart = CartService.instance;

  // =====================================
  // SUBSCRIPTION HELPERS
  // =====================================
  bool get isSubscription =>
      widget.subscriptionPlan != null;

  double get planPrice {
    final value = widget.subscriptionPlan?['price'];

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  double get subtotal {
    if (isSubscription) {
      return planPrice * quantity;
    }

    return cart.subtotal;
  }

  // Display estimates only.
  // Confirm actual charges with backend.
  double get deliveryCharge => 0;
  double get gst => 0;

  double get total =>
      subtotal + deliveryCharge + gst;

  String money(num value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  // =====================================
  // FORMAT START DATE
  // =====================================
  String get formattedDate {
    return '${startDate.day.toString().padLeft(2, '0')}-'
        '${startDate.month.toString().padLeft(2, '0')}-'
        '${startDate.year}';
  }

  String get apiDate {
    return '${startDate.year}-'
        '${startDate.month.toString().padLeft(2, '0')}-'
        '${startDate.day.toString().padLeft(2, '0')}';
  }

  // =====================================
  // SELECT SUBSCRIPTION START DATE
  // =====================================
  Future<void> selectDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final selected = await showDatePicker(
      context: context,
      initialDate:
      startDate.isBefore(today) ? today : startDate,
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 365),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        startDate = selected;
      });
    }
  }

  // =====================================
  // SHOW MESSAGE
  // =====================================
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================
  // PLACE SUBSCRIPTION ORDER
  // =====================================
  Future<void> placeSubscription() async {
    if (placingOrder) return;

    final plan = widget.subscriptionPlan;

    if (plan == null) return;

    final id = int.tryParse(
      plan['id']?.toString() ?? '',
    );

    if (id == null || id <= 0) {
      showMessage('Invalid subscription plan');
      return;
    }

    if (paymentMethod != 'cod') {
      showMessage(
        'Online payment integration is not available yet. '
            'Please select Cash on Delivery.',
      );
      return;
    }

    if (quantity != 1) {
      showMessage(
        'Multiple-person subscriptions require backend '
            'quantity support. Please select one person.',
      );
      return;
    }

    setState(() {
      placingOrder = true;
    });

    try {
      final result =
      await ApiService.createSubscription(
        planId: id,
        menuType: widget.menuType ?? 'diet',
        startDate: apiDate,
      );

      if (!mounted) return;

      if (result['success'] != true) {
        throw Exception(
          result['message'] ??
              'Subscription failed',
        );
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Subscription Created',
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your subscription has been created '
                  'successfully. You can view it in '
                  'My Subscriptions.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) {
        showMessage(
          error.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          placingOrder = false;
        });
      }
    }
  }

  // =====================================
  // PRICE ROW
  // =====================================
  Widget priceRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: bold ? 18 : 15,
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 19 : 15,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: bold
                  ? green
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // SUBSCRIPTION CARD
  // =====================================
  Widget subscriptionCard() {
    final plan = widget.subscriptionPlan!;

    final name =
    (plan['name'] ?? 'Subscription Plan')
        .toString();

    final days =
        plan['duration_days'] ?? plan['days'];

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Items (Subscription)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Menu: ${widget.menuType ?? 'diet'}',
                      ),

                      if (days != null)
                        Text(
                          'Duration: $days Days',
                        ),

                      const SizedBox(height: 8),

                      Text(
                        money(planPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // PERSONS
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Persons',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed: null,
                      icon: const Icon(
                        Icons.remove_circle_outline,
                      ),
                      color: green,
                    ),

                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: null,
                      icon: const Icon(
                        Icons.add_circle_outline,
                      ),
                      color: green,
                    ),
                  ],
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                'Currently available for one person '
                    'per subscription.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

            const Divider(),

            // START DATE
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month,
                color: green,
              ),
              title: const Text(
                'Subscription Start Date',
              ),
              subtitle: Text(formattedDate),
              trailing: TextButton(
                onPressed:
                placingOrder ? null : selectDate,
                child: const Text('Change'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // FOOD CART
  // =====================================
  Widget foodCart() {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 75,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: cart.items.map((item) {
            return Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: green,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.food.name,
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          Text(
                            money(item.food.price),
                          ),

                          Text(
                            money(item.totalPrice),
                            style: const TextStyle(
                              color: green,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        cart.decreaseItem(
                          item.food.id,
                        );
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: green,
                      ),
                    ),

                    Text(
                      '${item.quantity}',
                    ),

                    IconButton(
                      onPressed: () {
                        cart.addItem(
                          item.food,
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // =====================================
  // PAYMENT OPTIONS
  // =====================================
  Widget paymentOptions() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Text(
                'Cash on Delivery',
              ),
              value: 'cod',
              groupValue: paymentMethod,
              activeColor: green,
              onChanged: placingOrder
                  ? null
                  : (value) {
                if (value == null) return;

                setState(() {
                  paymentMethod = value;
                });
              },
            ),

            const RadioListTile<String>(
              title: Text('UPI / QR Code'),
              subtitle: Text('Coming soon'),
              value: 'upi',
              groupValue: 'cod',
              onChanged: null,
            ),

            const RadioListTile<String>(
              title: Text(
                'Debit / Credit Card',
              ),
              subtitle: Text('Coming soon'),
              value: 'card',
              groupValue: 'cod',
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // PRICE SUMMARY
  // =====================================
  Widget summary() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            priceRow(
              'Subtotal',
              money(subtotal),
            ),

            priceRow(
              'Delivery Charge',
              money(deliveryCharge),
            ),

            priceRow(
              'GST',
              money(gst),
            ),

            const Divider(),

            priceRow(
              'Total',
              money(total),
              bold: true,
            ),

            const SizedBox(height: 6),

            const Text(
              'Final charges are confirmed '
                  'during order processing.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // CHECKOUT BUTTON
  // =====================================
  Widget buildCheckoutButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10,
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
            green.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(10),
            ),
          ),
          onPressed: placingOrder
              ? null
              : () {
            if (isSubscription) {
              placeSubscription();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const CheckoutScreen(),
                ),
              );
            }
          },
          child: placingOrder
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Text(
            isSubscription
                ? 'Place Order - ${money(total)}'
                : 'Proceed to Checkout',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
          'Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
        const Color(0xFFEDF4EF),
        elevation: 0,
      ),

      // =====================================
      // BODY
      // =====================================
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final empty =
              !isSubscription && cart.isEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isSubscription)
                subscriptionCard()
              else
                foodCart(),

              if (!empty) ...[
                const SizedBox(height: 12),

                summary(),

                const SizedBox(height: 12),

                if (isSubscription)
                  paymentOptions(),
              ],

              const SizedBox(height: 20),
            ],
          );
        },
      ),

      // =====================================
      // CHECKOUT BUTTON + BOTTOM NAVIGATION
      // =====================================
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final empty =
              !isSubscription && cart.isEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!empty)
                buildCheckoutButton(),

              const AppBottomNavBar(
                selectedIndex: 0,
              ),
            ],
          );
        },
      ),
    );
  }
}
