import 'package:flutter/material.dart';

enum PillShape { round, capsule, liquid, square }

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<TimeOfDay> times;
  final String specialInstructions;
  int currentStock;
  int lowStockThreshold;
  final String? recommendationNote;
  final String? lifestyleWarnings;
  final PillShape pillShape;
  final Color pillColor;

  Medicine({
    String? id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.times = const [],
    this.specialInstructions = '',
    this.currentStock = 0,
    this.lowStockThreshold = 10,
    this.recommendationNote,
    this.lifestyleWarnings,
    this.pillShape = PillShape.round,
    this.pillColor = Colors.teal,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times.map((time) => '${time.hour}:${time.minute}').toList(),
      'specialInstructions': specialInstructions,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'recommendationNote': recommendationNote,
      'lifestyleWarnings': lifestyleWarnings,
      'pillShape': pillShape.index,
      'pillColor': pillColor.toARGB32(),
    };
  }

  Map<String, dynamic> toMap() => toJson(); // Alias for database

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      times: (json['times'] as List<dynamic>? ?? []).map((timeString) {
        final parts = timeString.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      specialInstructions: json['specialInstructions'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      recommendationNote: json['recommendationNote'],
      lifestyleWarnings: json['lifestyleWarnings'],
      pillShape: PillShape.values[json['pillShape'] ?? 0],
      pillColor: Color(json['pillColor'] ?? Colors.teal.toARGB32()),
    );
  }

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine.fromJson(map);
}
