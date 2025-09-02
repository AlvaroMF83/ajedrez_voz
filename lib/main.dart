import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'src/routes.dart';
import 'src/settings/settings_state.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/utils/log_console_overlay.dart'; // importa la consola

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('es'),
      startLocale: settingsController.locale, // <-- usar idioma guardado
      child: MyApp(controller: settingsController),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: controller),
        ChangeNotifierProvider<SettingsState>(create: (_) => SettingsState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'homeTitle'.tr(), // <-- también traducido
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,

        // 👇 Aquí inyectamos el overlay
        builder: (context, child) {
          return LogConsoleOverlay(
            child: child ?? const SizedBox.shrink(),
          );
        },
        
      ),
    );
  }
}
