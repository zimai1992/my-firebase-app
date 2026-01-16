import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
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
    Locale('ms'),
    Locale('zh')
  ];

  /// No description provided for @add_medicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get add_medicine;

  /// No description provided for @medicine_name.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicine_name;

  /// No description provided for @medicine_dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage (e.g., 500mg, 1 tablet)'**
  String get medicine_dosage;

  /// No description provided for @medicine_frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get medicine_frequency;

  /// No description provided for @special_instructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions (e.g., take with food)'**
  String get special_instructions;

  /// No description provided for @verification_prompt.
  ///
  /// In en, this message translates to:
  /// **'I have verified the medicine name, dosage, and frequency with a healthcare professional.'**
  String get verification_prompt;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a medicine name'**
  String get please_enter_name;

  /// No description provided for @please_enter_dosage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a dosage'**
  String get please_enter_dosage;

  /// No description provided for @please_select_frequency.
  ///
  /// In en, this message translates to:
  /// **'Please select a frequency'**
  String get please_select_frequency;

  /// No description provided for @select_frequency.
  ///
  /// In en, this message translates to:
  /// **'Select Frequency'**
  String get select_frequency;

  /// No description provided for @frequency_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequency_daily;

  /// No description provided for @frequency_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequency_weekly;

  /// No description provided for @frequency_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequency_monthly;

  /// No description provided for @schedule_timings.
  ///
  /// In en, this message translates to:
  /// **'Schedule Timings'**
  String get schedule_timings;

  /// No description provided for @evenly_spaced.
  ///
  /// In en, this message translates to:
  /// **'Evenly Spaced'**
  String get evenly_spaced;

  /// No description provided for @pick_times.
  ///
  /// In en, this message translates to:
  /// **'Pick Times'**
  String get pick_times;

  /// No description provided for @scheduled_at.
  ///
  /// In en, this message translates to:
  /// **'Scheduled at: {times}'**
  String scheduled_at(Object times);

  /// No description provided for @time_header.
  ///
  /// In en, this message translates to:
  /// **'Time {index}'**
  String time_header(Object index);

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @times_a_day.
  ///
  /// In en, this message translates to:
  /// **'{count} times a day'**
  String times_a_day(Object count);

  /// No description provided for @every_x_days.
  ///
  /// In en, this message translates to:
  /// **'Every {count} days'**
  String every_x_days(Object count);

  /// No description provided for @specific_days_of_week.
  ///
  /// In en, this message translates to:
  /// **'Specific days of the week'**
  String get specific_days_of_week;

  /// No description provided for @specific_dates_of_month.
  ///
  /// In en, this message translates to:
  /// **'Specific dates of the month'**
  String get specific_dates_of_month;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medicine?'**
  String get confirm_delete;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit_medicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get edit_medicine;

  /// No description provided for @how_many_times.
  ///
  /// In en, this message translates to:
  /// **'How many times?'**
  String get how_many_times;

  /// No description provided for @how_often.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get how_often;

  /// No description provided for @save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_button;

  /// No description provided for @verify_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Information'**
  String get verify_title;

  /// No description provided for @pharmacist_note.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist\'s Note'**
  String get pharmacist_note;

  /// No description provided for @upgrade_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade_appbar_title;

  /// No description provided for @premium_icon_label.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium_icon_label;

  /// No description provided for @upgrade_to_pro_title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgrade_to_pro_title;

  /// No description provided for @upgrade_to_pro_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and get the best experience.'**
  String get upgrade_to_pro_subtitle;

  /// No description provided for @feature_unlimited_medicines.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Medicines'**
  String get feature_unlimited_medicines;

  /// No description provided for @feature_export_reports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get feature_export_reports;

  /// No description provided for @feature_family_profiles.
  ///
  /// In en, this message translates to:
  /// **'Family Profiles'**
  String get feature_family_profiles;

  /// No description provided for @plan_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get plan_monthly;

  /// No description provided for @price_monthly.
  ///
  /// In en, this message translates to:
  /// **'\$9.99'**
  String get price_monthly;

  /// No description provided for @per_month.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get per_month;

  /// No description provided for @plan_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get plan_yearly;

  /// No description provided for @price_yearly.
  ///
  /// In en, this message translates to:
  /// **'\$99.99'**
  String get price_yearly;

  /// No description provided for @save_20_percent.
  ///
  /// In en, this message translates to:
  /// **'Save 20%'**
  String get save_20_percent;

  /// No description provided for @subscribe_button_label.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribe_button_label;

  /// No description provided for @subscribed_to_premium.
  ///
  /// In en, this message translates to:
  /// **'You are already subscribed to premium.'**
  String get subscribed_to_premium;

  /// No description provided for @subscribe_now.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe_now;

  /// No description provided for @restore_purchases_button_label.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore_purchases_button_label;

  /// No description provided for @restore_purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore_purchases;

  /// No description provided for @price_card_label.
  ///
  /// In en, this message translates to:
  /// **'{plan} - {price}'**
  String price_card_label(Object plan, Object price);

  /// No description provided for @popular_plan_label.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular_plan_label;

  /// No description provided for @selected_plan_label.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected_plan_label;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get language_spanish;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @language_section_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_section_title;

  /// No description provided for @tour_page_1_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your personal medical assistant!'**
  String get tour_page_1_title;

  /// No description provided for @tour_page_1_description.
  ///
  /// In en, this message translates to:
  /// **'Easily add and manage your medications. Set reminders so you never miss a dose.'**
  String get tour_page_1_description;

  /// No description provided for @tour_page_2_title.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get tour_page_2_title;

  /// No description provided for @tour_page_2_description.
  ///
  /// In en, this message translates to:
  /// **'Keep a log of your medication history. See what you have taken and when.'**
  String get tour_page_2_description;

  /// No description provided for @tour_page_3_title.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your health'**
  String get tour_page_3_title;

  /// No description provided for @tour_page_3_description.
  ///
  /// In en, this message translates to:
  /// **'Get insights into your medication adherence and share reports with your doctor.'**
  String get tour_page_3_description;

  /// No description provided for @get_started_button.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started_button;

  /// No description provided for @lifestyle_warnings.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Warnings'**
  String get lifestyle_warnings;
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
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
