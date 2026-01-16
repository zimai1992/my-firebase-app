import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/main.dart'; // Import ThemeProvider
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
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

    final List<String> appBarTitles = <String>[
      localizations.home,
      localizations.history,
      'Caregiver',
      localizations.settings,
    ];

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(appBarTitles[_selectedIndex]),
          actions: [
            IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.auto_mode),
              onPressed: () => themeProvider.setSystemTheme(),
              tooltip: 'Set System Theme',
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: localizations.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: localizations.history,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Caregiver',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: localizations.settings,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMedicineScreen()),
                  );
                },
                child: const Icon(Icons.add),
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
        final upcomingMedicines = provider.getUpcomingMedicines();
        final morningMedicines = provider.getMorningMedicines();
        final afternoonMedicines = provider.getAfternoonMedicines();
        final eveningMedicines = provider.getEveningMedicines();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _buildSectionTitle(context, 'Upcoming', upcomingMedicines.length),
            ..._buildAnimatedList(upcomingMedicines,
                (med) => _buildMedicineCard(context, med, isUpcoming: true)),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Morning', morningMedicines.length),
            ..._buildAnimatedList(
                morningMedicines, (med) => _buildMedicineCard(context, med)),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Afternoon', afternoonMedicines.length),
            ..._buildAnimatedList(
                afternoonMedicines, (med) => _buildMedicineCard(context, med)),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Evening', eveningMedicines.length),
            ..._buildAnimatedList(
                eveningMedicines, (med) => _buildMedicineCard(context, med)),
          ],
        );
      },
    );
  }

  List<Widget> _buildAnimatedList(
      List<Medicine> medicines, Widget Function(Medicine) cardBuilder) {
    return medicines.asMap().entries.map((entry) {
      return AnimatedFadeIn(
        delay: entry.key * 100, // Staggered delay
        child: cardBuilder(entry.value),
      );
    }).toList();
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '$count items',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, Medicine medicine,
      {bool isUpcoming = false}) {
    final time = medicine.times.isNotEmpty
        ? DateFormat.jm().format(DateTime(
            2023, 1, 1, medicine.times.first.hour, medicine.times.first.minute))
        : '';
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailScreen(medicine: medicine),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(medicine.name[0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(medicine.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${medicine.dosage} - ${medicine.frequency}'),
        trailing: isUpcoming
            ? Text(time,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary))
            : null,
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
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final log = history[index];
            final formattedTime =
                DateFormat.yMMMd().add_jm().format(log.timestamp);
            return AnimatedFadeIn(
              delay: index * 100,
              child: CustomCard(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.medicineName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(formattedTime,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
