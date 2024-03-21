import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/models/student.dart';
import 'package:student_app/repository/students_repository.dart';

void main() {
  group("Student Like", () {
    test('Known Student can be liked?', () {
      final studentsRepository = StudentsRepository();
      final testStudent = Student("Test Name", "Test Surname", 18, false);
      studentsRepository.students.add(testStudent);

      // liked
      expect(studentsRepository.liked(testStudent), false);

      // like
      studentsRepository.like(testStudent, true);
      expect(studentsRepository.liked(testStudent), true);

      //unlike
      studentsRepository.like(testStudent, false);
      expect(studentsRepository.liked(testStudent), false);
    });

    test('Unknown Student can be liked?', () {
      final studentsRepository = StudentsRepository();
      final testStudent = Student("Test Name", "Test Surname", 18, false);
      // liked
      expect(studentsRepository.liked(testStudent), false);
    });
  });
}
