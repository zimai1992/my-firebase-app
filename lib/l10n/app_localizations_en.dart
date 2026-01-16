// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get add_medicine => 'Add Medicine';

  @override
  String get medicine_name => 'Medicine Name';

  @override
  String get medicine_dosage => 'Dosage (e.g., 500mg, 1 tablet)';

  @override
  String get medicine_frequency => 'Frequency';

  @override
  String get special_instructions =>
      'Special Instructions (e.g., take with food)';

  @override
  String get verification_prompt =>
      'I have verified the medicine name, dosage, and frequency with a healthcare professional.';

  @override
  String get please_enter_name => 'Please enter a medicine name';

  @override
  String get please_enter_dosage => 'Please enter a dosage';

  @override
  String get please_select_frequency => 'Please select a frequency';

  @override
  String get select_frequency => 'Select Frequency';

  @override
  String get frequency_daily => 'Daily';

  @override
  String get frequency_weekly => 'Weekly';

  @override
  String get frequency_monthly => 'Monthly';

  @override
  String get schedule_timings => 'Schedule Timings';

  @override
  String get evenly_spaced => 'Evenly Spaced';

  @override
  String get pick_times => 'Pick Times';

  @override
  String scheduled_at(Object times) {
    return 'Scheduled at: $times';
  }

  @override
  String time_header(Object index) {
    return 'Time $index';
  }

  @override
  String get save_changes => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String times_a_day(Object count) {
    return '$count times a day';
  }

  @override
  String every_x_days(Object count) {
    return 'Every $count days';
  }

  @override
  String get specific_days_of_week => 'Specific days of the week';

  @override
  String get specific_dates_of_month => 'Specific dates of the month';

  @override
  String get times => 'Times';

  @override
  String get count => 'Count';

  @override
  String get interval => 'Interval';

  @override
  String get ok => 'OK';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get confirm_delete => 'Are you sure you want to delete this medicine?';

  @override
  String get delete => 'Delete';

  @override
  String get edit_medicine => 'Edit Medicine';

  @override
  String get how_many_times => 'How many times?';

  @override
  String get how_often => 'How often?';

  @override
  String get save_button => 'Save';

  @override
  String get verify_title => 'Verify Information';

  @override
  String get pharmacist_note => 'Pharmacist\'s Note';

  @override
  String get upgrade_appbar_title => 'Upgrade';

  @override
  String get premium_icon_label => 'PREMIUM';

  @override
  String get upgrade_to_pro_title => 'Upgrade to Pro';

  @override
  String get upgrade_to_pro_subtitle =>
      'Unlock all features and get the best experience.';

  @override
  String get feature_unlimited_medicines => 'Unlimited Medicines';

  @override
  String get feature_export_reports => 'Export Reports';

  @override
  String get feature_family_profiles => 'Family Profiles';

  @override
  String get plan_monthly => 'Monthly';

  @override
  String get price_monthly => '\$9.99';

  @override
  String get per_month => '/month';

  @override
  String get plan_yearly => 'Yearly';

  @override
  String get price_yearly => '\$99.99';

  @override
  String get save_20_percent => 'Save 20%';

  @override
  String get subscribe_button_label => 'Subscribe Now';

  @override
  String get subscribed_to_premium => 'You are already subscribed to premium.';

  @override
  String get subscribe_now => 'Subscribe';

  @override
  String get restore_purchases_button_label => 'Restore Purchases';

  @override
  String get restore_purchases => 'Restore Purchases';

  @override
  String price_card_label(Object plan, Object price) {
    return '$plan - $price';
  }

  @override
  String get popular_plan_label => 'Popular';

  @override
  String get selected_plan_label => 'Selected';

  @override
  String get popular => 'Popular';

  @override
  String get language_english => 'English';

  @override
  String get language_malay => 'Malay';

  @override
  String get language_chinese => 'Chinese';

  @override
  String get settings_title => 'Settings';

  @override
  String get language_section_title => 'Language';

  @override
  String get tour_page_1_title => 'Welcome to your personal medical assistant!';

  @override
  String get tour_page_1_description =>
      'Easily add and manage your medications. Set reminders so you never miss a dose.';

  @override
  String get tour_page_2_title => 'Track your progress';

  @override
  String get tour_page_2_description =>
      'Keep a log of your medication history. See what you have taken and when.';

  @override
  String get tour_page_3_title => 'Stay on top of your health';

  @override
  String get tour_page_3_description =>
      'Get insights into your medication adherence and share reports with your doctor.';

  @override
  String get get_started_button => 'Get Started';

  @override
  String get lifestyle_warnings => 'Lifestyle Warnings';
}
