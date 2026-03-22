import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/app_settings.dart';
import '../services/hive_service.dart';

const kNmapCandidates = [
  '/opt/homebrew/bin/nmap', // macOS Apple Silicon (Homebrew)
  '/usr/local/bin/nmap',    // macOS Intel (Homebrew)
  '/usr/bin/nmap',          // Linux (apt/yum)
  '/usr/local/sbin/nmap',   // FreeBSD / some Linux
  '/snap/bin/nmap',         // Linux Snap
];

/// Returns the first nmap path that exists on disk, or falls back to .env / default.
String detectNmapPath() {
  for (final path in kNmapCandidates) {
    if (File(path).existsSync()) return path;
  }
  return dotenv.env['DEFAULT_NMAP_PATH'] ?? kNmapCandidates.last;
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  AppSettings build() {
    final stored = HiveService.settings.get(_key);
    if (stored != null) {
      return AppSettings.fromJson(stored);
    }
    // First launch: auto-detect nmap and persist
    final settings = AppSettings(
      subnet: dotenv.env['DEFAULT_SUBNET'] ?? '192.168.1.0/24',
      nmapPath: detectNmapPath(),
    );
    HiveService.settings.put(_key, settings.toJson());
    return settings;
  }

  Future<void> save(AppSettings settings) async {
    state = settings;
    await HiveService.settings.put(_key, settings.toJson());
  }

  Future<void> updateSubnet(String subnet) => save(state.copyWith(subnet: subnet));
  Future<void> updateNmapPath(String path) => save(state.copyWith(nmapPath: path));
  Future<void> updateLocale(String? code) =>
      save(state.copyWith(localeCode: code, clearLocale: code == null));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
