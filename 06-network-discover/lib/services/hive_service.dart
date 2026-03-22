import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _settingsBox = 'settings';
  static const _cacheBox = 'scan_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_settingsBox);
    await Hive.openBox<Map>(_cacheBox);
  }

  static Box<Map> get settings => Hive.box<Map>(_settingsBox);
  static Box<Map> get cache => Hive.box<Map>(_cacheBox);
}
