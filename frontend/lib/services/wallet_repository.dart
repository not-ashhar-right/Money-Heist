import 'api_client.dart';
import 'auth_repository.dart';

class WalletRepository {
  final ApiClient _apiClient = ApiClient();
  final AuthRepository _authRepo = AuthRepository();

  Future<WalletData?> getWallet() async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiClient.getWallet(token);
      return WalletData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<WalletData?> deposit(double amount) async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiClient.deposit(token, amount);
      return WalletData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<WalletData?> withdraw(double amount) async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiClient.withdraw(token, amount);
      return WalletData.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiClient.getTransactions(token);
      if (response.isEmpty) return [];
      return response.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PaymentResult?> processPayment(double amount) async {
    try {
      final token = await _authRepo.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiClient.processPayment(token, amount);
      return PaymentResult.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

class WalletData {
  final String id;
  final String userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletData({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PaymentResult {
  final String status;
  final double invested;

  PaymentResult({required this.status, required this.invested});

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      status: json['status'] ?? '',
      invested: (json['invested'] ?? 0).toDouble(),
    );
  }
}

