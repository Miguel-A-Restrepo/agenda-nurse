import 'package:cloud_firestore/cloud_firestore.dart';

enum ShiftType {
  NURSE,
  BUSY,
}

class Shift {
  final String id;
  String? nurseID;
  DateTime startDate;
  DateTime finishDate;
  ShiftType? type;

  Shift(
      {required this.id,
      required this.startDate,
      required this.finishDate,
      required this.nurseID,
      this.type});

  factory Shift.fromFirestoreSnapshot(QueryDocumentSnapshot snapshot) {
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

    Timestamp? startDateTimestamp = map['start_date'];
    Timestamp? finishDateTimestamp = map['finish_date'];

    if (startDateTimestamp == null) {
      throw ArgumentError.value(
        snapshot,
        'snapshot',
        'The given snapshot must contain the key "start_date"',
      );
    }

    if (finishDateTimestamp == null) {
      throw ArgumentError.value(
        snapshot,
        'snapshot',
        'The given snapshot must contain the key "finish_date"',
      );
    }

    DateTime startDate = startDateTimestamp.toDate();
    DateTime finishDate = finishDateTimestamp.toDate();

    return Shift(
        id: snapshot.id,
        startDate: startDate,
        finishDate: finishDate,
        nurseID: map['nurse_id']);
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'start_date': startDate,
      'finish_date': finishDate,
      'nurse_id': nurseID,
    };
  }

  void validate() {
    if (startDate.isAfter(finishDate)) {
      throw ArgumentError.value(
        startDate,
        'startDate',
        'The start date must be before the finish date',
      );
    }

    if (nurseID == null) {
      throw ArgumentError.value(
        nurseID,
        'nurseID',
        'The nurse ID must not be null',
      );
    }

    if (nurseID!.isEmpty) {
      throw ArgumentError.value(
        nurseID,
        'nurseID',
        'The nurse ID must not be empty',
      );
    }

    if (duration.inHours > 8) {
      throw ArgumentError.value(
        duration,
        'duration',
        'The duration must not be longer than 8 hours',
      );
    }
  }

  bool overlaps(Shift other) {
    return startDate.isBefore(other.finishDate) &&
            startDate.isAfter(other.startDate) ||
        finishDate.isBefore(other.finishDate) &&
            finishDate.isAfter(other.startDate) ||
        startDate == other.startDate ||
        finishDate == other.finishDate;
  }

  bool couldBeJoinedBackwards(Shift other) {
    if (other.type == ShiftType.BUSY) {
      return false;
    }

    if (nurseID != other.nurseID) {
      return false;
    }

    return startDate == other.finishDate &&
        nurseID == other.nurseID &&
        startDate.difference(other.finishDate).inHours <= 8;
  }

  bool couldBeJoinedForwards(Shift other) {
    return finishDate == other.startDate &&
        nurseID == other.nurseID &&
        other.startDate.difference(finishDate).inHours <= 8;
  }

  bool couldBeJoined(Shift other) {
    return couldBeJoinedBackwards(other) || couldBeJoinedForwards(other);
  }

  Duration get duration {
    return finishDate.difference(startDate);
  }

  String subject(String nurseName) {
    return '$nurseName \n${startDate.day}/${startDate.month}/${startDate.year} - ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')} - ${finishDate.hour.toString().padLeft(2, '0')}:${finishDate.minute.toString().padLeft(2, '0')}';
  }
}
