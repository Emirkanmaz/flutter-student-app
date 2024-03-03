import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/services/data_service.dart';

import '../models/teacher.dart';

void main() => runApp(const TeacherAddPage());

class TeacherAddPage extends ConsumerStatefulWidget {
  const TeacherAddPage({super.key});

  @override
  ConsumerState<TeacherAddPage> createState() => _TeacherAddPageState();
}

class _TeacherAddPageState extends ConsumerState<TeacherAddPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> tempTeacher = {};
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Add Teachers"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please insert name.';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    tempTeacher["name"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please insert surname.';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    tempTeacher["surname"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please insert age.';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please insert a valid number.';
                    }
                    if (int.tryParse(value)! < 18) {
                      return 'Age must be higher than 18.';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    tempTeacher["age"] = int.parse(newValue!);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: tempTeacher["gender"],
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select gender';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      tempTeacher["gender"] = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          final formState = _formKey.currentState;
                          if (formState == null) return;
                          if (formState.validate() == true) {
                            formState.save();
                            setState(() {
                              tempTeacher["gender"] == "Female"
                                  ? tempTeacher["female"] = true
                                  : tempTeacher["female"] = false;
                              tempTeacher.remove("gender");
                            });
                            print(tempTeacher);
                          }

                          upload();
                        },
                        child: const Center(child: Text('Submit')),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> upload() async {
    try {
      setState(() {
        isUploading = true;
      });
      if(await ref.read(dataServiceProvider).addTeacher(Teacher.fromMap(tempTeacher))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Teacher ${tempTeacher["name"]} ${tempTeacher["surname"]} added succesfully.")));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
}
