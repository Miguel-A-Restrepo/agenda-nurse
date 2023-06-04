import 'package:agendanurse/models/nurse.dart';
import 'package:agendanurse/models/shift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NursesDropdown extends StatefulWidget {
  final ValueChanged<Nurse?>? onChanged;
  final List<Shift> weekShifts;
  final String? preSelectedNurseID;

  const NursesDropdown(
      {super.key,
      required this.weekShifts,
      this.preSelectedNurseID,
      this.onChanged});

  @override
  _NursesDropdownState createState() => _NursesDropdownState();
}

class _NursesDropdownState extends State<NursesDropdown> {
  String? _selectedNurseID;

  final Stream<QuerySnapshot<Map<String, dynamic>>> _allNursesStream =
      FirebaseFirestore.instance.collection('nurses').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _allNursesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        QuerySnapshot allNursesQuerySnapshot = snapshot.data!;

        if (allNursesQuerySnapshot.docs.isEmpty) {
          return const Text('No nurses found');
        }

        List<Nurse> allNurses = [];

        for (var nurseDoc in allNursesQuerySnapshot.docs) {
          try {
            allNurses.add(Nurse.fromFirestoreSnapshot(nurseDoc));
          } catch (e) {
            print(
                "Error loading nurse: ${nurseDoc.id} - ${nurseDoc.data()} - $e");
          }
        }

        List<Nurse> nursesWithLessThan44Hours = [];

        for (var nurse in allNurses) {
          int nurseHours = 0;
          for (var shift in widget.weekShifts) {
            if (shift.nurseID == nurse.id) {
              nurseHours += shift.duration.inHours;
            }
          }
          if (nurseHours < 44) {
            nursesWithLessThan44Hours.add(nurse);
          }
        }

        if (nursesWithLessThan44Hours.isEmpty) {
          return const Text('No nurses available');
        }

        _selectedNurseID ??= widget.preSelectedNurseID;

        return _buildNurseDropdownButton(nursesWithLessThan44Hours);
      },
    );
  }

  List<DropdownMenuItem<String>> _buildNurseDropdownItems(List<Nurse> nurses) {
    return nurses.map<DropdownMenuItem<String>>((Nurse nurse) {
      return DropdownMenuItem<String>(
        value: nurse.id,
        key: Key(nurse.id),
        child: Text(nurse.name),
      );
    }).toList();
  }

  DropdownButton _buildNurseDropdownButton(List<Nurse> nurses) {
    return DropdownButton<String>(
        value: _selectedNurseID,
        items: _buildNurseDropdownItems(nurses),
        onChanged: (value) {
          setState(() {
            _selectedNurseID = value;
          });

          if (widget.onChanged != null) {
            widget.onChanged!(nurses.firstWhere((nurse) => nurse.id == value));
          }
        });
  }
}
