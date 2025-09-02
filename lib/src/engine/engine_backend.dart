abstract class EngineBackend {
  Future<void> init();                                  // prepara el motor
  Future<String?> bestMove(String fen, {int moveTimeMs = 800});
  Future<void> dispose();

  // NUEVO: opciones e identificación
  Future<void> setSkillLevel(int skill) async {}        // 0–20
  Future<void> setEnabled(bool enabled) async {}        // si false → simula no disponible
  Future<String?> engineId() async => null;             // “Stockfish NN…” o null
}