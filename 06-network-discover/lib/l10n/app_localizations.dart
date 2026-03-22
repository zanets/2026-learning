import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Network Discover'**
  String get appTitle;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @scanDuration.
  ///
  /// In en, this message translates to:
  /// **'Scan completed in {seconds}s'**
  String scanDuration(String seconds);

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Press Scan to discover devices'**
  String get startScan;

  /// No description provided for @subnet.
  ///
  /// In en, this message translates to:
  /// **'Subnet'**
  String get subnet;

  /// No description provided for @nmapPath.
  ///
  /// In en, this message translates to:
  /// **'nmap Path'**
  String get nmapPath;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @verifyNmap.
  ///
  /// In en, this message translates to:
  /// **'Verify nmap'**
  String get verifyNmap;

  /// No description provided for @nmapVerified.
  ///
  /// In en, this message translates to:
  /// **'nmap verified'**
  String get nmapVerified;

  /// No description provided for @nmapNotFound.
  ///
  /// In en, this message translates to:
  /// **'nmap not found'**
  String get nmapNotFound;

  /// No description provided for @portScan.
  ///
  /// In en, this message translates to:
  /// **'Port Scan'**
  String get portScan;

  /// No description provided for @portScanRunning.
  ///
  /// In en, this message translates to:
  /// **'Scanning ports...'**
  String get portScanRunning;

  /// No description provided for @openPorts.
  ///
  /// In en, this message translates to:
  /// **'Open Ports'**
  String get openPorts;

  /// No description provided for @noPorts.
  ///
  /// In en, this message translates to:
  /// **'No open ports found'**
  String get noPorts;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @osDetection.
  ///
  /// In en, this message translates to:
  /// **'OS Detection'**
  String get osDetection;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @cachedResult.
  ///
  /// In en, this message translates to:
  /// **'Cached result from {time}'**
  String cachedResult(String time);

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @collapseLogs.
  ///
  /// In en, this message translates to:
  /// **'Collapse logs'**
  String get collapseLogs;

  /// No description provided for @expandLogs.
  ///
  /// In en, this message translates to:
  /// **'Expand logs'**
  String get expandLogs;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @riskSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get riskSafe;

  /// No description provided for @riskInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get riskInfo;

  /// No description provided for @riskWarn.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get riskWarn;

  /// No description provided for @riskDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get riskDanger;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips'**
  String get securityTips;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get chinese;

  /// No description provided for @devicesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} devices found'**
  String devicesFound(int count);

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan error: {error}'**
  String scanError(String error);

  /// No description provided for @detectSubnet.
  ///
  /// In en, this message translates to:
  /// **'Detect from default route'**
  String get detectSubnet;

  /// No description provided for @subnetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.0/24'**
  String get subnetHint;

  /// No description provided for @nmapPathHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. /usr/bin/nmap'**
  String get nmapPathHint;

  /// No description provided for @networkSettings.
  ///
  /// In en, this message translates to:
  /// **'Network Settings'**
  String get networkSettings;

  /// No description provided for @timeoutSettings.
  ///
  /// In en, this message translates to:
  /// **'Timeout Settings'**
  String get timeoutSettings;

  /// No description provided for @pingSweepTimeout.
  ///
  /// In en, this message translates to:
  /// **'Ping Sweep Timeout (s)'**
  String get pingSweepTimeout;

  /// No description provided for @portScanTimeout.
  ///
  /// In en, this message translates to:
  /// **'Port Scan Timeout (s)'**
  String get portScanTimeout;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
