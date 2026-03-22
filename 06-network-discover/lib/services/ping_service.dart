import 'dart:async';
import 'dart:io';

class PingResult {
  final String ip;
  final double? rttMs; // null = timeout / unreachable

  const PingResult({required this.ip, required this.rttMs});
}

class PingService {
  /// Pings a single IP once. Returns RTT in ms, or null on timeout.
  /// [waitMs] maps to the -W flag (milliseconds on macOS).
  Future<PingResult> ping(String ip, {int waitMs = 1000}) async {
    try {
      // -c 1 : one packet  -W <ms> : wait deadline  -t 64 : TTL
      final result = await Process.run(
        'ping',
        ['-c', '1', '-W', '$waitMs', ip],
      ).timeout(Duration(milliseconds: waitMs + 500));

      final stdout = result.stdout.toString();
      // macOS: "64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=1.234 ms"
      final match = RegExp(r'time[<=](\d+\.?\d*)\s*ms').firstMatch(stdout);
      if (match != null) {
        return PingResult(ip: ip, rttMs: double.parse(match.group(1)!));
      }
    } catch (_) {}
    return PingResult(ip: ip, rttMs: null);
  }

  /// Pings all IPs concurrently and yields results as they arrive.
  Stream<PingResult> pingAll(List<String> ips, {int waitMs = 1000}) {
    final controller = StreamController<PingResult>();
    var remaining = ips.length;

    if (ips.isEmpty) {
      controller.close();
      return controller.stream;
    }

    for (final ip in ips) {
      ping(ip, waitMs: waitMs).then((r) {
        if (!controller.isClosed) controller.add(r);
        remaining--;
        if (remaining == 0) controller.close();
      });
    }
    return controller.stream;
  }
}
