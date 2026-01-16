import 'package:flutter/material.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/l10n/app_localizations.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(localizations.medicine_name, medicine.name),
            _buildDetailItem(localizations.medicine_dosage, medicine.dosage),
            _buildDetailItem(
                localizations.medicine_frequency, medicine.frequency),
            if (medicine.recommendationNote != null &&
                medicine.recommendationNote!.isNotEmpty)
              _buildWarningCard(
                title: localizations.pharmacist_note,
                content: medicine.recommendationNote!,
                icon: Icons.note_alt_outlined,
                color: Colors.blue.shade100,
                context: context,
              ),
            if (medicine.lifestyleWarnings != null &&
                medicine.lifestyleWarnings!.isNotEmpty)
              _buildWarningCard(
                title: localizations.lifestyle_warnings,
                content: medicine.lifestyleWarnings!,
                icon: Icons.warning_amber_rounded,
                color: Colors.orange.shade100,
                context: context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
