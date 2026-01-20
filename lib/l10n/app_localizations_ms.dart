// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get add_medicine => 'Tambah Ubat';

  @override
  String get medicine_name => 'Nama Ubat';

  @override
  String get medicine_dosage => 'Dos (cth., 500mg, 1 biji)';

  @override
  String get medicine_frequency => 'Kekerapan';

  @override
  String get special_instructions => 'Arahan Khas (cth., ambil dengan makanan)';

  @override
  String get verification_prompt =>
      'Saya telah mengesahkan nama ubat, dos, dan kekerapan dengan profesional penjagaan kesihatan.';

  @override
  String get please_enter_name => 'Sila masukkan nama ubat';

  @override
  String get please_enter_dosage => 'Sila masukkan dos';

  @override
  String get please_select_frequency => 'Sila pilih kekerapan';

  @override
  String get select_frequency => 'Pilih Kekerapan';

  @override
  String get frequency_daily => 'Harian';

  @override
  String get frequency_weekly => 'Mingguan';

  @override
  String get frequency_monthly => 'Bulanan';

  @override
  String get schedule_timings => 'Masa Jadual';

  @override
  String get evenly_spaced => 'Jarak Sekata';

  @override
  String get pick_times => 'Pilih Masa';

  @override
  String scheduled_at(Object times) {
    return 'Dijadualkan pada: $times';
  }

  @override
  String time_header(Object index) {
    return 'Masa $index';
  }

  @override
  String get save_changes => 'Simpan Perubahan';

  @override
  String get cancel => 'Batal';

  @override
  String times_a_day(Object count) {
    return '$count kali sehari';
  }

  @override
  String every_x_days(Object count) {
    return 'Setiap $count hari';
  }

  @override
  String get specific_days_of_week => 'Hari tertentu dalam seminggu';

  @override
  String get specific_dates_of_month => 'Tarikh tertentu dalam sebulan';

  @override
  String get times => 'Masa';

  @override
  String get count => 'Kiraan';

  @override
  String get interval => 'Selang';

  @override
  String get ok => 'OK';

  @override
  String get home => 'Laman Utama';

  @override
  String get history => 'Sejarah';

  @override
  String get settings => 'Tetapan';

  @override
  String get confirm_delete => 'Adakah anda pasti mahu memadam ubat ini?';

  @override
  String get delete => 'Padam';

  @override
  String get edit_medicine => 'Edit Ubat';

  @override
  String get how_many_times => 'Berapa kali?';

  @override
  String get how_often => 'Berapa kerap?';

  @override
  String get save_button => 'Simpan';

  @override
  String get verify_title => 'Sahkan Maklumat';

  @override
  String get pharmacist_note => 'Nota Ahli Farmasi';

  @override
  String get upgrade_appbar_title => 'Naik Taraf';

  @override
  String get premium_icon_label => 'PREMIUM';

  @override
  String get upgrade_to_pro_title => 'Naik Taraf ke Pro';

  @override
  String get upgrade_to_pro_subtitle =>
      'Nyahkunci semua ciri dan dapatkan pengalaman terbaik.';

  @override
  String get feature_unlimited_medicines => 'Ubat Tanpa Had';

  @override
  String get feature_export_reports => 'Eksport Laporan';

  @override
  String get feature_family_profiles => 'Profil Keluarga';

  @override
  String get plan_monthly => 'Bulanan';

  @override
  String get price_monthly => 'RM39.99';

  @override
  String get per_month => '/bulan';

  @override
  String get plan_yearly => 'Tahunan';

  @override
  String get price_yearly => 'RM399.99';

  @override
  String get save_20_percent => 'Jimat 20%';

  @override
  String get subscribe_button_label => 'Langgan Sekarang';

  @override
  String get subscribed_to_premium => 'Anda sudah melanggan premium.';

  @override
  String get subscribe_now => 'Langgan';

  @override
  String get restore_purchases_button_label => 'Pulihkan Pembelian';

  @override
  String get restore_purchases => 'Pulihkan Pembelian';

  @override
  String price_card_label(Object plan, Object price) {
    return '$plan - $price';
  }

  @override
  String get popular_plan_label => 'Popular';

  @override
  String get selected_plan_label => 'Dipilih';

  @override
  String get popular => 'Popular';

  @override
  String get language_english => 'Inggeris';

  @override
  String get language_malay => 'Bahasa Melayu';

  @override
  String get language_chinese => 'Cina';

  @override
  String get settings_title => 'Tetapan';

  @override
  String get language_section_title => 'Bahasa';

  @override
  String get tour_page_1_title =>
      'Selamat datang ke pembantu perubatan peribadi anda!';

  @override
  String get tour_page_1_description =>
      'Tambah dan urus ubat anda dengan mudah. Tetapkan peringatan supaya anda tidak terlepas dos.';

  @override
  String get tour_page_2_title => 'Jejaki kemajuan anda';

  @override
  String get tour_page_2_description =>
      'Simpan log sejarah perubatan anda. Lihat apa yang anda telah ambil dan bila.';

  @override
  String get tour_page_3_title => 'Sentiasa menjaga kesihatan anda';

  @override
  String get tour_page_3_description =>
      'Dapatkan cerapan tentang pematuhan ubat anda dan kongsi laporan dengan doktor anda.';

  @override
  String get get_started_button => 'Mulakan';

  @override
  String get lifestyle_warnings => 'Amaran Gaya Hidup';

  @override
  String get level_label => 'TAHAP';

  @override
  String to_level_x(Object level, Object percent) {
    return '$percent% ke Tahap $level';
  }

  @override
  String get tier_seedling => 'Anak Benih';

  @override
  String get tier_guardian => 'Penjaga Kepatuhan';

  @override
  String get tier_hero => 'Wira Kepatuhan';

  @override
  String get tier_sentinel => 'Sentinel Berlian';

  @override
  String get tier_immortal => 'Abadi Kepatuhan';

  @override
  String get oracle_title => 'ORACLE KLINIKAL';

  @override
  String get oracle_description =>
      'Buka kunci pengesanan corak longitud termaju. (Memerlukan Premium & Tahap 50+)';

  @override
  String get oracle_button => 'RUNDING DENGAN ORACLE';

  @override
  String get premium_required =>
      'Oracle Klinikal memerlukan langganan Premium.';

  @override
  String get immortal_required =>
      'Oracle Klinikal hanya boleh diakses oleh \"Abadi Kepatuhan\" (Tahap 50+). Teruskan mengambil ubat anda untuk membuka kunci!';

  @override
  String get oracle_insights => 'Wawasan Oracle';

  @override
  String get oracle_empty =>
      'Oracle senyap. Data tidak mencukupi untuk analisis mendalam.';

  @override
  String get oracle_error =>
      'Kegagalan Penyegerakan Oracle: Analisis corak kesetiaan tinggi memerlukan log data yang lebih konsisten.';

  @override
  String get missed_label => 'TERLEPAS';

  @override
  String get filter_all => 'Semua';

  @override
  String get filter_missed => 'Terlepas Sahaja';

  @override
  String get reading_saved => 'Bacaan Disimpan';

  @override
  String get health_alert => 'Amaran Kesihatan';

  @override
  String get health_vitals => 'Vital Kesihatan';

  @override
  String get add_new_reading => 'Tambah Bacaan Baharu';

  @override
  String get save_record => 'SIMPAN REKOD';

  @override
  String get recent_history => 'SEJARAH TERKINI';

  @override
  String entries_count(Object count) {
    return '$count Entri';
  }

  @override
  String get no_readings_yet => 'Tiada bacaan direkodkan lagi';

  @override
  String get missed_dose_guide => 'Panduan Dos Terlepas';

  @override
  String get what_to_do_late => 'APA PERLU DIBUAT JIKA > 2 JAM LEWAT';

  @override
  String get safe_window => 'Window Selamat';

  @override
  String get clinical_references => 'RUJUKAN KLINIKAL';

  @override
  String get upgrade_to_premium => 'Naik Taraf ke Premium';

  @override
  String get maybe_later => 'Mungkin Kemudian';

  @override
  String get view_plans => 'Lihat Pelan';

  @override
  String get ai_pharmacist => 'Ahli Farmasi AI';

  @override
  String get typing_indicator => 'Menaip...';

  @override
  String get premium_feature => 'Ciri Premium';

  @override
  String get pro_label => 'PRO';

  @override
  String get share_data => 'Kongsi Data';

  @override
  String get caregiver_code_label => 'Kod penjaga unik anda:';

  @override
  String get copy_code => 'Salin Kod';

  @override
  String get close => 'Tutup';

  @override
  String get guest_login => 'Teruskan sebagai Tetamu';

  @override
  String get error_parsing_med => 'Ralat menghuraikan maklumat ubat.';

  @override
  String get health_adherence_report => 'LAPORAN PEMATUHAN KESIHATAN';

  @override
  String get generated_by_ai => 'Dijana oleh Pengurus Ubat AI';

  @override
  String page_info(Object current, Object total) {
    return 'Halaman $current daripada $total';
  }

  @override
  String get patient_info => 'MAKLUMAT PESAKIT';

  @override
  String get report_period => 'Tempoh Laporan: 30 Hari Terakhir';

  @override
  String get overall_adherence => 'Pematuhan Keseluruhan';

  @override
  String get medication_summary => 'RINGKASAN UBAT';

  @override
  String get health_vital_readings => 'BACAAN VITAL KESIHATAN';

  @override
  String get recent_dosage_logs => 'LOG DOS TERKINI';

  @override
  String get ai_clinical_summary => 'RINGKASAN KLINIKAL AI (OLEH GEMINI)';

  @override
  String get clinician_review_recommended => 'Semakan Klinikal Disyorkan';

  @override
  String get clinical_report => 'Laporan Klinikal';

  @override
  String get generate_pdf => 'JANA LAPORAN PDF';

  @override
  String get analyzing_patterns =>
      'Gemini sedang menganalisis corak kesihatan...';

  @override
  String get done => 'SELESAI';

  @override
  String oracle_sync_error(Object error) {
    return 'Kegagalan penyegerakan Oracle: $error';
  }

  @override
  String get systolic => 'Sistolik';

  @override
  String get diastolic => 'Diastolik';

  @override
  String get glucose_sugar => 'Glukosa (Gula)';

  @override
  String get blood_pressure => 'Tekanan Darah';

  @override
  String get inr_warfarin => 'INR (Warfarin)';

  @override
  String get unit_mmol_l => 'mmol/L';

  @override
  String get unit_mm_hg => 'mmHg';

  @override
  String get unit_ratio => 'Nisbah';

  @override
  String get abnormal_glucose =>
      'Tahap Glukosa Tidak Normal. Sila rujuk doktor dengan segera.';

  @override
  String get inr_out_of_range =>
      'INR di luar julat (Sasaran biasanya 2.0-3.0). Periksa dengan doktor anda!';

  @override
  String get share_report => 'Kongsi Laporan';

  @override
  String get my_health_report => 'Laporan Kesihatan Saya';

  @override
  String get filter_label => 'Penapis:';

  @override
  String get no_missed_doses => 'Tiada dos terlepas direkodkan.';

  @override
  String get no_history => 'Tiada sejarah lagi.';

  @override
  String get free_tier_history_note =>
      'Tahap percuma menunjukkan 7 hari terakhir. Naik taraf untuk melihat sejarah penuh.';

  @override
  String get appearance_language => 'Penampilan & Bahasa';

  @override
  String get dark_mode => 'Mod Gelap';

  @override
  String get health_support => 'Sokongan Kesihatan';

  @override
  String get doctor_report_title => 'Laporan Doktor';

  @override
  String get doctor_report_subtitle => 'Jana PDF sejarah perubatan';

  @override
  String get share_data_title => 'Kongsi Data Saya';

  @override
  String get share_data_subtitle => 'Pautkan dengan penjaga';

  @override
  String get monitoring_section => 'Pemantauan';

  @override
  String get caregiver_access_title => 'Akses Penjaga';

  @override
  String get caregiver_access_subtitle => 'Pantau kesihatan orang lain';

  @override
  String get account_section => 'Akaun';

  @override
  String get sign_out => 'Log Keluar';

  @override
  String premium_required_desc(Object feature) {
    return '$feature hanya tersedia untuk pelanggan premium. Naik taraf untuk mendapatkan akses penuh kepada cerapan kesihatan AI, arahan suara dan laporan.';
  }

  @override
  String get guest_email => 'Tiada e-mel dipautkan';

  @override
  String get my_profile => 'Profil Saya';

  @override
  String get caregiver_code_desc =>
      'Kongsi kod ini dengan penjaga anda untuk membolehkan mereka memantau kesihatan anda dalam masa nyata.';

  @override
  String get missed_dose_guide_title => 'Panduan Dos Terlepas';

  @override
  String get od_title => 'Sekali Sehari (OD)';

  @override
  String get od_protocol =>
      'Ambil dos yang terlepas sebaik sahaja diingat, sehingga 8 jam lewat.\n\nSelepas 8 jam, langkau dos dan tunggu masa jadual seterusnya.';

  @override
  String get multiple_times_title => 'Beberapa Kali Sehari';

  @override
  String get multiple_times_protocol =>
      'Jika lebih daripada 2 jam lewat, langkau dos yang terlepas dan tunggu sehingga dos seterusnya.\n\nJangan gandakan dos anda untuk mengejar semula.';

  @override
  String get side_effects_title => 'Kesan Sampingan';

  @override
  String get side_effects_protocol =>
      'Pantau kesan sampingan, kerana ini mungkin meningkat jika selang dos lebih pendek.';

  @override
  String get meals_food_title => 'Makanan & Hidangan';

  @override
  String get meals_food_protocol =>
      'Anda biasanya boleh mengabaikan amaran tentang pengambilan ubat dengan atau tanpa makanan, melainkan terdapat risiko serius kesan sampingan yang ketara.';

  @override
  String get forgiveness_title => ' \"Kemaafan\" Ubat';

  @override
  String get forgiveness_protocol =>
      'Secara saintifik, \"kemaafan\" menerangkan sejauh mana ubat anda melindungi anda selepas dos yang terlepas.\n\n• Memaafkan: Aspirin, Amlodipine (kesan tahan lama).\n• Tidak Memaafkan: Pencair darah (Rivaroxaban), ubat Epilepsi, dan Perancang Kehamilan. Ini memerlukan ketepatan masa yang ketat.';

  @override
  String get safe_window_title => 'Tingkap Selamat';

  @override
  String get safe_window_protocol =>
      'Sekali Sehari (OD): Anda boleh mengambil dos anda sehingga 8 jam lewat. Lain-lain: 2 jam dengan ketat.';

  @override
  String get caregiver_hub_title => 'Hab Penjaga';

  @override
  String get caregiver_login_prompt => 'Sila log masuk untuk meneruskan.';

  @override
  String get caregiver_dashboard => 'Papan Pemuka Pemantauan';

  @override
  String get caregiver_dashboard_desc =>
      'Memastikan orang tersayang kekal sihat.';

  @override
  String get pending_invitations => 'Jemputan Tertunda';

  @override
  String get your_patients => 'Pesakit Anda';

  @override
  String get no_patients_linked => 'Tiada pesakit dipautkan lagi.';

  @override
  String get invite_instructions =>
      'Pesakit boleh menjemput anda menggunakan e-mel anda.';

  @override
  String get sharing_health_data => 'Ingin berkongsi data kesihatan mereka';

  @override
  String get adherence_label => 'Pematuhan';

  @override
  String get adherence_good => 'Baik';

  @override
  String get health_academy_title => 'Akademi Kesihatan';

  @override
  String get insulin_pen_title => 'Cara Penggunaan Insulin Pen';

  @override
  String get insulin_pen_desc =>
      'Panduan rasmi KKM tentang teknik suntikan insulin yang betul.';

  @override
  String get inhaler_technique_title => 'Teknik Inhaler (MDI)';

  @override
  String get inhaler_technique_desc =>
      'Cara menggunakan inhaler untuk asma dengan betul.';

  @override
  String get know_warfarin_title => 'Kenali Ubat Warfarin';

  @override
  String get know_warfarin_desc =>
      'Pantang larang dan info penting bagi pesakit jantung.';

  @override
  String get hypoglycemia_signs_title => 'Tanda-tanda Hipoglisemia';

  @override
  String get hypoglycemia_signs_desc =>
      'Apa perlu buat jika gula darah anda terlalu rendah?';

  @override
  String get official_missed_dose_protocol_title =>
      'Protokol Rasmi Dos Terlepas';

  @override
  String get official_missed_dose_protocol_desc =>
      'Apa yang perlu dilakukan jika anda atau orang yang anda jaga terlepas dos.';

  @override
  String get know_your_medicine_title => 'Kenali Ubat';

  @override
  String get know_your_medicine_desc =>
      'Tips umum pengambilan ubat yang selamat.';

  @override
  String get expert_clinical_analysis => 'Analisis Klinikal Pakar';

  @override
  String get clinical_analysis_desc =>
      'Ringkasan dikuasakan AI tentang sejarah pematuhan ubat dan vital kesihatan anda.';

  @override
  String get precision_adherence_tracking => 'Penjejakan Pematuhan Ketepatan';

  @override
  String get health_vital_readings_desc =>
      'Bacaan Vital Kesihatan (Tekanan Darah, Gula)';

  @override
  String get ai_clinician_insights => 'Cerapan Corak Pakar Klinikal AI';
}
