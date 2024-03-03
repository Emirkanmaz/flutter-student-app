import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/services/data_service.dart';
import '../models/teacher.dart';

class TeachersRepository extends ChangeNotifier {
  List teachers = [
    // Teacher("John", "Doe", 20, false),
    // Teacher("Jane", "Doe", 18, true),
    // Teacher("Emirkan", "Kanmaz", 22, false),
  ];

  final DataService dataService;

  TeachersRepository(this.dataService);

  Future<void> download() async {
    teachers = [];
    final newTeachersList = await dataService.downloadTeacher();
    for (Teacher newTeacher in newTeachersList) {
      teachers.add(newTeacher);
    }
    notifyListeners();
  }
}

final teachersProvider = ChangeNotifierProvider((ref) {
  return TeachersRepository(ref.watch(dataServiceProvider));
});
