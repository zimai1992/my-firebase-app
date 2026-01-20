enum HealthLogType { bloodPressure, bloodGlucose, inr, weight, other }

class HealthLog {
  final String id;
  final HealthLogType type;
  final double value1; // Systolic or Glucose or INR
  final double? value2; // Diastolic (for BP)
  final DateTime timestamp;
  final String? note;

  HealthLog({
    required this.id,
    required this.type,
    required this.value1,
    this.value2,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'value1': value1,
      'value2': value2,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory HealthLog.fromMap(Map<String, dynamic> map) {
    return HealthLog(
      id: map['id'],
      type: HealthLogType.values[map['type']],
      value1: map['value1'],
      value2: map['value2'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }
}
