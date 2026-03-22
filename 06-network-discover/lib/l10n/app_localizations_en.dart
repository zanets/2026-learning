// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Network Discover';

  @override
  String get scan => 'Scan';

  @override
  String get cancel => 'Cancel';

  @override
  String get scanning => 'Scanning...';

  @override
  String get settings => 'Settings';

  @override
  String get devices => 'Devices';

  @override
  String scanDuration(String seconds) {
    return 'Scan completed in ${seconds}s';
  }

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get startScan => 'Press Scan to discover devices';

  @override
  String get subnet => 'Subnet';

  @override
  String get nmapPath => 'nmap Path';

  @override
  String get language => 'Language';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get verifyNmap => 'Verify nmap';

  @override
  String get nmapVerified => 'nmap verified';

  @override
  String get nmapNotFound => 'nmap not found';

  @override
  String get portScan => 'Port Scan';

  @override
  String get portScanRunning => 'Scanning ports...';

  @override
  String get openPorts => 'Open Ports';

  @override
  String get noPorts => 'No open ports found';

  @override
  String get port => 'Port';

  @override
  String get service => 'Service';

  @override
  String get version => 'Version';

  @override
  String get osDetection => 'OS Detection (-O)';

  @override
  String get confidence => 'Confidence';

  @override
  String cachedResult(String time) {
    return 'Cached result from $time';
  }

  @override
  String get logs => 'Logs';

  @override
  String get collapseLogs => 'Collapse logs';

  @override
  String get expandLogs => 'Expand logs';

  @override
  String get copied => 'Copied!';

  @override
  String get riskSafe => 'Safe';

  @override
  String get riskInfo => 'Info';

  @override
  String get riskWarn => 'Warning';

  @override
  String get riskDanger => 'Danger';

  @override
  String get securityTips => 'Security Tips';

  @override
  String get english => 'English';

  @override
  String get chinese => '繁體中文';

  @override
  String devicesFound(int count) {
    return '$count devices found';
  }

  @override
  String scanError(String error) {
    return 'Scan error: $error';
  }

  @override
  String get detectSubnet => 'Detect from default route';

  @override
  String get subnetHint => 'e.g. 192.168.1.0/24';

  @override
  String get nmapPathHint => 'e.g. /usr/bin/nmap';

  @override
  String get networkSettings => 'Network Settings';

  @override
  String get portScanOptions => 'Port Scan Options';

  @override
  String get portRange => 'Port Range';

  @override
  String get portRangeHint => 'e.g. 1-10000 or 22,80,443';

  @override
  String get timingTemplate => 'Timing Template';

  @override
  String get versionDetection => 'Version Detection (-sV)';

  @override
  String get openOnly => 'Open Ports Only (--open)';

  @override
  String get commandPreview => 'Command Preview';

  @override
  String get timeoutSettings => 'Timeout Settings';

  @override
  String get pingSweepTimeout => 'Ping Sweep Timeout (s)';

  @override
  String get portScanTimeout => 'Port Scan Timeout (s)';

  @override
  String get appSettings => 'App Settings';

  @override
  String get online => 'Online';

  @override
  String get unknown => 'Unknown';

  @override
  String get topology => 'Topology';

  @override
  String get ports => 'Ports';

  @override
  String get httpHeaders => 'HTTP Headers';

  @override
  String get scanPortsHint => 'Scan open ports on this device';

  @override
  String get reScan => 'Re-scan';

  @override
  String get fetchHeaders => 'Fetch Headers';

  @override
  String get reFetch => 'Re-fetch';

  @override
  String get httpProbeHint => 'Probe HTTP/HTTPS ports for server headers';

  @override
  String get noWebService => 'No web service responded';

  @override
  String portsResponded(int count) {
    return '$count port(s) responded';
  }
}
