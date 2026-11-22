
class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String customerName;
  final String phone;
  final String deliveryAddress;
  final String pincode;
  final String createdAt;
  final double subtotal;
  final double deliveryCharge;
  final double totalAmount;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.customerName,
    required this.phone,
    required this.deliveryAddress,
    required this.pincode,
    required this.createdAt,
    required this.subtotal,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.items,
  });

  static double toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return OrderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentMethod:
      json['payment_method']?.toString() ?? 'cod',
      paymentStatus:
      json['payment_status']?.toString() ?? 'pending',
      customerName:
      json['customer_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      deliveryAddress:
      json['delivery_address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      subtotal: toDouble(json['subtotal']),
      deliveryCharge: toDouble(json['delivery_charge']),
      totalAmount: toDouble(
        json['total_amount'] ?? json['grand_total'],
      ),
      items: rawItems is List
          ? rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList()
          : [],
    );
  }
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;
  final double total;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final quantity =
        int.tryParse(json['quantity'].toString()) ?? 0;

    final price = OrderModel.toDouble(
      json['price'] ?? json['unit_price'],
    );

    return OrderItemModel(
      name: json['food_item'] is Map
          ? json['food_item']['name']?.toString() ?? ''
          : json['name']?.toString() ??
          json['food_name']?.toString() ??
          '',
      quantity: quantity,
      price: price,
      total: OrderModel.toDouble(
        json['total'] ?? json['total_price'] ?? price * quantity,
      ),
    );
  }
}
