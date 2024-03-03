import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';

class StudentsRepository extends ChangeNotifier {
  final students = [
    Student("John", "Doe", 20, false),
    Student("Jane", "Doe", 18, true),
    Student("Emirkan", "Kanmaz", 22, false),
  ];

  final Set likedStudents = {};

  void like(Student student, bool liked) {
    if (liked) {
      likedStudents.add(student);
    } else {
      likedStudents.remove(student);
    }
    notifyListeners();
  }

  bool liked(Student student) {
    if (likedStudents.contains(student)) {
      return true;
    } else {
      return false;
    }
  }
}

final studentsProvider = ChangeNotifierProvider((ref) {
  return StudentsRepository();
});

