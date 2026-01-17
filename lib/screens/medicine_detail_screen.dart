import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/widgets/custom_card.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  Future<void> _launchMaps() async {
    final String query = Uri.encodeComponent('pharmacy near me');
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final Uri appleMapsUrl = Uri.parse('http://maps.apple.com/?q=$query');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      throw 'Could not launch maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _launchMaps,
            tooltip: 'Find nearby pharmacy',
          ),
        ],
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
            const SizedBox(height: 16),
            
            _buildInventorySection(context, medicine),
            const SizedBox(height: 16),

            if (medicine.recommendationNote != null &&
                medicine.recommendationNote!.isNotEmpty)
              _buildWarningCard(
                title: localizations.pharmacist_note,
                content: medicine.recommendationNote!,
                icon: Icons.note_alt_outlined,
                color: Colors.blue.shade50,
                context: context,
              ),
            if (medicine.lifestyleWarnings != null &&
                medicine.lifestyleWarnings!.isNotEmpty)
              _buildWarningCard(
                title: localizations.lifestyle_warnings,
                content: medicine.lifestyleWarnings!,
                icon: Icons.warning_amber_rounded,
                color: Colors.orange.shade50,
                context: context,
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _launchMaps,
            icon: const Icon(Icons.local_pharmacy),
            label: const Text('ONE-TAP REFILL (FIND PHARMACY)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context, Medicine medicine) {
    final isLow = medicine.currentStock <= medicine.lowStockThreshold;
    return CustomCard(
      color: isLow ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${medicine.currentStock} pills remaining', style: TextStyle(color: isLow ? Colors.red : Colors.grey)),
                ],
              ),
            ),
            if (isLow)
              const Icon(Icons.warning, color: Colors.red),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withAlpha(20)),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.black87),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
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
