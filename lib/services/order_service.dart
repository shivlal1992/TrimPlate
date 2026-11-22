
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/order_model.dart';
import 'auth_storage.dart';

class OrderService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': ?token?.letBearer,
    };
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final dynamic data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    if (response.statusCode >= 400) {
      throw Exception(
        data['message']?.toString() ??
            'Request failed: ${response.statusCode}',
      );
    }

    return data;
  }

  static Future<List<OrderModel>> getOrders() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 20));

    final result = _decode(response);
    final dynamic payload = result['data'] ?? result['orders'];

    // Supports a direct list or Laravel paginated response.
    final dynamic list =
    payload is Map ? payload['data'] : payload;

    if (list is! List) {
      throw Exception('Unexpected orders response format');
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  static Future<OrderModel> getOrderDetails(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$id'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 20));

    final result = _decode(response);
    final dynamic data = result['data'] ?? result['order'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid order details response');
    }

    return OrderModel.fromJson(data);
  }
}

extension _BearerToken on String {
  String get letBearer => 'Bearer $this';
}
