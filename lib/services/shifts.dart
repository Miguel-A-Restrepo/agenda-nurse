import 'package:agendanurse/models/shift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateShift(Shift shift) async {
  try {
    shift.validate();
  } catch (e) {
    throw ArgumentError.value(shift, 'shift', e.toString());
  }

  CollectionReference shifts = FirebaseFirestore.instance.collection('shifts');

  return shifts.doc(shift.id).update(shift.toFirestoreMap());
}

Future<DocumentReference> createShift(Shift shift) async {
  try {
    shift.validate();
  } catch (e) {
    throw ArgumentError.value(shift, 'shift', e.toString());
  }

  CollectionReference shifts = FirebaseFirestore.instance.collection('shifts');

  return shifts.add(shift.toFirestoreMap());
}

Future<void> deleteShift(String shiftID) async {
  CollectionReference shifts = FirebaseFirestore.instance.collection('shifts');

  return shifts.doc(shiftID).delete();
}
