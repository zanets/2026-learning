// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '網路探索';

  @override
  String get scan => '掃描';

  @override
  String get cancel => '取消';

  @override
  String get scanning => '掃描中...';

  @override
  String get settings => '設定';

  @override
  String get devices => '裝置';

  @override
  String scanDuration(String seconds) {
    return '掃描完成，耗時 $seconds 秒';
  }

  @override
  String get noDevicesFound => '未找到裝置';

  @override
  String get startScan => '按下掃描以探索裝置';

  @override
  String get subnet => '子網路';

  @override
  String get nmapPath => 'nmap 路徑';

  @override
  String get language => '語言';

  @override
  String get saveSettings => '儲存設定';

  @override
  String get settingsSaved => '設定已儲存';

  @override
  String get verifyNmap => '驗證 nmap';

  @override
  String get nmapVerified => 'nmap 驗證成功';

  @override
  String get nmapNotFound => '找不到 nmap';

  @override
  String get portScan => '連接埠掃描';

  @override
  String get portScanRunning => '連接埠掃描中...';

  @override
  String get openPorts => '開放連接埠';

  @override
  String get noPorts => '未找到開放連接埠';

  @override
  String get port => '連接埠';

  @override
  String get service => '服務';

  @override
  String get version => '版本';

  @override
  String get osDetection => '作業系統偵測';

  @override
  String get confidence => '信心度';

  @override
  String cachedResult(String time) {
    return '快取結果（$time）';
  }

  @override
  String get logs => '記錄';

  @override
  String get collapseLogs => '收起記錄';

  @override
  String get expandLogs => '展開記錄';

  @override
  String get copied => '已複製！';

  @override
  String get riskSafe => '安全';

  @override
  String get riskInfo => '資訊';

  @override
  String get riskWarn => '警告';

  @override
  String get riskDanger => '危險';

  @override
  String get securityTips => '安全建議';

  @override
  String get english => 'English';

  @override
  String get chinese => '繁體中文';

  @override
  String devicesFound(int count) {
    return '找到 $count 台裝置';
  }

  @override
  String scanError(String error) {
    return '掃描錯誤：$error';
  }

  @override
  String get detectSubnet => '從預設路由偵測';

  @override
  String get subnetHint => '例如：192.168.1.0/24';

  @override
  String get nmapPathHint => '例如：/usr/bin/nmap';

  @override
  String get networkSettings => '網路設定';

  @override
  String get appSettings => '應用程式設定';

  @override
  String get online => '連線中';

  @override
  String get unknown => '未知';
}
