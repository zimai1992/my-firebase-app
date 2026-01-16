import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/invitation.dart';
import 'package:myapp/models/patient.dart';
import 'package:myapp/screens/caregiver/patient_details_screen.dart';
import 'dart:developer' as developer;

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  Stream<List<Invitation>>? _invitationsStream;
  Stream<List<Patient>>? _patientsStream;

  @override
  void initState() {
    super.initState();
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
                    userData['email'] ??
                    'Unknown Patient',
                email: userData['email'] ?? 'No email provided',
              ));
            }
          }
        } catch (e, s) {
          developer.log('Error fetching patient document for caregiver',
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
        });
      }
      // No need for setState, StreamBuilder will handle the UI update
    } catch (e, s) {
      developer.log('Error updating invitation',
          name: 'myapp.caregiver', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: _currentUser == null
          ? const Center(
              child: Text('Please log in to use the caregiver features.'))
          : ListView(
              children: [
                _buildSectionTitle(context, 'Pending Invitations'),
                StreamBuilder<List<Invitation>>(
                  stream: _invitationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      developer.log('Error in invitations stream',
                          error: snapshot.error);
                      return const ListTile(
                          title: Text('Error loading invitations.'));
                    }
                    final invitations = snapshot.data ?? [];
                    if (invitations.isEmpty) {
                      return const ListTile(title: Text('No new invitations.'));
                    }
                    return Column(
                      children: invitations
                          .map((inv) => InvitationTile(
                                invitation: inv,
                                onAccept: () =>
                                    _updateInvitationStatus(inv, 'accepted'),
                                onDecline: () =>
                                    _updateInvitationStatus(inv, 'declined'),
                              ))
                          .toList(),
                    );
                  },
                ),
                const Divider(),
                _buildSectionTitle(context, 'Your Patients'),
                StreamBuilder<List<Patient>>(
                  stream: _patientsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      developer.log('Error in patients stream',
                          error: snapshot.error);
                      return const ListTile(
                          title: Text('Error loading patients.'));
                    }
                    final patients = snapshot.data ?? [];
                    if (patients.isEmpty) {
                      return const ListTile(
                          title:
                              Text('You are not monitoring any patients yet.'));
                    }
                    return Column(
                      children: patients
                          .map((patient) => PatientTile(
                                patient: patient,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientDetailsScreen(patient: patient),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InvitationTile extends StatelessWidget {
  final Invitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationTile(
      {super.key,
      required this.invitation,
      required this.onAccept,
      required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(invitation.patientName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Wants to add you as a caregiver'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: onAccept,
              tooltip: 'Accept',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: onDecline,
              tooltip: 'Decline',
            ),
          ],
        ),
      ),
    );
  }
}

class PatientTile extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientTile({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(patient.email),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
