import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

read_credentials_pref() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? items = prefs.getStringList('credentials');
  return items;
}

save_credentials_pref(email, password) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('credentials', <String>[email, password]);
  print('nagsave sya');
}

read_employeeProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? items = prefs.getStringList(('employeeCredentials'));
  return items;
}

save_employeeProfile(employeeName, department, email, password, guid,
    imageString, userType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('employeeCredentials', <String>[
    employeeName,
    department,
    email,
    password,
    guid,
    imageString,
    userType
  ]);
}

login_user(context, email, password) async {
  try {
    print('Email: ' + email);
    print('Password: ' + password);
    FirebaseAuth auth = FirebaseAuth.instance;
    final credential = await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) => save_credentials_pref(email, password))
        .then((value) => Navigator.pushReplacementNamed(context, 'Home'));
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

String timestampToDateString(dynamic timestamp, format) {
  if (timestamp != null) {
    if (timestamp is String) {
      return 'No Data';
    } else {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp)
          .add(Duration(hours: 8));
      return DateFormat(format).format(date.toLocal());
    }
  } else {
    return 'No Data';
  }
}

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date);
}

fetchAttendance() async {
  List<Attendance> _listKeys = [];
  DateTime now = DateTime.now();
  DateTime start = now.subtract(Duration(days: 15));
  final logRef = FirebaseDatabase.instance.ref().child('Logs');

  final ss = await logRef.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Attendance logs = Attendance();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn =
            timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        logs.userType = value['userType'].toString();
        logs.iswfh = value['isWfh'].toString();
        _listKeys.add(logs);
        // DateTime now = DateTime.now();
        // final date = DateTime.fromMillisecondsSinceEpoch(value['dateTimeIn']).add(Duration(hours:8));
        // Duration difference = now.difference(date);
        // if(difference <= Duration(days: 15)){
        //   Attendance logs = Attendance();
        //   logs.employeeID = value['employeeID'].toString();
        //   logs.employeeName = value['employeeName'].toString();
        //   logs.guid = value['guid'].toString();
        //   logs.dateTimeIn = timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        //   logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        //   logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        //   logs.userType = value['userType'].toString();
        //   logs.iswfh = value['isWfh'].toString();
        //   _listKeys.add(logs);
        // }
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

String generateGUID() {
  final _random = Random.secure();
  return '${_random.nextInt(1 << 32).toRadixString(16)}-${_random.nextInt(1 << 32).toRadixString(16)}-${_random.nextInt(1 << 32).toRadixString(16)}-${_random.nextInt(1 << 32).toRadixString(16)}';
}

fetchLatestWeeks(List<Attendance> logs) {
  DateTime now = DateTime.now();

  return logs.where((element) {
    DateTime? startDate1 = DateFormat('MM/dd/yyyy').parse(element.dateIn!);
    final date =
        DateTime.fromMillisecondsSinceEpoch(startDate1.millisecondsSinceEpoch)
            .add(Duration(hours: 8));
    Duration difference = now.difference(date);
    if (difference <= Duration(days: 15)) {
      return true;
    } else {
      return false;
    }
  }).toList();
}

getDateRange(dropdownvalue, startDate, endDate, List<Attendance> logs) {
  List<Attendance> ownLogs = [];
  if (dropdownvalue != null && dropdownvalue != '') {
    String startDateString = formatDate(startDate);
    String endDateString = formatDate(endDate);
    DateTime? startDate1 = DateFormat('MM/dd/yyyy').parse(startDateString);
    DateTime? endDate1 = DateFormat('MM/dd/yyyy').parse(endDateString);
    ownLogs = logs!.where((log) => log.empName == dropdownvalue).toList();
    if (startDate1 != null && endDate1 != null) {
      List<Attendance> newlogs = [];
      for (var attendance in ownLogs!) {
        if (attendance.dateIn != null) {
          var attendanceDate =
              DateFormat('MM/dd/yyyy').parse(attendance.dateIn!);
          if (attendanceDate != null &&
              attendanceDate.isAfter(startDate1!) &&
              attendanceDate.isBefore(endDate1!)) {
            newlogs.add(attendance);
          }
        }
      }
      ownLogs = sortList(newlogs);
    }
  }
  return ownLogs;
}

sortList(List<Attendance> attendance) {
  attendance.sort((a, b) {
    var dateA = DateFormat("MM/dd/yyyy").parse(a.dateIn!);
    var dateB = DateFormat("MM/dd/yyyy").parse(b.dateIn!);
    return dateB.compareTo(dateA);
  });

  return attendance;
}

fetchAllEmployees() async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Employees emp1 = Employees();
        emp1.employeeID = value['employeeID'].toString();
        emp1.department = value['department'].toString();
        emp1.email = value['email'].toString();
        emp1.employeeName = value['employeeName'].toString();
        emp1.setguid = value['guid'].toString();
        emp1.imageString = value['imageString'].toString();
        emp1.isWfh = value['isWfh'].toString();
        emp1.password = value['password'].toString();
        emp1.usertype = value['usertype'].toString();
        _listKeys.add(emp1);
      });
    }
  });
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
        }
      });
    }
  });
  print('done');
  return emp;
}

Future<String> generateQRBase64String(String text) async {
  final image = await QrPainter(
    data: text,
    version: QrVersions.auto,
    gapless: false,
    color: const Color(0xFF000000),
    emptyColor: const Color(0xFFFFFFFF),
  ).toImage(300);

  final pngBytes = await image.toByteData(format: ImageByteFormat.png);
  return base64Encode(pngBytes!.buffer.asUint8List());
}
