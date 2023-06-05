import 'package:agendanurse/models/nurse.dart';
import 'package:agendanurse/models/shift_calendar_data_source.dart';
import 'package:agendanurse/services/shifts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:agendanurse/models/shift.dart';

class NurseShiftCalendar extends StatefulWidget {
  final Nurse nurse;
  final List<Shift> shifts;

  const NurseShiftCalendar(
      {super.key, required this.nurse, required this.shifts});

  @override
  _NurseShiftCalendarState createState() => _NurseShiftCalendarState();
}

class _NurseShiftCalendarState extends State<NurseShiftCalendar> {
  ///1.Filtra los turnos de una enfermera considerando los grupos de turnos
  ///superpuestos, es decir, aquellos cuyos intervalos de tiempo se solapan.
  ///2.Sobre estos turnos filtra aquellos con al menos 6 personas asignadas.
  ///Esto permite mostrar en el calendario los turnos que
  ///ya se encuentran cubiertos u ocupados y de esta manera evitar
  ///que puedan ser tomados por otra enfermera.

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      List<Shift> displayShifts = widget.shifts;

      displayShifts = displayShifts.where((shift) {
        return shift.nurseID == widget.nurse.id;
      }).toList();

      List<List<Shift>> overlappingShiftGroups = [];
      for (var shift in widget.shifts) {
        bool shiftAdded = false;
        DateTime shiftStartDate = shift.startDate;
        DateTime shiftFinishDate = shift.finishDate;

        for (List<Shift> shiftGroup in overlappingShiftGroups) {
          Shift firstShiftInGroup = shiftGroup.first;
          DateTime groupStartDate = firstShiftInGroup.startDate;
          DateTime groupFinishDate = firstShiftInGroup.finishDate;

          bool shiftsOverlap = shiftStartDate.isBefore(groupFinishDate) &&
              shiftFinishDate.isAfter(groupStartDate);

          if (shiftsOverlap) {
            shiftGroup.add(shift);
            shiftAdded = true;
            break;
          }
        }

        if (!shiftAdded) {
          overlappingShiftGroups.add([shift]);
        }
      }
      List<Shift> busyShifts = [];

      for (var shiftGroup in overlappingShiftGroups) {
        if (shiftGroup.length < 6) {
          continue;
        }

        DateTime startDate = shiftGroup.first.startDate;
        DateTime finishDate = shiftGroup.first.finishDate;

        busyShifts.add(Shift(
          id: '',
          startDate: startDate,
          finishDate: finishDate,
          nurseID: widget.nurse.id,
        ));
      }

      displayShifts.addAll(busyShifts);

      return _buildCalendar(displayShifts);
    });
  }

  SfCalendar _buildCalendar(List<Shift> shifts) {
    return SfCalendar(
      view: CalendarView.week,
      dataSource: ShiftDataSource(shifts, widget.nurse),
      onTap: _tap,
      onLongPress: _longPress,
    );
  }

  void _showShiftDetails(BuildContext context, dynamic appointment) {
    final Shift shift = appointment as Shift;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.nurse.name),
          content: Text(
            'From: ${shift.startDate}\nTo: ${shift.finishDate}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditDialog(shift);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editShift(Shift newShift) async {
    Shift? joinableShift = _getJoinableShift(newShift);

    if (joinableShift != null) {
      _joinShift(newShift, joinableShift);
      return;
    }

    return updateShift(newShift);
  }

  Future<void> _addShift(Shift shift) async {
    if (_shiftOverlaps(shift)) {
      return;
    }

    try {
      Shift? joinableShift = _getJoinableShift(shift);
      if (joinableShift != null) {
        await _joinShift(shift, joinableShift);
        return;
      }

      await createShift(shift);
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Error adding shift'),
          );
        },
      );
    }
  }

  Future<void> _deleteShift(String shiftID) async {
    try {
      await deleteShift(shiftID);
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Error deleting shift'),
          );
        },
      );
    }
  }

  Future<void> _joinShift(Shift shift, Shift joinableShift) {
    if (shift.couldBeJoinedBackwards(joinableShift)) {
      return _joinShiftBackwards(shift, joinableShift);
    }

    if (shift.couldBeJoinedForwards(joinableShift)) {
      return _joinShiftForwards(shift, joinableShift);
    }

    throw Exception('Shifts could not be joined');
  }

  Future<void> _joinShiftBackwards(Shift shift, Shift joinableShift) async {
    DateTime newStartDate = joinableShift.startDate;
    DateTime newFinishDate = shift.finishDate;

    Shift newShift = Shift(
      id: joinableShift.id,
      startDate: newStartDate,
      finishDate: newFinishDate,
      nurseID: shift.nurseID,
    );

    await _editShift(newShift);
  }

  Future<void> _joinShiftForwards(Shift shift, Shift joinableShift) async {
    DateTime newStartDate = shift.startDate;
    DateTime newFinishDate = joinableShift.finishDate;

    Shift newShift = Shift(
      id: joinableShift.id,
      startDate: newStartDate,
      finishDate: newFinishDate,
      nurseID: shift.nurseID,
    );

    await _editShift(newShift);
  }

  void _showDeleteShiftDialog(Shift shift) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete this shift?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${shift.startDate}'),
              Text('To: ${shift.finishDate}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteShift(shift.id);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Shift shift) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${shift.startDate}'),
              Text('To: ${shift.finishDate}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteShiftDialog(shift);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _tap(CalendarTapDetails details) {
    if (details.targetElement != CalendarElement.appointment) {
      _addShift(Shift(
        id: '',
        startDate: details.date!,
        finishDate: details.date!.add(const Duration(hours: 1)),
        nurseID: widget.nurse.id,
      ));

      return;
    }

    dynamic appointment = details.appointments!.first;
    if (appointment is! Shift) {
      return;
    }

    _showShiftDetails(context, appointment);
  }

  void _longPress(CalendarLongPressDetails details) {
    if (details.targetElement != CalendarElement.appointment) {
      return;
    }

    dynamic appointment = details.appointments!.first;
    if (appointment is! Shift) {
      return;
    }

    DateTime newFinishDate =
        appointment.finishDate.subtract(const Duration(hours: 1));
    if (newFinishDate.isBefore(appointment.startDate)) {
      _showDeleteShiftDialog(appointment);
      return;
    }

    Shift newShift = Shift(
      id: appointment.id,
      startDate: appointment.startDate,
      finishDate: newFinishDate,
      nurseID: appointment.nurseID,
      type: appointment.type,
    );

    _editShift(newShift);
  }

  bool _shiftOverlaps(Shift shift) {
    return widget.shifts
        .where((s) => s.nurseID == shift.nurseID)
        .any((s) => shift.overlaps(s));
  }

  Shift? _getJoinableShift(Shift shift) {
    try {
      return widget.shifts.firstWhere((other) => shift.couldBeJoined(other));
    } catch (e) {
      if (e is! StateError) {
        print(e);
      }

      return null;
    }
  }
}
