import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/pages/teacher_add_page.dart';
import 'package:student_app/repository/teachers_repository.dart';
import '../models/teacher.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersRepository = ref.watch(teachersProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Teachers"),
      ),
      body: Column(
        children: [
          PhysicalModel(
            color: Colors.white,
            elevation: 10,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child:
                        Text("${teachersRepository.teachers.length} Teachers"),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerRight,
                  child: TeacherDownloaderButton(),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.separated(
            itemBuilder: (context, index) {
              // bool female = Random().nextBool();
              return TeacherRow(teachersRepository.teachers[index]);
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: teachersRepository.teachers.length,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) {
                return const TeacherAddPage();
              },
            ),);
          if(created == true){
            await ref.read(teachersProvider).download();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TeacherDownloaderButton extends StatefulWidget {
  const TeacherDownloaderButton({
    super.key,
  });

  @override
  State<TeacherDownloaderButton> createState() =>
      _TeacherDownloaderButtonState();
}

class _TeacherDownloaderButtonState extends State<TeacherDownloaderButton> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return isDownloading
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  try {
                    setState(() {
                      isDownloading = true;
                    });
                    await ref.read(teachersProvider).download();
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  } finally {
                    setState(() {
                      isDownloading = false;
                    });
                  }
                },
              );
      },
    );
  }
}

class TeacherRow extends StatelessWidget {
  final Teacher teacher;

  const TeacherRow(
    this.teacher, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${teacher.name} ${teacher.surname} Teacher"),
      leading: teacher.female
          ? const Text("👩‍🏫", style: TextStyle(fontSize: 30))
          : const Text("👨‍🏫", style: TextStyle(fontSize: 30)),
    );
  }
}
