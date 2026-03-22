class NetworkDevice {
  final String ip;
  final String? mac;
  final String? hostname;
  final String? vendor;
  final DateTime discoveredAt;

  const NetworkDevice({
    required this.ip,
    this.mac,
    this.hostname,
    this.vendor,
    required this.discoveredAt,
  });

  String get displayName => hostname?.isNotEmpty == true ? hostname! : ip;
  String get macDisplay => mac ?? 'Unknown MAC';
  String get vendorDisplay => vendor ?? 'Unknown Vendor';
}
