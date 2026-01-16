// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get add_medicine => '添加药物';

  @override
  String get medicine_name => '药物名称';

  @override
  String get medicine_dosage => '剂量（例如，500mg，1片）';

  @override
  String get medicine_frequency => '频率';

  @override
  String get special_instructions => '特别说明（例如，随餐服用）';

  @override
  String get verification_prompt => '我已经与医疗专业人员核实了药物名称、剂量和频率。';

  @override
  String get please_enter_name => '请输入药物名称';

  @override
  String get please_enter_dosage => '请输入剂量';

  @override
  String get please_select_frequency => '请选择频率';

  @override
  String get select_frequency => '选择频率';

  @override
  String get frequency_daily => '每天';

  @override
  String get frequency_weekly => '每周';

  @override
  String get frequency_monthly => '每月';

  @override
  String get schedule_timings => '时间安排';

  @override
  String get evenly_spaced => '均匀间隔';

  @override
  String get pick_times => '选择时间';

  @override
  String scheduled_at(Object times) {
    return '安排在: $times';
  }

  @override
  String time_header(Object index) {
    return '时间 $index';
  }

  @override
  String get save_changes => '保存更改';

  @override
  String get cancel => '取消';

  @override
  String times_a_day(Object count) {
    return '每天 $count 次';
  }

  @override
  String every_x_days(Object count) {
    return '每 $count 天';
  }

  @override
  String get specific_days_of_week => '每周的特定日期';

  @override
  String get specific_dates_of_month => '每月的特定日期';

  @override
  String get times => '时间';

  @override
  String get count => '次数';

  @override
  String get interval => '间隔';

  @override
  String get ok => '确定';

  @override
  String get home => '首页';

  @override
  String get history => '历史';

  @override
  String get settings => '设置';

  @override
  String get confirm_delete => '您确定要删除此药物吗？';

  @override
  String get delete => '删除';

  @override
  String get edit_medicine => '编辑药物';

  @override
  String get how_many_times => '几次？';

  @override
  String get how_often => '多久一次？';

  @override
  String get save_button => '保存';

  @override
  String get verify_title => '核实信息';

  @override
  String get pharmacist_note => '药剂师说明';

  @override
  String get upgrade_appbar_title => '升级';

  @override
  String get premium_icon_label => '高级版';

  @override
  String get upgrade_to_pro_title => '升级到 Pro';

  @override
  String get upgrade_to_pro_subtitle => '解锁所有功能，获得最佳体验。';

  @override
  String get feature_unlimited_medicines => '无限药物管理';

  @override
  String get feature_export_reports => '导出报告';

  @override
  String get feature_family_profiles => '家庭档案';

  @override
  String get plan_monthly => '月度';

  @override
  String get price_monthly => '¥68.00';

  @override
  String get per_month => '/月';

  @override
  String get plan_yearly => '年度';

  @override
  String get price_yearly => '¥648.00';

  @override
  String get save_20_percent => '节省 20%';

  @override
  String get subscribe_button_label => '立即订阅';

  @override
  String get subscribed_to_premium => '您已订阅高级版。';

  @override
  String get subscribe_now => '订阅';

  @override
  String get restore_purchases_button_label => '恢复购买';

  @override
  String get restore_purchases => '恢复购买';

  @override
  String price_card_label(Object plan, Object price) {
    return '$plan - $price';
  }

  @override
  String get popular_plan_label => '热门';

  @override
  String get selected_plan_label => '已选择';

  @override
  String get popular => '热门';

  @override
  String get language_english => '英语';

  @override
  String get language_malay => '马来语';

  @override
  String get language_chinese => '中文';

  @override
  String get settings_title => '设置';

  @override
  String get language_section_title => '语言';

  @override
  String get tour_page_1_title => '欢迎使用您的个人医疗助手！';

  @override
  String get tour_page_1_description => '轻松添加和管理您的药物。设置提醒，以免错过任何剂量。';

  @override
  String get tour_page_2_title => '跟踪您的进度';

  @override
  String get tour_page_2_description => '记录您的用药历史。查看您在何时服用了什么药物。';

  @override
  String get tour_page_3_title => '关注您的健康';

  @override
  String get tour_page_3_description => '深入了解您的用药依从性，并与您的医生分享报告。';

  @override
  String get get_started_button => '开始使用';

  @override
  String get lifestyle_warnings => '生活方式警告';
}
