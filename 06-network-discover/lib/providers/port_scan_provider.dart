import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/port_info.dart';
import '../models/scan_cache_entry.dart';
import '../services/port_scan_service.dart';
import 'settings_provider.dart';
import 'cache_provider.dart';

class PortScanState {
  final List<PortInfo> ports;
  final bool isScanning;
  final double? progress;
  final String? remaining;
  final String? osGuess;
  final int? osAccuracy;
  final List<String> logs;
  final ScanCacheEntry? cached;
  final String? error;

  const PortScanState({
    this.ports = const [],
    this.isScanning = false,
    this.progress,
    this.remaining,
    this.osGuess,
    this.osAccuracy,
    this.logs = const [],
    this.cached,
    this.error,
  });

  PortScanState copyWith({
    List<PortInfo>? ports,
    bool? isScanning,
    double? progress,
    String? remaining,
    String? osGuess,
    int? osAccuracy,
    List<String>? logs,
    ScanCacheEntry? cached,
    String? error,
    bool clearProgress = false,
    bool clearError = false,
  }) {
    return PortScanState(
      ports: ports ?? this.ports,
      isScanning: isScanning ?? this.isScanning,
      progress: clearProgress ? null : (progress ?? this.progress),
      remaining: clearProgress ? null : (remaining ?? this.remaining),
      osGuess: osGuess ?? this.osGuess,
      osAccuracy: osAccuracy ?? this.osAccuracy,
      logs: logs ?? this.logs,
      cached: cached ?? this.cached,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PortScanNotifier extends FamilyNotifier<PortScanState, String> {
  final _service = PortScanService();
  OsMatch? _lastOs;

  @override
  PortScanState build(String ip) {
    // Load cached entry on init
    final cached = ref.read(cacheProvider.notifier).get(ip);
    return PortScanState(cached: cached);
  }

  void cancel() {
    _service.cancel();
    state = state.copyWith(isScanning: false, clearProgress: true);
  }

  Future<void> startScan(String sudoPassword) async {
    if (state.isScanning) return;

    final settings = ref.read(settingsProvider);
    _lastOs = null;

    state = state.copyWith(
      isScanning: true,
      ports: [],
      logs: [],
      clearProgress: true,
      clearError: true,
    );

    try {
      final ports = await _service.scan(
        ip: arg,
        nmapPath: settings.nmapPath,
        sudoPassword: sudoPassword,
        onLog: (line) {
          state = state.copyWith(logs: [...state.logs, line]);
        },
        onPort: (port) {
          state = state.copyWith(ports: [...state.ports, port]);
        },
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.percent,
            remaining: progress.remaining,
          );
        },
        onOsDetected: (os) {
          _lastOs = os;
          state = state.copyWith(osGuess: os.name, osAccuracy: os.accuracy);
        },
      );

      // Save to cache
      await ref.read(cacheProvider.notifier).save(arg, ports, _lastOs);
      final cached = ref.read(cacheProvider.notifier).get(arg);

      state = state.copyWith(
        isScanning: false,
        clearProgress: true,
        cached: cached,
      );
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }
}

final portScanProvider = NotifierProviderFamily<PortScanNotifier, PortScanState, String>(
  PortScanNotifier.new,
);
