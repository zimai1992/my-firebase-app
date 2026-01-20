import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/health_tracker_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/widgets/adherence_chart.dart';
import 'package:myapp/widgets/special_badge.dart';
import 'package:myapp/widgets/gradient_scaffold.dart';
import 'package:myapp/widgets/skeleton/medicine_skeleton.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/utils/error_handler.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:myapp/screens/paywall_screen.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import './add_medicine_screen.dart';
import './medicine_detail_screen.dart';
import './settings_screen.dart';
import './caregiver/caregiver_dashboard_screen.dart';
import './education_screen.dart';
import './pharmacist_chat_screen.dart';
import './report_screen.dart';
import './missed_dose_guide_screen.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  static const List<Widget> _widgetOptions = <Widget>[
    MainContent(),
    HistoryScreen(),
    CaregiverDashboardScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _listen() async {
    final subscription =
        Provider.of<SubscriptionService>(context, listen: false);
    if (!subscription.isPremium) {
      _showPremiumRequired('Voice Commands');
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => developer.log('onStatus: $val'),
        onError: (val) => developer.log('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => _handleVoiceCommand(val.recognizedWords),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.toLowerCase();
    final provider = Provider.of<MedicineProvider>(context, listen: false);

    if (command.contains('add medicine') || command.contains('add med')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (c) => const AddMedicineScreen()));
    } else if (command.contains('check safety')) {
      _showInteractionDialog(context, provider.medicines);
    } else if (command.contains('did i take')) {
      final medicines = provider.medicines;
      Medicine? found;
      for (var med in medicines) {
        if (command.contains(med.name.toLowerCase())) {
          found = med;
          break;
        }
      }

      if (found != null) {
        final logs = provider.medicineLogs
            .where((l) =>
                l.medicineId == found!.id &&
                l.timestamp.day == DateTime.now().day)
            .toList();

        if (logs.isNotEmpty) {
          final lastTime = DateFormat.jm().format(logs.first.timestamp);
          GlobalErrorHandler.showError(
              context, 'Yes, you took ${found.name} at $lastTime today.');
        } else {
          GlobalErrorHandler.showError(
              context, 'No, you haven\'t taken ${found.name} yet today.');
        }
      } else {
        GlobalErrorHandler.showError(
            context, 'Which medicine are you asking about?');
      }
    }
  }

  void _showPremiumRequired(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text(
            '$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    final bool isDark = theme.brightness == Brightness.dark;
    final List<Color> bgColors;

    if (isDark) {
      bgColors = [const Color(0xFF0F172A), const Color(0xFF1E293B)];
    } else {
      if (hour < 12) {
        bgColors = [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)];
      } else if (hour < 18) {
        bgColors = [const Color(0xFFFFF9C4), const Color(0xFFFFECB3)];
      } else {
        bgColors = [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)];
      }
    }

    return GradientScaffold(
      // Background is now handled by GradientScaffold
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _selectedIndex == 0
            ? Row(
                children: [
                  Image.asset(
                    'assets/images/rx_genie_logo.png',
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                ],
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : null),
            onPressed: _listen,
          ),
          if (_selectedIndex == 0) ...[
            _buildSOSButton(context),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8), // Semi-transparent nav
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: localizations.home),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.history
                  : Icons.history_outlined),
              label: localizations.history),
          BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 2 ? Icons.group : Icons.group_outlined),
              label: 'Caregiver'),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3
                  ? Icons.settings
                  : Icons.settings_outlined),
              label: localizations.settings),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                final provider =
                    Provider.of<MedicineProvider>(context, listen: false);
                final subscription = Provider.of<SubscriptionService>(
                    context,
                    listen: false);
                if (provider.medicines.length >= 3 &&
                    !subscription.isPremium) {
                  _showPremiumRequired('Adding more than 3 medicines');
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AddMedicineScreen()));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Med'),
            )
          : null,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSOSButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.emergency, color: Colors.red),
      onPressed: () {
        Provider.of<MedicineProvider>(context, listen: false).sendSOS();
        GlobalErrorHandler.showError(context, 'SOS Alert Sent to Caregivers!');
      },
      tooltip: 'SOS Emergency',
    );
  }
}

