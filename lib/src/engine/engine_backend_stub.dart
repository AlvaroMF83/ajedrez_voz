import 'engine_backend.dart';

class StubBackend implements EngineBackend {
  bool _enabled = true;

  @override Future<void> init() async {}
  @override Future<String?> bestMove(String fen, {int moveTimeMs = 800}) async => null;
  @override Future<void> dispose() async {}

  @override Future<void> setSkillLevel(int skill) async {}
  @override Future<void> setEnabled(bool enabled) async { _enabled = enabled; }
  @override Future<String?> engineId() async => _enabled ? 'Fallback (sin motor)' : null;
}

EngineBackend createBackend() => StubBackend();