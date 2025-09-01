// =========================
// lib/src/engine/stockfish_service.dart (stub)
// =========================
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Process, IOSink; // ok: en Web no se usará
import 'package:flutter/foundation.dart' show kIsWeb;

class StockfishService {
  Process? _proc;
  IOSink? _stdin;
  Stream<String>? _lines;
  bool _ready = false;

  Future<void> _ensureStarted() async {
    if (kIsWeb) {
      // En Web no hay procesos nativos: forzamos modo fallback
      _proc = null;
      _stdin = null;
      _lines = null;
      _ready = false;
      return;
    }
    if (_proc != null) return;
    try {
      _proc = await Process.start('stockfish', [], runInShell: true);
      _stdin = _proc!.stdin;
      _lines = _proc!.stdout.transform(utf8.decoder).transform(const LineSplitter());
      _send('uci');
      _send('isready');
      await _waitFor('readyok', timeout: const Duration(seconds: 2));
      _ready = true;
      _send('ucinewgame');
    } catch (_) {
      _proc = null;
      _stdin = null;
      _lines = null;
      _ready = false;
    }
  }

  Future<String?> bestMove(String fen, {int moveTimeMs = 800}) async {
    await _ensureStarted();
    if (!_ready) return null; // en Web o si falla el proceso -> fallback

    _send('position fen $fen');
    _send('go movetime $moveTimeMs');

    try {
      final line = await _waitForPrefix('bestmove ', timeout: Duration(milliseconds: moveTimeMs + 1500));
      if (line == null) return null;
      final parts = line.split(' ');
      if (parts.length >= 2) return parts[1].trim();
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> dispose() async {
    try { _send('quit'); } catch (_) {}
    await _proc?.kill();
  }

  void _send(String cmd) => _stdin?.writeln(cmd);

  Future<String?> _waitFor(String token, {Duration timeout = const Duration(seconds: 2)}) async {
    if (_lines == null) return null;
    try {
      return await _lines!.firstWhere((l) => l.contains(token)).timeout(timeout);
    } on TimeoutException {
      return null;
    }
  }

  Future<String?> _waitForPrefix(String prefix, {required Duration timeout}) async {
    if (_lines == null) return null;
    try {
      return await _lines!.firstWhere((l) => l.startsWith(prefix)).timeout(timeout);
    } on TimeoutException {
      return null;
    }
  }
}