bool isNight() {
  final hour = DateTime.now().hour;
  return hour >= 18 || hour < 6;
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  Widget _buildFeatureGrid(BuildContext context, bool isPremium) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildFeatureCard(
          context,
          'Health Tracker',
          'Log Sugar, BP & INR',
          Icons.monitor_heart,
          const [Color(0xFFFFEEF0), Color(0xFFFFF1F3)],
          Colors.pink,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (c) => const HealthTrackerScreen())),
        ),
        _buildFeatureCard(
          context,
          'AI Pharmacist',
          'Ask Questions',
          Icons.question_answer,
          const [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
          Colors.purple,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (c) => const PharmacistChatScreen())),
        ),
        _buildFeatureCard(
          context,
          'AI Doctor Report',
          'Professional PDF',
          Icons.assessment,
          const [Color(0xFFF0FDFA), Color(0xFFF5FEFD)],
          Colors.teal,
          () => Navigator.push(
              context, MaterialPageRoute(builder: (c) => const ReportScreen())),
        ),
        _buildFeatureCard(
          context,
          'Health Education',
          'Learn & Watch',
          Icons.school,
          const [Color(0xFFFFF7ED), Color(0xFFFFFAF5)],
          Colors.orange,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (c) => const EducationScreen())),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      List<Color> bgColors,
      Color iconColor,
      VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return CustomCard(
      onTap: onTap,
      isGlass: true, // Glassmorphic features
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor)),
          const SizedBox(height: 2),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 10, color: textColor.withOpacity(0.6))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicineProvider, SubscriptionService>(
      builder: (context, provider, subscription, child) {
        if (provider.isLoading) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: List.generate(5, (_) => const MedicineCardSkeleton()),
          );
        }

        final medicines = List<Medicine>.from(provider.medicines)
          ..sort((a, b) {
            if (a.isStopped && !b.isStopped) return 1;
            if (!a.isStopped && b.isStopped) return -1;
            return 0;
          });
        final logs = provider.medicineLogs;
        final upcoming = provider.getPendingActions();
        final streak = provider.getAdherenceStreak();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            if (provider.interactionWarnings.isNotEmpty)
              _buildSafetyAlert(context, provider.interactionWarnings.first),
            if (provider.timingSuggestion != null)
              _buildTimingSuggestion(context, provider.timingSuggestion!),
            _buildDailyProgress(context, provider.getDailyProgress(), streak),
            const SizedBox(height: 16),
            _buildFeatureGrid(context, subscription.isPremium),
            const SizedBox(height: 16),
            if (upcoming.isNotEmpty)
              _buildFocusNextDose(context, upcoming.first),
            const SizedBox(height: 20),
            _buildChartSection(context, logs),
            const SizedBox(height: 20),
            _buildInteractionChecker(
                context, medicines, subscription.isPremium),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'All Medications', medicines.length),
            if (medicines.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No medicines added yet.')))
            else
              ...medicines.map((med) =>
                  AnimatedFadeIn(child: _buildMedicineCard(context, med))),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildDailyProgress(
      BuildContext context, Map<String, int> progress, int streak) {
    final theme = Theme.of(context);
    final int taken = progress['taken'] ?? 0;
    final int total = progress['total'] ?? 1;
    final double percent = (total == 0) ? 0 : (taken / total).clamp(0.0, 1.0);

    String milestone = '';
    if (streak >= 30)
      milestone = '🏆 Monthly Master!';
    else if (streak >= 7)
      milestone = '🌟 Weekly Warrior!';
    else if (streak >= 3) milestone = '🔥 On Fire!';

    final int level = Provider.of<MedicineProvider>(context).currentLevel;
    final double xpProgress = Provider.of<MedicineProvider>(context).levelProgress;
    final String tier = Provider.of<MedicineProvider>(context).prestigeTier;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${AppLocalizations.of(context)!.level_label} $level',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.primaryColor,
                              letterSpacing: 2)),
                      IconButton(
                        icon: const Icon(Icons.bug_report, size: 16, color: Colors.grey),
                        onPressed: () => Provider.of<MedicineProvider>(context, listen: false).debugAddXP(500),
                        tooltip: 'Debug: +500 XP',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 8,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: theme.primaryColor.withOpacity(0.1),
                    ),
                    child: LinearProgressIndicator(
                      value: xpProgress,
                      backgroundColor: Colors.transparent,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.to_level_x((xpProgress * 100).toInt(), level + 1),
                      style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
              SpecialBadge(tier: tier, level: level),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percent),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 16,
                      backgroundColor: theme.primaryColor.withOpacity(0.05),
                      color: theme.primaryColor,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(percent * 100).toInt()}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor)),
                  Text('$taken/$total doses',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStreakBadge(context, streak),
              if (milestone.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildMilestoneBadge(context, milestone),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 18),
          const SizedBox(width: 6),
          Text('$streak Days',
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.orange[800])),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadge(BuildContext context, String milestone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Text(milestone,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildFocusNextDose(BuildContext context, Map<String, dynamic> action) {
    final theme = Theme.of(context);
    final Medicine medicine = action['medicine'];
    final TimeOfDay time = action['time'];
    final bool isMissed = action['isMissed'];

    final Color cardColor = isMissed ? Colors.orange.shade800 : theme.primaryColor;
    final Color secondaryColor = isMissed ? Colors.deepOrange : theme.primaryColor.withBlue(200);

    return CustomCard(
      gradient: LinearGradient(
        colors: [cardColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(isMissed ? Icons.priority_high : Icons.notifications_active,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMissed ? 'MISSED DOSE' : 'UPCOMING DOSE',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(medicine.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text('${time.format(context)} • ${medicine.dosage}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15)),
                    ],
                  ),
                ),
                if (isMissed)
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white70),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const MissedDoseGuideScreen())),
                    tooltip: 'Missed Dose Advice',
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Provider.of<MedicineProvider>(context, listen: false)
                      .logMedicine(medicine, scheduledTime: time),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: cardColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text('LOG DOSE NOW',
                  style: TextStyle(
                      letterSpacing: 1.1, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List<MedicineLog> logs) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adherence Trend',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdherenceChart(logs: logs),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionChecker(
      BuildContext context, List<Medicine> medicines, bool isPremium) {
    final theme = Theme.of(context);
    return CustomCard(
      color: theme.colorScheme.primaryContainer.withAlpha(51),
      onTap: () {
        if (!isPremium) {
          _showPremiumRequired(context, 'AI Safety Check');
        } else {
          _showInteractionDialog(context, medicines);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.security, color: Colors.teal),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Safety Check',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Check for drug interactions between your meds',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (!isPremium)
              const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPremiumRequired(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text(
            '$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: textColor)),
          Text('$count',
              style: TextStyle(
                  fontSize: 12, color: textColor.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, Medicine medicine) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CustomCard(
      color: isDark ? theme.colorScheme.surface : null,
      margin: const EdgeInsets.only(bottom: 12.0),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => MedicineDetailScreen(medicine: medicine))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: medicine.pillColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _buildPillIcon(medicine),
          ),
          title: Text(medicine.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration:
                      medicine.isStopped ? TextDecoration.lineThrough : null,
                  color: medicine.isStopped
                      ? Colors.grey
                      : theme.colorScheme.onSurface)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: medicine.isStopped
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    medicine.isStopped
                        ? 'STOPPED'
                        : '${medicine.dosage} • ${medicine.frequency}',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: medicine.isStopped
                            ? Colors.red
                            : theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          trailing: Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildPillIcon(Medicine medicine) {
    if (medicine.isStopped)
      return const Icon(Icons.stop_circle_outlined,
          color: Colors.grey, size: 30);
    IconData icon;
    switch (medicine.pillShape) {
      case PillShape.capsule:
        icon = Icons.medication_liquid;
        break;
      case PillShape.liquid:
        icon = Icons.water_drop;
        break;
      case PillShape.square:
        icon = Icons.crop_square;
        break;
      default:
        icon = Icons.circle;
    }
    return Icon(icon, color: medicine.pillColor, size: 30);
  }

  Widget _buildTimingSuggestion(
      BuildContext context, Map<String, String> suggestion) {
    final medName = suggestion['medicineName'];
    final newTime = suggestion['newTime'];
    final diff = int.parse(suggestion['diff']!);
    final direction = diff > 0 ? 'later' : 'earlier';
    final absDiff = diff.abs();

    return CustomCard(
      gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SMART REMINDER TIP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.blue,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(
                        'You usually take $medName about $absDiff minutes $direction. Adjust to $newTime?',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Provider.of<MedicineProvider>(context, listen: false)
                          .clearTimingSuggestion(),
                  child: Text('DISMISS',
                      style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () =>
                      Provider.of<MedicineProvider>(context, listen: false)
                          .applyTimingSuggestion(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ADJUST NOW'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyAlert(BuildContext context, String warning) {
    return CustomCard(
      gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFFF1F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      margin: const EdgeInsets.only(bottom: 20),
      onTap: () => _showInteractionDialog(context,
          Provider.of<MedicineProvider>(context, listen: false).medicines),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI SAFETY ALERT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.red,
                          letterSpacing: 1.2)),
                  SizedBox(height: 4),
                  Text('Check for potential drug interactions',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F1D1D),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

void _showInteractionDialog(
    BuildContext context, List<Medicine> medicines) async {
  if (medicines.isEmpty) {
    GlobalErrorHandler.showError(context, 'Add some medicines first.');
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('AI Safety Analysis'),
      content: FutureBuilder<String>(
        future: GeminiService().checkInteractions(medicines),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing medications...'),
              ],
            );
          }
          return SingleChildScrollView(
              child: Text(snapshot.data ?? 'Error analyzing meds.'));
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    ),
  );
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showMissedOnly = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicineProvider, SubscriptionService>(
      builder: (context, provider, subscription, child) {
        final history = provider.medicineLogs;

        var filteredHistory = subscription.isPremium
            ? history
            : history
                .where((log) => log.timestamp
                    .isAfter(DateTime.now().subtract(const Duration(days: 7))))
                .toList();

        if (_showMissedOnly) {
          filteredHistory = filteredHistory.where((log) => log.isMissed).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.filter_label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.filter_all),
                    selected: !_showMissedOnly,
                    onSelected: (val) => setState(() => _showMissedOnly = !val),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.filter_missed),
                    selected: _showMissedOnly,
                    onSelected: (val) => setState(() => _showMissedOnly = val),
                    selectedColor: Colors.red.shade100,
                    labelStyle: TextStyle(
                        color: _showMissedOnly ? Colors.red.shade900 : null),
                  ),
                ],
              ),
            ),
            if (filteredHistory.isEmpty)
              Expanded(
                  child: Center(
                      child: Text(_showMissedOnly
                          ? AppLocalizations.of(context)!.no_missed_doses
                          : AppLocalizations.of(context)!.no_history))),
            if (!subscription.isPremium)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomCard(
                  color: Colors.blue.shade50,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const PaywallScreen())),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.lock_clock_outlined, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                AppLocalizations.of(context)!.free_tier_history_note,
                                style: const TextStyle(fontSize: 12))),
                        Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final log = filteredHistory[index];
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: log.isMissed
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          log.isMissed ? Icons.close : Icons.check_circle,
                          color: log.isMissed ? Colors.red : Colors.green,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(log.medicineName,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          if (log.isMissed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: BorderRadius.circular(4),
                              ),
                                child: Text(AppLocalizations.of(context)!.missed_label,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat.yMMMd().add_jm().format(log.timestamp),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6))),
                          if (log.scheduledTime != null)
                            Text(
                              'Scheduled: ${log.scheduledTime!.format(context)}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
