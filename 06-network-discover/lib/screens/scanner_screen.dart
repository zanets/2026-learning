import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scanner_provider.dart';
import '../models/network_device.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/device_card.dart';
import '../widgets/device_detail_sheet.dart';
import '../widgets/nmap_log_panel.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openDeviceDetail(NetworkDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceDetailSheet(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = ref.watch(scannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.radar, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Summary ribbon
          if (scanState.scanDuration != null && !scanState.isScanning)
            _SummaryRibbon(
              count: scanState.devices.length,
              duration: scanState.scanDuration!,
              l10n: l10n,
            ),

          // Error banner
          if (scanState.error != null)
            _ErrorBanner(
              error: scanState.error!,
              onDismiss: () => ref.read(scannerProvider.notifier).clearError(),
            ),

          // Scan button bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: scanState.isScanning
                        ? null
                        : () => ref.read(scannerProvider.notifier).startScan(),
                    icon: Icon(
                      scanState.isScanning ? Icons.hourglass_top : Icons.search,
                      size: 18,
                    ),
                    label: Text(
                      scanState.isScanning ? l10n.scanning : l10n.scan,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: scanState.devices.isEmpty
                ? _EmptyState(
                    isScanning: scanState.isScanning,
                    pulseController: _pulseController,
                    l10n: l10n,
                  )
                : _DeviceGrid(
                    devices: scanState.devices,
                    onDeviceTap: _openDeviceDetail,
                  ),
          ),

          // Log panel
          if (scanState.logs.isNotEmpty)
            NmapLogPanel(logs: scanState.logs),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SummaryRibbon extends StatelessWidget {
  final int count;
  final Duration duration;
  final AppLocalizations l10n;

  const _SummaryRibbon(
      {required this.count, required this.duration, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.success.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.success, size: 14),
          const SizedBox(width: 6),
          Text(
            l10n.devicesFound(count),
            style: const TextStyle(color: AppColors.success, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.scanDuration(duration.inSeconds.toString()),
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.danger.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 14, color: AppColors.danger),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  final AnimationController pulseController;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.isScanning,
    required this.pulseController,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) => Opacity(
              opacity: 0.4 + pulseController.value * 0.6,
              child: child,
            ),
            child: Icon(
              isScanning ? Icons.radar : Icons.network_check,
              size: 64,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? l10n.scanning : l10n.startScan,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DeviceGrid extends StatelessWidget {
  final List<NetworkDevice> devices;
  final void Function(NetworkDevice) onDeviceTap;

  const _DeviceGrid({required this.devices, required this.onDeviceTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = (width / 240).floor().clamp(2, 6);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) => DeviceCard(
        device: devices[index],
        onTap: () => onDeviceTap(devices[index]),
      ),
    );
  }
}
