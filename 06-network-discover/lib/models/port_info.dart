class PortInfo {
  final int port;
  final String protocol;
  final String state;
  final String service;
  final String? version;
  final String? product;

  const PortInfo({
    required this.port,
    required this.protocol,
    required this.state,
    required this.service,
    this.version,
    this.product,
  });

  String get serviceLabel {
    final parts = [product, version].where((e) => e != null && e.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : service;
  }

  Map<String, dynamic> toJson() => {
        'port': port,
        'protocol': protocol,
        'state': state,
        'service': service,
        'version': version,
        'product': product,
      };

  factory PortInfo.fromJson(Map<dynamic, dynamic> json) => PortInfo(
        port: json['port'] as int,
        protocol: json['protocol'] as String,
        state: json['state'] as String,
        service: json['service'] as String,
        version: json['version'] as String?,
        product: json['product'] as String?,
      );
}
