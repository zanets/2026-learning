import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/network_device.dart';
import '../models/port_info.dart';
import '../providers/port_scan_provider.dart';
import '../providers/http_header_provider.dart';
import '../services/http_header_service.dart';
import '../data/port_descriptions.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'copyable_text.dart';
import 'nmap_log_panel.dart';

class DeviceDetailSheet extends ConsumerStatefulWidget {
  final NetworkDevice device;

  const DeviceDetailSheet({super.key, required this.device});

  @override
  ConsumerState<DeviceDetailSheet> createState() => _DeviceDetailSheetState();
}

class _DeviceDetailSheetState extends ConsumerState<DeviceDetailSheet>
    with TickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    // Get sudo password via osascript
    final pwResult = await Process.run('osascript', [
      '-e',
      'display dialog "Enter sudo password for port scan" '
          'default answer "" with hidden answer '
          'buttons {"Cancel","OK"} default button "OK" '
          'with title "Authentication Required"',
    ]);

    if (pwResult.exitCode != 0) return;

    final match = RegExp(r'text returned:(.*)$').firstMatch(
      pwResult.stdout.toString().trim(),
    );
    final password = match?.group(1)?.trim() ?? '';

    ref.read(portScanProvider(widget.device.ip).notifier).startScan(password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = ref.watch(portScanProvider(widget.device.ip));
    final httpState = ref.watch(httpHeaderProvider(widget.device.ip));
    final device = widget.device;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.computer, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    CopyableText(
                      device.ip,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (device.hostname != null)
                      _Chip(
                          icon: Icons.dns,
                          label: device.hostname!,
                          color: AppColors.info),
                    _Chip(
                        icon: Icons.memory,
                        label: device.macDisplay,
                        color: AppColors.textSecondary,
                        mono: true),
                    if (device.vendor != null)
                      _Chip(
                          icon: Icons.router,
                          label: device.vendor!,
                          color: AppColors.textSecondary),
                    if (scanState.osGuess != null)
                      _Chip(
                        icon: Icons.terminal,
                        label:
                            '${scanState.osGuess} (${scanState.osAccuracy}%)',
                        color: AppColors.accent,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 20),
          // Body
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: l10n.ports),
                      Tab(text: l10n.httpHeaders),
                    ],
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                    dividerColor: AppColors.border,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // ── Port scan tab ──
                        _PortScanTab(
                          state: scanState,
                          spinController: _spinController,
                          l10n: l10n,
                          onScan: _startScan,
                          onCancel: () => ref
                              .read(portScanProvider(device.ip).notifier)
                              .cancel(),
                          onRescan: _startScan,
                        ),

                        // ── HTTP headers tab ──
                        _HttpHeaderView(
                          ip: device.ip,
                          state: httpState,
                          l10n: l10n,
                          onFetch: () => ref
                              .read(httpHeaderProvider(device.ip).notifier)
                              .fetch(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool mono;

  const _Chip(
      {required this.icon,
      required this.label,
      required this.color,
      this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Port scan tab wrapper ─────────────────────────────────────────────────────

class _PortScanTab extends StatelessWidget {
  final PortScanState state;
  final AnimationController spinController;
  final AppLocalizations l10n;
  final VoidCallback onScan;
  final VoidCallback onCancel;
  final VoidCallback onRescan;

  const _PortScanTab({
    required this.state,
    required this.spinController,
    required this.l10n,
    required this.onScan,
    required this.onCancel,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isScanning) {
      return _ScanningView(
        progress: state.progress,
        remaining: state.remaining,
        ports: state.ports,
        spinController: spinController,
        logs: state.logs,
        l10n: l10n,
        onCancel: onCancel,
      );
    }

    final ports = state.ports.isNotEmpty
        ? state.ports
        : state.cached?.ports;

    if (ports != null && ports.isNotEmpty) {
      return _PortListView(
        ports: ports,
        cached: state.cached,
        logs: state.logs,
        l10n: l10n,
        onRescan: onRescan,
      );
    }

    return _EmptyPortView(l10n: l10n, onScan: onScan);
  }
}

class _EmptyPortView extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onScan;

  const _EmptyPortView({required this.l10n, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.radar, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            l10n.scanPortsHint,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.search, size: 16),
            label: Text(l10n.portScan),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanningView extends StatelessWidget {
  final double? progress;
  final String? remaining;
  final List<PortInfo> ports;
  final AnimationController spinController;
  final List<String> logs;
  final AppLocalizations l10n;
  final VoidCallback onCancel;

  const _ScanningView({
    required this.progress,
    required this.remaining,
    required this.ports,
    required this.spinController,
    required this.logs,
    required this.l10n,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (progress != null)
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  color: AppColors.accent,
                ),
              if (progress == null)
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  color: AppColors.accent,
                ),
              RotationTransition(
                turns: spinController,
                child: CustomPaint(
                  size: const Size(90, 90),
                  painter: _ArcPainter(),
                ),
              ),
              Text(
                progress != null
                    ? '${(progress! * 100).toStringAsFixed(0)}%'
                    : '...',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.portScanRunning,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        if (remaining != null) ...[
          const SizedBox(height: 4),
          Text(
            remaining!,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
        if (ports.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${ports.length} ports found so far',
            style: const TextStyle(color: AppColors.accent, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.stop, size: 16),
          label: Text(l10n.cancel),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
        ),
        const Spacer(),
        NmapLogPanel(logs: logs, mini: true),
      ],
    );
  }
}

class _PortListView extends StatelessWidget {
  final List<PortInfo> ports;
  final dynamic cached;
  final List<String> logs;
  final AppLocalizations l10n;
  final VoidCallback onRescan;

  const _PortListView({
    required this.ports,
    required this.cached,
    required this.logs,
    required this.l10n,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                '${ports.length} ${l10n.openPorts}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (cached != null) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.cachedResult(cached!.relativeTime),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: onRescan,
                icon: const Icon(Icons.refresh, size: 14),
                label: Text(l10n.reScan, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ports.length,
            itemBuilder: (context, index) =>
                _PortRow(port: ports[index], l10n: l10n),
          ),
        ),
        NmapLogPanel(logs: logs, mini: true),
      ],
    );
  }
}

class _PortRow extends StatefulWidget {
  final PortInfo port;
  final AppLocalizations l10n;

  const _PortRow({required this.port, required this.l10n});

  @override
  State<_PortRow> createState() => _PortRowState();
}

class _PortRowState extends State<_PortRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final desc = kPortDescriptions[widget.port.port];
    final riskColor = _riskColor(desc?.risk);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: desc != null ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Port number
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${widget.port.port}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Protocol badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      widget.port.protocol,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desc?.name ?? widget.port.service,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                        ),
                        if (widget.port.serviceLabel != widget.port.service)
                          Text(
                            widget.port.serviceLabel,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  // Risk badge
                  if (desc != null)
                    _RiskBadge(risk: desc.risk, color: riskColor, l10n: widget.l10n),
                  if (desc != null)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
          // Expanded description
          if (desc != null && _expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border, height: 8),
                  Text(
                    desc.description,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (desc.tips != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 12, color: riskColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            desc.tips!,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _riskColor(PortRisk? risk) {
    switch (risk) {
      case PortRisk.safe:
        return AppColors.success;
      case PortRisk.info:
        return AppColors.info;
      case PortRisk.warn:
        return AppColors.warn;
      case PortRisk.danger:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _RiskBadge extends StatelessWidget {
  final PortRisk risk;
  final Color color;
  final AppLocalizations l10n;

  const _RiskBadge(
      {required this.risk, required this.color, required this.l10n});

  String _label() {
    switch (risk) {
      case PortRisk.safe:
        return l10n.riskSafe;
      case PortRisk.info:
        return l10n.riskInfo;
      case PortRisk.warn:
        return l10n.riskWarn;
      case PortRisk.danger:
        return l10n.riskDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label(),
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}

// ── HTTP Headers view ─────────────────────────────────────────────────────────

class _HttpHeaderView extends StatelessWidget {
  final String ip;
  final HttpHeaderState state;
  final VoidCallback onFetch;
  final AppLocalizations l10n;

  const _HttpHeaderView({
    required this.ip,
    required this.state,
    required this.onFetch,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.results.isEmpty && state.error == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.http, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l10n.httpProbeHint,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onFetch,
              icon: const Icon(Icons.send_outlined, size: 16),
              label: Text(l10n.fetchHeaders),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                l10n.portsResponded(state.results.length),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onFetch,
                icon: const Icon(Icons.refresh, size: 14),
                label: Text(l10n.reFetch, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(state.error!,
                style: const TextStyle(
                    color: AppColors.danger, fontSize: 12)),
          ),
        Expanded(
          child: state.results.isEmpty
              ? Center(
                  child: Text(
                    l10n.noWebService,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.results.length,
                  itemBuilder: (_, i) =>
                      _HeaderResultCard(result: state.results[i]),
                ),
        ),
      ],
    );
  }
}

class _HeaderResultCard extends StatefulWidget {
  final HttpHeaderResult result;
  const _HeaderResultCard({required this.result});

  @override
  State<_HeaderResultCard> createState() => _HeaderResultCardState();
}

class _HeaderResultCardState extends State<_HeaderResultCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final scheme = r.https ? 'HTTPS' : 'HTTP';
    final statusColor = r.statusCode < 300
        ? AppColors.success
        : r.statusCode < 400
            ? AppColors.info
            : AppColors.warn;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (r.https ? AppColors.success : AppColors.info)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scheme,
                      style: TextStyle(
                        color: r.https ? AppColors.success : AppColors.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ':${r.port}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${r.statusCode}',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  const Spacer(),
                  if (r.headers['server'] != null)
                    Flexible(
                      child: Text(
                        r.headers['server']!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && r.headers.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: r.headers.entries.map((e) => _HeaderRow(e)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final MapEntry<String, String> entry;
  const _HeaderRow(this.entry);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              entry.key,
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: CopyableText(
              entry.value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentDim.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, math.pi * 1.2, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}
