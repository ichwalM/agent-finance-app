import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/app_exception.dart';
import '../models/transaction_model.dart';
import '../models/receipt_scan_model.dart';

/// Network Client Service for communicating with the Finance REST API Gateway
class ApiService {
  final http.Client _client;
  String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.defaultBaseUrl;

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl.replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// 1. Health Check
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.health}');
      final response = await _client.get(uri).timeout(ApiEndpoints.connectTimeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 2. Get All Transactions
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.transactions}');
      final response = await _client.get(uri, headers: _headers).timeout(ApiEndpoints.receiveTimeout);

      final data = _handleResponse(response);
      if (data is List) {
        return data.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on TimeoutException {
      throw const AppTimeoutException('Gagal mengambil data transaksi: Waktu koneksi habis.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Koneksi terputus: ${e.toString()}');
    }
  }

  /// 3. Create Transaction (POST)
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.transactions}');
      final payload = jsonEncode(transaction.toJson());
      final response = await _client
          .post(uri, headers: _headers, body: payload)
          .timeout(ApiEndpoints.connectTimeout);

      _handleResponse(response);
    } on TimeoutException {
      throw const AppTimeoutException('Gagal menyimpan transaksi: Waktu koneksi habis.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Koneksi terputus: ${e.toString()}');
    }
  }

  /// 4. Update Transaction (PUT)
  Future<void> updateTransaction(int row, TransactionModel transaction) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.transactions}/$row');
      final payload = jsonEncode(transaction.toJson());
      final response = await _client
          .put(uri, headers: _headers, body: payload)
          .timeout(ApiEndpoints.connectTimeout);

      _handleResponse(response);
    } on TimeoutException {
      throw const AppTimeoutException('Gagal memperbarui transaksi: Waktu koneksi habis.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Koneksi terputus: ${e.toString()}');
    }
  }

  /// 5. Delete Transaction (DELETE)
  Future<void> deleteTransaction(int row) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.transactions}/$row');
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(ApiEndpoints.connectTimeout);

      _handleResponse(response);
    } on TimeoutException {
      throw const AppTimeoutException('Gagal menghapus transaksi: Waktu koneksi habis.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Koneksi terputus: ${e.toString()}');
    }
  }

  /// 6. Scan Receipt with AI Vision (Multipart POST)
  Future<ReceiptScanModel> scanReceipt(Uint8List imageBytes, String filename) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.scanReceipt}');
      final request = http.MultipartRequest('POST', uri);

      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? MediaType('image', 'png')
          : ext == 'webp'
              ? MediaType('image', 'webp')
              : MediaType('image', 'jpeg');

      request.files.add(
        http.MultipartFile.fromBytes(
          'receipt',
          imageBytes,
          filename: filename,
          contentType: mimeType,
        ),
      );

      final streamedResponse = await request.send().timeout(ApiEndpoints.scanTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return ReceiptScanModel.fromJson(data);
      }
      throw const ServerException('Format respons scanner tidak valid.');
    } on TimeoutException {
      throw const AppTimeoutException('Proses analisis struk melebihi batas waktu (timeout).');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Gagal mengunggah foto struk: ${e.toString()}');
    }
  }

  /// Standard error & data unpacker
  dynamic _handleResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      throw ServerException(
        'Respons server tidak valid (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (jsonBody is Map<String, dynamic>) {
        return jsonBody['data'] ?? jsonBody;
      }
      return jsonBody;
    }

    // Parse structured backend error response
    String errorMessage = 'Terjadi kesalahan pada server';
    String? errorCode;
    if (jsonBody is Map<String, dynamic> && jsonBody['error'] is Map) {
      final err = jsonBody['error'] as Map<String, dynamic>;
      errorMessage = err['message'] ?? errorMessage;
      errorCode = err['code'];
    }

    if (response.statusCode == 400) {
      throw ValidationException(errorMessage, code: errorCode ?? 'VALIDATION_ERROR');
    } else {
      throw ServerException(
        errorMessage,
        code: errorCode ?? 'SERVER_ERROR',
        statusCode: response.statusCode,
      );
    }
  }
}
