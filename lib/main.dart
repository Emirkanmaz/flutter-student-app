import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/pages/google_sign_in.dart';
import 'package:student_app/pages/messages_page.dart';
import 'package:student_app/pages/students_page.dart';
import 'package:student_app/pages/teachers_page.dart';
import 'package:student_app/repository/messages_repository.dart';
import 'package:student_app/repository/students_repository.dart';
import 'package:student_app/repository/teachers_repository.dart';

import 'firebase_options.dart';

void main() {
  runApp(const ProviderScope(child: StudentApp()));
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsRepository = ref.watch(studentsProvider);
    final teachersRepository = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      // Add the drawer property to Scaffold
      drawer: const MyDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MessagesPage();
                    },
                  ),
                );
              },
              child:
                  Text("${ref.watch(unreadedMessagesProvider)} New Messages"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) {
                      return const StudentsPage();
                    },
                  ),
                );
              },
              child: Text("${studentsRepository.students.length} Students"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) {
                      return const TeachersPage();
                    },
                  ),
                );
              },
              child: Text("${teachersRepository.teachers.length} Teachers"),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    setState(() {
      isFirebaseInitialized = true;
    });
    if (FirebaseAuth.instance.currentUser != null) {

      String uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        "SignIn": true,
        "lastSignIn": FieldValue.serverTimestamp(),
      });
      goHomePage();
    }
    // goHomePage();
  }

  void goHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Student Home Page'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isFirebaseInitialized
            ? ElevatedButton(
                onPressed: () async {
                  UserCredential userCredential = await signInWithGoogle();

                  String uid = FirebaseAuth.instance.currentUser!.uid;
                  FirebaseFirestore.instance.collection('users').doc(uid).set({
                    "SignIn": true,
                    "lastSignIn": FieldValue.serverTimestamp(),
                  });
                  goHomePage();
                },
                child: Text("Sign with GOOGLE"))
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove top padding
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              FirebaseAuth.instance.currentUser!.displayName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Messages'),
            onTap: () {
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) {
                    return const MessagesPage();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Students'),
            onTap: () {
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) {
                    return const StudentsPage();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Teachers'),
            onTap: () {
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) {
                    return const TeachersPage();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await signOutWithGoogle();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
