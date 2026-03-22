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

const _kFallbackSubnet = '192.168.1.0/24';

/// Filled by [initDetectedSubnet] before runApp; used on first launch only.
String _detectedSubnet = _kFallbackSubnet;

/// Returns the first nmap path that exists on disk, or falls back to .env / default.
String detectNmapPath() {
  for (final path in kNmapCandidates) {
    if (File(path).existsSync()) return path;
  }
  return dotenv.env['DEFAULT_NMAP_PATH'] ?? kNmapCandidates.last;
}

/// Detects the local subnet from the macOS default route.
///
/// 1. `route -n get default`  →  interface name (e.g. en0)
/// 2. `ifconfig <iface>`      →  inet + hex netmask
/// 3. Apply mask to IP        →  network address / CIDR
///
/// Falls back to [_kFallbackSubnet] on any failure.
Future<String> detectSubnet() async {
  try {
    // Step 1 – find default interface
    final routeResult = await Process.run('route', ['-n', 'get', 'default']);
    final routeOut = routeResult.stdout.toString();
    final ifaceMatch = RegExp(r'interface:\s+(\S+)').firstMatch(routeOut);
    if (ifaceMatch == null) return _kFallbackSubnet;
    final iface = ifaceMatch.group(1)!;

    // Step 2 – get inet address + netmask for that interface
    final ifResult = await Process.run('ifconfig', [iface]);
    final ifOut = ifResult.stdout.toString();
    // e.g.  inet 192.168.50.100 netmask 0xffffff00 broadcast ...
    final inetMatch =
        RegExp(r'inet (\d+\.\d+\.\d+\.\d+) netmask (0x[0-9a-f]+)')
            .firstMatch(ifOut);
    if (inetMatch == null) return _kFallbackSubnet;

    final ip = inetMatch.group(1)!;
    final maskInt = int.parse(inetMatch.group(2)!.substring(2), radix: 16);

    // Step 3 – compute network address and CIDR prefix length
    final ipParts = ip.split('.').map(int.parse).toList();
    final maskBytes = [
      (maskInt >> 24) & 0xff,
      (maskInt >> 16) & 0xff,
      (maskInt >> 8) & 0xff,
      maskInt & 0xff,
    ];
    final netParts = List.generate(4, (i) => ipParts[i] & maskBytes[i]);
    final cidr = _popcount(maskInt);

    return '${netParts.join('.')}/$cidr';
  } catch (_) {
    return _kFallbackSubnet;
  }
}

int _popcount(int n) {
  int count = 0;
  int v = n;
  while (v != 0) {
    count += v & 1;
    v = v >>> 1;
  }
  return count;
}

/// Call this once in main() before runApp().
Future<void> initDetectedSubnet() async {
  _detectedSubnet = await detectSubnet();
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  AppSettings build() {
    final stored = HiveService.settings.get(_key);
    if (stored != null) {
      return AppSettings.fromJson(stored);
    }
    // First launch: auto-detect subnet & nmap path, then persist
    final settings = AppSettings(
      subnet: _detectedSubnet,
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
