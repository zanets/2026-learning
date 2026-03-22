import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/network_device.dart';
import '../providers/topology_provider.dart';
import '../providers/scanner_provider.dart';
import '../theme/app_theme.dart';

class TopologyScreen extends ConsumerWidget {
  const TopologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topoState = ref.watch(topologyProvider);
    final scanState = ref.watch(scannerProvider);
    final devices = scanState.devices;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: AppColors.accent, size: 20),
            SizedBox(width: 8),
            Text('Network Topology'),
          ],
        ),
        actions: [
          if (topoState.isPinging)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.wifi_tethering, color: AppColors.accent),
              tooltip: 'Ping All',
              onPressed: devices.isEmpty
                  ? null
                  : () => ref.read(topologyProvider.notifier).pingAll(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: devices.isEmpty
          ? const _EmptyState()
          : _TopologyView(
              devices: devices,
              rttMap: topoState.rttMap,
              gatewayIp: topoState.gatewayIp,
              isPinging: topoState.isPinging,
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No devices found.\nRun a scan first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TopologyView extends StatelessWidget {
  final List<NetworkDevice> devices;
  final Map<String, double?> rttMap;
  final String? gatewayIp;
  final bool isPinging;

  const _TopologyView({
    required this.devices,
    required this.rttMap,
    required this.gatewayIp,
    required this.isPinging,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height / 2);

        // Compute radial positions for each device
        final positions = _computePositions(size, center);

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.3,
          maxScale: 3.0,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // Connection lines
                CustomPaint(
                  size: size,
                  painter: _TopologyPainter(
                    center: center,
                    positions: positions,
                    rttMap: rttMap,
                    gatewayIp: gatewayIp,
                  ),
                ),

                // Gateway node at center
                _GatewayNode(center: center, gatewayIp: gatewayIp),

                // Device nodes
                ...positions.entries.map((e) {
                  final device = devices.firstWhere((d) => d.ip == e.key);
                  final rtt = rttMap[e.key];
                  return _DeviceNode(
                    device: device,
                    position: e.value,
                    rtt: rtt,
                    hasResult: rttMap.containsKey(e.key),
                  );
                }),

                // Legend
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: _Legend(),
                ),

                // Ping hint
                if (rttMap.isEmpty && !isPinging)
                  const Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _HintBanner(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, Offset> _computePositions(Size size, Offset center) {
    const minRadius = 120.0;
    const maxRadius = 220.0;
    // 0 ms → 80 px, 140 ms → 220 px, linear, clamped
    const rttScale = (maxRadius - minRadius) / 140.0;

    final positions = <String, Offset>{};
    final count = devices.length;

    for (var i = 0; i < count; i++) {
      final ip = devices[i].ip;
      final angle = (2 * pi * i / count) - pi / 2;

      double radius;
      if (!rttMap.containsKey(ip)) {
        radius = (minRadius + maxRadius) / 2;
      } else {
        final rtt = rttMap[ip];
        if (rtt == null) {
          radius = maxRadius;
        } else {
          radius = (minRadius + rtt * rttScale).clamp(minRadius, maxRadius);
        }
      }

      positions[ip] = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    }

    return positions;
  }
}

// ── CustomPainter for lines ────────────────────────────────────────────────────

class _TopologyPainter extends CustomPainter {
  final Offset center;
  final Map<String, Offset> positions;
  final Map<String, double?> rttMap;
  final String? gatewayIp;

  const _TopologyPainter({
    required this.center,
    required this.positions,
    required this.rttMap,
    required this.gatewayIp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in positions.entries) {
      final ip = entry.key;
      final pos = entry.value;
      final rtt = rttMap[ip];
      final hasResult = rttMap.containsKey(ip);

      final color = hasResult
          ? (rtt == null
              ? AppColors.textSecondary
              : _rttColor(rtt).withValues(alpha: 0.5))
          : AppColors.border;

      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, pos, paint);
    }
  }

  @override
  bool shouldRepaint(_TopologyPainter old) =>
      old.positions != positions || old.rttMap != rttMap;
}

// ── Node widgets ──────────────────────────────────────────────────────────────

class _GatewayNode extends StatelessWidget {
  final Offset center;
  final String? gatewayIp;

  const _GatewayNode({required this.center, required this.gatewayIp});

  @override
  Widget build(BuildContext context) {
    const nodeSize = 56.0;
    return Positioned(
      left: center.dx - nodeSize / 2,
      top: center.dy - nodeSize / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: const Icon(Icons.router, color: AppColors.accent, size: 24),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              gatewayIp ?? 'Gateway',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceNode extends StatelessWidget {
  final NetworkDevice device;
  final Offset position;
  final double? rtt;
  final bool hasResult;

  const _DeviceNode({
    required this.device,
    required this.position,
    required this.rtt,
    required this.hasResult,
  });

  @override
  Widget build(BuildContext context) {
    const nodeSize = 44.0;
    final color = hasResult
        ? (rtt == null ? AppColors.textSecondary : _rttColor(rtt!))
        : AppColors.border;

    final label = device.hostname?.isNotEmpty == true
        ? device.hostname!
        : device.ip;

    final rttLabel = !hasResult
        ? null
        : (rtt == null ? 'timeout' : '${rtt!.toStringAsFixed(1)} ms');

    return Positioned(
      left: position.dx - nodeSize / 2,
      top: position.dy - nodeSize / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.devices, color: color, size: 20),
          ),
          const SizedBox(height: 3),
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (rttLabel != null)
                  Text(
                    rttLabel,
                    style: TextStyle(color: color, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend ─────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(color: AppColors.success, label: '< 5 ms'),
          _LegendItem(color: AppColors.info, label: '5 – 20 ms'),
          _LegendItem(color: AppColors.warn, label: '20 – 100 ms'),
          _LegendItem(color: AppColors.danger, label: '> 100 ms'),
          _LegendItem(color: AppColors.textSecondary, label: 'Timeout'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 6),
          Text(
            'Tap the ping button to measure latency',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── RTT color helper ──────────────────────────────────────────────────────────

Color _rttColor(double rttMs) {
  if (rttMs < 5) return AppColors.success;
  if (rttMs < 20) return AppColors.info;
  if (rttMs < 100) return AppColors.warn;
  return AppColors.danger;
}
