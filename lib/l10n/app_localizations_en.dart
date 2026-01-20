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

  @override
  String get level_label => 'LEVEL';

  @override
  String to_level_x(Object level, Object percent) {
    return '$percent% to Level $level';
  }

  @override
  String get tier_seedling => 'Seedling';

  @override
  String get tier_guardian => 'Adherence Guardian';

  @override
  String get tier_hero => 'Adherence Hero';

  @override
  String get tier_sentinel => 'Diamond Sentinel';

  @override
  String get tier_immortal => 'Adherence Immortal';

  @override
  String get oracle_title => 'THE CLINICAL ORACLE';

  @override
  String get oracle_description =>
      'Unlock advanced longitudinal pattern detection. (Requires Premium & Level 50+)';

  @override
  String get oracle_button => 'CONSULT THE ORACLE';

  @override
  String get premium_required =>
      'The Clinical Oracle requires a Premium subscription.';

  @override
  String get immortal_required =>
      'The Clinical Oracle is only accessible to \'Adherence Immortals\' (Level 50+). Keep taking your medicine to unlock!';

  @override
  String get oracle_insights => 'Oracle Insights';

  @override
  String get oracle_empty =>
      'The Oracle is silent. Insufficient data for deep analysis.';

  @override
  String get oracle_error =>
      'Oracle Sync Failure: High-fidelity pattern analysis requires more consistent data logging.';

  @override
  String get missed_label => 'MISSED';

  @override
  String get filter_all => 'All';

  @override
  String get filter_missed => 'Missed Only';

  @override
  String get reading_saved => 'Reading Saved';

  @override
  String get health_alert => 'Health Alert';

  @override
  String get health_vitals => 'Health Vitals';

  @override
  String get add_new_reading => 'Add New Reading';

  @override
  String get save_record => 'SAVE RECORD';

  @override
  String get recent_history => 'RECENT HISTORY';

  @override
  String entries_count(Object count) {
    return '$count Entries';
  }

  @override
  String get no_readings_yet => 'No readings recorded yet';

  @override
  String get missed_dose_guide => 'Missed Dose Guide';

  @override
  String get what_to_do_late => 'WHAT TO DO IF > 2 HOURS LATE';

  @override
  String get safe_window => 'Safe Window';

  @override
  String get clinical_references => 'CLINICAL REFERENCES';

  @override
  String get upgrade_to_premium => 'Upgrade to Premium';

  @override
  String get maybe_later => 'Maybe Later';

  @override
  String get view_plans => 'View Plans';

  @override
  String get ai_pharmacist => 'AI Pharmacist';

  @override
  String get typing_indicator => 'Typing...';

  @override
  String get premium_feature => 'Premium Feature';

  @override
  String get pro_label => 'PRO';

  @override
  String get share_data => 'Share Data';

  @override
  String get caregiver_code_label => 'Your unique caregiver code:';

  @override
  String get copy_code => 'Copy Code';

  @override
  String get close => 'Close';

  @override
  String get guest_login => 'Continue as Guest';

  @override
  String get error_parsing_med => 'Error parsing medication information.';

  @override
  String get health_adherence_report => 'HEALTH ADHERENCE REPORT';

  @override
  String get generated_by_ai => 'Generated by AI Medication Manager';

  @override
  String page_info(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String get patient_info => 'PATIENT INFORMATION';

  @override
  String get report_period => 'Report Period: Last 30 Days';

  @override
  String get overall_adherence => 'Overall Adherence';

  @override
  String get medication_summary => 'MEDICATION SUMMARY';

  @override
  String get health_vital_readings => 'HEALTH VITAL READINGS';

  @override
  String get recent_dosage_logs => 'RECENT DOSAGE LOGS';

  @override
  String get ai_clinical_summary => 'AI CLINICAL SUMMARY (BY GEMINI)';

  @override
  String get clinician_review_recommended => 'Clinician Review Recommended';

  @override
  String get clinical_report => 'Clinical Report';

  @override
  String get generate_pdf => 'GENERATE PDF REPORT';

  @override
  String get analyzing_patterns => 'Gemini is analyzing health patterns...';

  @override
  String get done => 'DONE';

  @override
  String oracle_sync_error(Object error) {
    return 'Oracle sync failed: $error';
  }

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get glucose_sugar => 'Glucose (Sugar)';

  @override
  String get blood_pressure => 'Blood Pressure';

  @override
  String get inr_warfarin => 'INR (Warfarin)';

  @override
  String get unit_mmol_l => 'mmol/L';

  @override
  String get unit_mm_hg => 'mmHg';

  @override
  String get unit_ratio => 'Ratio';

  @override
  String get abnormal_glucose =>
      'Abnormal Glucose Level. Please consult a doctor immediately.';

  @override
  String get inr_out_of_range =>
      'INR out of range (Target 2.0-3.0 usually). Check with your doctor!';

  @override
  String get share_report => 'Share Report';

  @override
  String get my_health_report => 'My Health Report';

  @override
  String get filter_label => 'Filter:';

  @override
  String get no_missed_doses => 'No missed doses recorded.';

  @override
  String get no_history => 'No history yet.';

  @override
  String get free_tier_history_note =>
      'Free tier shows last 7 days. Upgrade to see full history.';

  @override
  String get appearance_language => 'Appearance & Language';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get health_support => 'Health Support';

  @override
  String get doctor_report_title => 'Doctor Report';

  @override
  String get doctor_report_subtitle => 'Generate a medication history PDF';

  @override
  String get share_data_title => 'Share My Data';

  @override
  String get share_data_subtitle => 'Link with a caregiver';

  @override
  String get monitoring_section => 'Monitoring';

  @override
  String get caregiver_access_title => 'Caregiver Access';

  @override
  String get caregiver_access_subtitle => 'Monitor someone else\'s health';

  @override
  String get account_section => 'Account';

  @override
  String get sign_out => 'Sign Out';

  @override
  String premium_required_desc(Object feature) {
    return '$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.';
  }

  @override
  String get guest_email => 'No email linked';

  @override
  String get my_profile => 'My Profile';

  @override
  String get caregiver_code_desc =>
      'Share this code with your caregiver to allow them to monitor your health in real-time.';

  @override
  String get missed_dose_guide_title => 'Missed Dose Guide';

  @override
  String get od_title => 'Once Daily (OD)';

  @override
  String get od_protocol =>
      'Take the missed dose as soon as it is remembered, up to 8 hours late.\n\nAfter 8 hours, skip the dose and wait for your next scheduled time.';

  @override
  String get multiple_times_title => 'Multiple Times a Day';

  @override
  String get multiple_times_protocol =>
      'If more than 2 hours late, skip the missed dose and wait until the next dose is due.\n\nDo not double your dose to catch up.';

  @override
  String get side_effects_title => 'Side Effects';

  @override
  String get side_effects_protocol =>
      'Monitor for side effects, as these may be increased if the dosing interval is shorter.';

  @override
  String get meals_food_title => 'Meals & Food';

  @override
  String get meals_food_protocol =>
      'You can usually ignore warnings about taking the medicine with or without meals, unless there’s a significant risk of serious side-effects.';

  @override
  String get forgiveness_title => 'Medication \"Forgiveness\"';

  @override
  String get forgiveness_protocol =>
      'Scientifically, \"forgiveness\" describes how much your medicine protects you after a missed dose.\n\n• Forgiving: Aspirin, Amlodipine (long-acting effects).\n• Unforgiving: Blood thinners (Rivaroxaban), Epilepsy meds, and Contraceptives. These require strict timing.';

  @override
  String get safe_window_title => 'Safe Window';

  @override
  String get safe_window_protocol =>
      'Once Daily (OD): You can take your dose up to 8 hours late. Others: 2 hours strictly.';

  @override
  String get caregiver_hub_title => 'Caregiver Hub';

  @override
  String get caregiver_login_prompt => 'Please login to continue.';

  @override
  String get caregiver_dashboard => 'Monitoring Dashboard';

  @override
  String get caregiver_dashboard_desc =>
      'Ensuring loved ones stay on track with their health.';

  @override
  String get pending_invitations => 'Pending Invitations';

  @override
  String get your_patients => 'Your Patients';

  @override
  String get no_patients_linked => 'No patients linked yet.';

  @override
  String get invite_instructions => 'Patients can invite you using your email.';

  @override
  String get sharing_health_data => 'Wants to share their health data';

  @override
  String get adherence_label => 'Adherence';

  @override
  String get adherence_good => 'Good';

  @override
  String get health_academy_title => 'Health Academy';

  @override
  String get insulin_pen_title => 'How to Use Insulin Pen';

  @override
  String get insulin_pen_desc =>
      'Official MOH guide on correct insulin injection technique.';

  @override
  String get inhaler_technique_title => 'Inhaler Technique (MDI)';

  @override
  String get inhaler_technique_desc =>
      'How to use an inhaler for asthma correctly.';

  @override
  String get know_warfarin_title => 'Know Your Warfarin';

  @override
  String get know_warfarin_desc =>
      'Contraindications and important info for heart patients.';

  @override
  String get hypoglycemia_signs_title => 'Signs of Hypoglycemia';

  @override
  String get hypoglycemia_signs_desc =>
      'What to do if your blood sugar is too low?';

  @override
  String get official_missed_dose_protocol_title =>
      'Official Missed Dose Protocol';

  @override
  String get official_missed_dose_protocol_desc =>
      'What to do if you or the person you care for misses a dose.';

  @override
  String get know_your_medicine_title => 'Know Your Medicine';

  @override
  String get know_your_medicine_desc =>
      'General tips for safe medication intake.';

  @override
  String get expert_clinical_analysis => 'Expert Clinical Analysis';

  @override
  String get clinical_analysis_desc =>
      'AI-powered summary of your medication adherence and health vitals history.';

  @override
  String get precision_adherence_tracking => 'Precision Adherence Tracking';

  @override
  String get health_vital_readings_desc => 'Health Vital Readings (BP, Sugar)';

  @override
  String get ai_clinician_insights => 'AI Clinician Pattern Insights';
}
