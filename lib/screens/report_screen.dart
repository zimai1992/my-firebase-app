import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/utils/compliance_calculator.dart';
import 'package:myapp/utils/pdf_generator.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _generateReport(context),
          child: const Text('Generate Report'),
        ),
      ),
    );
  }

  Future<void> _generateReport(BuildContext context) async {
    final medicineProvider =
        Provider.of<MedicineProvider>(context, listen: false);
    final medicines = medicineProvider.medicines;
    final logs = medicineProvider.medicineLogs;

    final compliance = calculateOverallCompliance(medicines, logs);

    // TODO: Replace "Patient Name" with actual patient name from user data
    await generateAndSharePdf(compliance, medicines, logs, "Patient Name");
  }
}
