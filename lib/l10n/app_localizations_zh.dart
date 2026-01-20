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

  @override
  String get level_label => '等级';

  @override
  String to_level_x(Object level, Object percent) {
    return '距离第 $level 级还有 $percent%';
  }

  @override
  String get tier_seedling => '幼苗';

  @override
  String get tier_guardian => '准守卫者';

  @override
  String get tier_hero => '准守英雄';

  @override
  String get tier_sentinel => '钻石哨兵';

  @override
  String get tier_immortal => '准守永生者';

  @override
  String get oracle_title => '临床先知';

  @override
  String get oracle_description => '解锁先进的纵向模式检测。（需要高级版和 50 级以上）';

  @override
  String get oracle_button => '咨询先知';

  @override
  String get premium_required => '临床先知需要高级版订阅。';

  @override
  String get immortal_required => '只有“准守永生者”（50 级以上）才能访问临床先知。继续服药以解锁！';

  @override
  String get oracle_insights => '先知洞察';

  @override
  String get oracle_empty => '先知保持沉默。数据不足，无法进行深度分析。';

  @override
  String get oracle_error => '先知同步失败：高保真模式分析需要更一致的数据记录。 ';

  @override
  String get missed_label => '已错过';

  @override
  String get filter_all => '全部';

  @override
  String get filter_missed => '仅限错过';

  @override
  String get reading_saved => '读取已保存';

  @override
  String get health_alert => '健康警报';

  @override
  String get health_vitals => '健康体征';

  @override
  String get add_new_reading => '添加新记录';

  @override
  String get save_record => '保存记录';

  @override
  String get recent_history => '最近历史';

  @override
  String entries_count(Object count) {
    return '$count 条记录';
  }

  @override
  String get no_readings_yet => '尚未记录任何读数';

  @override
  String get missed_dose_guide => '漏服药物指南';

  @override
  String get what_to_do_late => '如果超过 2 小时未服药该怎么办';

  @override
  String get safe_window => '安全窗口';

  @override
  String get clinical_references => '临床参考文献';

  @override
  String get upgrade_to_premium => '升级到高级版';

  @override
  String get maybe_later => '以后再说';

  @override
  String get view_plans => '查看计划';

  @override
  String get ai_pharmacist => 'AI 药剂师';

  @override
  String get typing_indicator => '正在输入...';

  @override
  String get premium_feature => '高级功能';

  @override
  String get pro_label => '专业版';

  @override
  String get share_data => '分享数据';

  @override
  String get caregiver_code_label => '您的唯一护理人员代码：';

  @override
  String get copy_code => '复制代码';

  @override
  String get close => '关闭';

  @override
  String get guest_login => '以游客身份继续';

  @override
  String get error_parsing_med => '解析药物信息时出错。';

  @override
  String get health_adherence_report => '健康依从性报告';

  @override
  String get generated_by_ai => '由 AI 药物管理器生成';

  @override
  String page_info(Object current, Object total) {
    return '第 $current 页，共 $total 页';
  }

  @override
  String get patient_info => '患者信息';

  @override
  String get report_period => '报告期：最近 30 天';

  @override
  String get overall_adherence => '总体依从性';

  @override
  String get medication_summary => '用药摘要';

  @override
  String get health_vital_readings => '健康体征记录';

  @override
  String get recent_dosage_logs => '最近服药记录';

  @override
  String get ai_clinical_summary => 'AI 临床摘要（由 GEMINI 提供）';

  @override
  String get clinician_review_recommended => '建议临床医生审核';

  @override
  String get clinical_report => '临床报告';

  @override
  String get generate_pdf => '生成 PDF 报告';

  @override
  String get analyzing_patterns => 'Gemini 正在分析健康模式...';

  @override
  String get done => '完成';

  @override
  String oracle_sync_error(Object error) {
    return '先知同步失败：$error';
  }

  @override
  String get systolic => '收缩压';

  @override
  String get diastolic => '舒张压';

  @override
  String get glucose_sugar => '血糖';

  @override
  String get blood_pressure => '血压';

  @override
  String get inr_warfarin => '国际标准化比值 (华法林)';

  @override
  String get unit_mmol_l => 'mmol/L';

  @override
  String get unit_mm_hg => 'mmHg';

  @override
  String get unit_ratio => '比率';

  @override
  String get abnormal_glucose => '血糖水平异常。请立即咨询医生。';

  @override
  String get inr_out_of_range => 'INR 超出范围（目标通常为 2.0-3.0）。请咨询您的医生！';

  @override
  String get share_report => '分享报告';

  @override
  String get my_health_report => '我的健康报告';

  @override
  String get filter_label => '筛选：';

  @override
  String get no_missed_doses => '无错过剂量记录。';

  @override
  String get no_history => '暂无记录。';

  @override
  String get free_tier_history_note => '免费版显示最近 7 天。升级以查看完整历史记录。';

  @override
  String get appearance_language => '外观与语言';

  @override
  String get dark_mode => '深色模式';

  @override
  String get health_support => '健康支持';

  @override
  String get doctor_report_title => '医生报告';

  @override
  String get doctor_report_subtitle => '生成用药历史 PDF';

  @override
  String get share_data_title => '分享我的数据';

  @override
  String get share_data_subtitle => '关联护理人员';

  @override
  String get monitoring_section => '监控';

  @override
  String get caregiver_access_title => '护理人员访问';

  @override
  String get caregiver_access_subtitle => '监控他人的健康状况';

  @override
  String get account_section => '账户';

  @override
  String get sign_out => '退出登录';

  @override
  String premium_required_desc(Object feature) {
    return '“$feature”仅适用于高级订阅者。升级后可获得 AI 健康洞察、语音命令和报告的完整访问权限。';
  }

  @override
  String get guest_email => '未关联电子邮件';

  @override
  String get my_profile => '我的个人资料';

  @override
  String get caregiver_code_desc => '将此代码分享给您的护理人员，以便他们实时监控您的健康状况。';

  @override
  String get missed_dose_guide_title => '漏服剂量指南';

  @override
  String get od_title => '每日一次 (OD)';

  @override
  String get od_protocol => '想起时立即补服，最多延迟 8 小时。\n\n超过 8 小时后，请跳过该剂量，等待下一次预定时间。';

  @override
  String get multiple_times_title => '每日多次';

  @override
  String get multiple_times_protocol =>
      '如果延迟超过 2 小时，请跳过漏服的剂量，等待下一次剂量。\n\n不要为了补服而加倍剂量。';

  @override
  String get side_effects_title => '副作用';

  @override
  String get side_effects_protocol => '监测副作用，因为如果给药间隔缩短，副作用可能会增加。';

  @override
  String get meals_food_title => '膳食与食物';

  @override
  String get meals_food_protocol => '除非存在严重副作用的风险，否则通常可以忽略关于随餐或空腹服药的警告。';

  @override
  String get forgiveness_title => '药物“宽恕度”';

  @override
  String get forgiveness_protocol =>
      '科学上，“宽恕度”描述了漏服后药物对您的保护程度。\n\n• 宽恕型：阿司匹林、氨氯地平（长效作用）。\n• 不宽恕型：血液稀释剂（利伐沙班）、癫痫药物和避孕药。这些需要严格的时间控制。';

  @override
  String get safe_window_title => '安全窗口';

  @override
  String get safe_window_protocol => '每日一次 (OD)：您最多可以延迟 8 小时服药。其他：严格限制在 2 小时内。';

  @override
  String get caregiver_hub_title => '护理中心';

  @override
  String get caregiver_login_prompt => '请登录以继续。';

  @override
  String get caregiver_dashboard => '监控仪表板';

  @override
  String get caregiver_dashboard_desc => '确保亲人的健康步入正轨。';

  @override
  String get pending_invitations => '待处理邀请';

  @override
  String get your_patients => '您的患者';

  @override
  String get no_patients_linked => '暂无关联患者。';

  @override
  String get invite_instructions => '患者可以使用您的电子邮件邀请您。';

  @override
  String get sharing_health_data => '想要分享他们的健康数据';

  @override
  String get adherence_label => '依从性';

  @override
  String get adherence_good => '良好';

  @override
  String get health_academy_title => '健康学院';

  @override
  String get insulin_pen_title => '胰岛素笔使用方法';

  @override
  String get insulin_pen_desc => '卫生部关于正确胰岛素注射技术的官方指南。';

  @override
  String get inhaler_technique_title => '吸入器使用技巧 (MDI)';

  @override
  String get inhaler_technique_desc => '如何正确使用哮喘吸入器。';

  @override
  String get know_warfarin_title => '认识华法林 (Warfarin)';

  @override
  String get know_warfarin_desc => '心脏病患者的禁忌和重要信息。';

  @override
  String get hypoglycemia_signs_title => '低血糖症状';

  @override
  String get hypoglycemia_signs_desc => '如果您的血糖过低该怎么办？';

  @override
  String get official_missed_dose_protocol_title => '官方漏服药物方案';

  @override
  String get official_missed_dose_protocol_desc => '如果您或您照顾的人漏服药物该怎么办。';

  @override
  String get know_your_medicine_title => '了解您的药物';

  @override
  String get know_your_medicine_desc => '安全服药的一般提示。';

  @override
  String get expert_clinical_analysis => '专家临床分析';

  @override
  String get clinical_analysis_desc => 'AI 驱动的用药依从性和生命体征历史摘要。';

  @override
  String get precision_adherence_tracking => '精确依从性追踪';

  @override
  String get health_vital_readings_desc => '健康生命体征读数（血压、血糖）';

  @override
  String get ai_clinician_insights => 'AI 临床医生模式洞察';
}
