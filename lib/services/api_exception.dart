class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}
