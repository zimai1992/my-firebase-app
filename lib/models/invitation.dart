import 'package:cloud_firestore/cloud_firestore.dart';

class Invitation {
  final String id;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String caregiverEmail;
  final String status;
  final Timestamp createdAt;

  Invitation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.caregiverEmail,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Invitation(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientEmail: data['patientEmail'] ?? '',
      caregiverEmail: data['caregiverEmail'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
