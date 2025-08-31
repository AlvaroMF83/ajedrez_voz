// Flutter starter for "Ajedrez por Voz" (PWA + Mobile friendly)
// Single-file demo with a main menu and a configuration screen that
// persists settings using SharedPreferences.
//
// ✅ Features implemented
// - Main Menu: Título, Inicio, Configuración, Salir
// - Configuración: Idioma (ES/EN), Engine (Stockfish), Voz (ON/OFF),
//   Dificultad (0–20 skill), Modo de visualización (5 opciones)
// - Guardado de cambios y retorno al menú principal
// - Etiquetas traducidas (ES/EN) con un micro-sistema de i18n local
// - Comportamiento de "Salir": en móvil cierra la app; en web muestra aviso
//
// 📦 Añade estas dependencias en pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   shared_preferences: ^2.2.2
//   google_fonts: ^6.2.1   // opcional para tipografía agradable
//
// Para Flutter Web como PWA, recuerda habilitar la PWA en web/manifest.json
// y usar "flutter build web". Más tarde podrás integrar Stockfish WASM
// y reconocimiento de voz.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceChessApp());
}

// ===== Models =====

enum AppLanguage { es, en }

enum EngineOption { stockfish }

enum VisualizationMode {
  normal,
  sameColorPieces,
  discsDifferentColor,
  discsSameColor,
  invisible,
}

class AppSettings {
  AppLanguage language;
  EngineOption engine;
  bool voiceEnabled;
  int difficulty; // Stockfish Skill Level 0–20
  VisualizationMode visualizationMode;

  AppSettings({
    this.language = AppLanguage.es,
    this.engine = EngineOption.stockfish,
    this.voiceEnabled = true,
    this.difficulty = 10,
    this.visualizationMode = VisualizationMode.normal,
  });

  static const _kLang = 'language';
  static const _kEngine = 'engine';
  static const _kVoice = 'voiceEnabled';
  static const _kDifficulty = 'difficulty';
  static const _kViz = 'visualization';

  Map<String, dynamic> toMap() => {
        _kLang: language.index,
        _kEngine: engine.index,
        _kVoice: voiceEnabled,
        _kDifficulty: difficulty,
        _kViz: visualizationMode.index,
      };

  factory AppSettings.fromPrefs(SharedPreferences p) {
    return AppSettings(
      language: AppLanguage.values[p.getInt(_kLang) ?? AppLanguage.es.index],
      engine: EngineOption.values[p.getInt(_kEngine) ?? EngineOption.stockfish.index],
      voiceEnabled: p.getBool(_kVoice) ?? true,
      difficulty: p.getInt(_kDifficulty) ?? 10,
      visualizationMode: VisualizationMode.values[p.getInt(_kViz) ?? VisualizationMode.normal.index],
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLang, language.index);
    await p.setInt(_kEngine, engine.index);
    await p.setBool(_kVoice, voiceEnabled);
    await p.setInt(_kDifficulty, difficulty);
    await p.setInt(_kViz, visualizationMode.index);
  }
}

// Simple AppState holder with ValueNotifier (sin provider para mantenerlo ligero)
class AppState extends ChangeNotifier {
  AppSettings settings = AppSettings();
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    settings = AppSettings.fromPrefs(p);
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateAndSave(AppSettings newSettings) async {
    settings = newSettings;
    await settings.save();
    notifyListeners();
  }
}

// ===== i18n micro layer =====
class I18n {
  final AppLanguage lang;
  I18n(this.lang);

  static String _t(AppLanguage l, String es, String en) => l == AppLanguage.es ? es : en;

  String get appTitle => _t(lang, 'Ajedrez por Voz', 'Voice Chess');
  String get start => _t(lang, 'Inicio', 'Start');
  String get settings => _t(lang, 'Configuración', 'Settings');
  String get exit => _t(lang, 'Salir', 'Exit');

  String get language => _t(lang, 'Idioma', 'Language');
  String get spanish => _t(lang, 'Español', 'Spanish');
  String get english => _t(lang, 'Inglés', 'English');

  String get engine => _t(lang, 'Motor', 'Engine');
  String get stockfish => 'Stockfish';

  String get voice => _t(lang, 'Comandos por voz', 'Voice commands');
  String get difficulty => _t(lang, 'Dificultad', 'Difficulty');
  String get visualization => _t(lang, 'Modo de visualización', 'Visualization mode');

  String get normal => _t(lang, 'Normal', 'Normal');
  String get sameColorPieces => _t(lang, 'Piezas mismo color', 'Same color pieces');
  String get discsDifferent => _t(lang, 'Discos distinto color', 'Discs – different colors');
  String get discsSame => _t(lang, 'Discos mismo color', 'Discs – same color');
  String get invisible => _t(lang, 'Invisible', 'Invisible');

  String get saveAndBack => _t(lang, 'Guardar y volver', 'Save & back');
  String get comingSoon => _t(lang, 'Próximamente…', 'Coming soon…');
  String get cannotExitWeb => _t(lang, 'En web no se puede cerrar; cierra la pestaña.', 'On web you cannot exit; close the tab.');
}

// ===== App Widget =====
class VoiceChessApp extends StatefulWidget {
  const VoiceChessApp({super.key});

  @override
  State<VoiceChessApp> createState() => _VoiceChessAppState();
}

