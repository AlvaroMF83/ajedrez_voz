// =========================
// lib/src/screens/settings_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Entrada por voz'),
            subtitle: const Text('Jugar dictando movimientos'),
            value: s.voiceEnabled,
            onChanged: (v) => s.setVoiceEnabled(v),
          ),
          ListTile(
            title: const Text('Dificultad visual'),
            subtitle: Text(s.visualModeLabel(const Strings(
              visualNormal: 'Normal (piezas estándar)',
              visualSameColorPieces: 'Piezas del mismo color',
              visualColoredDiscs: 'Discos de colores',
              visualMonochromeDiscs: 'Discos monocromos',
              visualNoPieces: 'Sin piezas',
            ))),
            onTap: () => _pickVisualMode(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('Motor'),
            subtitle: Text(s.enginePrefLabel()),
            onTap: () => _pickEngine(context),
          ),
          ListTile(
            title: const Text('Dificultad del motor'),
            subtitle: Text('Skill ${s.engineSkill}'),
            onTap: () => _pickSkill(context),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: s.themeMode == ThemeMode.dark,
            onChanged: (v) => s.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVisualMode(BuildContext context) async {
    final s = context.read<SettingsController>();
    final result = await showModalBottomSheet<VisualMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(value: VisualMode.normal, groupValue: s.visualMode, onChanged: (v) => Navigator.pop(ctx, v), title: const Text('Normal (piezas estándar)')),
            RadioListTile(value: VisualMode.sameColorPieces, groupValue: s.visualMode, onChanged: (v) => Navigator.pop(ctx, v), title: const Text('Piezas del mismo color')),
            RadioListTile(value: VisualMode.coloredDiscs, groupValue: s.visualMode, onChanged: (v) => Navigator.pop(ctx, v), title: const Text('Discos de colores')),
            RadioListTile(value: VisualMode.monochromeDiscs, groupValue: s.visualMode, onChanged: (v) => Navigator.pop(ctx, v), title: const Text('Discos monocromos')),
            RadioListTile(value: VisualMode.noPieces, groupValue: s.visualMode, onChanged: (v) => Navigator.pop(ctx, v), title: const Text('Sin piezas')),
          ],
        ),
      ),
    );
    if (result != null) s.setVisualMode(result);
  }

  Future<void> _pickEngine(BuildContext context) async {
    final s = context.read<SettingsController>();
    final sel = await showModalBottomSheet<EnginePref>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: EnginePref.values.map((p) {
            final label = switch (p) {
              EnginePref.auto => 'Auto (Web=WASM, Android/Desktop=nativo)',
              EnginePref.stockfish => 'Stockfish (forzar si disponible)',
              EnginePref.fallback => 'Fallback simple (sin motor)',
            };
            return RadioListTile<EnginePref>(
              title: Text(label),
              value: p,
              groupValue: s.enginePref,
              onChanged: (v) => Navigator.pop(ctx, v),
            );
          }).toList(),
        ),
      ),
    );
    if (sel != null) await s.setEnginePref(sel);
  }

  Future<void> _pickSkill(BuildContext context) async {
    final s = context.read<SettingsController>();
    int temp = s.engineSkill;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dificultad del motor (0–20)'),
        content: StatefulBuilder(
          builder: (_, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: temp.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                label: '$temp',
                onChanged: (v) => setState(() => temp = v.round()),
              ),
              Text('Skill: $temp'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) await s.setEngineSkill(temp);
  }
}
