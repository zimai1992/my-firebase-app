import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/screens/missed_dose_guide_screen.dart';
import 'package:myapp/l10n/app_localizations.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  List<Map<String, String>> _getVideos(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.insulin_pen_title,
        'description': l10n.insulin_pen_desc,
        'url':
            'https://www.youtube.com/results?search_query=cara+guna+insulin+pen+kkm',
        'icon': '💉',
      },
      {
        'title': l10n.inhaler_technique_title,
        'description': l10n.inhaler_technique_desc,
        'url':
            'https://www.youtube.com/results?search_query=cara+guna+inhaler+kkm',
        'icon': '💨',
      },
      {
        'title': l10n.know_warfarin_title,
        'description': l10n.know_warfarin_desc,
        'url': 'https://www.youtube.com/results?search_query=ubat+warfarin+kkm',
        'icon': '❤️',
      },
      {
        'title': l10n.hypoglycemia_signs_title,
        'description': l10n.hypoglycemia_signs_desc,
        'url':
            'https://www.youtube.com/results?search_query=tanda+hipoglisemia+kkm',
        'icon': '🍬',
      },
      {
        'title': l10n.official_missed_dose_protocol_title,
        'description': l10n.official_missed_dose_protocol_desc,
        'url': 'internal://missed-dose-guide',
        'icon': '📋',
      },
      {
        'title': l10n.know_your_medicine_title,
        'description': l10n.know_your_medicine_desc,
        'url': 'https://www.knowyourmedicine.gov.my/',
        'icon': '💊',
      },
    ];
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    if (urlString == 'internal://missed-dose-guide') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MissedDoseGuideScreen()));
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Since we need context for localization, we generate the list inside build
    final videos = _getVideos(context);
    
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.health_academy_title,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 20),
              onTap: () => _launchURL(context, video['url']!),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(video['icon']!,
                          style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video['title']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                  color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 6),
                          Text(video['description']!,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 13,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                    Icon(Icons.play_circle_outline,
                        color: theme.primaryColor.withOpacity(0.3), size: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
