import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/patient.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';

class VisitModeScreen extends StatefulWidget {
  final Patient patient;
  const VisitModeScreen({super.key, required this.patient});

  @override
  State<VisitModeScreen> createState() => _VisitModeScreenState();
}

class _VisitModeScreenState extends State<VisitModeScreen> {
  final List<String> _checklist = [
    'Verified pillbox matches app schedule',
    'Checked for expired medications',
    'Patient confirmed feeling well after doses',
    'Supplies (water, cups) are accessible',
  ];
  final Set<int> _checkedItems = {};
  final TextEditingController _notesController = TextEditingController();
  String _mood = 'Good';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Visit Checklist'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildPatientHeader(theme),
            const SizedBox(height: 24),
            const Text('Safety & Audit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...List.generate(_checklist.length, (index) => CheckboxListTile(
              title: Text(_checklist[index], style: const TextStyle(fontSize: 14)),
              value: _checkedItems.contains(index),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _checkedItems.add(index);
                  } else {
                    _checkedItems.remove(index);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            )),
            const SizedBox(height: 24),
            const Text('Patient Wellness', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Great', 'Good', 'Tired', 'Pain'].map((m) => ChoiceChip(
                    label: Text(m),
                    selected: _mood == m,
                    onSelected: (s) => setState(() => _mood = m),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Visit Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any observations for the doctor...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitVisit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text('Complete Visit Log', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(ThemeData theme) {
    return CustomCard(
      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(child: Text(widget.patient.name[0])),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Physical Wellness Check-in', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitVisit() async {
    final visitData = {
      'patientId': widget.patient.id,
      'timestamp': FieldValue.serverTimestamp(),
      'itemsVerified': _checkedItems.map((i) => _checklist[i]).toList(),
      'mood': _mood,
      'notes': _notesController.text,
      'type': 'physical_visit',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patient.id)
        .collection('visit_logs')
        .add(visitData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit log saved.')));
      Navigator.pop(context);
    }
  }
}
