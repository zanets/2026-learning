import 'package:go_router/go_router.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/topology_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/topology',
      builder: (context, state) => const TopologyScreen(),
    ),
  ],
);
