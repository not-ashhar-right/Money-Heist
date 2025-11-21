import 'package:flutter/foundation.dart';
import '../services/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _walletRepo = WalletRepository();
  WalletData? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  WalletData? get wallet => _wallet;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get balance => _wallet?.balance ?? 0.0;
  double get pendingInvestment {
    return _transactions
        .where((t) => t.type == 'investment')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalInvested {
    return _transactions
        .where((t) => t.type == 'investment')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  int get totalInvestments {
    return _transactions.where((t) => t.type == 'investment').length;
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallet = await _walletRepo.getWallet();
      _transactions = await _walletRepo.getTransactions();
    } catch (e) {
      debugPrint('Error refreshing wallet: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _walletRepo.processPayment(amount);
      if (result != null) {
        await refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deposit(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final wallet = await _walletRepo.deposit(amount);
      if (wallet != null) {
        await refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error depositing: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

