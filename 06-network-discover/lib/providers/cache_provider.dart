import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_cache_entry.dart';
import '../models/port_info.dart';
import '../services/hive_service.dart';
import '../services/port_scan_service.dart';

class CacheNotifier extends Notifier<Map<String, ScanCacheEntry>> {
  @override
  Map<String, ScanCacheEntry> build() {
    final box = HiveService.cache;
    final result = <String, ScanCacheEntry>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        result[key as String] = ScanCacheEntry.fromJson(raw);
      }
    }
    return result;
  }

  Future<void> save(String ip, List<PortInfo> ports, OsMatch? os) async {
    final entry = ScanCacheEntry(
      scannedAt: DateTime.now(),
      ports: List.unmodifiable(ports),
      osGuess: os?.name,
      osAccuracy: os?.accuracy,
    );
    state = {...state, ip: entry};
    await HiveService.cache.put(ip, entry.toJson());
  }

  ScanCacheEntry? get(String ip) => state[ip];
}

final cacheProvider = NotifierProvider<CacheNotifier, Map<String, ScanCacheEntry>>(
  CacheNotifier.new,
);
