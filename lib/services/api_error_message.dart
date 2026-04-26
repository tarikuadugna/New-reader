import 'dart:async';
import 'dart:io';

import 'api_exception.dart';

String apiErrorMessage(Object? error) {
  if (error is SocketException) {
    return 'No internet connection. Check your connection and try again.';
  }

  if (error is TimeoutException) {
    return 'Request timed out. Please try again.';
  }

  if (error is ApiException) {
    if (error.statusCode == 0) {
      return error.message;
    }
    return 'Server returned ${error.statusCode}: ${error.message}';
  }

  if (error is FormatException) {
    return 'Unexpected data format received.';
  }

  return 'An unexpected error occurred: ${error ?? 'Unknown error'}';
}
