import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/widgets/adherence_chart.dart';
import 'package:myapp/services/gemini_service.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import './add_medicine_screen.dart';
import './medicine_detail_screen.dart';
import './settings_screen.dart';
import './caregiver/caregiver_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    final List<String> appBarTitles = <String>[
      localizations.home,
      localizations.history,
      'Caregiver Hub',
      localizations.settings,
    ];

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            appBarTitles[_selectedIndex],
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_selectedIndex == 0) ...[
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _onItemTapped(3),
                tooltip: 'Settings',
              ),
            ],
            IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMedicineScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Add Med'),
              )
            : null,
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final medicines = provider.medicines;
        final logs = provider.medicineLogs;
        final upcoming = provider.getUpcomingMedicines();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            _buildChartSection(context, logs),
            const SizedBox(height: 20),
            _buildInteractionChecker(context, medicines),
            const SizedBox(height: 20),
            if (upcoming.isNotEmpty) ...[
              _buildSectionTitle(context, 'Next Doses', upcoming.length),
              ...upcoming.take(3).map((med) => AnimatedFadeIn(child: _buildMedicineCard(context, med, isUpcoming: true))),
              const SizedBox(height: 20),
            ],
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

  Widget _buildInteractionChecker(BuildContext context, List<Medicine> medicines) {
    final theme = Theme.of(context);
    return CustomCard(
      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
      onTap: () => _showInteractionDialog(context, medicines),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.security, color: Colors.teal),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Safety Check', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Check for drug interactions between your meds', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showInteractionDialog(BuildContext context, List<Medicine> medicines) async {
    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add some medicines first.')));
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

  Widget _buildMedicineCard(BuildContext context, Medicine medicine, {bool isUpcoming = false}) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MedicineDetailScreen(medicine: medicine))),
      child: ListTile(
        leading: Icon(Icons.medication, color: theme.colorScheme.primary),
        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${medicine.dosage} • ${medicine.frequency}'),
        trailing: isUpcoming ? const Icon(Icons.access_time, color: Colors.orange, size: 16) : null,
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final history = provider.medicineLogs;
        if (history.isEmpty) return const Center(child: Text('No history yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final log = history[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(log.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(log.timestamp)),
              ),
            );
          },
        );
      },
    );
  }
}
