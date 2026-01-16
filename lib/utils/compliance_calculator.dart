import 'dart:math';
import 'package:myapp/models/medicine.dart';
import 'package:myapp/models/medicine_log.dart';

double calculateOverallCompliance(
    List<Medicine> medicines, List<MedicineLog> logs) {
  if (medicines.isEmpty) {
    return 0.0;
  }

  // For MVP, generate a realistic mock score
  return 70 + Random().nextDouble() * 30;
}

double calculateMedicineCompliance(Medicine medicine, List<MedicineLog> logs) {
  // For MVP, generate a realistic mock score for each medicine
  return 70 + Random().nextDouble() * 30;
}
