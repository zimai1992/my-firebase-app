import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/models/health_log.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/gradient_scaffold.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();

  @override
  void dispose() {
    _val1Controller.dispose();
    _val2Controller.dispose();
    super.dispose();
  }

  void _submit(HealthLogType type) {
    if (_val1Controller.text.isEmpty) return;

    final val1 = double.tryParse(_val1Controller.text);
    if (val1 == null) return;

    double? val2;
    if (type == HealthLogType.bloodPressure) {
      if (_val2Controller.text.isEmpty) return;
      val2 = double.tryParse(_val2Controller.text);
      if (val2 == null) return;
    }

    final log = HealthLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      value1: val1,
      value2: val2,
      timestamp: DateTime.now(),
    );

    context.read<MedicineProvider>().addHealthLog(log);
    _val1Controller.clear();
    _val2Controller.clear();

    // Simple Reminder SnackBar
    if (type == HealthLogType.bloodGlucose && (val1 < 4.0 || val1 > 11.0)) {
      _showWarning(
          AppLocalizations.of(context)!.abnormal_glucose);
    } else if (type == HealthLogType.inr && (val1 > 3.0 || val1 < 2.0)) {
      _showWarning(
          AppLocalizations.of(context)!.inr_out_of_range);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.reading_saved)));
    }
  }

  void _showWarning(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.health_alert, style: const TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.ok))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        // Check for Warfarin
        final hasWarfarin = provider.medicines.any((m) {
          final name = m.name.toLowerCase();
          final generic = m.genericName?.toLowerCase() ?? '';
          return name.contains('warfarin') ||
              name.contains('coumadin') ||
              generic.contains('warfarin');
        });

        final tabs = [
          Tab(text: AppLocalizations.of(context)!.glucose_sugar),
          Tab(text: AppLocalizations.of(context)!.blood_pressure),
          if (hasWarfarin) Tab(text: AppLocalizations.of(context)!.inr_warfarin),
        ];

        final tabViews = [
          _buildInputPage(HealthLogType.bloodGlucose, AppLocalizations.of(context)!.unit_mmol_l, Colors.teal),
          _buildInputPage(HealthLogType.bloodPressure, AppLocalizations.of(context)!.unit_mm_hg, Colors.red),
          if (hasWarfarin)
            _buildInputPage(HealthLogType.inr, AppLocalizations.of(context)!.unit_ratio, Colors.blue),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: GradientScaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent, // Ensure transparency
              title: Text(AppLocalizations.of(context)!.health_vitals),
              bottom: TabBar(
                tabs: tabs,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {
                    final report = provider.generateDoctorReport();
                    Share.share(report, subject: AppLocalizations.of(context)!.my_health_report);
                  },
                  tooltip: AppLocalizations.of(context)!.share_report,
                )
              ],
            ),
            body: TabBarView(
              children: tabViews,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputPage(HealthLogType type, String unit, Color accentColor) {
    return Consumer<MedicineProvider>(builder: (context, provider, child) {
      final logs = provider.healthLogs
          .where((l) => l.type == type)
          .toList()
          .reversed
          .toList();
      final theme = Theme.of(context);

      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CustomCard(
                  padding: const EdgeInsets.all(24),
                  isGlass: true, // Glassmorphism
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.add_chart, color: accentColor),
                          ),
                          const SizedBox(width: 16),
                          Text(AppLocalizations.of(context)!.add_new_reading,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _val1Controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: type == HealthLogType.bloodPressure
                                    ? AppLocalizations.of(context)!.systolic
                                    : AppLocalizations.of(context)!.medicine_dosage, // using existing dosage for generic "Reading"
                                hintText: '0.0',
                                suffixText: type == HealthLogType.bloodPressure
                                    ? null
                                    : unit,
                                filled: true,
                                fillColor: theme.brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          if (type == HealthLogType.bloodPressure) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _val2Controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.diastolic,
                                  hintText: '0.0',
                                  suffixText: 'mmHg',
                                  filled: true,
                                  fillColor: theme.brightness == Brightness.dark
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _submit(type),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Text(AppLocalizations.of(context)!.save_record,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.recent_history,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 1.5)),
                    if (logs.isNotEmpty)
                      Text(AppLocalizations.of(context)!.entries_count(logs.length),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                if (logs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.no_readings_yet,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ...logs.map((log) {
                  String displayVal = log.value1.toString();
                  if (type == HealthLogType.bloodPressure) {
                    displayVal = '${log.value1.toInt()}/${log.value2?.toInt()}';
                  }
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.05),
                            shape: BoxShape.circle),
                        child: Icon(Icons.monitor_heart,
                            color: accentColor, size: 20),
                      ),
                      title: Text('$displayVal $unit',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      subtitle: Text(
                        log.timestamp
                            .toString()
                            .split('.')[0], // YYYY-MM-DD HH:MM:SS
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      trailing:
                          Icon(Icons.chevron_right, color: Colors.grey[300]),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      );
    });
  }
}
