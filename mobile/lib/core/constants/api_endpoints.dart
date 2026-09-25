/// Central API Endpoints and Network Configuration
class ApiEndpoints {
  ApiEndpoints._();

  /// Default production API Gateway URL (Cloudflare Tunnel)
  static const String defaultBaseUrl = 'https://finance.walldev.my.id';

  /// Endpoints
  static const String health = '/api/health';
  static const String transactions = '/api/transactions';
  static const String scanReceipt = '/api/scan-receipt';
  static const String receipts = '/api/receipts';

  /// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 25);
  static const Duration scanTimeout = Duration(seconds: 45);
}
