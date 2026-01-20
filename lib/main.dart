import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/theme/theme.dart';
import './providers/medicine_provider.dart';
import './providers/locale_provider.dart';
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/onboarding/welcome_screen.dart';
import './services/notification_service.dart';
import './services/subscription_service.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

// Global navigator key for notification callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenTour = prefs.getBool('hasSeenTour') ?? false;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.init(
      onNotificationResponse: (NotificationResponse details) async {
        developer.log(
            'Notification action: ${details.actionId}, payload: ${details.payload}');

        // Handle action IDs
        if (details.actionId == 'mark_taken') {
          // Payload format: "medicineId|medicineName"
          if (details.payload != null) {
            final parts = details.payload!.split('|');
            if (parts.length >= 2) {
              final medicineId = parts[0];
              final medicineName = parts[1];

              // Try to access context and mark as taken
              final context = navigatorKey.currentContext;
              if (context != null) {
                try {
                  final provider =
                      Provider.of<MedicineProvider>(context, listen: false);
                  final medicine =
                      provider.medicines.firstWhere((m) => m.id == medicineId);
                  await provider.logMedicine(medicine);

                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('✓ $medicineName logged!'),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  developer.log('Error logging medicine from notification',
                      error: e);
                }
              }
            }
          }
        } else if (details.actionId == 'snooze') {
          // Reschedule notification for +10 minutes
          if (details.id != null) {
            final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
            await notificationService.flutterLocalNotificationsPlugin
                .zonedSchedule(
              details.id!,
              'Medicine Reminder (Snoozed)',
              'Time to take your medicine',
              tz.TZDateTime.from(snoozeTime, tz.local),
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'medicine_reminders',
                  'Medicine Reminders',
                  channelDescription: 'Snoozed reminders',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
      },
    );

    // Initialize Subscription Service
    final subscriptionService = SubscriptionService();
    await subscriptionService.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) =>
                  MedicineProvider(prefs, FirebaseAuth.instance.currentUser)),
          ChangeNotifierProvider(create: (context) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider.value(value: subscriptionService),
        ],
        child: MyApp(hasSeenTour: hasSeenTour),
      ),
    );
  } catch (e, stackTrace) {
    developer.log('Initialization error', error: e, stackTrace: stackTrace);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
                'Failed to initialize app. Please check your connection and try again.\n\nError: $e'),
          ),
        ),
      ),
    ));
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenTour;

  const MyApp({super.key, required this.hasSeenTour});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final medicineProvider = Provider.of<MedicineProvider>(context);
    final bool isImmortal = medicineProvider.isImmortal;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Rx Genie',
      theme: isImmortal ? lightImmortalTheme : lightTheme,
      darkTheme: isImmortal ? darkImmortalTheme : darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ms'), // Malay
        Locale('zh'), // Chinese
      ],
      home: AuthWrapper(hasSeenTour: hasSeenTour),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool hasSeenTour;
  const AuthWrapper({super.key, required this.hasSeenTour});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        if (!hasSeenTour) {
          return const WelcomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
