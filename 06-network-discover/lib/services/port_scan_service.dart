import 'dart:io';
import 'package:xml/xml.dart';
import '../models/port_info.dart';

class ScanProgress {
  final double? percent;
  final String? remaining;

  const ScanProgress({this.percent, this.remaining});
}

class OsMatch {
  final String name;
  final int accuracy;

  const OsMatch({required this.name, required this.accuracy});
}

class PortScanService {
  Process? _process;

  void cancel() {
    _process?.kill(ProcessSignal.sigterm);
    _process = null;
  }

  Future<List<PortInfo>> scan({
    required String ip,
    required String nmapPath,
    required String sudoPassword,
    required int timeoutSeconds,
    required List<String> nmapArgs,
    required void Function(String line) onLog,
    required void Function(PortInfo port) onPort,
    void Function(ScanProgress progress)? onProgress,
    void Function(OsMatch os)? onOsDetected,
  }) async {
    final fullCmd = 'sudo -S $nmapPath ${nmapArgs.join(' ')}';
    onLog('Starting port scan on $ip');
    onLog('Command: $fullCmd');

    final process = await Process.start('sudo', ['-S', nmapPath, ...nmapArgs]);

    _process = process;
    process.stdin.write('$sudoPassword\n');
    await process.stdin.flush();

    final xmlBuffer = StringBuffer();
    final ports = <PortInfo>[];

    // Use forEach() so we get awaitable Futures — ensures all data is
    // fully delivered to xmlBuffer before we attempt XML parsing.
    final stdoutDone = process.stdout
        .transform(const SystemEncoding().decoder)
        .forEach((chunk) => xmlBuffer.write(chunk));

    final stderrDone = process.stderr
        .transform(const SystemEncoding().decoder)
        .forEach((line) {
      onLog(line.trim());
      _parseProgress(line, onProgress);
    });

    final timeout = Duration(seconds: timeoutSeconds);
    int exitCode;
    try {
      exitCode = await process.exitCode.timeout(
        timeout,
        onTimeout: () {
          onLog('Port scan timed out after ${timeoutSeconds}s — killing process');
          process.kill(ProcessSignal.sigterm);
          return -1;
        },
      );
      // Drain remaining buffered stream data after process exits
      await Future.wait([stdoutDone, stderrDone]);
    } finally {
      _process = null;
    }

    if (exitCode == -1) {
      throw Exception('Port scan timed out after ${timeoutSeconds}s');
    }

    final xmlStr = xmlBuffer.toString();
    if (xmlStr.trim().isEmpty) {
      throw Exception('nmap produced no output');
    }

    try {
      final doc = XmlDocument.parse(xmlStr);
      final host = doc.findAllElements('host').firstOrNull;
      if (host == null) return ports;

      // OS detection
      final osMatches = host.findAllElements('osmatch').toList();
      if (osMatches.isNotEmpty && onOsDetected != null) {
        final best = osMatches.first;
        final name = best.getAttribute('name') ?? '';
        final accuracy =
            int.tryParse(best.getAttribute('accuracy') ?? '0') ?? 0;
        onOsDetected(OsMatch(name: name, accuracy: accuracy));
      }

      // Ports
      final portElements = host.findAllElements('port').toList()
        ..sort((a, b) {
          final pa = int.tryParse(a.getAttribute('portid') ?? '0') ?? 0;
          final pb = int.tryParse(b.getAttribute('portid') ?? '0') ?? 0;
          return pa.compareTo(pb);
        });

      for (final portEl in portElements) {
        final state =
            portEl.findElements('state').firstOrNull?.getAttribute('state');
        if (state != 'open') continue;

        final portNum = int.tryParse(portEl.getAttribute('portid') ?? '');
        final protocol = portEl.getAttribute('protocol') ?? 'tcp';
        if (portNum == null) continue;

        final serviceEl = portEl.findElements('service').firstOrNull;
        final service = serviceEl?.getAttribute('name') ?? 'unknown';
        final product = serviceEl?.getAttribute('product');
        final version = serviceEl?.getAttribute('version');

        final portInfo = PortInfo(
          port: portNum,
          protocol: protocol,
          state: 'open',
          service: service,
          product: product,
          version: version,
        );
        ports.add(portInfo);
        onPort(portInfo);
        onLog('Port $portNum/$protocol open - $service');
      }
    } catch (e) {
      throw Exception('Failed to parse nmap output: $e');
    }

    onLog('Port scan complete. Found ${ports.length} open ports');
    return ports;
  }

  void _parseProgress(String line, void Function(ScanProgress)? onProgress) {
    if (onProgress == null) return;
    final percentIdx = line.indexOf('%');
    if (percentIdx < 0) return;
    final aboutIdx = line.lastIndexOf(' ', percentIdx - 1);
    if (aboutIdx < 0) return;
    final percentStr = line.substring(aboutIdx + 1, percentIdx);
    final percent = double.tryParse(percentStr);

    String? remaining;
    final remMatch = RegExp(r'\(([^)]+remaining)\)').firstMatch(line);
    if (remMatch != null) remaining = remMatch.group(1);

    if (percent != null) {
      onProgress(ScanProgress(percent: percent / 100, remaining: remaining));
    }
  }
}
