import 'dart:async';
import 'dart:html';
import 'engine_backend.dart';
import 'package:ajedrez_voz/src/utils/logger.dart';

class WebBackend implements EngineBackend {
  late final Worker _worker;
  final _lines = StreamController<String>.broadcast();
  bool _ready = false;
  bool _enabled = true;
  String? _idName;

  @override
  Future<void> init() async {
    appLog('Inicio init web');
    if (!_enabled) return;
    _worker = Worker('engine/stockfish.worker.js');
    _worker.onMessage.listen((e) {
      final data = e.data;
      final type = data['type'];
      final payload = data['payload'];
      if (type == 'ready') {
        _ready = true;
      } else if (type == 'line') {
        final line = payload as String;
        _lines.add(line);
        if (line.startsWith('id name')) _idName = line.substring(8).trim();
      }
    });
    _worker.postMessage({'type': 'load', 'payload': {'url': 'engine/stockfish.js'}});
    await Future.delayed(const Duration(milliseconds: 120));
    // Forzamos uci para capturar “id name”
    await _uciHandshake();
    appLog('Fin init web');
  }

  Future<void> _uciHandshake() async {
    if (!_ready) return;
    _send('uci');
    await _waitFor('uciok', timeout: const Duration(seconds: 3));
    _send('isready');
    await _waitFor('readyok', timeout: const Duration(seconds: 2));
    _send('ucinewgame');
  }

  @override
  Future<String?> bestMove(String fen, {int moveTimeMs = 800}) async {
    appLog('Best Move web $_enabled $_ready');
    if (!_enabled || !_ready) return null;
    appLog('Best Move web 2');
    _send('position fen $fen');
    _send('go movetime $moveTimeMs');
    final line = await _waitForPrefix('bestmove ', timeout: Duration(milliseconds: moveTimeMs + 1500));
    appLog('Best Move web 3 $line');
    if (line == null) return null;
    final parts = line.split(' ');
    return parts.length >= 2 ? parts[1].trim() : null;
  }

  @override
  Future<void> setSkillLevel(int skill) async {
    if (!_enabled || !_ready) return;
    // 0–20 típico en builds WASM
    _send('setoption name Skill Level value $skill');
  }

  @override
  Future<void> setEnabled(bool enabled) async { _enabled = enabled; }

  @override
  Future<String?> engineId() async => _idName;

  void _send(String cmd) => _worker.postMessage({'type': 'cmd', 'payload': cmd});

  Future<String?> _waitFor(String token, {Duration timeout = const Duration(seconds: 2)}) async {
    try { return await _lines.stream.firstWhere((l) => l.contains(token)).timeout(timeout); }
    on TimeoutException { return null; }
  }

  Future<String?> _waitForPrefix(String prefix, {required Duration timeout}) async {
    try { return await _lines.stream.firstWhere((l) => l.startsWith(prefix)).timeout(timeout); }
    on TimeoutException { return null; }
  }

  @override
  Future<void> dispose() async {
    try { _worker.terminate(); } catch (_) {}
    await _lines.close();
  }
}

EngineBackend createBackend() => WebBackend();
