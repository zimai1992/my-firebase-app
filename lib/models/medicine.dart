import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final List<TimeOfDay> times;
  final String specialInstructions;
  int currentStock;
  int lowStockThreshold;
  final String? recommendationNote;
  final String? lifestyleWarnings;

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.times = const [],
    this.specialInstructions = '',
    this.currentStock = 0,
    this.lowStockThreshold = 10,
    this.recommendationNote,
    this.lifestyleWarnings,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times.map((time) => '${time.hour}:${time.minute}').toList(),
      'specialInstructions': specialInstructions,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'recommendationNote': recommendationNote,
      'lifestyleWarnings': lifestyleWarnings,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
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
    );
  }
}
