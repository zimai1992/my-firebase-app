import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/l10n/app_localizations.dart';

class VerifyScreen extends StatefulWidget {
  final String extractedText;

  const VerifyScreen({super.key, required this.extractedText});

  @override
  VerifyScreenState createState() => VerifyScreenState();
}

class VerifyScreenState extends State<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger('VerifyScreen');
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _noteController;
  late TextEditingController _lifestyleWarningsController;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _frequencyController = TextEditingController();
    _noteController = TextEditingController();
    _lifestyleWarningsController = TextEditingController();
    _parseExtractedText();
  }

  void _parseExtractedText() {
    try {
      final jsonText = widget.extractedText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> parsedJson = jsonDecode(jsonText);
      setState(() {
        _nameController.text = parsedJson['name'] ?? '';
        _dosageController.text = parsedJson['dosage'] ?? '';
        _frequencyController.text = parsedJson['frequency'] ?? '';
        _noteController.text = parsedJson['recommendation_note'] ?? '';

        // Handle lifestyle warnings which could be a list or a string
        final warnings = parsedJson['lifestyle_warnings'];
        if (warnings is List) {
          _lifestyleWarningsController.text = warnings.join(', ');
        } else if (warnings is String) {
          _lifestyleWarningsController.text = warnings;
        } else {
          _lifestyleWarningsController.text = '';
        }
      });
    } catch (e, s) {
      _logger.severe('Error parsing extracted text: $e', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error parsing medication information.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _noteController.dispose();
    _lifestyleWarningsController.dispose();
    super.dispose();
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate() && _verified) {
      final newMedicine = Medicine(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
      );
      Provider.of<MedicineProvider>(context, listen: false)
          .addMedicine(newMedicine);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (!_verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.verification_prompt),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.verify_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: localizations.medicine_name),
                validator: (value) =>
                    value!.isEmpty ? localizations.please_enter_name : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration:
                    InputDecoration(labelText: localizations.medicine_dosage),
                validator: (value) =>
                    value!.isEmpty ? localizations.please_enter_dosage : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                    labelText: localizations.medicine_frequency),
              ),
              const SizedBox(height: 20),
              if (_noteController.text.isNotEmpty)
                _buildInfoCard(
                  title: localizations.pharmacist_note,
                  content: _noteController.text,
                  icon: Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.secondary.withAlpha(25),
                  borderColor: Theme.of(context).colorScheme.secondary,
                ),
              const SizedBox(height: 10),
              if (_lifestyleWarningsController.text.isNotEmpty)
                _buildInfoCard(
                  title: localizations.lifestyle_warnings,
                  content: _lifestyleWarningsController.text,
                  icon: Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error.withAlpha(25),
                  borderColor: Theme.of(context).colorScheme.error,
                ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(localizations.verification_prompt),
                value: _verified,
                onChanged: (bool value) {
                  setState(() {
                    _verified = value;
                  });
                },
                subtitle: Text(
                  !_verified ? 'Please verify to enable saving' : 'Verified',
                  style:
                      TextStyle(color: _verified ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _verified ? _saveMedicine : null,
                  child: Text(localizations.save_button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required Color borderColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: borderColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: borderColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
