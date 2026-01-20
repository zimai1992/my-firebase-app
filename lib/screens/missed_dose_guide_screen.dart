import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/gradient_scaffold.dart';

class MissedDoseGuideScreen extends StatelessWidget {
  const MissedDoseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.missed_dose_guide_title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoreRule(context),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.what_to_do_late,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                      letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _buildProtocolCard(
                context,
                AppLocalizations.of(context)!.od_title,
                AppLocalizations.of(context)!.od_protocol,
                Icons.calendar_today,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildProtocolCard(
                context,
                AppLocalizations.of(context)!.multiple_times_title,
                AppLocalizations.of(context)!.multiple_times_protocol,
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 32),
              _buildNote(
                context,
                AppLocalizations.of(context)!.side_effects_title,
                AppLocalizations.of(context)!.side_effects_protocol,
                Icons.visibility,
              ),
              const SizedBox(height: 12),
              _buildNote(
                context,
                AppLocalizations.of(context)!.meals_food_title,
                AppLocalizations.of(context)!.meals_food_protocol,
                Icons.restaurant_menu,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              _buildProtocolCard(
                context,
                AppLocalizations.of(context)!.forgiveness_title,
                AppLocalizations.of(context)!.forgiveness_protocol,
                Icons.science,
                Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              _buildReference(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
    );
  }

  Widget _buildCoreRule(BuildContext context) {
    return CustomCard(
      color: Colors.green.withOpacity(0.1),
      isGlass: true, // Glassmorphism
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.safe_window_title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.safe_window_protocol,
                  style: TextStyle(height: 1.4, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      isGlass: true, // Glassmorphism
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: const TextStyle(height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNote(
      BuildContext context, String title, String content, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey)),
              const SizedBox(height: 4),
              Text(content,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReference(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.clinical_references,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(
          '1. Albassam A, Hughes DA. "What should patients do if they miss a dose? A systematic review of patient information leaflets and summaries of product characteristics." Eur J Clin Pharmacol. 2021;77(4):615-621. doi:10.1007/s00228-020-03031-6.',
          style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.4),
        ),
        const SizedBox(height: 8),
        Text(
          '2. National Patient Safety Agency (NPSA). Grading of risk of harm from omitted and delayed medicines.',
          style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.4),
        ),
      ],
    );
  }
}
