import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/network_device.dart';
import '../services/ping_service.dart';
import 'scanner_provider.dart';
import 'settings_provider.dart';

class TopologyState {
  final bool isPinging;
  final Map<String, double?> rttMap; // IP -> ms (null = timeout)
  final String? gatewayIp;

  const TopologyState({
    this.isPinging = false,
    this.rttMap = const {},
    this.gatewayIp,
  });

  TopologyState copyWith({
    bool? isPinging,
    Map<String, double?>? rttMap,
    String? gatewayIp,
    bool clearGateway = false,
  }) {
    return TopologyState(
      isPinging: isPinging ?? this.isPinging,
      rttMap: rttMap ?? this.rttMap,
      gatewayIp: clearGateway ? null : (gatewayIp ?? this.gatewayIp),
    );
  }
}

class TopologyNotifier extends Notifier<TopologyState> {
  final _ping = PingService();

  @override
  TopologyState build() => const TopologyState();

  List<NetworkDevice> get _devices => ref.read(scannerProvider).devices;

  Future<void> pingAll() async {
    if (state.isPinging || _devices.isEmpty) return;

    // Detect gateway from default route
    final gateway = await _detectGateway();

    // Reset RTT map and start pinging
    state = state.copyWith(
      isPinging: true,
      rttMap: {},
      gatewayIp: gateway,
    );

    final waitMs = ref.read(settingsProvider).pingWaitMs;
    final ips = _devices.map((d) => d.ip).toList();

    // Also ping gateway if not already in the device list
    final allIps = gateway != null && !ips.contains(gateway)
        ? [...ips, gateway]
        : ips;

    await for (final result in _ping.pingAll(allIps, waitMs: waitMs)) {
      state = state.copyWith(
        rttMap: {...state.rttMap, result.ip: result.rttMs},
      );
    }

    state = state.copyWith(isPinging: false);
  }

  Future<String?> _detectGateway() async {
    try {
      final result = await Process.run('route', ['-n', 'get', 'default']);
      final out = result.stdout.toString();
      final match = RegExp(r'gateway:\s+(\S+)').firstMatch(out);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }
}

final topologyProvider = NotifierProvider<TopologyNotifier, TopologyState>(
  TopologyNotifier.new,
);
