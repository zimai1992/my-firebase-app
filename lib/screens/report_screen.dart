import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/utils/compliance_calculator.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/gradient_scaffold.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:myapp/l10n/app_localizations.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isGenerating = false;
  final GeminiService _geminiService = GeminiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clinical_report),
        backgroundColor: Colors.transparent, // Transparent appBar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.assignment_turned_in,
                      size: 60, color: theme.primaryColor),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.expert_clinical_analysis,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.clinical_analysis_desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
              ],
            ),
            const SizedBox(height: 40),
            CustomCard(
              padding: const EdgeInsets.all(24),
              isGlass: true,
              child: Column(
                children: [
                  _buildFeatureRow(context, Icons.analytics_outlined,
                      AppLocalizations.of(context)!.precision_adherence_tracking),
                  Divider(
                      height: 32, color: theme.dividerColor.withOpacity(0.05)),
                  _buildFeatureRow(context, Icons.monitor_heart_outlined,
                      AppLocalizations.of(context)!.health_vital_readings_desc),
                  Divider(
                      height: 32, color: theme.dividerColor.withOpacity(0.05)),
                  _buildFeatureRow(context, Icons.auto_awesome,
                      AppLocalizations.of(context)!.ai_clinician_insights),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isGenerating ? null : () => _generateReport(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                shadowColor: theme.primaryColor.withOpacity(0.4),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(AppLocalizations.of(context)!.generate_pdf,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
            ),
            const SizedBox(height: 24),
            Consumer2<MedicineProvider, SubscriptionService>(
              builder: (context, medicineProvider, subscription, child) {
                final isPremium = subscription.isPremium;
                return CustomCard(
                  padding: const EdgeInsets.all(24),
                  isGlass: true, // Use glassmorphism instead of flat amber color if possible, or keep color
                  color: Colors.amber.withOpacity(0.05),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.oracle_title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                  letterSpacing: 1.2)),
                          const Spacer(),
                          if (!isPremium || !medicineProvider.isImmortal)
                            const Icon(Icons.lock, size: 16, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.oracle_description,
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isGenerating
                            ? null
                            : () => _consultOracle(context, isPremium),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(AppLocalizations.of(context)!.oracle_button,
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_isGenerating) ...[
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.analyzing_patterns,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _consultOracle(BuildContext context, bool isPremium) async {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final isImmortal = provider.isImmortal;

    if (!isPremium || !isImmortal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!isPremium 
            ? AppLocalizations.of(context)!.premium_required
            : AppLocalizations.of(context)!.immortal_required),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      final rawData = provider.generateDoctorReport(); // Using same data for now, but Oracle handles it differently
      final analysis = await _geminiService.performAdvancedAnalysis(rawData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.oracle_insights),
              ],
            ),
            content: SingleChildScrollView(child: Text(analysis)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.done),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oracle sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        const SizedBox(width: 16),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _generateReport(BuildContext context) async {
    setState(() {
      _isGenerating = true;
    });
    try {
      final medicineProvider =
          Provider.of<MedicineProvider>(context, listen: false);
      final medicines = medicineProvider.medicines;
      final logs = medicineProvider.medicineLogs;
      final healthLogs = medicineProvider.healthLogs;
      final user = FirebaseAuth.instance.currentUser;
      final patientName = user?.displayName ?? user?.email ?? "Patient";

      // 1. Calculate Compliance
      final compliance = calculateOverallCompliance(medicines, logs);

      // 2. Generate raw data for AI analysis
      final rawData = medicineProvider.generateDoctorReport();

      // 3. Get AI Analysis
      final aiNotes = await _geminiService.analyzeHealthData(rawData);

      // 4. Generate and Share PDF
      await generateAndSharePdf(
          compliance, medicines, logs, healthLogs, aiNotes, patientName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
