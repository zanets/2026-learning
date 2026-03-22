import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'services/hive_service.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: NetworkDiscoverApp(),
    ),
  );
}

class NetworkDiscoverApp extends ConsumerWidget {
  const NetworkDiscoverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Determine locale
    Locale? locale;
    if (settings.localeCode != null) {
      locale = Locale(settings.localeCode!);
    }

    return MaterialApp.router(
      title: dotenv.env['APP_NAME'] ?? 'Network Discover',
      theme: buildAppTheme(),
      routerConfig: appRouter,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