class _VoiceChessAppState extends State<VoiceChessApp> {
  final appState = AppState();

  @override
  void initState() {
    super.initState();
    appState.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final loaded = appState.isLoaded;
        final i18n = I18n(appState.settings.language);
        return MaterialApp(
          title: i18n.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          home: loaded
              ? MainMenu(
                  state: appState,
                )
              : const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ===== Main Menu =====
class MainMenu extends StatelessWidget {
  final AppState state;
  const MainMenu({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final i18n = I18n(state.settings.language);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.mic, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  i18n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 32),
                _MenuButton(
                  icon: Icons.play_arrow,
                  label: i18n.start,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePlaceholder(state: state),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.settings,
                  label: i18n.settings,
                  onPressed: () async {
                    final updated = await Navigator.push<AppSettings>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(initial: state.settings),
                      ),
                    );
                    if (updated != null) {
                      await state.updateAndSave(updated);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.exit_to_app,
                  label: i18n.exit,
                  onPressed: () {
                    if (kIsWeb) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(i18n.cannotExitWeb)),
                      );
                    } else {
                      try {
                        SystemNavigator.pop();
                      } catch (_) {
                        // Fallback para plataformas donde no aplica
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(i18n.cannotExitWeb)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _MenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}

// ===== Game Placeholder =====
class GamePlaceholder extends StatelessWidget {
  final AppState state;
  const GamePlaceholder({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final i18n = I18n(state.settings.language);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.start)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.chessKnight, size: 80),
            const SizedBox(height: 16),
            Text(i18n.comingSoon),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                // Preview rápido de ajustes activos
                'Lang: ${state.settings.language.name} | Engine: ${state.settings.engine.name}\n'
                'Voz: ${state.settings.voiceEnabled} | Skill: ${state.settings.difficulty}\n'
                'Vista: ${state.settings.visualizationMode.name}',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ===== Settings Screen =====
class SettingsScreen extends StatefulWidget {
  final AppSettings initial;
  const SettingsScreen({super.key, required this.initial});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _working;

  @override
  void initState() {
    super.initState();
    _working = AppSettings(
      language: widget.initial.language,
      engine: widget.initial.engine,
      voiceEnabled: widget.initial.voiceEnabled,
      difficulty: widget.initial.difficulty,
      visualizationMode: widget.initial.visualizationMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n(_working.language);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: i18n.language, child: _languagePicker(i18n)),
          const SizedBox(height: 12),
          _Section(title: i18n.engine, child: _enginePicker(i18n)),
          const SizedBox(height: 12),
          _Section(title: i18n.voice, child: _voiceSwitch(i18n)),
          const SizedBox(height: 12),
          _Section(title: i18n.difficulty, child: _difficultyPicker(i18n)),
          const SizedBox(height: 12),
          _Section(title: i18n.visualization, child: _visualizationPicker(i18n)),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () async {
                // Guardar y volver
                Navigator.pop(context, _working);
              },
              icon: const Icon(Icons.save),
              label: Text(i18n.saveAndBack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languagePicker(I18n i18n) {
    return DropdownButtonFormField<AppLanguage>(
      value: _working.language,
      items: [
        DropdownMenuItem(value: AppLanguage.es, child: Text(i18n.spanish)),
        DropdownMenuItem(value: AppLanguage.en, child: Text(i18n.english)),
      ],
      onChanged: (v) => setState(() => _working.language = v ?? AppLanguage.es),
    );
  }

  Widget _enginePicker(I18n i18n) {
    return DropdownButtonFormField<EngineOption>(
      value: _working.engine,
      items: [
        DropdownMenuItem(value: EngineOption.stockfish, child: Text(i18n.stockfish)),
      ],
      onChanged: (v) => setState(() => _working.engine = v ?? EngineOption.stockfish),
    );
  }

  Widget _voiceSwitch(I18n i18n) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(i18n.voice),
      value: _working.voiceEnabled,
      onChanged: (v) => setState(() => _working.voiceEnabled = v),
    );
  }

  Widget _difficultyPicker(I18n i18n) {
    // Stockfish "Skill Level" va de 0 a 20; lo modelamos con Slider de enteros
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          min: 0,
          max: 20,
          divisions: 20,
          value: _working.difficulty.toDouble(),
          label: _working.difficulty.toString(),
          onChanged: (v) => setState(() => _working.difficulty = v.round()),
        ),
        Text('${i18n.difficulty}: ${_working.difficulty}')
      ],
    );
  }

  Widget _visualizationPicker(I18n i18n) {
    return DropdownButtonFormField<VisualizationMode>(
      value: _working.visualizationMode,
      items: [
        DropdownMenuItem(value: VisualizationMode.normal, child: Text(i18n.normal)),
        DropdownMenuItem(value: VisualizationMode.sameColorPieces, child: Text(i18n.sameColorPieces)),
        DropdownMenuItem(value: VisualizationMode.discsDifferentColor, child: Text(i18n.discsDifferent)),
        DropdownMenuItem(value: VisualizationMode.discsSameColor, child: Text(i18n.discsSame)),
        DropdownMenuItem(value: VisualizationMode.invisible, child: Text(i18n.invisible)),
      ],
      onChanged: (v) => setState(() => _working.visualizationMode = v ?? VisualizationMode.normal),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
