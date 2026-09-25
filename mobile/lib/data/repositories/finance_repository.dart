import 'dart:typed_data';
import '../models/transaction_model.dart';
import '../models/receipt_scan_model.dart';
import '../services/api_service.dart';

abstract class IFinanceRepository {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(int row, TransactionModel transaction);
  Future<void> deleteTransaction(int row);
  Future<ReceiptScanModel> scanReceipt(Uint8List imageBytes, String filename);
  Future<bool> checkServerHealth();
}

class FinanceRepository implements IFinanceRepository {
  final ApiService _apiService;

  FinanceRepository(this._apiService);

  @override
  Future<List<TransactionModel>> getTransactions() {
    return _apiService.getTransactions();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) {
    return _apiService.createTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(int row, TransactionModel transaction) {
    return _apiService.updateTransaction(row, transaction);
  }

  @override
  Future<void> deleteTransaction(int row) {
    return _apiService.deleteTransaction(row);
  }

  @override
  Future<ReceiptScanModel> scanReceipt(Uint8List imageBytes, String filename) {
    return _apiService.scanReceipt(imageBytes, filename);
  }

  @override
  Future<bool> checkServerHealth() {
    return _apiService.checkHealth();
  }
}
