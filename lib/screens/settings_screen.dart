import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'caregiver/add_caregiver_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    String getLanguageName(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
          return localizations.language_english;
        case 'es':
          return localizations.language_spanish;
        default:
          return locale.languageCode;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.language_section_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Semantics(
              label: localizations.language_section_title,
              button: true,
              child: DropdownButton<Locale>(
                value: localeProvider.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localeProvider.setLocale(newLocale);
                  }
                },
                items: AppLocalizations.supportedLocales
                    .map<DropdownMenuItem<Locale>>((Locale locale) {
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(getLanguageName(locale)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Caregiver',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Generate and show 6-digit code
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Share Your Data'),
                    content: const Text(
                        'Your 6-digit code is: 123456'), // Replace with actual code
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Share My Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddCaregiverScreen(),
                  ),
                );
              },
              child: const Text('Add Caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}
