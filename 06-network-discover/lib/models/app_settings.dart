class AppSettings {
  final String subnet;
  final String nmapPath;
  final String? localeCode;
  final int pingSweepTimeout; // seconds
  final int portScanTimeout;  // seconds
  final int pingWaitMs;       // milliseconds for -W flag

  // Port scan options
  final String portRange;      // e.g. "1-10000" | "1-65535" | "22,80,443"
  final int timingTemplate;    // 1-5 → -T1 … -T5
  final bool versionDetection; // -sV
  final bool osDetection;      // -O  (requires sudo)
  final bool openOnly;         // --open

  const AppSettings({
    required this.subnet,
    required this.nmapPath,
    this.localeCode,
    this.pingSweepTimeout = 120,
    this.portScanTimeout = 300,
    this.pingWaitMs = 1000,
    this.portRange = '1-10000',
    this.timingTemplate = 4,
    this.versionDetection = true,
    this.osDetection = true,
    this.openOnly = true,
  });

  AppSettings copyWith({
    String? subnet,
    String? nmapPath,
    String? localeCode,
    int? pingSweepTimeout,
    int? portScanTimeout,
    int? pingWaitMs,
    String? portRange,
    int? timingTemplate,
    bool? versionDetection,
    bool? osDetection,
    bool? openOnly,
    bool clearLocale = false,
  }) {
    return AppSettings(
      subnet: subnet ?? this.subnet,
      nmapPath: nmapPath ?? this.nmapPath,
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      pingSweepTimeout: pingSweepTimeout ?? this.pingSweepTimeout,
      portScanTimeout: portScanTimeout ?? this.portScanTimeout,
      pingWaitMs: pingWaitMs ?? this.pingWaitMs,
      portRange: portRange ?? this.portRange,
      timingTemplate: timingTemplate ?? this.timingTemplate,
      versionDetection: versionDetection ?? this.versionDetection,
      osDetection: osDetection ?? this.osDetection,
      openOnly: openOnly ?? this.openOnly,
    );
  }

  Map<String, dynamic> toJson() => {
        'subnet': subnet,
        'nmapPath': nmapPath,
        'localeCode': localeCode,
        'pingSweepTimeout': pingSweepTimeout,
        'portScanTimeout': portScanTimeout,
        'pingWaitMs': pingWaitMs,
        'portRange': portRange,
        'timingTemplate': timingTemplate,
        'versionDetection': versionDetection,
        'osDetection': osDetection,
        'openOnly': openOnly,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        subnet: json['subnet'] as String,
        nmapPath: json['nmapPath'] as String,
        localeCode: json['localeCode'] as String?,
        pingSweepTimeout: (json['pingSweepTimeout'] as int?) ?? 120,
        portScanTimeout: (json['portScanTimeout'] as int?) ?? 300,
        pingWaitMs: (json['pingWaitMs'] as int?) ?? 1000,
        portRange: (json['portRange'] as String?) ?? '1-10000',
        timingTemplate: (json['timingTemplate'] as int?) ?? 4,
        versionDetection: (json['versionDetection'] as bool?) ?? true,
        osDetection: (json['osDetection'] as bool?) ?? true,
        openOnly: (json['openOnly'] as bool?) ?? true,
      );

  /// Returns the effective nmap command as a human-readable string for display.
  String get portScanPreview {
    final args = _buildPortScanArgs('<ip>');
    return 'nmap ${args.join(' ')}';
  }

  List<String> buildPortScanArgs(String ip) => _buildPortScanArgs(ip);

  List<String> _buildPortScanArgs(String ip) {
    return [
      if (versionDetection) '-sV',
      if (osDetection) '-O',
      if (openOnly) '--open',
      '-T$timingTemplate',
      '-p', portRange,
      '--stats-every', '2s',
      '-oX', '-',
      ip,
    ];
  }
}
