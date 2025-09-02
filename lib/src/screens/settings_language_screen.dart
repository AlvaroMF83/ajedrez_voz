// =========================
// lib/src/screens/settings_language_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // NECESARIO para context.read()
import 'package:ajedrez_voz/src/settings/settings_controller.dart'; // NECESARIO para SettingsController

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text('language'.tr())),
      body: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Español'),
            value: 'es',
            groupValue: currentLang,
            onChanged: (_) {
              final locale = const Locale('es');
              context.setLocale(locale); // <-- cambia el idioma visible
              context.read<SettingsController>().setLocale(locale); // <-- guarda el idioma en settings
            }
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLang,
            onChanged: (_) {
              final locale = const Locale('en');
              context.setLocale(locale); // <-- cambia el idioma visible
              context.read<SettingsController>().setLocale(locale); // <-- guarda el idioma en settings
            }
          ),
        ],
      ),
    );
  }
}
