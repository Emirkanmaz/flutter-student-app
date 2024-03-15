import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/models/teacher.dart';
import 'package:http/http.dart' as http;

class DataService {
  final baseURL = "https://65e1019cd3db23f7624a5c7e.mockapi.io/";

  Future<List> downloadTeacher() async {

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection("teachers").get();
      return querySnapshot.docs.map((e) => Teacher.fromMap(e.data())).toList();
    }
    catch(e){
      throw Exception('Failed to get teacher. $e');
    }


    // final response = await http.get(Uri.parse("${baseURL}teachers"));
    //
    // if (response.statusCode == 200) {
    //   // If the server did return a 200 OK response,
    //   // then parse the JSON.
    //   final newTeachers = [];
    //   for (Map<String, dynamic> i in jsonDecode(response.body)) {
    //     newTeachers.add(Teacher.fromMap(i));
    //   }
    //   return newTeachers;
    // } else {
    //   // If the server did not return a 200 OK response,
    //   // then throw an exception.
    //   throw Exception("Failed. ${response.statusCode}");
    // }
  }

  Future<bool> addTeacher(Teacher newTeacher) async {
    try {
      await FirebaseFirestore.instance.collection("teachers").add(
          newTeacher.toMap());
      return true;
    }
    catch(e){
      throw Exception('Failed to add teacher. $e');
    }

    // final response = await http.post(Uri.parse("${baseURL}teachers"),
    //     headers: <String, String>{
    //       "Content-Type": "application/json; charset=UTF-8",
    //     },
    //     body: jsonEncode(newTeacher.toMap()));
    //
    // if (response.statusCode == 201) {
    //   // If the server did return a 201 CREATED response,
    //   // then parse the JSON.
    //   return true;
    // } else {
    //   // If the server did not return a 201 CREATED response,
    //   // then throw an exception.
    //   throw Exception('Failed to add teacher. ${response.statusCode}');
    // }
  }
}

final dataServiceProvider = Provider((ref) {
  return DataService();
});


