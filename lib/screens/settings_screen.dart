import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import '../providers/locale_provider.dart';
import 'caregiver/add_caregiver_screen.dart';
import 'report_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(localizations.settings_title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileHeader(user, theme),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Appearance & Language'),
                  CustomCard(
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.language,
                          title: localizations.language_section_title,
                          trailing: _buildLanguageDropdown(localeProvider, localizations),
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (v) => themeProvider.toggleTheme(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Health Support'),
                  CustomCard(
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.picture_as_pdf,
                          iconColor: Colors.red,
                          title: 'Doctor Report',
                          subtitle: 'Generate a medication history PDF',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ReportScreen())),
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: Icons.share,
                          iconColor: Colors.blue,
                          title: 'Share My Data',
                          subtitle: 'Link with a caregiver',
                          onTap: () => _showShareCodeDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Monitoring'),
                  CustomCard(
                    child: _buildSettingTile(
                      icon: Icons.person_add,
                      iconColor: Colors.green,
                      title: 'Caregiver Access',
                      subtitle: 'Monitor someone else\'s health',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddCaregiverScreen())),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Account'),
                  CustomCard(
                    child: _buildSettingTile(
                      icon: Icons.logout,
                      iconColor: Colors.grey,
                      title: 'Sign Out',
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user, ThemeData theme) {
    return AnimatedFadeIn(
      child: CustomCard(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'My Profile',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? 'No email linked',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.teal).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.teal, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDropdown(LocaleProvider localeProvider, AppLocalizations localizations) {
    return DropdownButton<Locale>(
      value: localeProvider.locale,
      underline: const SizedBox(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) localeProvider.setLocale(newLocale);
      },
      items: AppLocalizations.supportedLocales.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale, localizations), style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  String _getLanguageName(Locale locale, AppLocalizations localizations) {
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'ms': return 'Bahasa Melayu';
      case 'zh': return '中文';
      default: return locale.languageCode;
    }
  }

  void _showShareCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.blue),
            SizedBox(width: 12),
            Text('Share Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your unique caregiver code:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                '123 456',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this code with your caregiver to allow them to monitor your health in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () {}, child: const Text('Copy Code')),
        ],
      ),
    );
  }
}
