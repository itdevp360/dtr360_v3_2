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
    imageString, userType, key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('employeeCredentials', <String>[
    employeeName,
    department,
    email,
    password,
    guid,
    imageString,
    userType,
    key
  ]);
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

logoutUser(context) {
  FirebaseAuth.instance.signOut();
  save_credentials_pref('', '');
  save_employeeProfile('', '', '', '', '', '', '', '');
  Navigator.pushReplacementNamed(context, 'Login');
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

//Ascending A to Z
sortListAlphabetical(List<Employees> employees) {
  employees.sort((a, b) {
    return a.empName!.compareTo(b.empName!);
  });
  return employees;
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
