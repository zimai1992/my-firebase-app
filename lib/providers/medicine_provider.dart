import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../services/notification_service.dart';
import '../models/medicine_log.dart';
import '../models/health_log.dart';
import '../services/notification_service.dart';
import '../database/local_database.dart';
import '../services/gemini_service.dart';
import 'dart:developer' as developer;

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<MedicineLog> _medicineLogs = [];
  List<HealthLog> _healthLogs = [];
  List<String> _caregivers = [];
  List<String> _interactionWarnings = [];
  Map<String, String>?
      _timingSuggestion; // { 'medicineId', 'medicineName', 'oldTime', 'newTime', 'diff' }
  bool _isLoading = true;

  final SharedPreferences _prefs;
  final User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final LocalDatabase _localDB = LocalDatabase.instance;
  final GeminiService _geminiService = GeminiService();

  Timer? _missedDoseTimer;

  MedicineProvider(this._prefs, this._user) {
    _init();
    _missedDoseTimer = Timer.periodic(const Duration(minutes: 1), (_) => checkMissedDoses());
  }

  @override
  void dispose() {
    _missedDoseTimer?.cancel();
    super.dispose();
  }

  bool get isLoading => _isLoading;
  List<Medicine> get medicines => _medicines;
  List<MedicineLog> get medicineLogs => _medicineLogs;
  List<String> get caregivers => _caregivers;
  List<String> get interactionWarnings => _interactionWarnings;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await _loadFromLocalDB();

    if (_user != null) {
      await loadMedicines();
      await loadMedicineLogs();
      await loadCaregivers();
    } else {
      await _loadMedicinesFromPrefs();
      await _loadMedicineLogsFromPrefs();
      await _loadCaregiversFromPrefs();
    }

    _isLoading = false;
    notifyListeners();

    // Initial check
    if (_medicines.isNotEmpty) _runInteractionCheck();
  }

  Future<void> _loadFromLocalDB() async {
    _medicines = await _localDB.getMedicines();
    _medicineLogs = await _localDB.getLogs();
    _healthLogs = await _localDB.getHealthLogs();
  }

  List<Map<String, dynamic>> getPendingActions() {
    final now = DateTime.now();
    final nowTime = TimeOfDay.fromDateTime(now);
    final List<Map<String, dynamic>> pending = [];

    for (var med in _medicines) {
      if (med.isStopped) continue;

      for (var time in med.times) {
        // Check if this specific dose was handled (Taken or Missed) today
        bool handled = _medicineLogs.any((l) =>
            l.medicineId == med.id &&
            l.timestamp.year == now.year &&
            l.timestamp.month == now.month &&
            l.timestamp.day == now.day &&
            l.scheduledTime?.hour == time.hour &&
            l.scheduledTime?.minute == time.minute);

        if (handled) continue;

        // Calculate delay in hours
        final scheduledDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        final isPast = now.isAfter(scheduledDateTime);
        
        if (isPast) {
          final delayHours = now.difference(scheduledDateTime).inHours;
          final bool isOD = med.frequency.toUpperCase().contains('OD') || med.times.length == 1;
          final int safeWindow = isOD ? 8 : 2;

          if (delayHours >= safeWindow) {
            // This dose should be handled by checkMissedDoses()
            // We skip it from the "Pending/Loggable" list
            continue;
          }

          pending.add({
            'medicine': med,
            'time': time,
            'isMissed': true,
          });
        } else {
          pending.add({
            'medicine': med,
            'time': time,
            'isMissed': false,
          });
        }
      }
    }

    // Sort: Missed doses first, then upcoming by time
    pending.sort((a, b) {
      if (a['isMissed'] != b['isMissed']) {
        return a['isMissed'] ? -1 : 1;
      }
      final TimeOfDay tA = a['time'];
      final TimeOfDay tB = b['time'];
      if (tA.hour != tB.hour) return tA.hour.compareTo(tB.hour);
      return tA.minute.compareTo(tB.minute);
    });

    return pending;
  }

  List<Medicine> getUpcomingMedicines() {
    return getPendingActions()
        .map((p) => p['medicine'] as Medicine)
        .toList();
  }

  Map<String, int> getDailyProgress() {
    int total = 0;
    int takenCount = 0;
    final now = DateTime.now();

    for (var med in _medicines) {
      if (med.isStopped) continue;
      
      for (var time in med.times) {
        total++;
        
        // Check if THIS specific slot was fulfilled today (isMissed: false)
        bool isFulfilled = _medicineLogs.any((l) =>
            l.medicineId == med.id &&
            !l.isMissed &&
            l.timestamp.year == now.year &&
            l.timestamp.month == now.month &&
            l.timestamp.day == now.day &&
            l.scheduledTime?.hour == time.hour &&
            l.scheduledTime?.minute == time.minute);
            
        if (isFulfilled) {
          takenCount++;
        }
      }
    }
    return {'total': total, 'taken': takenCount};
  }

  int getAdherenceStreak() {
    if (_medicineLogs.isEmpty) return 0;
    int streak = 0;
    DateTime date = DateTime.now();

    // Normalize to date only for comparison
    DateTime currentDate = DateTime(date.year, date.month, date.day);

    while (true) {
      final logsOnDate = _medicineLogs.where((log) =>
          log.timestamp.year == currentDate.year &&
          log.timestamp.month == currentDate.month &&
          log.timestamp.day == currentDate.day);

      // Only count a day as part of the streak if there are TAKEN doses and NO MISSED doses
      final hasTaken = logsOnDate.any((log) => !log.isMissed);
      final hasMissed = logsOnDate.any((log) => log.isMissed);

      if (hasTaken && !hasMissed) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }


  int _debugXP = 0;
  
  int get totalXP {
    try {
      final logsXP = _medicineLogs.where((l) => !l.isMissed).length * 10;
      return logsXP + _debugXP;
    } catch (_) {
      return 0;
    }
  }
  
  void debugAddXP(int amount) {
    _debugXP += amount;
    notifyListeners();
  }
  
  int get currentLevel => (totalXP ~/ 100) + 1;
  
  double get levelProgress {
    final xp = totalXP;
    return (xp % 100) / 100.0;
  }

  String get prestigeTier {
    final lvl = currentLevel;
    if (lvl >= 50) return 'Adherence Immortal';
    if (lvl >= 30) return 'Diamond Sentinel';
    if (lvl >= 15) return 'Adherence Hero';
    if (lvl >= 5) return 'Adherence Guardian';
    return 'Seedling';
  }

  bool get isImmortal => currentLevel >= 50;

  Future<void> sendSOS() async {
    if (_user == null) return;
    try {
      await _firestore.collection('alerts').add({
        'type': 'SOS',
        'patientId': _user.uid,
        'patientName': _user.displayName ?? _user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    } catch (e) {
      developer.log('Error sending SOS', error: e);
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    _medicines.add(medicine);
    await _localDB.saveMedicine(medicine);
    await _saveMedicines();
    notifyListeners();
    _runInteractionCheck();
  }

  Future<void> _runInteractionCheck() async {
    if (_medicines.length < 2) {
      _interactionWarnings = [];
      notifyListeners();
      return;
    }

    try {
      final result = await _geminiService.checkInteractions(_medicines);

      if (!result.toLowerCase().contains('no major interactions') &&
          !result.toLowerCase().contains('no critical interactions') &&
          !result.contains('Error')) {
        _interactionWarnings = [result];
      } else {
        _interactionWarnings = [];
      }
    } catch (e) {
      developer.log('Auto Check Error', error: e);
    }
    notifyListeners();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    _medicines.removeWhere((m) => m.id == medicine.id);
    await _localDB.deleteMedicine(medicine.id);
    if (_user != null) {
      await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('medicines')
          .doc(medicine.id)
          .delete();
    }
    await _saveMedicines();
    notifyListeners();
  }

  Future<void> decreaseStock(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      if (_medicines[index].currentStock > 0) {
        _medicines[index].currentStock--;
        await _localDB.saveMedicine(_medicines[index]);
        if (_medicines[index].currentStock <=
            _medicines[index].lowStockThreshold) {
          _notificationService.scheduleRefillNotification(medicine);
        }
        await _saveMedicines();
        notifyListeners();
      }
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
      await _localDB.saveMedicine(medicine);
      await _saveMedicines();
      notifyListeners();
    }
  }

  Future<String?> checkDuplicate(String name, String? genericName) async {
    for (var m in _medicines) {
      if (m.isStopped) continue;

      // Check Brand Name
      if (m.name.toLowerCase() == name.toLowerCase()) {
        return 'Brand name "${m.name}" already exists.';
      }

      // Check Generic Name
      if (genericName != null &&
          genericName.isNotEmpty &&
          m.genericName != null &&
          m.genericName!.isNotEmpty) {
        if (m.genericName!.toLowerCase() == genericName.toLowerCase()) {
          return 'Generic name "${m.genericName}" already exists (in ${m.name}).';
        }
      }
    }
    return null; // No duplicate
  }

  Future<void> toggleMedicineStatus(Medicine medicine) async {
    final updatedMedicine = Medicine(
        id: medicine.id,
        name: medicine.name,
        dosage: medicine.dosage,
        frequency: medicine.frequency,
        times: medicine.times,
        specialInstructions: medicine.specialInstructions,
        currentStock: medicine.currentStock,
        lowStockThreshold: medicine.lowStockThreshold,
        recommendationNote: medicine.recommendationNote,
        lifestyleWarnings: medicine.lifestyleWarnings,
        pillShape: medicine.pillShape,
        pillColor: medicine.pillColor,
        isStopped: !medicine.isStopped);
    await updateMedicine(updatedMedicine);
  }

  Future<void> updateMedicineWithAlerts(
      BuildContext context, Medicine oldMed, Medicine newMed) async {
    await updateMedicine(newMed);

    // Check for Stop/Resume
    if (oldMed.isStopped != newMed.isStopped) {
      if (newMed.isStopped) {
        _showAlert(context, 'Medicine Stopped',
            'You have stopped taking ${newMed.name}. You will no longer receive reminders for this medication.\n\nPlease consult your doctor if this was not intended.');
      } else {
        _showAlert(context, 'Medicine Resumed',
            'You have resumed ${newMed.name}. Reminders have been reactivated.');
      }
    }

    // Check for Dosage Change
    if (oldMed.dosage != newMed.dosage) {
      _showAlert(context, 'Dosage Changed',
          'The dosage for ${newMed.name} has been updated from "${oldMed.dosage}" to "${newMed.dosage}".\n\nPlease ensure you follow the new dosage instructions carefully.');
    }
  }

  void _showAlert(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> logMedicine(Medicine medicine,
      {TimeOfDay? scheduledTime}) async {
    final log = MedicineLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineId: medicine.id,
      medicineName: medicine.name,
      timestamp: DateTime.now(),
      scheduledTime: scheduledTime,
    );
    _medicineLogs.insert(0, log);
    await _localDB.saveLog(log);
    await decreaseStock(medicine);
    await _saveMedicineLogs();

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }

    // Trigger timing pattern analysis
    if (scheduledTime != null) {
      _analyzeTimingPatterns(medicine);
    }

    notifyListeners();
  }

  Future<void> checkMissedDoses() async {
    final now = DateTime.now();
    bool changed = false;

    for (var med in _medicines) {
      if (med.isStopped) continue;
      for (var time in med.times) {
        final scheduledDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        if (now.isBefore(scheduledDateTime)) continue;

        // Check if already handled
        bool handled = _medicineLogs.any((l) =>
            l.medicineId == med.id &&
            l.timestamp.year == now.year &&
            l.timestamp.month == now.month &&
            l.timestamp.day == now.day &&
            l.scheduledTime?.hour == time.hour &&
            l.scheduledTime?.minute == time.minute);

        if (handled) continue;

        final delayHours = now.difference(scheduledDateTime).inHours;
        final bool isOD = med.frequency.toUpperCase().contains('OD') || med.times.length == 1;
        final int safeWindow = isOD ? 8 : 2;

        if (delayHours >= safeWindow) {
          await _autoLogMissedDose(med, time);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> _autoLogMissedDose(Medicine medicine, TimeOfDay scheduledTime) async {
    final log = MedicineLog(
      medicineId: medicine.id,
      medicineName: medicine.name,
      timestamp: DateTime.now(),
      scheduledTime: scheduledTime,
      isMissed: true,
    );
    _medicineLogs.insert(0, log);
    await _localDB.saveLog(log);
    await _saveMedicineLogs();

    // Send critical notification
    _notificationService.showMissedDoseAlert(medicine, scheduledTime);

    developer.log('Automatically marked dose as MISSED: ${medicine.name} at ${scheduledTime.hour}:${scheduledTime.minute}');
    notifyListeners();
  }

  void _analyzeTimingPatterns(Medicine medicine) {
    final logs = _medicineLogs
        .where((l) => l.medicineId == medicine.id && l.scheduledTime != null)
        .take(5)
        .toList();

    if (logs.length < 5) return;

    int totalDiff = 0;
    bool consistent = true;
    final firstDiff = logs.first.getDelayMinutes() ?? 0;

    // Check if user is consistently off by at least 15 minutes in the same direction
    if (firstDiff.abs() < 15) return;

    for (var log in logs) {
      final diff = log.getDelayMinutes() ?? 0;
      // If any log is in the opposite direction or difference is too small, it's not consistent
      if ((diff > 0 && firstDiff < 0) ||
          (diff < 0 && firstDiff > 0) ||
          diff.abs() < 15) {
        consistent = false;
        break;
      }
      totalDiff += diff;
    }

    if (consistent) {
      final avgDiff = (totalDiff / logs.length).round();
      if (avgDiff.abs() >= 20) {
        final lastScheduled = logs.first.scheduledTime!;
        final newMinutes =
            lastScheduled.hour * 60 + lastScheduled.minute + avgDiff;
        final newHour = (newMinutes ~/ 60) % 24;
        final newMin = newMinutes % 60;

        _timingSuggestion = {
          'medicineId': medicine.id,
          'medicineName': medicine.name,
          'oldTime':
              '${lastScheduled.hour.toString().padLeft(2, '0')}:${lastScheduled.minute.toString().padLeft(2, '0')}',
          'newTime':
              '${newHour.toString().padLeft(2, '0')}:${newMin.toString().padLeft(2, '0')}',
          'diff': avgDiff.toString(),
        };
        developer.log(
            'Detected timing pattern for ${medicine.name}: $avgDiff min offset');
      }
    }
  }

  Future<void> applyTimingSuggestion() async {
    if (_timingSuggestion == null) return;

    final medId = _timingSuggestion!['medicineId'];
    final oldTimeStr = _timingSuggestion!['oldTime'];
    final newTimeStr = _timingSuggestion!['newTime'];

    final medicine = _medicines.firstWhere((m) => m.id == medId);
    final oldTimeParts = oldTimeStr!.split(':');
    final oldTime = TimeOfDay(
        hour: int.parse(oldTimeParts[0]), minute: int.parse(oldTimeParts[1]));

    final newTimeParts = newTimeStr!.split(':');
    final newTime = TimeOfDay(
        hour: int.parse(newTimeParts[0]), minute: int.parse(newTimeParts[1]));

    final newTimes = medicine.times.map((t) {
      if (t.hour == oldTime.hour && t.minute == oldTime.minute) {
        return newTime;
      }
      return t;
    }).toList();

    await updateMedicine(medicine.copyWith(times: newTimes));
    _timingSuggestion = null;
    notifyListeners();
  }

  void clearTimingSuggestion() {
    _timingSuggestion = null;
    notifyListeners();
  }

  Future<void> addHealthLog(HealthLog log) async {
    _healthLogs.insert(0, log);
    await _localDB.saveHealthLog(log);
    // Sync to firestore if needed, for now local only as requested
    notifyListeners();
  }

  List<HealthLog> get healthLogs => _healthLogs;
  Map<String, String>? get timingSuggestion => _timingSuggestion;

  // Analysis for Dr Report
  String generateDoctorReport() {
    final sb = StringBuffer();
    sb.writeln('=== PATIENT HEALTH REPORT ===');
    sb.writeln('Generated: ${DateTime.now().toString()}\n');

    sb.writeln('--- MEDICATIONS ---');
    if (_medicines.isEmpty) {
      sb.writeln('No active medications.');
    } else {
      for (var m in _medicines) {
        sb.writeln(
            '• ${m.name} (${m.dosage}) - ${m.frequency} [${m.isStopped ? "STOPPED" : "ACTIVE"}]');
      }
    }
    sb.writeln('');

    sb.writeln('--- VITALS & READINGS ---');
    if (_healthLogs.isEmpty) {
      sb.writeln('No readings recorded.');
    } else {
      for (var log in _healthLogs) {
        String val = log.value1.toString();
        if (log.type == HealthLogType.bloodPressure) {
          val = '${log.value1.toInt()}/${log.value2?.toInt() ?? 0} mmHg';
        } else if (log.type == HealthLogType.bloodGlucose) {
          val = '$val mmol/L';
        } else if (log.type == HealthLogType.inr) {
          val = 'INR: $val';
        }
        sb.writeln(
            '• ${log.type.name.toUpperCase()}: $val (${log.timestamp.toString().split('.')[0]})');
      }
    }
    sb.writeln('');

    sb.writeln('--- MISSED DOSES (Last 30 Days) ---');
    final missedLogs = _medicineLogs
        .where((l) =>
            l.isMissed &&
            l.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();

    if (missedLogs.isEmpty) {
      sb.writeln('No missed doses recorded in the last 30 days.');
    } else {
      for (var log in missedLogs) {
        final timeStr = log.scheduledTime != null 
          ? '${log.scheduledTime!.hour.toString().padLeft(2, '0')}:${log.scheduledTime!.minute.toString().padLeft(2, '0')}'
          : "Unknown time";
        sb.writeln(
            '• ${log.medicineName}: Missed dose scheduled for $timeStr on ${DateFormat.yMMMd().format(log.timestamp)}');
      }
    }

    return sb.toString();
  }

  Future<void> addCaregiver(String email) async {
    if (_user == null || _user.email == null) return;
    try {
      final invitation = {
        'patientId': _user.uid,
        'patientName': _user.displayName ?? _user.email,
        'patientEmail': _user.email,
        'caregiverEmail': email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('invitations').add(invitation);
    } catch (e) {
      developer.log('Error adding caregiver', error: e);
    }
  }

  Future<void> _saveMedicines() async {
    if (_user == null) {
      final medicinesJson = _medicines.map((m) => m.toJson()).toList();
      await _prefs.setString('medicines', json.encode(medicinesJson));
    } else {
      for (var medicine in _medicines) {
        await _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('medicines')
            .doc(medicine.id)
            .set(medicine.toJson());
      }
    }
  }

  Future<void> _saveMedicineLogs() async {
    if (_user == null) {
      final logsJson = _medicineLogs.map((log) => log.toJson()).toList();
      await _prefs.setString('medicine_logs', json.encode(logsJson));
    } else {
      await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('medicine_logs')
          .add(_medicineLogs.first.toJson());
    }
  }

  Future<void> loadMedicines() async {
    try {
      if (_user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('medicines')
            .get();
        _medicines =
            snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList();
        for (var med in _medicines) {
          await _localDB.saveMedicine(med);
        }
      }
    } catch (e) {
      developer.log('Error loading medicines from Firestore, using local data',
          error: e);
    }
    notifyListeners();
  }

  Future<void> loadMedicineLogs() async {
    try {
      if (_user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('medicine_logs')
            .orderBy('timestamp', descending: true)
            .get();
        _medicineLogs = snapshot.docs
            .map((doc) => MedicineLog.fromJson(doc.data()))
            .toList();
        for (var log in _medicineLogs) {
          await _localDB.saveLog(log);
        }
      }
    } catch (e) {
      developer.log('Error loading logs from Firestore, using local data',
          error: e);
    }
    notifyListeners();
  }

  Future<void> _loadMedicinesFromPrefs() async {
    final medicinesString = _prefs.getString('medicines');
    if (medicinesString != null) {
      final medicinesJson = json.decode(medicinesString) as List<dynamic>;
      _medicines =
          medicinesJson.map((json) => Medicine.fromJson(json)).toList();
    }
  }

  Future<void> _loadMedicineLogsFromPrefs() async {
    final logsString = _prefs.getString('medicine_logs');
    if (logsString != null) {
      final logsJson = json.decode(logsString) as List<dynamic>;
      _medicineLogs =
          logsJson.map((json) => MedicineLog.fromJson(json)).toList();
    }
  }

  Future<void> loadCaregivers() async {
    if (_user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('caregivers')
          .get();
      _caregivers =
          snapshot.docs.map((doc) => doc.data()['email'] as String).toList();
    }
  }

  Future<void> _loadCaregiversFromPrefs() async {
    _caregivers = _prefs.getStringList('caregivers') ?? [];
  }
}
