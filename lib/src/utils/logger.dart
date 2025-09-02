// lib/src/utils/logger.dart
import 'dart:collection';

class AppLogger {
  static final AppLogger I = AppLogger._();
  AppLogger._();

  final _buffer = ListQueue<String>();
  final int _max = 500;
  final _listeners = <void Function()>[];

  void log(String msg) {
    final line = '${DateTime.now().toIso8601String()}  $msg';
    if (_buffer.length >= _max) _buffer.removeFirst(); // <-- sin capacity
    _buffer.add(line);
    for (final fn in _listeners) fn();
  }

  List<String> get lines => List.unmodifiable(_buffer);

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
}

// helpers
void appLog(Object? msg) => AppLogger.I.log(msg.toString());
void appLogDebug(Object? msg) => AppLogger.I.log('[DEBUG] ${msg.toString()}');
