import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/invitation.dart';
import 'package:myapp/models/patient.dart';
import 'package:myapp/screens/caregiver/patient_details_screen.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'dart:developer' as developer;

class CaregiverDashboardScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const CaregiverDashboardScreen({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  User? _currentUser;

  Stream<List<Invitation>>? _invitationsStream;
  Stream<List<Patient>>? _patientsStream;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    _auth = widget.auth ?? FirebaseAuth.instance;
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _initializeStreams();
    }
  }

  void _initializeStreams() {
    if (_currentUser?.email == null) return;

    _invitationsStream = _firestore
        .collection('invitations')
        .where('caregiverEmail', isEqualTo: _currentUser!.email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invitation.fromFirestore(doc)).toList());

    _patientsStream = _firestore
        .collectionGroup('caregivers')
        .where('email', isEqualTo: _currentUser!.email)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Patient> patients = [];
      for (var doc in snapshot.docs) {
        try {
          final userDoc = await doc.reference.parent.parent!.get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null) {
              patients.add(Patient(
                id: userDoc.id,
                name: userData['displayName'] ??
                    userData['email']?.split('@')[0] ??
                    'Patient',
                email: userData['email'] ?? 'No email',
              ));
            }
          }
        } catch (e, s) {
          developer.log('Error fetching patient',
              name: 'myapp.caregiver', error: e, stackTrace: s);
        }
      }
      return patients;
    });
  }

  Future<void> _updateInvitationStatus(
      Invitation invitation, String status) async {
    try {
      await _firestore
          .collection('invitations')
          .doc(invitation.id)
          .update({'status': status});

      if (status == 'accepted') {
        await _firestore
            .collection('users')
            .doc(invitation.patientId)
            .collection('caregivers')
            .doc(_currentUser!.uid)
            .set({
          'email': _currentUser!.email,
          'uid': _currentUser!.uid,
          'addedAt': FieldValue.serverTimestamp(),
          'caregiverName': _currentUser!.displayName ?? 'Caregiver',
        });
      }
    } catch (e, s) {
      developer.log('Error updating invitation',
          name: 'myapp.caregiver', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: TexturedBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(AppLocalizations.of(context)!.caregiver_hub_title),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {},
                ),
              ],
            ),
            if (_currentUser == null)
              SliverFillRemaining(
                child: Center(child: Text(AppLocalizations.of(context)!.caregiver_login_prompt)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSummaryCard(context, theme),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, AppLocalizations.of(context)!.pending_invitations,
                        Icons.person_add_outlined),
                    _buildInvitationsList(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, AppLocalizations.of(context)!.your_patients,
                        Icons.health_and_safety_outlined),
                    _buildPatientsList(),
                    const SizedBox(
                        height: 100), // Space for FAB or bottom padding
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ThemeData theme) {
    return AnimatedFadeIn(
      child: CustomCard(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.medical_services,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.caregiver_dashboard,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.caregiver_dashboard_desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withAlpha((0.8 * 255).toInt()),
                      ),
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

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList() {
    return StreamBuilder<List<Invitation>>(
      stream: _invitationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        final invitations = snapshot.data ?? [];
        if (invitations.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: invitations
              .map((inv) => AnimatedFadeIn(
                    child: InvitationCard(
                      invitation: inv,
                      onAccept: () => _updateInvitationStatus(inv, 'accepted'),
                      onDecline: () => _updateInvitationStatus(inv, 'declined'),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildPatientsList() {
    return StreamBuilder<List<Patient>>(
      stream: _patientsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        final patients = snapshot.data ?? [];
        if (patients.isEmpty) {
          return _buildEmptyState();
        }
        return Column(
          children: patients
              .map((patient) => AnimatedFadeIn(
                    child: PatientCard(
                      patient: patient,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientDetailsScreen(patient: patient),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_patients_linked,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.invite_instructions,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class InvitationCard extends StatelessWidget {
  final Invitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(Icons.person, color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invitation.patientName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.sharing_health_data,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              onPressed: onDecline,
              icon: const Icon(Icons.close, color: Colors.red),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withAlpha((0.1 * 255).toInt())),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAccept,
              icon: const Icon(Icons.check, color: Colors.green),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withAlpha((0.1 * 255).toInt())),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildComplianceIndicator(85), // TODO: Fetch real compliance
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(patient.email,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.of(context)!.adherence_label,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(AppLocalizations.of(context)!.adherence_good,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                ],
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceIndicator(double percent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 45,
          height: 45,
          child: CircularProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.grey[200],
            color: _getColor(percent),
            strokeWidth: 4,
          ),
        ),
        Text(
          '${percent.toInt()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }
}
