import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:myapp/screens/caregiver/caregiver_dashboard_screen.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser(
      isAnonymous: false,
      uid: 'caregiver123',
      email: 'caregiver@example.com',
      displayName: 'Nurse Joy',
    );
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
      locale: const Locale('en'),
      home: CaregiverDashboardScreen(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  testWidgets('Caregiver Dashboard renders correctly with logged in user',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Title (findsWidgets because SliverAppBar.large might render it twice)
    expect(find.text('Caregiver Hub'), findsWidgets);
    
    // Verify Sections (using localized strings)
    expect(find.text('Pending Invitations'), findsOneWidget);
    expect(find.text('Your Patients'), findsOneWidget);
    
    // Verify Empty State initially
    expect(find.text('No patients linked yet.'), findsOneWidget);
  });

  testWidgets('Caregiver Dashboard displays pending invitations',
      (WidgetTester tester) async {
    // Seed Firestore with an invitation
    await fakeFirestore.collection('invitations').add({
      'caregiverEmail': 'caregiver@example.com',
      'patientId': 'patient123',
      'patientName': 'John Doe',
      'status': 'pending',
      'timestamp': DateTime.now(),
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Invitation appears
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Wants to share their health data'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('Caregiver Dashboard displays linked patients',
      (WidgetTester tester) async {
    // Seed Firestore with a patient-caregiver link
    await fakeFirestore
        .collection('users')
        .doc('patient123')
        .collection('caregivers')
        .doc('caregiver123')
        .set({
      'email': 'caregiver@example.com',
    });

    // Also need the patient user doc for the name to be fetched or fallback
    // The code fetches: doc.reference.parent.parent!.get()
    // 'caregivers' is a subcollection of 'users'. So parent.parent is the user doc.
    await fakeFirestore.collection('users').doc('patient123').set({
      'displayName': 'Jane Patient',
      'email': 'jane@example.com',
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Patient Card appears
    expect(find.text('Jane Patient'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    // Adherence label
    expect(find.text('Adherence'), findsOneWidget);
  });
}
