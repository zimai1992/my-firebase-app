import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/utils/compliance_calculator.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:myapp/widgets/custom_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.description, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Generate Health Report',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'This report includes your medication adherence, upcoming schedule, and compliance history. You can share this directly with your healthcare professional.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFeatureRow(Icons.check_circle, 'Adherence Percentage'),
                    const Divider(),
                    _buildFeatureRow(Icons.history, 'Full Medication History'),
                    const Divider(),
                    _buildFeatureRow(Icons.medication, 'Current Medications List'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isGenerating ? null : () => _generateReport(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isGenerating 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Generate & Share PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
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

      final compliance = calculateOverallCompliance(medicines, logs);

      // TODO: Replace "Patient Name" with actual patient name from user data
      await generateAndSharePdf(compliance, medicines, logs, "Patient Name");
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
