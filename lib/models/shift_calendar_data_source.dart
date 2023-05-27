import 'package:agendanurse/models/nurse.dart';
import 'package:agendanurse/models/shift.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ShiftDataSource extends CalendarDataSource<Shift> {
  final Nurse _nurse;

  ShiftDataSource(List<Shift> source, this._nurse) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getShiftData(index).startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return _getShiftData(index).finishDate;
  }

  @override
  String getSubject(int index) {
    Shift shift = _getShiftData(index);
    return shift.subject(_nurse.name);
  }

  @override
  Color getColor(int index) {
    Shift shift = _getShiftData(index);

    if (shift.type == ShiftType.BUSY) {
      return Colors.red;
    }

    return Colors.blue;
  }

  @override
  Shift convertAppointmentToObject(Shift customData, Appointment appointment) {
    return Shift(
      id: customData.id,
      startDate: appointment.startTime,
      finishDate: appointment.endTime,
      nurseID: customData.nurseID,
    );
  }

  Shift _getShiftData(int index) {
    final dynamic shift = appointments![index];
    late final Shift shiftData;
    if (shift is Shift) {
      shiftData = shift;
    }

    return shiftData;
  }
}
