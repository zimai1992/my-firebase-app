import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/models/medicine_log.dart';
import 'package:myapp/models/patient.dart';
import 'dart:developer' as developer;

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Medicine>>? _medicinesStream;
  Stream<List<MedicineLog>>? _medicineLogsStream;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    _medicinesStream = _firestore
        .collection('users')
        .doc(widget.patient.id)
        .collection('medicines')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList());

    _medicineLogsStream = _firestore
        .collection('users')
        .doc(widget.patient.id)
        .collection('medicine_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineLog.fromJson(doc.data()))
            .toList());
  }

  Future<void> _logMedicineForPatient(Medicine medicine) async {
    try {
      final log =
          MedicineLog(medicineName: medicine.name, timestamp: DateTime.now());
      await _firestore
          .collection('users')
          .doc(widget.patient.id)
          .collection('medicine_logs')
          .add(log.toJson());

      final medicineRef = _firestore
          .collection('users')
          .doc(widget.patient.id)
          .collection('medicines')
          .doc(medicine.name);

      await _firestore.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(medicineRef);
        if (freshSnapshot.exists) {
          final currentStock = freshSnapshot.data()?['currentStock'] ?? 0;
          if (currentStock > 0) {
            transaction.update(medicineRef, {'currentStock': currentStock - 1});
          }
        }
      });
      // No need to manually refresh, StreamBuilder will handle it.
    } catch (e, s) {
      developer.log('Error logging medicine for patient',
          name: 'myapp.caregiver', error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to log medicine. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Medicines'),
          StreamBuilder<List<MedicineLog>>(
            stream: _medicineLogsStream,
            builder: (context, logSnapshot) {
              final logs = logSnapshot.data ?? [];
              return StreamBuilder<List<Medicine>>(
                stream: _medicinesStream,
                builder: (context, medSnapshot) {
                  if (medSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (medSnapshot.hasError) {
                    return const Center(
                        child: Text('Error loading medicines.'));
                  }
                  final medicines = medSnapshot.data ?? [];
                  if (medicines.isEmpty) {
                    return const Text(
                        'This patient has no medicines added yet.');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final med = medicines[index];
                      final bool isTaken =
                          _isMedicineTakenToday(med.name, logs);
                      return MedicineCard(
                          medicine: med,
                          isTaken: isTaken,
                          onLog: () => _logMedicineForPatient(med));
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Recent Logs'),
          StreamBuilder<List<MedicineLog>>(
            stream: _medicineLogsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading logs.'));
              }
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return const Text('No medication logs yet.');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return LogTile(log: log);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isMedicineTakenToday(String medicineName, List<MedicineLog> logs) {
    final today = DateUtils.dateOnly(DateTime.now());
    return logs.any((log) {
      final logDate = DateUtils.dateOnly(log.timestamp);
      return log.medicineName == medicineName &&
          logDate.isAtSameMomentAs(today);
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isTaken;
  final VoidCallback onLog;

  const MedicineCard(
      {super.key,
      required this.medicine,
      required this.isTaken,
      required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${medicine.dosage}, Stock: ${medicine.currentStock}'),
            Text(
                'Times: ${medicine.times.map((t) => t.format(context)).join(', ')}'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isTaken ? null : onLog,
                icon: Icon(isTaken ? Icons.check : Icons.medical_services),
                label: Text(isTaken ? 'Logged for Today' : 'Log as Taken'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isTaken
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogTile extends StatelessWidget {
  final MedicineLog log;

  const LogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final formattedDate =
        MaterialLocalizations.of(context).formatFullDate(log.timestamp);
    final formattedTime = TimeOfDay.fromDateTime(log.timestamp).format(context);

    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(log.medicineName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$formattedDate at $formattedTime'),
    );
  }
}
