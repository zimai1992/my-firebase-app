import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../services/notification_service.dart';
import '../database/local_database.dart';
import 'dart:developer' as developer;

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<MedicineLog> _medicineLogs = [];
  List<String> _caregivers = [];
  bool _isLoading = true;

  final SharedPreferences _prefs;
  final User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final LocalDatabase _localDB = LocalDatabase.instance;

  MedicineProvider(this._prefs, this._user) {
    _init();
  }

  bool get isLoading => _isLoading;
  List<Medicine> get medicines => _medicines;
  List<MedicineLog> get medicineLogs => _medicineLogs;
  List<String> get caregivers => _caregivers;

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
  }

  Future<void> _loadFromLocalDB() async {
    _medicines = await _localDB.getMedicines();
    _medicineLogs = await _localDB.getLogs();
  }

  List<Medicine> getUpcomingMedicines() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    return _medicines.where((med) {
      return med.times.any((time) =>
          time.hour > now.hour ||
          (time.hour == now.hour && time.minute > now.minute));
    }).toList()..sort((a, b) {
      if (a.times.isEmpty) return 1;
      if (b.times.isEmpty) return -1;
      final aTime = a.times.first;
      final bTime = b.times.first;
      if (aTime.hour != bTime.hour) return aTime.hour.compareTo(bTime.hour);
      return aTime.minute.compareTo(bTime.minute);
    });
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
        log.timestamp.day == currentDate.day
      );
      
      if (logsOnDate.isNotEmpty) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

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
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    _medicines.removeWhere((m) => m.id == medicine.id);
    await _localDB.deleteMedicine(medicine.id);
    if (_user != null) {
      await _firestore.collection('users').doc(_user.uid).collection('medicines').doc(medicine.id).delete();
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
        if (_medicines[index].currentStock <= _medicines[index].lowStockThreshold) {
          _notificationService.scheduleRefillNotification(medicine);
        }
        await _saveMedicines();
        notifyListeners();
      }
    }
  }

  Future<void> logMedicine(Medicine medicine) async {
    final log = MedicineLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineId: medicine.id,
      medicineName: medicine.name, 
      timestamp: DateTime.now()
    );
    _medicineLogs.insert(0, log);
    await _localDB.saveLog(log);
    await decreaseStock(medicine);
    await _saveMedicineLogs();
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    
    notifyListeners();
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
        await _firestore.collection('users').doc(_user.uid).collection('medicines').doc(medicine.id).set(medicine.toJson());
      }
    }
  }

  Future<void> _saveMedicineLogs() async {
    if (_user == null) {
      final logsJson = _medicineLogs.map((log) => log.toJson()).toList();
      await _prefs.setString('medicine_logs', json.encode(logsJson));
    } else {
      await _firestore.collection('users').doc(_user.uid).collection('medicine_logs').add(_medicineLogs.first.toJson());
    }
  }

  Future<void> loadMedicines() async {
    try {
      if (_user != null) {
        final snapshot = await _firestore.collection('users').doc(_user.uid).collection('medicines').get();
        _medicines = snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList();
        for (var med in _medicines) {
          await _localDB.saveMedicine(med);
        }
      }
    } catch (e) {
      developer.log('Error loading medicines from Firestore, using local data', error: e);
    }
    notifyListeners();
  }

  Future<void> loadMedicineLogs() async {
    try {
      if (_user != null) {
        final snapshot = await _firestore.collection('users').doc(_user.uid).collection('medicine_logs').orderBy('timestamp', descending: true).get();
        _medicineLogs = snapshot.docs.map((doc) => MedicineLog.fromJson(doc.data())).toList();
        for (var log in _medicineLogs) {
          await _localDB.saveLog(log);
        }
      }
    } catch (e) {
      developer.log('Error loading logs from Firestore, using local data', error: e);
    }
    notifyListeners();
  }

  Future<void> _loadMedicinesFromPrefs() async {
    final medicinesString = _prefs.getString('medicines');
    if (medicinesString != null) {
      final medicinesJson = json.decode(medicinesString) as List<dynamic>;
      _medicines = medicinesJson.map((json) => Medicine.fromJson(json)).toList();
    }
  }

  Future<void> _loadMedicineLogsFromPrefs() async {
    final logsString = _prefs.getString('medicine_logs');
    if (logsString != null) {
      final logsJson = json.decode(logsString) as List<dynamic>;
      _medicineLogs = logsJson.map((json) => MedicineLog.fromJson(json)).toList();
    }
  }

  Future<void> loadCaregivers() async {
    if (_user != null) {
      final snapshot = await _firestore.collection('users').doc(_user.uid).collection('caregivers').get();
      _caregivers = snapshot.docs.map((doc) => doc.data()['email'] as String).toList();
    }
  }

  Future<void> _loadCaregiversFromPrefs() async {
    _caregivers = _prefs.getStringList('caregivers') ?? [];
  }
}
