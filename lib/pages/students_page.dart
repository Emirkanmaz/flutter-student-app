import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/repository/students_repository.dart';
import '../models/student.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsRepository = ref.watch(studentsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Students"),
      ),
      body: Column(
        children: [
          PhysicalModel(
            color: Colors.white,
            elevation: 10,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text("${studentsRepository.students.length} Students"),
              ),
            ),
          ),
          Expanded(
              child: ListView.separated(
            itemBuilder: (context, index) {
              // bool female = Random().nextBool();
              return StudentRow(
                studentsRepository.students[index],
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: studentsRepository.students.length,
          )),
        ],
      ),
    );
  }
}

class StudentRow extends ConsumerWidget {
  final Student student;

  const StudentRow(
    this.student, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsRepository = ref.watch(studentsProvider);
    bool liked = studentsRepository.liked(student);
    return ListTile(
      title: Text("${student.name} ${student.surname}"),
      leading: student.female
          ? const Text("👩‍🎓", style: TextStyle(fontSize: 30))
          : const Text("👨‍🎓", style: TextStyle(fontSize: 30)),
      trailing: IconButton(
          onPressed: () {
            ref.read(studentsProvider).like(student, !liked);
          },
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border)),
    );
  }
}
