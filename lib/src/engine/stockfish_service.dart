// =========================
// lib/src/engine/stockfish_service.dart (stub)
// =========================
import 'engine_backend.dart';
import 'engine_backend_stub.dart'
  if (dart.library.html) 'engine_backend_web.dart'
  if (dart.library.io) 'engine_backend_io.dart' as backend;
import 'package:ajedrez_voz/src/utils/logger.dart';

enum EngineMode { auto, stockfishOnly, fallbackOnly }

class StockfishService {
  late final EngineBackend _backend;

  StockfishService({EngineMode mode = EngineMode.auto}) {
    appLog('stockfish service createBackend');
    _backend = backend.createBackend();
    _backend.init();
    // en fallbackOnly desactivamos explícitamente
    if (mode == EngineMode.fallbackOnly) {
      _backend.setEnabled(false);
    }
  }

  Future<void> init() => _backend.init();
  Future<void> setSkillLevel(int skill) => _backend.setSkillLevel(skill);
  Future<String?> engineId() => _backend.engineId();

  Future<String?> bestMove(String fen, {int moveTimeMs = 800}) =>
      _backend.bestMove(fen, moveTimeMs: moveTimeMs);

  Future<void> dispose() => _backend.dispose();
}
