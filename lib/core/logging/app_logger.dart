import 'dart:developer' as developer;

/// Minimal structured logging wrapper.
///
/// Centralizing logging here (instead of scattering `debugPrint`/`print`
/// calls through the codebase) keeps the door open to later plug in a real
/// crash/log reporting backend without touching call sites.
abstract final class AppLogger {
  static const _name = 'sentinel';

  static void debug(String message) {
    developer.log(message, name: _name, level: 500);
  }

  static void info(String message) {
    developer.log(message, name: _name, level: 800);
  }

  static void warning(String message) {
    developer.log(message, name: _name, level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
