import 'dart:convert';

import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

read_credentials_pref() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? items = prefs.getStringList('credentials');
  return items;
}

save_credentials_pref(email, password) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('credentials', <String>[email, password]);
}

login_user(context, email, password) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    final credential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    save_credentials_pref(email, password);

    Navigator.pushReplacementNamed(context, 'Home');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
}

Image imageFromBase64String(String base64String) {
  return Image.memory(
      base64Decode(base64String.replaceAll(RegExp(r'\s+'), '')));
}

fetchAttendance() async {
  List<Attendance> _listKeys = [];
  final logRef = FirebaseDatabase.instance.ref().child('Logs');
  final ss = await logRef.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Attendance logs = Attendance();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn = value['dateTimeIn'].toString();
        logs.timeIn = value['timeIn'].toString();
        logs.timeOut = value['timeOut'].toString();
        logs.userType = value['userType'].toString();
        logs.iswfh = value['isWfh'].toString();
        _listKeys.add(logs);
      });
    }
  });

  // final snapshotlogs = await ref.get().then((snapshot) {
  //   if (snapshot.exists) {
  //     Map<dynamic, dynamic>? values = snapshot.value as Map?;
  //     values!.forEach((key, value) {
  //       Attendance logs = Attendance();
  //       logs.employeeID = value['employeeID'];
  //       logs.employeeName = value['employeeName'];
  //       logs.guid = value['guid'];
  //       logs.dateTimeIn = value['dateTimeIn'];
  //       logs.timein = value['timeIn'];
  //       logs.timeout = value['timeOut'];
  //       logs.userType = value['userType'];
  //       logs.iswfh = value['isWfh'];
  //       _listKeys.add(logs);
  //     });
  //   }
  // });
  return _listKeys;
}

fetchEmployees(String email) async {
  print(email);
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');
  Employees emp = Employees();
  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        if (value['email'] == email) {
          emp.employeeID = value['employeeID'].toString();
          emp.department = value['department'].toString();
          emp.email = value['email'].toString();
          emp.employeeName = value['employeeName'].toString();
          emp.setguid = value['guid'].toString();
          emp.imageString = value['imageString'].toString();
          emp.isWfh = value['isWfh'].toString();
          emp.password = value['password'].toString();
          emp.usertype = value['usertype'].toString();
          // emp.employeeName = value['employeeName'];
          // emp.employeeID = value['employeeID'];
          // emp.email = value['email'];
          // emp.department = value['department'];
          // emp.guid = value['guid'];
          // emp.imageString = value['imageString'];
          // emp.isWfh = value['isWfh'];
          // emp.password = value['password'];
          // emp.usertype = value['usertype'];

        }
      });
    }
  });
  print('done');
  return emp;
}
