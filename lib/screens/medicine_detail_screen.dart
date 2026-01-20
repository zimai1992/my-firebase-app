import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/utils/kkm_resources.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/models/prediction_result.dart';
import 'package:myapp/screens/missed_dose_guide_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchMaps() async {
    final String query = Uri.encodeComponent('pharmacy near me');
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
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
    final currentMedicine = context.select<MedicineProvider, Medicine>((p) => p
        .medicines
        .firstWhere((m) => m.id == medicine.id, orElse: () => medicine));

    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final medColor = currentMedicine.pillColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _launchMaps,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [medColor, medColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getShapeIcon(currentMedicine.pillShape),
                          color: Colors.white, size: 60),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentMedicine.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${currentMedicine.dosage} • ${currentMedicine.frequency}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentMedicine.isStopped) _buildStopAlert(context),
                  _buildInventorySection(context, currentMedicine),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'How to Use'),
                  _buildKkmSection(context, currentMedicine),
                  _buildSectionTitle(context, 'Safety & Notes'),
                  if (currentMedicine.specialInstructions.isNotEmpty)
                    _buildWarningCard(
                      title: localizations.special_instructions,
                      content: currentMedicine.specialInstructions,
                      icon: Icons.info_outline,
                      gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.blue[100]!]),
                      iconColor: Colors.blue[700]!,
                      context: context,
                    ),
                  if (currentMedicine.recommendationNote != null &&
                      currentMedicine.recommendationNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildWarningCard(
                      title: localizations.pharmacist_note,
                      content: currentMedicine.recommendationNote!,
                      icon: Icons.note_alt_outlined,
                      gradient: LinearGradient(
                          colors: [Colors.purple[50]!, Colors.purple[100]!]),
                      iconColor: Colors.purple[700]!,
                      context: context,
                    ),
                  ],
                  if (currentMedicine.lifestyleWarnings != null &&
                      currentMedicine.lifestyleWarnings!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildWarningCard(
                      title: localizations.lifestyle_warnings,
                      content: currentMedicine.lifestyleWarnings!,
                      icon: Icons.warning_amber_rounded,
                      gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.orange[100]!]),
                      iconColor: Colors.orange[700]!,
                      context: context,
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Find the relevant pending action for this medicine
                        final action = context.read<MedicineProvider>().getPendingActions().firstWhere(
                          (a) => a['medicine'].id == currentMedicine.id,
                          orElse: () => {'medicine': currentMedicine, 'time': currentMedicine.times.firstOrNull ?? TimeOfDay.now(), 'isMissed': false}
                        );
                        context.read<MedicineProvider>().logMedicine(
                          currentMedicine,
                          scheduledTime: action['time']
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logged ${currentMedicine.name} dose!'))
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('LOG DOSE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                    onPressed: () {
                      final provider = context.read<MedicineProvider>();
                      final oldMed = currentMedicine;
                      final newMed = currentMedicine.copyWith(
                          isStopped: !currentMedicine.isStopped);
                      provider.updateMedicineWithAlerts(
                          context, oldMed, newMed);
                    },
                    icon: Icon(currentMedicine.isStopped
                        ? Icons.play_arrow
                        : Icons.stop_circle_outlined),
                    label: Text(currentMedicine.isStopped ? 'RESUME' : 'STOP'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: currentMedicine.isStopped
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showEditDosageDialog(context, currentMedicine),
                      icon: const Icon(Icons.edit),
                      label: const Text('EDIT'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => const MissedDoseGuideScreen())),
                icon: const Icon(Icons.help_outline),
                label: const Text('MISSED DOSE ADVICE'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDosageDialog(BuildContext context, Medicine medicine) {
    final controller = TextEditingController(text: medicine.dosage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Dosage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Dosage'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newDosage = controller.text.trim();
              if (newDosage.isNotEmpty && newDosage != medicine.dosage) {
                final newMed = medicine.copyWith(dosage: newDosage);
                context
                    .read<MedicineProvider>()
                    .updateMedicineWithAlerts(context, medicine, newMed);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context, Medicine medicine) {
    final isLow = medicine.currentStock <= medicine.lowStockThreshold;
    final provider = context.watch<MedicineProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Inventory Management'),
        CustomCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: (isLow ? Colors.red : theme.primaryColor)
                        .withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.inventory_2,
                    color: isLow ? Colors.red : theme.primaryColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Remaining',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${medicine.currentStock} Pills',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              if (isLow)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('LOW',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // AI Refill Prediction
        FutureBuilder<PredictionResult>(
          future: GeminiService()
              .predictRunoutDate(medicine, provider.medicineLogs),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final prediction = snapshot.data!;
            if (prediction.daysRemaining == null)
              return const SizedBox.shrink();

            final days = prediction.daysRemaining!;
            final Color progressColor = days > 14
                ? Colors.green
                : (days > 7 ? Colors.orange : Colors.red);

            return CustomCard(
              gradient: LinearGradient(colors: [
                progressColor.withOpacity(0.05),
                progressColor.withOpacity(0.1)
              ]),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Text('AI PREDICTION',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: progressColor,
                              letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(prediction.message,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (days / 30).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildStopAlert(BuildContext context) {
    return CustomCard(
      color: Colors.red.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Icon(Icons.stop_circle, color: Colors.red),
          SizedBox(width: 12),
          Text('Treatment has been suspended',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getShapeIcon(PillShape shape) {
    switch (shape) {
      case PillShape.capsule:
        return Icons.medication_liquid;
      case PillShape.liquid:
        return Icons.water_drop;
      case PillShape.square:
        return Icons.crop_square;
      default:
        return Icons.circle;
    }
  }

  Widget _buildKkmSection(BuildContext context, Medicine medicine) {
    final kkmResource =
        KKMRepository.getResource(medicine.name, medicine.genericName);
    if (kkmResource == null) return const SizedBox.shrink();

    return CustomCard(
      gradient:
          const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
      onTap: () => _launchUrl(kkmResource.videoUrl),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KKM OFFICIAL GUIDE',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(kkmResource.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: Colors.white24, size: 20),
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String title,
    required String content,
    required IconData icon,
    required Gradient gradient,
    required Color iconColor,
    required BuildContext context,
  }) {
    return CustomCard(
      gradient: gradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                      fontSize: 11,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: iconColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
