import 'package:cloud_firestore/cloud_firestore.dart';

class Nurse {
  final String id;
  final DateTime? birthDate;
  final String? nationalID;
  final String? fullLastName;
  final String? fullName;
  final String? gender;
  final String? phone;
  final String? role;

  Nurse({
    required this.id,
    this.birthDate,
    this.nationalID,
    this.fullLastName,
    this.fullName,
    this.gender,
    this.phone,
    this.role,
  });

  factory Nurse.fromFirestoreSnapshot(QueryDocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      throw ArgumentError.value(
          snapshot, 'snapshot', 'The given snapshot must exist');
    }

    if (snapshot.id.isEmpty) {
      throw ArgumentError.value(
        snapshot,
        'snapshot',
        'The given snapshot must contain the key "id"',
      );
    }

    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;

    Timestamp birthDate = map['birth_date'];

    return Nurse(
      id: snapshot.id,
      birthDate: birthDate.toDate(),
      nationalID: map['national_id'],
      fullLastName: map['full_last_name'],
      fullName: map['full_name'],
      gender: map['gender'],
      phone: map['phone'],
      role: map['role'],
    );
  }

  String get name {
    String nurseName = '$fullName $fullLastName';
    if (nurseName.trim().isEmpty) {
      return "No nurse name";
    }

    return nurseName;
  }
}
