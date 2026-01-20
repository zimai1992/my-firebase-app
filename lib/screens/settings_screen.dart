import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/widgets/gradient_scaffold.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:myapp/screens/paywall_screen.dart';
import '../providers/locale_provider.dart';
import 'caregiver/add_caregiver_screen.dart';
import 'report_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final subscription = Provider.of<SubscriptionService>(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return GradientScaffold(
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
                  _buildProfileHeader(user, theme, subscription.isPremium, localizations),
                  const SizedBox(height: 24),

                  _buildSectionHeader(localizations.appearance_language),
                  CustomCard(
                    isGlass: true,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.language,
                          title: localizations.language_section_title,
                          trailing: _buildLanguageDropdown(
                              localeProvider, localizations),
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: themeProvider.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          title: localizations.dark_mode,
                          trailing: Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (v) => themeProvider.toggleTheme(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(localizations.health_support),
                  CustomCard(
                    isGlass: true,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.picture_as_pdf,
                          iconColor: Colors.red,
                          title: localizations.doctor_report_title,
                          subtitle: localizations.doctor_report_subtitle,
                          trailing: !subscription.isPremium
                              ? const Icon(Icons.lock_outline,
                                  size: 16, color: Colors.grey)
                              : null,
                          onTap: () {
                            if (!subscription.isPremium) {
                              _showPremiumRequired(context, 'Doctor Reports', localizations);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const ReportScreen()));
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          icon: Icons.share,
                          iconColor: Colors.blue,
                          title: localizations.share_data_title,
                          subtitle: localizations.share_data_subtitle,
                          trailing: !subscription.isPremium
                              ? const Icon(Icons.lock_outline,
                                  size: 16, color: Colors.grey)
                              : null,
                          onTap: () {
                          if (!subscription.isPremium) {
                               _showPremiumRequired(
                                  context, localizations.share_data_title, localizations);
                            } else {
                               _showShareCodeDialog(context, localizations);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(localizations.monitoring_section),
                  CustomCard(
                    isGlass: true,
                    child: _buildSettingTile(
                        icon: Icons.person_add,
                        iconColor: Colors.green,
                        title: localizations.caregiver_access_title,
                        subtitle: localizations.caregiver_access_subtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const AddCaregiverScreen())),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(localizations.account_section),
                  CustomCard(
                    isGlass: true,
                    child: _buildSettingTile(
                        icon: Icons.logout,
                        iconColor: Colors.grey,
                        title: localizations.sign_out,
                        onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // DEBUG TOOLS
                  _buildSectionHeader('Developer Tools'),
                  CustomCard(
                    color: Colors.grey[100],
                    child: _buildSettingTile(
                      icon: Icons.bug_report,
                      iconColor: Colors.orange,
                      title: 'Toggle Premium (Debug)',
                      subtitle:
                          'Status: ${subscription.isPremium ? 'PREMIUM' : 'FREE'}',
                      onTap: () => subscription.togglePremiumDebug(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      );
  }

  void _showPremiumRequired(BuildContext context, String feature, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.premium_feature),
        content: Text(
            localizations.premium_required_desc(feature)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.maybe_later)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: Text(localizations.view_plans),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user, ThemeData theme, bool isPremium, AppLocalizations localizations) {
    return AnimatedFadeIn(
      child: CustomCard(
        color: isPremium
            ? Colors.amber.shade100.withAlpha(50)
            : theme.colorScheme.primaryContainer.withAlpha((0.3 * 255).toInt()),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (user?.displayName ?? user?.email ?? 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.star,
                            size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.displayName ?? localizations.my_profile,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(localizations.pro_label,
                                style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ]
                      ],
                    ),
                    Text(
                      user?.email ?? localizations.guest_email,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withAlpha((0.6 * 255).toInt()),
                          fontSize: 13),
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
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey),
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
          color: (iconColor ?? Colors.teal).withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.teal, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing ??
          (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDropdown(
      LocaleProvider localeProvider, AppLocalizations localizations) {
    return DropdownButton<Locale>(
      value: localeProvider.locale,
      underline: const SizedBox(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) localeProvider.setLocale(newLocale);
      },
      items: AppLocalizations.supportedLocales.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale, localizations),
              style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  String _getLanguageName(Locale locale, AppLocalizations localizations) {
    switch (locale.languageCode) {
      case 'en':
        return localizations.language_english;
      case 'ms':
        return localizations.language_malay;
      case 'zh':
        return localizations.language_chinese;
      default:
        return locale.languageCode;
    }
  }

  void _showShareCodeDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.share, color: Colors.blue),
            const SizedBox(width: 12),
            Text(localizations.share_data_title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.caregiver_code_label),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.blue.withAlpha((0.3 * 255).toInt())),
              ),
              child: const Text(
                '123 456',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.caregiver_code_desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.close)),
          ElevatedButton(onPressed: () {}, child: Text(localizations.copy_code)),
        ],
      ),
    );
  }
}
