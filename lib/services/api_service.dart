
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/food_item.dart';
import 'auth_storage.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  // =====================================
  // SEND OTP
  // =====================================
  static Future<Map<String, dynamic>> sendOtp(
      String phone,
      ) async {
    return _post('/auth/send-otp', {
      'phone': phone,
    });
  }

  // =====================================
  // VERIFY OTP
  // =====================================
  static Future<Map<String, dynamic>> verifyOtp(
      String phone,
      String otp,
      ) async {
    final result = await _post('/auth/verify-otp', {
      'phone': phone,
      'otp': otp,
    });

    if (result['success'] == true &&
        result['token'] is String) {
      await AuthStorage.saveToken(
        result['token'] as String,
      );
    }

    return result;
  }

  // =====================================
  // USER PROFILE
  // =====================================
  static Future<Map<String, dynamic>> profile() async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    ).timeout(_timeout);

    return _decode(response);
  }

  // =====================================
  // LOGOUT
  // =====================================
  static Future<void> logout() async {
    final token = await AuthStorage.getToken();

    try {
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(_timeout);

        _decode(response);
      }
    } finally {
      await AuthStorage.clearToken();
    }
  }

  // =====================================
  // POST REQUEST
  // =====================================
  static Future<Map<String, dynamic>> _post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    ).timeout(_timeout);

    return _decode(response);
  }

  // =====================================
  // DECODE RESPONSE
  // =====================================
  static Map<String, dynamic> _decode(
      http.Response response,
      ) {
    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Invalid server response (${response.statusCode})',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }

    if (response.statusCode >= 400) {
      final errors = decoded['errors'];
      String? validationMessage;

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          validationMessage = firstError.first.toString();
        } else if (firstError != null) {
          validationMessage = firstError.toString();
        }
      }

      throw Exception(
        validationMessage ??
            decoded['message']?.toString() ??
            'Request failed (${response.statusCode})',
      );
    }

    return decoded;
  }

  // =====================================
  // EXTRACT LIST FROM API RESPONSE
  // =====================================
  static List<Map<String, dynamic>> _extractList(
      Map<String, dynamic> result,
      String errorMessage,
      ) {
    final dynamic raw = result['data'];

    final List<dynamic> records;

    if (raw is List) {
      records = raw;
    } else if (raw is Map && raw['data'] is List) {
      records = raw['data'] as List;
    } else {
      throw Exception(errorMessage);
    }

    return records.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // =====================================
  // GET SUBSCRIPTION PLANS
  // =====================================
  static Future<List<Map<String, dynamic>>>
  getSubscriptionPlans() async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/subscription-plans',
      ),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    ).timeout(_timeout);

    final result = _decode(response);

    return _extractList(
      result,
      'Invalid subscription plans response',
    );
  }

  // =====================================
  // CREATE SUBSCRIPTION
  // =====================================
  static Future<Map<String, dynamic>>
  createSubscription({
    required int planId,
    required String menuType,
    required String startDate,
  }) async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in to continue');
    }

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/subscriptions',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subscription_plan_id': planId,
        'menu_type': menuType,
        'start_date': startDate,
      }),
    ).timeout(_timeout);

    return _decode(response);
  }

  // =====================================
  // GET MY SUBSCRIPTIONS
  // =====================================
  static Future<List<Map<String, dynamic>>>
  getSubscriptions() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in to continue');
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/subscriptions',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(_timeout);

    final result = _decode(response);

    return _extractList(
      result,
      'Invalid subscriptions response',
    );
  }

  // =====================================
// UPDATE USER PROFILE
// =====================================
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? email,
  }) async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in to continue');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email?.trim().isEmpty == true
            ? null
            : email?.trim(),
      }),
    ).timeout(_timeout);

    return _decode(response);
  }

  // =====================================
  // GET FOOD ITEMS
  // =====================================
  static Future<List<FoodItem>> getFoodItems({
    String? category,
    String? menuType,
    String? search,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/food-items',
    ).replace(
      queryParameters: {
        if (category != null &&
            category.isNotEmpty &&
            category != 'All')
          'category': category,
        if (menuType != null && menuType.isNotEmpty)
          'menu_type': menuType,
        if (search != null && search.isNotEmpty)
          'search': search,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(_timeout);

    final result = _decode(response);

    final items = _extractList(
      result,
      'Invalid food items response',
    );

    return items.map((item) {
      return FoodItem.fromJson(item);
    }).toList();
  }
}
