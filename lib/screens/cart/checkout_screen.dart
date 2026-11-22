
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/auth_storage.dart';
import '../../services/cart_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color green = Color(0xFF008747);
  static const Color background = Color(0xFFF8FAF8);

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();

  final cart = CartService.instance;

  bool _loading = false;
  String _paymentMethod = 'cod';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _pincode.dispose();
    super.dispose();
  }

  // =====================================
  // PLACE ORDER THROUGH LARAVEL API
  // =====================================
  Future<void> _placeOrder() async {
    if (_loading || cart.isEmpty) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paymentMethod != 'cod') {
      _showMessage(
        'Only Cash on Delivery is available.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please login again');
      }

      final response = await http
          .post(
        Uri.parse(
          '${ApiConfig.baseUrl}/orders',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer_name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'delivery_address':
          _address.text.trim(),
          'pincode': _pincode.text.trim(),
          'payment_method': _paymentMethod,
          'items': cart.items.map((item) {
            return {
              'food_item_id': item.food.id,
              'quantity': item.quantity,
            };
          }).toList(),
        }),
      )
          .timeout(
        const Duration(seconds: 30),
      );

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw Exception(
          decoded['message'] ??
              'Unable to place order',
        );
      }

      final orderData = decoded['data'];

      if (orderData is! Map) {
        throw Exception(
          'Order details missing',
        );
      }

      final order =
      Map<String, dynamic>.from(orderData);

      final orderNumber =
      (order['order_number'] ?? '').toString();

      final total = double.tryParse(
        (order['total_amount'] ?? '0')
            .toString(),
      ) ??
          0;

      if (orderNumber.isEmpty) {
        throw Exception(
          'Order number missing from server',
        );
      }

      if (!mounted) return;

      // Clear cart only after successful API response.
      cart.clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderNumber: orderNumber,
            total: total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Order failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =====================================
  // SHOW MESSAGE
  // =====================================
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================
  // INPUT FIELD
  // =====================================
  Widget _field(
      TextEditingController controller,
      String label, {
        TextInputType? keyboardType,
        int maxLines = 1,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        enabled: !_loading,
        textCapitalization:
        label == 'Mobile Number' ||
            label == 'Pincode'
            ? TextCapitalization.none
            : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: green,
              width: 1.5,
            ),
          ),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter $label';
          }

          if (label == 'Mobile Number' &&
              !RegExp(r'^[6-9][0-9]{9}$')
                  .hasMatch(text)) {
            return 'Enter a valid 10-digit mobile number';
          }

          if (label == 'Pincode' &&
              !RegExp(r'^[0-9]{6}$')
                  .hasMatch(text)) {
            return 'Enter a valid 6-digit pincode';
          }

          return null;
        },
      ),
    );
  }

  // =====================================
  // SECTION TITLE
  // =====================================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // =====================================
  // DELIVERY DETAILS
  // =====================================
  Widget _deliveryDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8E3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle('Delivery Details'),

          const SizedBox(height: 18),

          _field(
            _name,
            'Full Name',
          ),

          _field(
            _phone,
            'Mobile Number',
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          _field(
            _address,
            'Delivery Address',
            keyboardType:
            TextInputType.streetAddress,
            maxLines: 3,
          ),

          _field(
            _pincode,
            'Pincode',
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }

  // =====================================
  // PAYMENT METHOD
  // =====================================

  Widget _paymentOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8E3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment Method'),

          const SizedBox(height: 15),

          // Cash on Delivery - Selected
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5F3E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: green,
                width: 1.2,
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.radio_button_checked,
                color: green,
              ),
              title: const Text(
                'Cash on Delivery',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Pay when your food arrives',
              ),
              trailing: const Icon(
                Icons.check_circle,
                color: green,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Online Payment - Coming Soon
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.payments_outlined,
              color: Colors.grey,
            ),
            title: Text('Online Payment'),
            subtitle: Text(
              'UPI / Debit Card / Credit Card - Coming soon',
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }

  // =====================================
  // ORDER SUMMARY
  // =====================================
  Widget _orderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8E3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle('Order Summary'),

          const SizedBox(height: 12),

          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...cart.items.map(
                  (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Qty: ${item.quantity}',
                ),
                trailing: Text(
                  '₹${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const Divider(),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Subtotal'),
            trailing: Text(
              '₹${cart.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Delivery Charge'),
            trailing: Text(
              'Calculated by server',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'The final order amount is calculated '
                'by the server after placing your order.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // PLACE ORDER BUTTON
  // =====================================
  Widget _placeOrderButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed:
          _loading || cart.isEmpty
              ? null
              : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
            green.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            'Place Order',
            style: TextStyle(
              fontSize: 18,
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
          'Checkout',
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
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _deliveryDetails(),

                const SizedBox(height: 16),

                _paymentOptions(),

                const SizedBox(height: 16),

                _orderSummary(),

                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),

      // =====================================
      // PLACE ORDER + COMMON BOTTOM NAV
      // =====================================
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _placeOrderButton(),

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
