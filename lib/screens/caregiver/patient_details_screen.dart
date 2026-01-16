import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/models/medicine_log.dart';
import 'package:myapp/models/patient.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/utils/compliance_calculator.dart';
import 'package:myapp/screens/caregiver/visit_mode_screen.dart';
import 'package:intl/intl.dart';
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
  Stream<QuerySnapshot>? _visitLogsStream;

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

    _visitLogsStream = _firestore
        .collection('users')
        .doc(widget.patient.id)
        .collection('visit_logs')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  Future<void> _logMedicineForPatient(Medicine medicine) async {
    try {
      final log = MedicineLog(medicineName: medicine.name, timestamp: DateTime.now());
      await _firestore.collection('users').doc(widget.patient.id).collection('medicine_logs').add(log.toJson());

      final medicineRef = _firestore.collection('users').doc(widget.patient.id).collection('medicines').doc(medicine.name);

      await _firestore.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(medicineRef);
        if (freshSnapshot.exists) {
          final currentStock = freshSnapshot.data()?['currentStock'] ?? 0;
          if (currentStock > 0) {
            transaction.update(medicineRef, {'currentStock': currentStock - 1});
          }
        }
      });
    } catch (e, s) {
      developer.log('Error logging medicine', name: 'myapp.caregiver', error: e, stackTrace: s);
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
              title: Text(widget.patient.name),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => VisitModeScreen(patient: widget.patient))),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Start Visit'),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildComplianceOverview(theme),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Visit History', Icons.visibility_outlined),
                  _buildVisitHistory(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Current Medications', Icons.medication_outlined),
                  _buildMedicinesList(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Medication History', Icons.history_outlined),
                  _buildLogsList(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _visitLogsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No physical visits logged yet.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          );
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.emoji_people, color: Colors.orange, size: 20),
                title: Text('Visit - ${data['mood'] ?? 'Unknown mood'}'),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(timestamp), style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => _showVisitDetails(data),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showVisitDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Visit Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Mood: ${data['mood']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Notes:', style: TextStyle(color: Colors.grey)),
            Text(data['notes']?.isEmpty == true ? 'No notes provided.' : data['notes']),
            const SizedBox(height: 16),
            const Text('Verified Items:', style: TextStyle(color: Colors.grey)),
            ...(data['itemsVerified'] as List? ?? []).map((i) => Text('• $i', style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceOverview(ThemeData theme) {
    return AnimatedFadeIn(
      child: StreamBuilder<List<MedicineLog>>(
        stream: _medicineLogsStream,
        builder: (context, logSnapshot) {
          return StreamBuilder<List<Medicine>>(
            stream: _medicinesStream,
            builder: (context, medSnapshot) {
              final medicines = medSnapshot.data ?? [];
              final logs = logSnapshot.data ?? [];
              final compliance = calculateOverallCompliance(medicines, logs);
              return CustomCard(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health Score', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const Text('Based on last 7 days adherence', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getComplianceColor(compliance).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${compliance.toInt()}%', style: TextStyle(color: _getComplianceColor(compliance), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: compliance / 100,
                        backgroundColor: Colors.grey[300],
                        color: _getComplianceColor(compliance),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getComplianceColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return StreamBuilder<List<MedicineLog>>(
      stream: _medicineLogsStream,
      builder: (context, logSnapshot) {
        final logs = logSnapshot.data ?? [];
        return StreamBuilder<List<Medicine>>(
          stream: _medicinesStream,
          builder: (context, medSnapshot) {
            if (medSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final medicines = medSnapshot.data ?? [];
            if (medicines.isEmpty) {
              return const CustomCard(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No medications assigned.', style: TextStyle(color: Colors.grey))));
            }
            return Column(
              children: medicines.map((med) {
                final bool isTaken = _isMedicineTakenToday(med.name, logs);
                return AnimatedFadeIn(child: MedicineCard(medicine: med, isTaken: isTaken, onLog: () => _logMedicineForPatient(med)));
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildLogsList() {
    return StreamBuilder<List<MedicineLog>>(
      stream: _medicineLogsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) return const Text('No activity history yet.', style: TextStyle(color: Colors.grey));
        return Column(children: logs.take(5).map((log) => AnimatedFadeIn(child: LogTile(log: log))).toList());
      },
    );
  }

  bool _isMedicineTakenToday(String medicineName, List<MedicineLog> logs) {
    final today = DateUtils.dateOnly(DateTime.now());
    return logs.any((log) {
      final logDate = DateUtils.dateOnly(log.timestamp);
      return log.medicineName == medicineName && logDate.isAtSameMomentAs(today);
    });
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isTaken;
  final VoidCallback onLog;

  const MedicineCard({super.key, required this.medicine, required this.isTaken, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicine.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${medicine.dosage} • ${medicine.frequency}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (isTaken)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Row(children: [Icon(Icons.check, size: 14, color: Colors.green), SizedBox(width: 4), Text('Done', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))]),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('Next Dose', style: TextStyle(fontSize: 10, color: Colors.grey)), Text(medicine.times.isNotEmpty ? medicine.times.first.format(context) : '--:--', style: const TextStyle(fontWeight: FontWeight.w500))],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('Stock', style: TextStyle(fontSize: 10, color: Colors.grey)), Text('${medicine.currentStock} left', style: TextStyle(fontWeight: FontWeight.w500, color: medicine.currentStock < 10 ? Colors.red : null))],
                ),
                ElevatedButton(onPressed: isTaken ? null : onLog, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), minimumSize: const Size(80, 32), backgroundColor: theme.colorScheme.primary), child: const Text('Log Visit', style: TextStyle(fontSize: 12))),
              ],
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
    final theme = Theme.of(context);
    final formattedDate = MaterialLocalizations.of(context).formatMediumDate(log.timestamp);
    final formattedTime = TimeOfDay.fromDateTime(log.timestamp).format(context);
    return CustomCard(margin: const EdgeInsets.only(bottom: 8), color: Colors.white.withOpacity(0.5), child: ListTile(dense: true, leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 20), title: Text(log.medicineName, style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Text('$formattedDate • $formattedTime', style: const TextStyle(fontSize: 11))));
  }
}
