import 'dart:developer' as dev;

/// Log levels
enum LogLevel {
  none,
  error,
  warning,
  info,
  debug,
}

/// Simple logger for Agora video call kit
///
/// Can be configured globally or per-instance
class AgoraLogger {
  static LogLevel globalLogLevel = LogLevel.error;
  static bool enableConsoleOutput = true;

  final String tag;
  LogLevel? instanceLogLevel;

  AgoraLogger(this.tag);

  LogLevel get effectiveLogLevel => instanceLogLevel ?? globalLogLevel;

  /// Log an error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, error, stackTrace);
    }
  }

  /// Log a warning message
  void warning(String message) {
    if (_shouldLog(LogLevel.warning)) {
      _log('WARN', message);
    }
  }

  /// Log an info message
  void info(String message) {
    if (_shouldLog(LogLevel.info)) {
      _log('INFO', message);
    }
  }

  /// Log a debug message
  void debug(String message) {
    if (_shouldLog(LogLevel.debug)) {
      _log('DEBUG', message);
    }
  }

  bool _shouldLog(LogLevel level) {
    return level.index <= effectiveLogLevel.index;
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final logMessage = '[$tag] $message';

    if (enableConsoleOutput) {
      dev.log(
        logMessage,
        name: tag,
        level: _getLogLevelValue(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  int _getLogLevelValue(String level) {
    switch (level) {
      case 'ERROR':
        return 1000;
      case 'WARN':
        return 900;
      case 'INFO':
        return 800;
      case 'DEBUG':
      default:
        return 500;
    }
  }

  /// Configure global logging
  static void configure({
    LogLevel? logLevel,
    bool? enableConsole,
  }) {
    if (logLevel != null) {
      globalLogLevel = logLevel;
    }
    if (enableConsole != null) {
      enableConsoleOutput = enableConsole;
    }
  }
}
