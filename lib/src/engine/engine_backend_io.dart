import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'engine_backend.dart';
import 'package:ajedrez_voz/src/utils/logger.dart';

class IoBackend implements EngineBackend {
  Process? _proc;
  IOSink? _stdin;
  Stream<String>? _lines;
  bool _ready = false;
  bool _enabled = true;
  String? _idName;

  @override
  Future<void> init() async {
    if (!_enabled) return;
    try {
      await _start('stockfish');           // PATH
    } catch (_) {
      _ready = false;                      // si no hay binario, bestMove devolverá null
    }
  }

  Future<void> _start(String cmd) async {
    _proc = await Process.start(cmd, [], runInShell: true);
    _stdin = _proc!.stdin;
    _lines = _proc!.stdout.transform(utf8.decoder).transform(const LineSplitter());
    _send('uci');
    // captura “id name …”
    final line = await _waitForPrefix('id name ', timeout: const Duration(seconds: 2));
    if (line != null) _idName = line.substring(8).trim();
    _send('isready');
    await _waitFor('readyok', timeout: const Duration(seconds: 2));
    _send('ucinewgame');
    _ready = true;
  }

  @override
  Future<String?> bestMove(String fen, {int moveTimeMs = 800}) async {
    appLog('Best Move io');
    if (!_enabled || !_ready) return null;
    _send('position fen $fen');
    _send('go movetime $moveTimeMs');
    final line = await _waitForPrefix('bestmove ', timeout: Duration(milliseconds: moveTimeMs + 1500));
    if (line == null) return null;
    final parts = line.split(' ');
    return parts.length >= 2 ? parts[1].trim() : null;
  }

  @override
  Future<void> setSkillLevel(int skill) async {
    if (!_enabled || !_ready) return;
    _send('setoption name Skill Level value $skill');    // 0–20
  }

  @override
  Future<void> setEnabled(bool enabled) async { _enabled = enabled; }

  @override
  Future<String?> engineId() async => _idName;

  void _send(String cmd) => _stdin?.writeln(cmd);

  Future<String?> _waitFor(String token, {Duration timeout = const Duration(seconds: 2)}) async {
    if (_lines == null) return null;
    try { return await _lines!.firstWhere((l) => l.contains(token)).timeout(timeout); }
    on TimeoutException { return null; }
  }
  Future<String?> _waitForPrefix(String prefix, {required Duration timeout}) async {
    if (_lines == null) return null;
    try { return await _lines!.firstWhere((l) => l.startsWith(prefix)).timeout(timeout); }
    on TimeoutException { return null; }
  }

  @override
  Future<void> dispose() async {
    try { _send('quit'); } catch (_) {}
    await _proc?.kill();
  }
}

EngineBackend createBackend() => IoBackend();
