// =========================
// lib/src/screens/settings_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_controller.dart';
import '../settings/localization_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = LocalizationService.t(context);
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(t.voiceInput),
            subtitle: Text(t.voiceInputDesc),
            value: settings.voiceEnabled,
            onChanged: (v) => settings.setVoiceEnabled(v),
          ),
          ListTile(
            title: Text(t.visualDifficulty),
            subtitle: Text(settings.visualModeLabel(t)),
            onTap: () => _pickVisualMode(context),
          ),
          ListTile(
            title: Text(t.language),
            subtitle: Text(settings.locale.languageCode.toUpperCase()),
            onTap: () => Navigator.pushNamed(context, '/settings/language'),
          ),
          SwitchListTile(
            title: Text(t.darkMode),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (v) => settings.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVisualMode(BuildContext context) async {
    final settings = context.read<SettingsController>();
    final t = LocalizationService.t(context);
    final result = await showModalBottomSheet<VisualMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(t.visualNormal), onTap: () => Navigator.pop(ctx, VisualMode.normal)),
            ListTile(title: Text(t.visualSameColorPieces), onTap: () => Navigator.pop(ctx, VisualMode.sameColorPieces)),
            ListTile(title: Text(t.visualColoredDiscs), onTap: () => Navigator.pop(ctx, VisualMode.coloredDiscs)),
            ListTile(title: Text(t.visualMonochromeDiscs), onTap: () => Navigator.pop(ctx, VisualMode.monochromeDiscs)),
            ListTile(title: Text(t.visualNoPieces), onTap: () => Navigator.pop(ctx, VisualMode.noPieces)),
          ],
        ),
      ),
    );
    if (result != null) settings.setVisualMode(result);
  }
}