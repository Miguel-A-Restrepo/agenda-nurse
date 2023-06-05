import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agendanurse/models/nurse.dart';

void main() {
  group('Nurse', () {
    test('Should return the correct nurse name', () {
      // Arrange
      final nurse = Nurse(
        id: '1',
        fullName: 'John',
        fullLastName: 'Doe',
      );

      // Act
      final name = nurse.name;

      // Assert
      expect(name, equals('John Doe'));
    });

    test('Should return "No nurse name" if nurse name is empty', () {
      // Arrange
      final nurse = Nurse(
        id: '2',
        fullName: '',
        fullLastName: '',
      );

      // Act
      final name = nurse.name;

      // Assert
      expect(name, equals('No nurse name'));
    });
  });
}
