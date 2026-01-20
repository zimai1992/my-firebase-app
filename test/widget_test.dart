import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/main.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function(MethodCall call);

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await Firebase.initializeApp();
  });

  testWidgets('App flow test: Onboarding to Login',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hasSeenTour': false});
    final prefs = await SharedPreferences.getInstance();

    final user = MockUser(
      isAnonymous: false,
      uid: 'test_uid',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    final auth = MockFirebaseAuth(signedIn: true, mockUser: user);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => MedicineProvider(prefs, auth.currentUser)),
          ChangeNotifierProvider(create: (context) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: const MyApp(hasSeenTour: false),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify we are on the Welcome screen
    expect(find.text('Your Personal Health Assistant'), findsOneWidget);

    // 2. Swipe through onboarding
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Setup Your First Medicine'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Involve a Caregiver'), findsOneWidget);

    // 3. Tap Done/Skip to reach Home (since we mocked signedIn: true)
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    // Check for Home screen indicators
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_core');

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeApp') {
      return {
        'name': '[DEFAULT]',
        'options': {
          'apiKey': '123',
          'appId': '123',
          'messagingSenderId': '123',
          'projectId': '123',
        },
      };
    }
    return null;
  });
}
