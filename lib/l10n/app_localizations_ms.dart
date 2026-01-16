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
}
