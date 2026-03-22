class AppSettings {
  final String subnet;
  final String nmapPath;
  final String? localeCode;
  final int pingSweepTimeout;  // seconds
  final int portScanTimeout;   // seconds

  const AppSettings({
    required this.subnet,
    required this.nmapPath,
    this.localeCode,
    this.pingSweepTimeout = 120,
    this.portScanTimeout = 300,
  });

  AppSettings copyWith({
    String? subnet,
    String? nmapPath,
    String? localeCode,
    int? pingSweepTimeout,
    int? portScanTimeout,
    bool clearLocale = false,
  }) {
    return AppSettings(
      subnet: subnet ?? this.subnet,
      nmapPath: nmapPath ?? this.nmapPath,
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      pingSweepTimeout: pingSweepTimeout ?? this.pingSweepTimeout,
      portScanTimeout: portScanTimeout ?? this.portScanTimeout,
    );
  }

  Map<String, dynamic> toJson() => {
        'subnet': subnet,
        'nmapPath': nmapPath,
        'localeCode': localeCode,
        'pingSweepTimeout': pingSweepTimeout,
        'portScanTimeout': portScanTimeout,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        subnet: json['subnet'] as String,
        nmapPath: json['nmapPath'] as String,
        localeCode: json['localeCode'] as String?,
        pingSweepTimeout: (json['pingSweepTimeout'] as int?) ?? 120,
        portScanTimeout: (json['portScanTimeout'] as int?) ?? 300,
      );
}
