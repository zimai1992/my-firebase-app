import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/widgets/textured_background.dart';
import 'package:myapp/widgets/custom_card.dart';
import 'package:myapp/widgets/animated_fade_in.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:myapp/screens/paywall_screen.dart';
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
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  
  Map<String, dynamic>? _frequency;
  String _specialInstructions = '';
  bool _isVerified = false;
  ScheduleType _scheduleType = ScheduleType.evenlySpaced;
  List<TimeOfDay> _selectedTimes = [];
  PillShape _selectedShape = PillShape.round;
  Color _selectedColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _dosageController = TextEditingController(text: widget.initialDosage);
    _stockController = TextEditingController(text: '0');
    _thresholdController = TextEditingController(text: '10');
    
    if (widget.initialFrequency != null) {
      _parseInitialFrequency(widget.initialFrequency!);
    }
  }

  void _parseInitialFrequency(String freqString) {
    final parts = freqString.split(' ');
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
              count, (index) => TimeOfDay(hour: 8 + (index * (24 ~/ count)) % 24, minute: 0));
        }
      } catch (e) {
        dev.log('Error parsing frequency: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _selectFrequency() async {
    final selectedFrequency = await showFrequencyPicker(context);
    if (selectedFrequency != null) {
      setState(() {
        _frequency = selectedFrequency;
        final count = _frequency!['count'] as int;
        if (_frequency!['interval'] == 'Daily' && count > 1) {
          _selectedTimes = _calculateEvenlySpacedTimes(count);
        } else {
          _selectedTimes = List<TimeOfDay>.from(_frequency!['times'] ?? []);
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
    final theme = Theme.of(context);
    final isPremium = Provider.of<SubscriptionService>(context).isPremium;
    
    String frequencyText = _frequency != null 
        ? '${_frequency!['count']} x ${_frequency!['interval']}' 
        : localizations.select_frequency;

    List<TimeOfDay> displayTimes = [];
    if (_frequency != null) {
      if (_frequency!['interval'] == 'Daily' && (_frequency!['count'] as int) > 1) {
        displayTimes = _scheduleType == ScheduleType.evenlySpaced 
            ? _calculateEvenlySpacedTimes(_frequency!['count'] as int) 
            : _selectedTimes;
      } else {
        displayTimes = List<TimeOfDay>.from(_frequency!['times'] ?? []);
      }
    }

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(localizations.add_medicine, style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              _buildAIScanBanner(context, isPremium),
              const SizedBox(height: 24),
              
              _buildSectionHeader(context, 'Basic Information', Icons.info_outline),
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.medicine_name,
                        prefixIcon: const Icon(Icons.medication),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? localizations.please_enter_name : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: localizations.medicine_dosage,
                        prefixIcon: const Icon(Icons.scale),
                        hintText: 'e.g. 500mg or 1 Tablet',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? localizations.please_enter_dosage : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Pill Appearance', Icons.palette_outlined),
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: PillShape.values.map((shape) => InkWell(
                        onTap: () => setState(() => _selectedShape = shape),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedShape == shape ? theme.colorScheme.primary.withAlpha(25) : null,
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedShape == shape ? Border.all(color: theme.colorScheme.primary) : null,
                          ),
                          child: Icon(_getPillIcon(shape), color: _selectedShape == shape ? theme.colorScheme.primary : Colors.grey),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [Colors.teal, Colors.blue, Colors.orange, Colors.red, Colors.purple, Colors.pink, Colors.green]
                          .map((color) => InkWell(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
                              ),
                            ),
                          )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Schedule & Frequency', Icons.calendar_today_outlined),
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localizations.medicine_frequency),
                      subtitle: Text(frequencyText, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectFrequency,
                    ),
                    if (_frequency != null && _frequency!['interval'] == 'Daily' && _frequency!['count'] > 1) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(localizations.schedule_timings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 12),
                      SegmentedButton<ScheduleType>(
                        segments: [
                          ButtonSegment(value: ScheduleType.evenlySpaced, label: Text(localizations.evenly_spaced, style: const TextStyle(fontSize: 12))),
                          ButtonSegment(value: ScheduleType.pickTimes, label: Text(localizations.pick_times, style: const TextStyle(fontSize: 12))),
                        ],
                        selected: {_scheduleType},
                        onSelectionChanged: (s) => setState(() => _scheduleType = s.first),
                      ),
                      const SizedBox(height: 16),
                      if (_scheduleType == ScheduleType.evenlySpaced)
                        _buildTimeSummary(displayTimes)
                      else
                        _buildTimePickerList(displayTimes),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Stock Management', Icons.inventory_2_outlined),
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Current Stock', suffixText: 'pills'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Low Alert at', suffixText: 'pills'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Additional Details', Icons.note_add_outlined),
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: localizations.special_instructions,
                    hintText: 'Take after food, avoid alcohol, etc.',
                  ),
                  onSaved: (v) => _specialInstructions = v ?? '',
                ),
              ),
              const SizedBox(height: 32),

              _buildVerificationCard(localizations, theme),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isVerified ? _saveMedicine : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(localizations.add_medicine, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPillIcon(PillShape shape) {
    switch (shape) {
      case PillShape.capsule: return Icons.medication_liquid;
      case PillShape.liquid: return Icons.water_drop;
      case PillShape.square: return Icons.crop_square;
      default: return Icons.circle;
    }
  }

  Widget _buildAIScanBanner(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    return AnimatedFadeIn(
      child: InkWell(
        onTap: () {
          if (!isPremium) {
            _showPremiumRequired('AI Smart Scan');
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const CameraScannerScreen()));
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: theme.colorScheme.primary.withAlpha(76), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Smart Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Scan your prescription to autofill details.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (!isPremium) 
                const Icon(Icons.lock_outline, color: Colors.white)
              else
                const Icon(Icons.camera_alt, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumRequired(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text('$feature is only available to premium subscribers. Upgrade to get full access to AI health insights, voice commands, and reports.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTimeSummary(List<TimeOfDay> times) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Wrap(
        spacing: 8,
        children: times.map((t) => Chip(
          label: Text(t.format(context), style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.grey),
        )).toList(),
      ),
    );
  }

  Widget _buildTimePickerList(List<TimeOfDay> times) {
    return Column(
      children: List.generate(times.length, (i) => ListTile(
        title: Text('Time ${i + 1}'),
        trailing: Text(times[i].format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () async {
          final time = await showTimePicker(context: context, initialTime: times[i]);
          if (time != null) setState(() => _selectedTimes[i] = time);
        },
      )),
    );
  }

  Widget _buildVerificationCard(AppLocalizations localizations, ThemeData theme) {
    return CustomCard(
      color: _isVerified ? Colors.green.withAlpha(13) : Colors.red.withAlpha(13),
      border: Border.all(color: _isVerified ? Colors.green.withAlpha(76) : Colors.red.withAlpha(76)),
      child: CheckboxListTile(
        title: Text(localizations.verification_prompt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        value: _isVerified,
        onChanged: (v) => setState(() => _isVerified = v!),
        activeColor: Colors.green,
      ),
    );
  }

  void _saveMedicine() {
    if (_frequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select frequency')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final medicine = Medicine(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: '${_frequency!['count']} x ${_frequency!['interval']}',
        times: _scheduleType == ScheduleType.evenlySpaced ? _calculateEvenlySpacedTimes(_frequency!['count'] as int) : _selectedTimes,
        specialInstructions: _specialInstructions,
        currentStock: int.tryParse(_stockController.text) ?? 0,
        lowStockThreshold: int.tryParse(_thresholdController.text) ?? 10,
        pillShape: _selectedShape,
        pillColor: _selectedColor,
      );
      Provider.of<MedicineProvider>(context, listen: false).addMedicine(medicine);
      Navigator.pop(context);
    }
  }
}
