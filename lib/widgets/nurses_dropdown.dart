import 'package:agendanurse/models/nurse.dart';
import 'package:agendanurse/models/shift.dart';
import 'package:agendanurse/services/nurse_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NursesDropdown extends StatefulWidget {
  final ValueChanged<Nurse?>? onChanged;
  final List<Shift> weekShifts;
  final String? preSelectedNurseID;

  const NursesDropdown(
      {Key? key,
      required this.weekShifts,
      this.preSelectedNurseID,
      this.onChanged})
      : super(key: key);

  @override
  _NursesDropdownState createState() => _NursesDropdownState();
}

class _NursesDropdownState extends State<NursesDropdown> {
  String? _selectedNurseID;
  final NurseDataSource _nurseDataSource = NurseDataSource();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Nurse>>(
      future: _nurseDataSource.getAllNurses(),
      builder: (BuildContext context, AsyncSnapshot<List<Nurse>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<Nurse> allNurses = snapshot.data!;

        List<Nurse> nursesWithLessThan44Hours = _nurseDataSource
            .getNursesWithLessThan44Hours(allNurses, widget.weekShifts);

        if (nursesWithLessThan44Hours.isEmpty) {
          return const Text('No nurses available');
        }

        _selectedNurseID ??= widget.preSelectedNurseID;

        return _buildNurseDropdownButton(nursesWithLessThan44Hours);
      },
    );
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

  List<DropdownMenuItem<String>> _buildNurseDropdownItems(List<Nurse> nurses) {
    return nurses.map<DropdownMenuItem<String>>((Nurse nurse) {
      return DropdownMenuItem<String>(
        value: nurse.id,
        key: Key(nurse.id),
        child: Text(nurse.name),
      );
    }).toList();
  }
}
