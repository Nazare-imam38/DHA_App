import 'dart:developer' as developer;

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  
  factory LoggerService() => _instance;
  
  static LoggerService get instance => _instance;
  
  LoggerService._internal();

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'INFO',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'WARNING',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'DEBUG',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
