import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(teachersProvider).download();
    // Future.delayed(Duration.zero).then((value) => ref.read(teachersProvider).download());
  }

  @override
  Widget build(BuildContext context) {
    final studentsRepository = ref.watch(studentsProvider);
    final teachersRepository = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Student Home Page'),
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
        builder: (context) => const MyHomePage(),
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
                child: const Text("Sign with GOOGLE"))
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Future<Uint8List?>? _ppicFuture;

  @override
  void initState() {
    super.initState();

    _ppicFuture = _ppicDownload();
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<Uint8List?> _ppicDownload() async {
    final documentSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final userRecMap = documentSnapshot.data();

    if (userRecMap == null) return null;

    if (userRecMap.containsKey("ppicref")) {
      Uint8List? uint8list =
          await FirebaseStorage.instance.ref(userRecMap["ppicref"]).getData();
      return uint8list;
    }
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FirebaseAuth.instance.currentUser!.displayName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    XFile? xFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (xFile == null) return;

                    final imagePath = xFile.path;

                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final ppicRef =
                        FirebaseStorage.instance.ref("ppics").child("$uid.jpg");
                    await ppicRef.putFile(File(imagePath));

                    FirebaseFirestore.instance.collection("users").doc(uid).update({"ppicref": ppicRef.fullPath});

                    setState(() {
                      _ppicFuture = _ppicDownload();
                    });
                  },
                  child: FutureBuilder<Uint8List?>(
                    future: _ppicFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<Uint8List?> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final picInMemory = snapshot.data!;

                        return CircleAvatar(
                          backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
                        );
                      }
                      return const CircleAvatar(
                        child: Icon(Icons.camera_alt),
                      );
                    },
                  ),
                ),
              ],
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
