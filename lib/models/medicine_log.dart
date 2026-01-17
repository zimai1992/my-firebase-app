class MedicineLog {
  final String id;
  final String medicineId;
  final String medicineName;
  final DateTime timestamp;

  MedicineLog({
    String? id,
    required this.medicineId,
    required this.medicineName,
    required this.timestamp,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: json['id'],
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  factory MedicineLog.fromMap(Map<String, dynamic> map) => MedicineLog.fromJson(map);
}
