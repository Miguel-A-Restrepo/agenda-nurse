import 'package:agendanurse/models/nurse.dart';
import 'package:agendanurse/models/shift.dart';
import 'package:agendanurse/widgets/nurse_shift_calendar.dart';
import 'package:agendanurse/widgets/nurses_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeNurseShift extends StatefulWidget {
  const ChangeNurseShift({Key? key}) : super(key: key);

  @override
  _ChangeNurseShiftState createState() => _ChangeNurseShiftState();
}

class _ChangeNurseShiftState extends State<ChangeNurseShift> {
  Nurse? _selectedNurse;

  final Stream<QuerySnapshot> _weekShiftsStream = FirebaseFirestore.instance
      .collection('shifts')
      .where('finish_date', isGreaterThanOrEqualTo: _getWeekStart())
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _weekShiftsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        }

        QuerySnapshot currentWeekShiftsQuerySnapshot = snapshot.data!;

        List<Shift> weekShifts = [];

        for (var shiftDoc in currentWeekShiftsQuerySnapshot.docs) {
          try {
            weekShifts.add(Shift.fromFirestoreSnapshot(shiftDoc));
          } catch (e) {
            print(
                "Error loading shift: ${shiftDoc.id} - ${shiftDoc.data()} - $e");
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nurse Shift Calendar'),
            actions: _buildAppBarActions(weekShifts),
          ),
          body: Center(
            child: Builder(builder: (BuildContext context) {
              if (_selectedNurse != null) {
                return NurseShiftCalendar(
                    nurse: _selectedNurse!, shifts: weekShifts);
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Select a nurse to view their shifts'),
                    _buildNursesDropdown(weekShifts),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(List<Shift> weekShifts) {
    if (_selectedNurse != null) {
      return [
        _buildNursesDropdown(weekShifts, preselectedNurseID: _selectedNurse!.id)
      ];
    }

    return [];
  }

  NursesDropdown _buildNursesDropdown(List<Shift> weekShifts,
      {String? preselectedNurseID}) {
    return NursesDropdown(
      weekShifts: weekShifts,
      preSelectedNurseID: preselectedNurseID,
      onChanged: (Nurse? nurse) {
        setState(() {
          _selectedNurse = nurse;
        });
      },
    );
  }

  static Timestamp _getWeekStart() {
    DateTime now = DateTime.now();

    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

    return Timestamp.fromMillisecondsSinceEpoch(
        weekStart.millisecondsSinceEpoch);
  }
}
