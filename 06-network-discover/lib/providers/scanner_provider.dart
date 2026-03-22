import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/network_device.dart';
import '../services/scanner_service.dart';
import 'settings_provider.dart';

class ScannerState {
  final List<NetworkDevice> devices;
  final bool isScanning;
  final String? error;
  final List<String> logs;
  final Duration? scanDuration;

  const ScannerState({
    this.devices = const [],
    this.isScanning = false,
    this.error,
    this.logs = const [],
    this.scanDuration,
  });

  ScannerState copyWith({
    List<NetworkDevice>? devices,
    bool? isScanning,
    String? error,
    List<String>? logs,
    Duration? scanDuration,
    bool clearError = false,
    bool clearDuration = false,
  }) {
    return ScannerState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      scanDuration: clearDuration ? null : (scanDuration ?? this.scanDuration),
    );
  }
}

class ScannerNotifier extends Notifier<ScannerState> {
  final _service = ScannerService();

  @override
  ScannerState build() => const ScannerState();

  Future<void> startScan() async {
    if (state.isScanning) return;

    final settings = ref.read(settingsProvider);
    state = state.copyWith(
      isScanning: true,
      devices: [],
      logs: [],
      clearError: true,
      clearDuration: true,
    );

    try {
      final result = await _service.scan(
        subnet: settings.subnet,
        nmapPath: settings.nmapPath,
        onLog: (line) {
          state = state.copyWith(logs: [...state.logs, line]);
        },
        onDevice: (device) {
          state = state.copyWith(devices: [...state.devices, device]);
        },
        onError: (error) {
          state = state.copyWith(error: error);
        },
      );
      state = state.copyWith(
        isScanning: false,
        scanDuration: result.duration,
      );
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
