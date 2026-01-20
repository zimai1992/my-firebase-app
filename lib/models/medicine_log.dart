import 'package:flutter/material.dart';

class MedicineLog {
  final String id;
  final String medicineId;
  final String medicineName;
  final DateTime timestamp;
  final TimeOfDay? scheduledTime; // NEW: When it was supposed to be taken
  final bool isMissed; // NEW: Whether this represents a skipped/missed dose

  MedicineLog({
    String? id,
    required this.medicineId,
    required this.medicineName,
    required this.timestamp,
    this.scheduledTime,
    this.isMissed = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'timestamp': timestamp.toIso8601String(),
      'scheduledTime': scheduledTime != null
          ? '${scheduledTime!.hour}:${scheduledTime!.minute}'
          : null,
      'isMissed': isMissed,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    TimeOfDay? scheduled;
    if (json['scheduledTime'] != null) {
      final parts = json['scheduledTime'].split(':');
      scheduled =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return MedicineLog(
      id: json['id'],
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'],
      timestamp: DateTime.parse(json['timestamp']),
      scheduledTime: scheduled,
      isMissed: json['isMissed'] ?? false,
    );
  }

  factory MedicineLog.fromMap(Map<String, dynamic> map) =>
      MedicineLog.fromJson(map);

  // Calculate minutes difference between scheduled and actual time
  int? getDelayMinutes() {
    if (scheduledTime == null) return null;

    final scheduled = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      scheduledTime!.hour,
      scheduledTime!.minute,
    );

    return timestamp.difference(scheduled).inMinutes;
  }
}
