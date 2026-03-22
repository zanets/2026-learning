import 'dart:io';
import 'package:xml/xml.dart';
import '../models/network_device.dart';

class ScanResult {
  final List<NetworkDevice> devices;
  final Duration duration;

  const ScanResult({required this.devices, required this.duration});
}

class ScannerService {
  static const _timeout = Duration(seconds: 120);

  Process? _process;

  void cancel() {
    _process?.kill(ProcessSignal.sigterm);
    _process = null;
  }

  Future<ScanResult> scan({
    required String subnet,
    required String nmapPath,
    required void Function(String line) onLog,
    required void Function(NetworkDevice device) onDevice,
    void Function(String error)? onError,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Request sudo via osascript (macOS native dialog)
    final pwResult = await Process.run('osascript', [
      '-e',
      'display dialog "Network Discover requires sudo for ARP scan" '
          'default answer "" with hidden answer '
          'buttons {"Cancel","OK"} default button "OK" '
          'with title "Authentication Required"',
    ]);

    if (pwResult.exitCode != 0) {
      throw Exception('Authentication cancelled');
    }

    final match = RegExp(r'text returned:(.*)$').firstMatch(
      pwResult.stdout.toString().trim(),
    );
    final password = match?.group(1)?.trim() ?? '';

    onLog('Starting ping sweep on $subnet');

    final process = await Process.start('sudo', [
      '-S',
      nmapPath,
      '-sn',
      '-PR',
      '--min-parallelism',
      '100',
      '-oX',
      '-',
      subnet,
    ]);

    _process = process;
    process.stdin.write('$password\n');
    await process.stdin.flush();

    final xmlBuffer = StringBuffer();
    final devices = <NetworkDevice>[];

    process.stdout.transform(const SystemEncoding().decoder).listen((chunk) {
      xmlBuffer.write(chunk);
    });

    process.stderr.transform(const SystemEncoding().decoder).listen((line) {
      onLog(line.trim());
    });

    int exitCode;
    try {
      exitCode = await process.exitCode.timeout(
        _timeout,
        onTimeout: () {
          onLog('Scan timed out after ${_timeout.inSeconds}s — killing process');
          process.kill(ProcessSignal.sigterm);
          return -1;
        },
      );
    } finally {
      _process = null;
    }

    if (exitCode == -1) {
      throw Exception('Scan timed out after ${_timeout.inSeconds}s');
    }

    final xmlStr = xmlBuffer.toString();
    if (xmlStr.trim().isEmpty) {
      throw Exception('nmap produced no output. Check nmap path and permissions.');
    }

    try {
      final doc = XmlDocument.parse(xmlStr);
      for (final host in doc.findAllElements('host')) {
        final status = host.findElements('status').firstOrNull;
        if (status?.getAttribute('state') != 'up') continue;

        String? ip, mac, vendor, hostname;

        for (final addr in host.findElements('address')) {
          final type = addr.getAttribute('addrtype');
          if (type == 'ipv4') ip = addr.getAttribute('addr');
          if (type == 'mac') {
            mac = addr.getAttribute('addr');
            vendor = addr.getAttribute('vendor');
          }
        }

        final hostnamesEl = host.findElements('hostnames').firstOrNull;
        hostname = hostnamesEl
            ?.findElements('hostname')
            .firstOrNull
            ?.getAttribute('name');

        if (ip == null) continue;

        final device = NetworkDevice(
          ip: ip,
          mac: mac,
          hostname: hostname,
          vendor: vendor,
          discoveredAt: DateTime.now(),
        );
        devices.add(device);
        onDevice(device);
        onLog('Found: $ip${hostname != null ? ' ($hostname)' : ''}');
      }
    } catch (e) {
      throw Exception('Failed to parse nmap output: $e');
    }

    stopwatch.stop();
    onLog(
        'Scan complete. Found ${devices.length} devices in ${stopwatch.elapsed.inSeconds}s');
    return ScanResult(devices: devices, duration: stopwatch.elapsed);
  }
}
