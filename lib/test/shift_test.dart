import 'package:flutter_test/flutter_test.dart';
import 'package:agendanurse/models/shift.dart';
import 'package:agendanurse/models/nurse.dart';
void main() {
  group('Shift', () {
    test('Should validate shift correctly', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(() => shift.validate(), returnsNormally);
    });

    test('Should throw an error if start date is after finish date', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 2, 8, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(() => shift.validate(), throwsArgumentError);
    });

    test('Should throw an error if NURSE ID is null', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: null,
        type: ShiftType.NURSE,
      );

      expect(() => shift.validate(), throwsArgumentError);
    });

    test('Should throw an error if NURSE ID is empty', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: '',
        type: ShiftType.NURSE,
      );

      expect(() => shift.validate(), throwsArgumentError);
    });

    test('Should throw an error if duration is longer than 8 hours', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 18, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(() => shift.validate(), throwsArgumentError);
    });

    test('Should return true if shifts overlap', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 11, 0),
        finishDate: DateTime(2023, 1, 1, 15, 0),
        nurseID: 'N002',
        type: ShiftType.NURSE,
      );

      expect(shift1.overlaps(shift2), isTrue);
    });

    test('Should return false if shifts do not overlap', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 13, 0),
        finishDate: DateTime(2023, 1, 1, 15, 0),
        nurseID: 'N002',
        type: ShiftType.NURSE,
      );

      expect(shift1.overlaps(shift2), isFalse);
    });

    test('Should return true if shifts can be joined backwards', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoinedBackwards(shift2), isFalse);
    });

    test('Should return false if shifts cannot be joined backwards', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N002',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoinedBackwards(shift2), isFalse);
    });

    test('Should return true if shifts can be joined forwards', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoinedForwards(shift2), isTrue);
    });

    test('Should return false if shifts cannot be joined forwards', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N002',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoinedForwards(shift2), isFalse);
    });

    test('Should return true if shifts can be joined', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoined(shift2), isTrue);
    });

    test('Should return false if shifts cannot be joined', () {
      final shift1 = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      final shift2 = Shift(
        id: '2',
        startDate: DateTime(2023, 1, 1, 12, 0),
        finishDate: DateTime(2023, 1, 1, 16, 0),
        nurseID: 'N002',
        type: ShiftType.NURSE,
      );

      expect(shift1.couldBeJoined(shift2), isFalse);
    });

    test('Should return the correct duration', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(shift.duration, equals(Duration(hours: 4)));
    });

    test('Should return the correct subject', () {
      final shift = Shift(
        id: '1',
        startDate: DateTime(2023, 1, 1, 8, 0),
        finishDate: DateTime(2023, 1, 1, 12, 0),
        nurseID: 'N001',
        type: ShiftType.NURSE,
      );

      expect(
        shift.subject('John Doe'),
        equals('John Doe \n1/1/2023 - 08:00 - 12:00'),
      );
    });
  });
}

