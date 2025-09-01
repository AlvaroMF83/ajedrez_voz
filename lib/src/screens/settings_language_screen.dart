// =========================
// lib/src/screens/settings_language_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_controller.dart';
import '../settings/localization_service.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = LocalizationService.t(context);
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(t.language)),
      body: ListView(
        children: LocalizationService.supportedLocales.map((locale) {
          final selected = settings.locale == locale;
          return RadioListTile<Locale>(
            title: Text(LocalizationService.localeName(locale)),
            value: locale,
            groupValue: settings.locale,
            onChanged: (l) => l != null ? settings.setLocale(l) : null,
            selected: selected,
          );
        }).toList(),
      ),
    );
  }
}
