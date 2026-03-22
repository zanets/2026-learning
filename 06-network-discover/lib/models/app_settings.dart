class AppSettings {
  final String subnet;
  final String nmapPath;
  final String? localeCode;

  const AppSettings({
    required this.subnet,
    required this.nmapPath,
    this.localeCode,
  });

  AppSettings copyWith({
    String? subnet,
    String? nmapPath,
    String? localeCode,
    bool clearLocale = false,
  }) {
    return AppSettings(
      subnet: subnet ?? this.subnet,
      nmapPath: nmapPath ?? this.nmapPath,
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
    );
  }

  Map<String, dynamic> toJson() => {
        'subnet': subnet,
        'nmapPath': nmapPath,
        'localeCode': localeCode,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        subnet: json['subnet'] as String,
        nmapPath: json['nmapPath'] as String,
        localeCode: json['localeCode'] as String?,
      );
}
