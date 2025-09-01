// =========================
// lib/src/screens/home_screen.dart
// =========================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../settings/localization_service.dart';
import '../settings/settings_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = LocalizationService.t(context);
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(t.homeTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrimaryButton(
                label: t.start,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.chooseColor),
              ),
              const SizedBox(height: 16),
              _PrimaryButton(
                label: t.settings,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: 16),
              _PrimaryButton(
                label: t.exit,
                onPressed: () => _confirmExit(context),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${t.language}: ${settings.locale.languageCode.toUpperCase()}'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsLanguage),
                    child: Text(t.change),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) async {
    final t = LocalizationService.t(context);
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.exit),
        content: Text(t.exitConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.exit)),
        ],
      ),
    );
    if (shouldClose == true) {
      // En dispositivos móviles, cierra la app (SystemNavigator.pop o similar)
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
