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

  /// No description provided for @language_malay.
  ///
  /// In en, this message translates to:
  /// **'Malay'**
  String get language_malay;

  /// No description provided for @language_chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get language_chinese;

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

  /// No description provided for @level_label.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get level_label;

  /// No description provided for @to_level_x.
  ///
  /// In en, this message translates to:
  /// **'{percent}% to Level {level}'**
  String to_level_x(Object level, Object percent);

  /// No description provided for @tier_seedling.
  ///
  /// In en, this message translates to:
  /// **'Seedling'**
  String get tier_seedling;

  /// No description provided for @tier_guardian.
  ///
  /// In en, this message translates to:
  /// **'Adherence Guardian'**
  String get tier_guardian;

  /// No description provided for @tier_hero.
  ///
  /// In en, this message translates to:
  /// **'Adherence Hero'**
  String get tier_hero;

  /// No description provided for @tier_sentinel.
  ///
  /// In en, this message translates to:
  /// **'Diamond Sentinel'**
  String get tier_sentinel;

  /// No description provided for @tier_immortal.
  ///
  /// In en, this message translates to:
  /// **'Adherence Immortal'**
  String get tier_immortal;

  /// No description provided for @oracle_title.
  ///
  /// In en, this message translates to:
  /// **'THE CLINICAL ORACLE'**
  String get oracle_title;

  /// No description provided for @oracle_description.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced longitudinal pattern detection. (Requires Premium & Level 50+)'**
  String get oracle_description;

  /// No description provided for @oracle_button.
  ///
  /// In en, this message translates to:
  /// **'CONSULT THE ORACLE'**
  String get oracle_button;

  /// No description provided for @premium_required.
  ///
  /// In en, this message translates to:
  /// **'The Clinical Oracle requires a Premium subscription.'**
  String get premium_required;

  /// No description provided for @immortal_required.
  ///
  /// In en, this message translates to:
  /// **'The Clinical Oracle is only accessible to \'Adherence Immortals\' (Level 50+). Keep taking your medicine to unlock!'**
  String get immortal_required;

  /// No description provided for @oracle_insights.
  ///
  /// In en, this message translates to:
  /// **'Oracle Insights'**
  String get oracle_insights;

  /// No description provided for @oracle_empty.
  ///
  /// In en, this message translates to:
  /// **'The Oracle is silent. Insufficient data for deep analysis.'**
  String get oracle_empty;

  /// No description provided for @oracle_error.
  ///
  /// In en, this message translates to:
  /// **'Oracle Sync Failure: High-fidelity pattern analysis requires more consistent data logging.'**
  String get oracle_error;

  /// No description provided for @missed_label.
  ///
  /// In en, this message translates to:
  /// **'MISSED'**
  String get missed_label;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @filter_missed.
  ///
  /// In en, this message translates to:
  /// **'Missed Only'**
  String get filter_missed;

  /// No description provided for @reading_saved.
  ///
  /// In en, this message translates to:
  /// **'Reading Saved'**
  String get reading_saved;

  /// No description provided for @health_alert.
  ///
  /// In en, this message translates to:
  /// **'Health Alert'**
  String get health_alert;

  /// No description provided for @health_vitals.
  ///
  /// In en, this message translates to:
  /// **'Health Vitals'**
  String get health_vitals;

  /// No description provided for @add_new_reading.
  ///
  /// In en, this message translates to:
  /// **'Add New Reading'**
  String get add_new_reading;

  /// No description provided for @save_record.
  ///
  /// In en, this message translates to:
  /// **'SAVE RECORD'**
  String get save_record;

  /// No description provided for @recent_history.
  ///
  /// In en, this message translates to:
  /// **'RECENT HISTORY'**
  String get recent_history;

  /// No description provided for @entries_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Entries'**
  String entries_count(Object count);

  /// No description provided for @no_readings_yet.
  ///
  /// In en, this message translates to:
  /// **'No readings recorded yet'**
  String get no_readings_yet;

  /// No description provided for @missed_dose_guide.
  ///
  /// In en, this message translates to:
  /// **'Missed Dose Guide'**
  String get missed_dose_guide;

  /// No description provided for @what_to_do_late.
  ///
  /// In en, this message translates to:
  /// **'WHAT TO DO IF > 2 HOURS LATE'**
  String get what_to_do_late;

  /// No description provided for @safe_window.
  ///
  /// In en, this message translates to:
  /// **'Safe Window'**
  String get safe_window;

  /// No description provided for @clinical_references.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL REFERENCES'**
  String get clinical_references;

  /// No description provided for @upgrade_to_premium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgrade_to_premium;

  /// No description provided for @maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybe_later;

  /// No description provided for @view_plans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get view_plans;

  /// No description provided for @ai_pharmacist.
  ///
  /// In en, this message translates to:
  /// **'AI Pharmacist'**
  String get ai_pharmacist;

  /// No description provided for @typing_indicator.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing_indicator;

  /// No description provided for @premium_feature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premium_feature;

  /// No description provided for @pro_label.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro_label;

  /// No description provided for @share_data.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get share_data;

  /// No description provided for @caregiver_code_label.
  ///
  /// In en, this message translates to:
  /// **'Your unique caregiver code:'**
  String get caregiver_code_label;

  /// No description provided for @copy_code.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copy_code;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @guest_login.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guest_login;

  /// No description provided for @error_parsing_med.
  ///
  /// In en, this message translates to:
  /// **'Error parsing medication information.'**
  String get error_parsing_med;

  /// No description provided for @health_adherence_report.
  ///
  /// In en, this message translates to:
  /// **'HEALTH ADHERENCE REPORT'**
  String get health_adherence_report;

  /// No description provided for @generated_by_ai.
  ///
  /// In en, this message translates to:
  /// **'Generated by AI Medication Manager'**
  String get generated_by_ai;

  /// No description provided for @page_info.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String page_info(Object current, Object total);

  /// No description provided for @patient_info.
  ///
  /// In en, this message translates to:
  /// **'PATIENT INFORMATION'**
  String get patient_info;

  /// No description provided for @report_period.
  ///
  /// In en, this message translates to:
  /// **'Report Period: Last 30 Days'**
  String get report_period;

  /// No description provided for @overall_adherence.
  ///
  /// In en, this message translates to:
  /// **'Overall Adherence'**
  String get overall_adherence;

  /// No description provided for @medication_summary.
  ///
  /// In en, this message translates to:
  /// **'MEDICATION SUMMARY'**
  String get medication_summary;

  /// No description provided for @health_vital_readings.
  ///
  /// In en, this message translates to:
  /// **'HEALTH VITAL READINGS'**
  String get health_vital_readings;

  /// No description provided for @recent_dosage_logs.
  ///
  /// In en, this message translates to:
  /// **'RECENT DOSAGE LOGS'**
  String get recent_dosage_logs;

  /// No description provided for @ai_clinical_summary.
  ///
  /// In en, this message translates to:
  /// **'AI CLINICAL SUMMARY (BY GEMINI)'**
  String get ai_clinical_summary;

  /// No description provided for @clinician_review_recommended.
  ///
  /// In en, this message translates to:
  /// **'Clinician Review Recommended'**
  String get clinician_review_recommended;

  /// No description provided for @clinical_report.
  ///
  /// In en, this message translates to:
  /// **'Clinical Report'**
  String get clinical_report;

  /// No description provided for @generate_pdf.
  ///
  /// In en, this message translates to:
  /// **'GENERATE PDF REPORT'**
  String get generate_pdf;

  /// No description provided for @analyzing_patterns.
  ///
  /// In en, this message translates to:
  /// **'Gemini is analyzing health patterns...'**
  String get analyzing_patterns;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @oracle_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Oracle sync failed: {error}'**
  String oracle_sync_error(Object error);

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @glucose_sugar.
  ///
  /// In en, this message translates to:
  /// **'Glucose (Sugar)'**
  String get glucose_sugar;

  /// No description provided for @blood_pressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get blood_pressure;

  /// No description provided for @inr_warfarin.
  ///
  /// In en, this message translates to:
  /// **'INR (Warfarin)'**
  String get inr_warfarin;

  /// No description provided for @unit_mmol_l.
  ///
  /// In en, this message translates to:
  /// **'mmol/L'**
  String get unit_mmol_l;

  /// No description provided for @unit_mm_hg.
  ///
  /// In en, this message translates to:
  /// **'mmHg'**
  String get unit_mm_hg;

  /// No description provided for @unit_ratio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get unit_ratio;

  /// No description provided for @abnormal_glucose.
  ///
  /// In en, this message translates to:
  /// **'Abnormal Glucose Level. Please consult a doctor immediately.'**
  String get abnormal_glucose;

  /// No description provided for @inr_out_of_range.
  ///
  /// In en, this message translates to:
  /// **'INR out of range (Target 2.0-3.0 usually). Check with your doctor!'**
  String get inr_out_of_range;

  /// No description provided for @share_report.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get share_report;

  /// No description provided for @my_health_report.
  ///
  /// In en, this message translates to:
  /// **'My Health Report'**
  String get my_health_report;

  /// No description provided for @filter_label.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get filter_label;

  /// No description provided for @no_missed_doses.
  ///
  /// In en, this message translates to:
  /// **'No missed doses recorded.'**
  String get no_missed_doses;

  /// No description provided for @no_history.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get no_history;

  /// No description provided for @free_tier_history_note.
  ///
  /// In en, this message translates to:
  /// **'Free tier shows last 7 days. Upgrade to see full history.'**
  String get free_tier_history_note;

  /// No description provided for @appearance_language.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get appearance_language;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @health_support.
  ///
  /// In en, this message translates to:
  /// **'Health Support'**
  String get health_support;

  /// No description provided for @doctor_report_title.
  ///
  /// In en, this message translates to:
  /// **'Doctor Report'**
  String get doctor_report_title;

  /// No description provided for @doctor_report_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a medication history PDF'**
  String get doctor_report_subtitle;

  /// No description provided for @share_data_title.
  ///
  /// In en, this message translates to:
  /// **'Share My Data'**
  String get share_data_title;

  /// No description provided for @share_data_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Link with a caregiver'**
  String get share_data_subtitle;

  /// No description provided for @monitoring_section.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoring_section;

  /// No description provided for @caregiver_access_title.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Access'**
  String get caregiver_access_title;

  /// No description provided for @caregiver_access_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor someone else\'s health'**
  String get caregiver_access_subtitle;

  /// No description provided for @account_section.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_section;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @premium_required_desc.
  ///
  /// In en, this message translates to:
  /// **'{feature} is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'**
  String premium_required_desc(Object feature);

  /// No description provided for @guest_email.
  ///
  /// In en, this message translates to:
  /// **'No email linked'**
  String get guest_email;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @caregiver_code_desc.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your caregiver to allow them to monitor your health in real-time.'**
  String get caregiver_code_desc;

  /// No description provided for @missed_dose_guide_title.
  ///
  /// In en, this message translates to:
  /// **'Missed Dose Guide'**
  String get missed_dose_guide_title;

  /// No description provided for @od_title.
  ///
  /// In en, this message translates to:
  /// **'Once Daily (OD)'**
  String get od_title;

  /// No description provided for @od_protocol.
  ///
  /// In en, this message translates to:
  /// **'Take the missed dose as soon as it is remembered, up to 8 hours late.\n\nAfter 8 hours, skip the dose and wait for your next scheduled time.'**
  String get od_protocol;

  /// No description provided for @multiple_times_title.
  ///
  /// In en, this message translates to:
  /// **'Multiple Times a Day'**
  String get multiple_times_title;

  /// No description provided for @multiple_times_protocol.
  ///
  /// In en, this message translates to:
  /// **'If more than 2 hours late, skip the missed dose and wait until the next dose is due.\n\nDo not double your dose to catch up.'**
  String get multiple_times_protocol;

  /// No description provided for @side_effects_title.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get side_effects_title;

  /// No description provided for @side_effects_protocol.
  ///
  /// In en, this message translates to:
  /// **'Monitor for side effects, as these may be increased if the dosing interval is shorter.'**
  String get side_effects_protocol;

  /// No description provided for @meals_food_title.
  ///
  /// In en, this message translates to:
  /// **'Meals & Food'**
  String get meals_food_title;

  /// No description provided for @meals_food_protocol.
  ///
  /// In en, this message translates to:
  /// **'You can usually ignore warnings about taking the medicine with or without meals, unless there’s a significant risk of serious side-effects.'**
  String get meals_food_protocol;

  /// No description provided for @forgiveness_title.
  ///
  /// In en, this message translates to:
  /// **'Medication \"Forgiveness\"'**
  String get forgiveness_title;

  /// No description provided for @forgiveness_protocol.
  ///
  /// In en, this message translates to:
  /// **'Scientifically, \"forgiveness\" describes how much your medicine protects you after a missed dose.\n\n• Forgiving: Aspirin, Amlodipine (long-acting effects).\n• Unforgiving: Blood thinners (Rivaroxaban), Epilepsy meds, and Contraceptives. These require strict timing.'**
  String get forgiveness_protocol;

  /// No description provided for @safe_window_title.
  ///
  /// In en, this message translates to:
  /// **'Safe Window'**
  String get safe_window_title;

  /// No description provided for @safe_window_protocol.
  ///
  /// In en, this message translates to:
  /// **'Once Daily (OD): You can take your dose up to 8 hours late. Others: 2 hours strictly.'**
  String get safe_window_protocol;

  /// No description provided for @caregiver_hub_title.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Hub'**
  String get caregiver_hub_title;

  /// No description provided for @caregiver_login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue.'**
  String get caregiver_login_prompt;

  /// No description provided for @caregiver_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Dashboard'**
  String get caregiver_dashboard;

  /// No description provided for @caregiver_dashboard_desc.
  ///
  /// In en, this message translates to:
  /// **'Ensuring loved ones stay on track with their health.'**
  String get caregiver_dashboard_desc;

  /// No description provided for @pending_invitations.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pending_invitations;

  /// No description provided for @your_patients.
  ///
  /// In en, this message translates to:
  /// **'Your Patients'**
  String get your_patients;

  /// No description provided for @no_patients_linked.
  ///
  /// In en, this message translates to:
  /// **'No patients linked yet.'**
  String get no_patients_linked;

  /// No description provided for @invite_instructions.
  ///
  /// In en, this message translates to:
  /// **'Patients can invite you using your email.'**
  String get invite_instructions;

  /// No description provided for @sharing_health_data.
  ///
  /// In en, this message translates to:
  /// **'Wants to share their health data'**
  String get sharing_health_data;

  /// No description provided for @adherence_label.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence_label;

  /// No description provided for @adherence_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get adherence_good;

  /// No description provided for @health_academy_title.
  ///
  /// In en, this message translates to:
  /// **'Health Academy'**
  String get health_academy_title;

  /// No description provided for @insulin_pen_title.
  ///
  /// In en, this message translates to:
  /// **'How to Use Insulin Pen'**
  String get insulin_pen_title;

  /// No description provided for @insulin_pen_desc.
  ///
  /// In en, this message translates to:
  /// **'Official MOH guide on correct insulin injection technique.'**
  String get insulin_pen_desc;

  /// No description provided for @inhaler_technique_title.
  ///
  /// In en, this message translates to:
  /// **'Inhaler Technique (MDI)'**
  String get inhaler_technique_title;

  /// No description provided for @inhaler_technique_desc.
  ///
  /// In en, this message translates to:
  /// **'How to use an inhaler for asthma correctly.'**
  String get inhaler_technique_desc;

  /// No description provided for @know_warfarin_title.
  ///
  /// In en, this message translates to:
  /// **'Know Your Warfarin'**
  String get know_warfarin_title;

  /// No description provided for @know_warfarin_desc.
  ///
  /// In en, this message translates to:
  /// **'Contraindications and important info for heart patients.'**
  String get know_warfarin_desc;

  /// No description provided for @hypoglycemia_signs_title.
  ///
  /// In en, this message translates to:
  /// **'Signs of Hypoglycemia'**
  String get hypoglycemia_signs_title;

  /// No description provided for @hypoglycemia_signs_desc.
  ///
  /// In en, this message translates to:
  /// **'What to do if your blood sugar is too low?'**
  String get hypoglycemia_signs_desc;

  /// No description provided for @official_missed_dose_protocol_title.
  ///
  /// In en, this message translates to:
  /// **'Official Missed Dose Protocol'**
  String get official_missed_dose_protocol_title;

  /// No description provided for @official_missed_dose_protocol_desc.
  ///
  /// In en, this message translates to:
  /// **'What to do if you or the person you care for misses a dose.'**
  String get official_missed_dose_protocol_desc;

  /// No description provided for @know_your_medicine_title.
  ///
  /// In en, this message translates to:
  /// **'Know Your Medicine'**
  String get know_your_medicine_title;

  /// No description provided for @know_your_medicine_desc.
  ///
  /// In en, this message translates to:
  /// **'General tips for safe medication intake.'**
  String get know_your_medicine_desc;

  /// No description provided for @expert_clinical_analysis.
  ///
  /// In en, this message translates to:
  /// **'Expert Clinical Analysis'**
  String get expert_clinical_analysis;

  /// No description provided for @clinical_analysis_desc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered summary of your medication adherence and health vitals history.'**
  String get clinical_analysis_desc;

  /// No description provided for @precision_adherence_tracking.
  ///
  /// In en, this message translates to:
  /// **'Precision Adherence Tracking'**
  String get precision_adherence_tracking;

  /// No description provided for @health_vital_readings_desc.
  ///
  /// In en, this message translates to:
  /// **'Health Vital Readings (BP, Sugar)'**
  String get health_vital_readings_desc;

  /// No description provided for @ai_clinician_insights.
  ///
  /// In en, this message translates to:
  /// **'AI Clinician Pattern Insights'**
  String get ai_clinician_insights;
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
