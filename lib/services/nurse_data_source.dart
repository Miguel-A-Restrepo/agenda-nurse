import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nurse.dart';
import '../models/shift.dart';

class NurseDataSource {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _allNursesStream =
      FirebaseFirestore.instance.collection('nurses').snapshots();

  Future<List<Nurse>> getAllNurses() async {
    QuerySnapshot allNursesQuerySnapshot = await _allNursesStream.first;
    List<Nurse> allNurses = [];
    for (var nurseDoc in allNursesQuerySnapshot.docs) {
      try {
        allNurses.add(Nurse.fromFirestoreSnapshot(nurseDoc));
      } catch (e) {
        print("Error loading nurse: ${nurseDoc.id} - ${nurseDoc.data()} - $e");
      }
    }
    return allNurses;
  }

  List<Nurse> getNursesWithLessThan44Hours(
      List<Nurse> allNurses, List<Shift> weekShifts) {
    List<Nurse> nursesWithLessThan44Hours = [];
    for (var nurse in allNurses) {
      int nurseHours = calculateShiftHours(nurse.id, weekShifts);
      if (nurseHours < 44) {
        nursesWithLessThan44Hours.add(nurse);
      }
    }
    return nursesWithLessThan44Hours;
  }

  int calculateShiftHours(String nurseId, List<Shift> weekShifts) {
    int nurseHours = 0;
    for (var shift in weekShifts) {
      if (shift.nurseID == nurseId) {
        nurseHours += shift.duration.inHours;
      }
    }
    return nurseHours;
  }
}
