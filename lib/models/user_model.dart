import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final List<String> caregivers;
  final List<String> monitoring;

  User({
    required this.id,
    required this.email,
    required this.caregivers,
    required this.monitoring,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      caregivers: List<String>.from(data['caregivers'] ?? []),
      monitoring: List<String>.from(data['monitoring'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'caregivers': caregivers,
      'monitoring': monitoring,
    };
  }
}
