import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../services/notification_service.dart';
import 'dart:developer' as developer;

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<MedicineLog> _medicineLogs = [];
  List<String> _caregivers = [];

  final SharedPreferences _prefs;
  final User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  MedicineProvider(this._prefs, this._user) {
    if (_user != null) {
      loadMedicines();
      loadMedicineLogs();
      loadCaregivers();
    } else {
      _loadMedicinesFromPrefs();
      _loadMedicineLogsFromPrefs();
      _loadCaregiversFromPrefs();
    }
  }

  List<Medicine> get medicines => _medicines;
  List<MedicineLog> get medicineLogs => _medicineLogs;
  List<String> get caregivers => _caregivers;

  List<Medicine> getUpcomingMedicines() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    return _medicines.where((med) {
      return med.times.any((time) =>
          time.hour > now.hour ||
          (time.hour == now.hour && time.minute > now.minute));
    }).toList();
  }

  List<Medicine> getMorningMedicines() {
    return _medicines.where((med) {
      return med.times.any((time) => time.hour < 12);
    }).toList();
  }

  List<Medicine> getAfternoonMedicines() {
    return _medicines.where((med) {
      return med.times.any((time) => time.hour >= 12 && time.hour < 17);
    }).toList();
  }

  List<Medicine> getEveningMedicines() {
    return _medicines.where((med) {
      return med.times.any((time) => time.hour >= 17);
    }).toList();
  }

  bool isMedicineTakenToday(String medicineName) {
    final today = DateTime.now();
    return _medicineLogs.any((log) =>
        log.medicineName == medicineName &&
        log.timestamp.year == today.year &&
        log.timestamp.month == today.month &&
        log.timestamp.day == today.day);
  }

  Future<void> addMedicine(Medicine medicine) async {
    _medicines.add(medicine);
    await _saveMedicines();
    notifyListeners();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    _medicines.removeWhere((m) => m.name == medicine.name);
    if (_user != null) {
      await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('medicines')
          .doc(medicine.name)
          .delete();
    }
    await _saveMedicines();
    notifyListeners();
  }

  Future<void> decreaseStock(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.name == medicine.name);
    if (index != -1) {
      if (_medicines[index].currentStock > 0) {
        _medicines[index].currentStock--;
        if (_medicines[index].currentStock <=
            _medicines[index].lowStockThreshold) {
          _notificationService.scheduleRefillNotification(medicine);
        }
        await _saveMedicines();
        notifyListeners();
      }
    }
  }

  Future<void> refillStock(Medicine medicine, {int amount = 30}) async {
    final index = _medicines.indexWhere((m) => m.name == medicine.name);
    if (index != -1) {
      _medicines[index].currentStock += amount;
      await _saveMedicines();
      notifyListeners();
    }
  }

  Future<void> logMedicine(Medicine medicine) async {
    final log =
        MedicineLog(medicineName: medicine.name, timestamp: DateTime.now());
    _medicineLogs.add(log);
    await _saveMedicineLogs();
    notifyListeners();
  }

  Future<void> addCaregiver(String email) async {
    if (_user == null || _user.email == null) {
      developer.log('User not logged in or has no email.');
      return;
    }
    if (email == _user.email) {
      developer.log('Cannot add yourself as a caregiver.');
      return;
    }
    try {
      final existingInvitation = await _firestore
          .collection('invitations')
          .where('patientId', isEqualTo: _user.uid)
          .where('caregiverEmail', isEqualTo: email)
          .where('status', whereIn: ['pending', 'accepted'])
          .limit(1)
          .get();

      if (existingInvitation.docs.isNotEmpty) {
        developer.log('Invitation already sent to or accepted by $email.');
        return;
      }

      final invitation = {
        'patientId': _user.uid,
        'patientName': _user.displayName ?? _user.email,
        'patientEmail': _user.email,
        'caregiverEmail': email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('invitations').add(invitation);
      developer.log('Invitation sent to $email.');
    } catch (e, s) {
      developer.log('Error sending caregiver invitation',
          name: 'myapp.caregiver', error: e, stackTrace: s);
    }
  }

  Future<void> loadCaregivers() async {
    if (_user == null) {
      await _loadCaregiversFromPrefs();
    } else {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('caregivers')
          .get();
      _caregivers =
          snapshot.docs.map((doc) => doc.data()['email'] as String).toList();
    }
    notifyListeners();
  }

  Future<void> _saveMedicines() async {
    if (_user == null) {
      final medicinesJson =
          _medicines.map((medicine) => medicine.toJson()).toList();
      await _prefs.setString('medicines', json.encode(medicinesJson));
    } else {
      final batch = _firestore.batch();
      for (var medicine in _medicines) {
        final docRef = _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('medicines')
            .doc(medicine.name);
        batch.set(docRef, medicine.toJson());
      }
      await batch.commit();
    }
  }

  Future<void> _saveMedicineLogs() async {
    if (_user == null) {
      final logsJson = _medicineLogs.map((log) => log.toJson()).toList();
      await _prefs.setString('medicine_logs', json.encode(logsJson));
    } else {
      final batch = _firestore.batch();
      for (var log in _medicineLogs) {
        final docRef = _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('medicine_logs')
            .doc(); // Firestore will auto-generate an ID
        batch.set(docRef, log.toJson());
      }
      await batch.commit();
    }
  }

  Future<void> loadMedicines() async {
    if (_user == null) {
      await _loadMedicinesFromPrefs();
    } else {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('medicines')
          .get();
      _medicines =
          snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList();
      notifyListeners();
    }
  }

  Future<void> loadMedicineLogs() async {
    if (_user == null) {
      await _loadMedicineLogsFromPrefs();
    } else {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('medicine_logs')
          .orderBy('timestamp', descending: true)
          .get();
      _medicineLogs =
          snapshot.docs.map((doc) => MedicineLog.fromJson(doc.data())).toList();
      notifyListeners();
    }
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

  Future<void> _loadCaregiversFromPrefs() async {
    _caregivers = _prefs.getStringList('caregivers') ?? [];
  }
}
