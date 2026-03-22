import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/app_settings.dart';
import '../services/hive_service.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  AppSettings build() {
    final stored = HiveService.settings.get(_key);
    if (stored != null) {
      return AppSettings.fromJson(stored);
    }
    return AppSettings(
      subnet: dotenv.env['DEFAULT_SUBNET'] ?? '192.168.1.0/24',
      nmapPath: dotenv.env['DEFAULT_NMAP_PATH'] ?? '/usr/bin/nmap',
    );
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
