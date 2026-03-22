import 'dart:async';
import 'dart:io';

class HttpHeaderResult {
  final int port;
  final bool https;
  final int statusCode;
  final Map<String, String> headers;

  const HttpHeaderResult({
    required this.port,
    required this.https,
    required this.statusCode,
    required this.headers,
  });

  String get url => '${https ? 'https' : 'http'}://…:$port';
}

class HttpHeaderService {
  static const _probePorts = [
    (port: 80, https: false),
    (port: 443, https: true),
    (port: 8080, https: false),
    (port: 8443, https: true),
    (port: 8000, https: false),
    (port: 3000, https: false),
    (port: 5000, https: false),
  ];

  /// Probes all common web ports concurrently and returns results that responded.
  Future<List<HttpHeaderResult>> fetchAll(String ip) async {
    final futures = _probePorts.map((p) => _fetch(ip, p.port, p.https));
    final results = await Future.wait(futures);
    return results.whereType<HttpHeaderResult>().toList();
  }

  Future<HttpHeaderResult?> _fetch(String ip, int port, bool https) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..badCertificateCallback = (_, __, ___) => true; // accept self-signed
    try {
      final uri = Uri(scheme: https ? 'https' : 'http', host: ip, port: port, path: '/');
      final request = await client.headUrl(uri).timeout(const Duration(seconds: 4));
      request.headers.set(HttpHeaders.userAgentHeader, 'NetworkDiscover/1.0');
      final response = await request.close().timeout(const Duration(seconds: 4));
      await response.drain<void>();

      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });

      return HttpHeaderResult(
        port: port,
        https: https,
        statusCode: response.statusCode,
        headers: headers,
      );
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
