class MedicineLog {
  final String medicineName;
  final DateTime timestamp;

  MedicineLog({
    required this.medicineName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      medicineName: json['medicineName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
