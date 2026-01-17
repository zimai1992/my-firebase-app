import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/widgets/adherence_chart.dart';
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
    final subscription = Provider.of<SubscriptionService>(context, listen: false);
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
      Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMedicineScreen()));
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
        final logs = provider.medicineLogs.where((l) => 
          l.medicineId == found!.id && 
          l.timestamp.day == DateTime.now().day
        ).toList();
        
        if (logs.isNotEmpty) {
          final lastTime = DateFormat.jm().format(logs.first.timestamp);
          GlobalErrorHandler.showError(context, 'Yes, you took ${found.name} at $lastTime today.');
        } else {
          GlobalErrorHandler.showError(context, 'No, you haven\'t taken ${found.name} yet today.');
        }
      } else {
        GlobalErrorHandler.showError(context, 'Which medicine are you asking about?');
      }
    }
  }

  void _showPremiumRequired(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text('$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen()));
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
    final bgColors = hour < 12 
      ? [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)] 
      : (hour < 18 ? [const Color(0xFFFFF9C4), const Color(0xFFFFECB3)] : [const Color(0xFF1A237E), const Color(0xFF0D47A1)]);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
      ),
      child: TexturedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _selectedIndex == 0 ? _getGreeting() : '',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : null),
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
            elevation: 8,
            backgroundColor: theme.colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined), label: localizations.home),
              BottomNavigationBarItem(icon: Icon(_selectedIndex == 1 ? Icons.history : Icons.history_outlined), label: localizations.history),
              BottomNavigationBarItem(icon: Icon(_selectedIndex == 2 ? Icons.group : Icons.group_outlined), label: 'Caregiver'),
              BottomNavigationBarItem(icon: Icon(_selectedIndex == 3 ? Icons.settings : Icons.settings_outlined), label: localizations.settings),
            ],
          ),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    final provider = Provider.of<MedicineProvider>(context, listen: false);
                    final subscription = Provider.of<SubscriptionService>(context, listen: false);
                    if (provider.medicines.length >= 3 && !subscription.isPremium) {
                      _showPremiumRequired('Adding more than 3 medicines');
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMedicineScreen()));
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Med'),
                )
              : null,
        ),
      ),
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

class MainContent extends StatelessWidget {
  const MainContent({super.key});

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

        final medicines = provider.medicines;
        final logs = provider.medicineLogs;
        final upcoming = provider.getUpcomingMedicines();
        final streak = provider.getAdherenceStreak();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            _buildStreakBadge(context, streak),
            const SizedBox(height: 16),
            if (upcoming.isNotEmpty) _buildFocusNextDose(context, upcoming.first),
            const SizedBox(height: 20),
            _buildChartSection(context, logs),
            const SizedBox(height: 20),
            _buildInteractionChecker(context, medicines, subscription.isPremium),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'All Medications', medicines.length),
            if (medicines.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('No medicines added yet.')))
            else
              ...medicines.map((med) => AnimatedFadeIn(child: _buildMedicineCard(context, med))),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak) {
    final theme = Theme.of(context);
    String milestone = '';
    if (streak >= 30) milestone = '🏆 Monthly Master!';
    else if (streak >= 7) milestone = '🌟 Weekly Warrior!';
    else if (streak >= 3) milestone = '🔥 On Fire!';

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text('$streak Day Streak!', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange[800])),
              ],
            ),
          ),
          if (milestone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(milestone, style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange[900], fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildFocusNextDose(BuildContext context, Medicine medicine) {
    final theme = Theme.of(context);
    final time = medicine.times.first;
    return CustomCard(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notifications_active, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UPCOMING DOSE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      Text(medicine.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${time.format(context)} • ${medicine.dosage}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Provider.of<MedicineProvider>(context, listen: false).logMedicine(medicine),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('LOG DOSE NOW'),
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
            Text('Adherence Trend', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdherenceChart(logs: logs),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionChecker(BuildContext context, List<Medicine> medicines, bool isPremium) {
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
                  Text('AI Safety Check', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Check for drug interactions between your meds', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
        content: Text('$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('$count', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, Medicine medicine) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MedicineDetailScreen(medicine: medicine))),
      child: ListTile(
        leading: _buildPillIcon(medicine),
        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${medicine.dosage} • ${medicine.frequency}'),
        trailing: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }

  Widget _buildPillIcon(Medicine medicine) {
    IconData icon;
    switch (medicine.pillShape) {
      case PillShape.capsule: icon = Icons.medication_liquid; break;
      case PillShape.liquid: icon = Icons.water_drop; break;
      case PillShape.square: icon = Icons.crop_square; break;
      default: icon = Icons.circle;
    }
    return Icon(icon, color: medicine.pillColor, size: 30);
  }
}

void _showInteractionDialog(BuildContext context, List<Medicine> medicines) async {
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
          return SingleChildScrollView(child: Text(snapshot.data ?? 'Error analyzing meds.'));
        },
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicineProvider, SubscriptionService>(
      builder: (context, provider, subscription, child) {
        final history = provider.medicineLogs;
        
        final filteredHistory = subscription.isPremium 
          ? history 
          : history.where((log) => 
              log.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
            ).toList();

        if (filteredHistory.isEmpty) return const Center(child: Text('No history yet.'));
        
        return Column(
          children: [
            if (!subscription.isPremium)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomCard(
                  color: Colors.blue.shade50,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen())),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.lock_clock_outlined, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('Free tier shows last 7 days. Upgrade to see full history.', style: TextStyle(fontSize: 12))),
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
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(log.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(log.timestamp)),
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
