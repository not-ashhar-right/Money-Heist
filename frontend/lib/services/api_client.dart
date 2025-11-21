import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get baseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001';
    } catch (e) {
      // If dotenv is not loaded, use default
      return 'http://localhost:5001';
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('API Request: $method $uri'); // Debug
    print('Body: $body'); // Debug
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        final decoded = jsonDecode(response.body);
        // Handle array responses (like transactions list)
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessage = errorBody['error'] is String
            ? errorBody['error']
            : errorBody['error']?.toString() ?? 'Request failed with status ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> signup(String email, String password) async {
    return await _request('POST', '/api/auth/signup', body: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _request('POST', '/api/auth/login', body: {
      'email': email,
      'password': password,
    });
  }

  // Wallet endpoints
  Future<Map<String, dynamic>> getWallet(String token) async {
    return await _request('GET', '/api/wallet', token: token);
  }

  Future<Map<String, dynamic>> deposit(String token, double amount) async {
    return await _request('POST', '/api/wallet/deposit',
        body: {'amount': amount}, token: token);
  }

  Future<Map<String, dynamic>> withdraw(String token, double amount) async {
    return await _request('POST', '/api/wallet/withdraw',
        body: {'amount': amount}, token: token);
  }

  // Transaction endpoints
  Future<List<dynamic>> getTransactions(String token) async {
    final response = await _request('GET', '/api/transactions', token: token);
    return (response['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> processPayment(
      String token, double amount) async {
    return await _request('POST', '/api/transactions/process-payment',
        body: {'amount': amount}, token: token);
  }
}

