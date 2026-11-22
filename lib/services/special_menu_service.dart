import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class SpecialMenuService {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<List<Map<String, dynamic>>> getMenus() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/special-menus'),
      headers: {'Accept': 'application/json'},
    ).timeout(_timeout);

    final result = _decode(response);
    final data = result['data'];

    if (data is! List) {
      throw Exception('Invalid special menus response');
    }

    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<Map<String, dynamic>> getMenu(String slug) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/special-menus/${Uri.encodeComponent(slug)}',
      ),
      headers: {'Accept': 'application/json'},
    ).timeout(_timeout);

    final result = _decode(response);
    final data = result['data'];

    if (data is! Map) {
      throw Exception('Invalid special menu response');
    }

    return Map<String, dynamic>.from(data);
  }

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
      throw Exception(
        decoded['message']?.toString() ??
            'Request failed (${response.statusCode})',
      );
    }

    return decoded;
  }
}