import 'port_info.dart';

class ScanCacheEntry {
  final DateTime scannedAt;
  final List<PortInfo> ports;
  final String? osGuess;
  final int? osAccuracy;

  const ScanCacheEntry({
    required this.scannedAt,
    required this.ports,
    this.osGuess,
    this.osAccuracy,
  });

  String get relativeTime {
    final diff = DateTime.now().difference(scannedAt);
    if (diff.inSeconds < 60) return '剛剛';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分鐘前';
    if (diff.inHours < 24) return '${diff.inHours} 小時前';
    return '${diff.inDays} 天前';
  }

  Map<String, dynamic> toJson() => {
        'scannedAt': scannedAt.toIso8601String(),
        'ports': ports.map((p) => p.toJson()).toList(),
        'osGuess': osGuess,
        'osAccuracy': osAccuracy,
      };

  factory ScanCacheEntry.fromJson(Map<dynamic, dynamic> json) {
    final rawPorts = json['ports'] as List<dynamic>? ?? [];
    return ScanCacheEntry(
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      ports: rawPorts.map((p) => PortInfo.fromJson(p as Map)).toList(),
      osGuess: json['osGuess'] as String?,
      osAccuracy: json['osAccuracy'] as int?,
    );
  }
}
