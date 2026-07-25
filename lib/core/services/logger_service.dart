import 'dart:developer' as developer;

/// Logging sederhana. Dipusatkan di satu tempat supaya nanti mudah
/// diganti dengan package logging pihak ketiga tanpa mengubah call site.
class LoggerService {
  LoggerService._();
  static const String _tag = 'ReminderDiaryApp';

  static void info(String message) {
    developer.log(message, name: _tag, level: 800);
  }

  static void warning(String message) {
    developer.log(message, name: _tag, level: 900);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
