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
import 'dart:developer' as developer;

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
    await notificationService.init();

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
            child: Text('Failed to initialize app. Please check your connection and try again.\n\nError: $e'),
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

    return MaterialApp(
      title: 'Medicine Reminder',
      theme: lightTheme,
      darkTheme: darkTheme,
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
        if (!hasSeenTour) {
          return const WelcomeScreen();
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
