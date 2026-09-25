/// Standard typed exceptions for network and API layers
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Tidak dapat terhubung ke server'])
      : super(code: 'NETWORK_ERROR');
}

class AppTimeoutException extends AppException {
  const AppTimeoutException([super.message = 'Koneksi ke server melebihi batas waktu (timeout)'])
      : super(code: 'TIMEOUT');
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.statusCode});
}

class ValidationException extends AppException {
  final Map<String, dynamic>? details;

  const ValidationException(super.message, {this.details, super.code = 'VALIDATION_ERROR'});
}
