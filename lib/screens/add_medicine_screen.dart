import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/frequency_picker.dart';
import './camera_scanner_screen.dart';

enum ScheduleType { evenlySpaced, pickTimes }

class AddMedicineScreen extends StatefulWidget {
  final String? initialName;
  final String? initialDosage;
  final String? initialFrequency;

  const AddMedicineScreen({
    super.key,
    this.initialName,
    this.initialDosage,
    this.initialFrequency,
  });

  @override
  AddMedicineScreenState createState() => AddMedicineScreenState();
}

class AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  Map<String, dynamic>? _frequency;
  String _specialInstructions = '';
  bool _isVerified = false;
  ScheduleType _scheduleType = ScheduleType.evenlySpaced;
  List<TimeOfDay> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _dosageController = TextEditingController(text: widget.initialDosage);
    if (widget.initialFrequency != null) {
      // A simple parsing logic, assuming format "X times Daily/Weekly/Monthly"
      final parts = widget.initialFrequency!.split(' ');
      if (parts.length >= 3) {
        try {
          final count = int.parse(parts[0]);
          final interval = parts[2];
          _frequency = {
            'count': count,
            'interval': interval,
            'times': <TimeOfDay>[]
          };
          if (interval == 'Daily' && count > 1) {
            _selectedTimes = List.generate(
                count, (index) => const TimeOfDay(hour: 8, minute: 0));
          }
        } catch (e) {
          log('Error parsing frequency: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _selectFrequency() async {
    final selectedFrequency = await showFrequencyPicker(context);
    if (selectedFrequency != null) {
      setState(() {
        _frequency = selectedFrequency;
        if (_frequency!['interval'] == 'Daily' &&
            (_frequency!['count'] as int) > 1) {
          _selectedTimes = List.generate((_frequency!['count'] as int),
              (index) => const TimeOfDay(hour: 8, minute: 0));
        } else {
          _selectedTimes = _frequency!['times'] as List<TimeOfDay>;
        }
      });
    }
  }

  List<TimeOfDay> _calculateEvenlySpacedTimes(int count) {
    if (count <= 0) return [];
    final interval = 24 / count;
    return List.generate(count, (i) {
      final hour = (8 + (i * interval)) % 24;
      return TimeOfDay(hour: hour.toInt(), minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    List<TimeOfDay> displayTimes = [];

    String frequencyText = localizations.select_frequency;
    if (_frequency != null) {
      final count = _frequency!['count'];
      final interval = _frequency!['interval'];
      final String localizedInterval;
      switch (interval) {
        case 'Daily':
          localizedInterval = localizations.frequency_daily;
          break;
        case 'Weekly':
          localizedInterval = localizations.frequency_weekly;
          break;
        case 'Monthly':
          localizedInterval = localizations.frequency_monthly;
          break;
        default:
          localizedInterval = interval;
      }
      frequencyText = '$count x $localizedInterval';
    }

    if (_frequency != null) {
      final bool showScheduleOptions = _frequency!['interval'] == 'Daily' &&
          (_frequency!['count'] as int) > 1;

      if (showScheduleOptions) {
        if (_scheduleType == ScheduleType.evenlySpaced) {
          displayTimes =
              _calculateEvenlySpacedTimes(_frequency!['count'] as int);
        } else {
          // pickTimes
          displayTimes = _selectedTimes;
        }
      } else {
        displayTimes = _frequency!['times'] as List<TimeOfDay>;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.add_medicine,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF009688)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CameraScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const Key('medicine_name_field'),
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: localizations.medicine_name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.please_enter_name;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('medicine_dosage_field'),
                controller: _dosageController,
                decoration:
                    InputDecoration(labelText: localizations.medicine_dosage),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.please_enter_dosage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectFrequency,
                child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: localizations.medicine_frequency),
                  child: Text(frequencyText),
                ),
              ),
              if (_frequency != null &&
                  _frequency!['interval'] == 'Daily' &&
                  _frequency!['count'] > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(localizations.schedule_timings,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    SegmentedButton<ScheduleType>(
                      segments: [
                        ButtonSegment(
                            value: ScheduleType.evenlySpaced,
                            label: Text(localizations.evenly_spaced)),
                        ButtonSegment(
                            value: ScheduleType.pickTimes,
                            label: Text(localizations.pick_times)),
                      ],
                      selected: {_scheduleType},
                      onSelectionChanged: (Set<ScheduleType> newSelection) {
                        setState(() {
                          _scheduleType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_scheduleType == ScheduleType.evenlySpaced)
                      Text(localizations.scheduled_at(displayTimes
                          .map((e) => e.format(context))
                          .join(', ')))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _frequency!['count'] as int,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(localizations.time_header(index + 1)),
                            trailing: Text(displayTimes[index].format(context)),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _selectedTimes[index],
                              );
                              if (time != null) {
                                setState(() {
                                  final newTimes =
                                      List<TimeOfDay>.from(_selectedTimes);
                                  newTimes[index] = time;
                                  _selectedTimes = newTimes;
                                });
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('special_instructions_field'),
                decoration: InputDecoration(
                    labelText: localizations.special_instructions),
                onSaved: (value) {
                  _specialInstructions = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: Text(
                  localizations.verification_prompt,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                value: _isVerified,
                onChanged: (bool? value) {
                  setState(() {
                    _isVerified = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('save_button'),
                onPressed: _isVerified
                    ? () {
                        if (_frequency == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(localizations.please_select_frequency),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final medicine = Medicine(
                            name: _nameController.text,
                            dosage: _dosageController.text,
                            frequency: frequencyText,
                            times: displayTimes,
                            specialInstructions: _specialInstructions,
                          );
                          Provider.of<MedicineProvider>(context, listen: false)
                              .addMedicine(medicine);
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(localizations.add_medicine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
