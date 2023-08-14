import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:dtr360_version3_2/model/codeTable.dart';
import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

read_credentials_pref() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? items = prefs.getStringList('credentials');
  return items;
}

save_credentials_pref(email, password) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('credentials', <String>[email, password]);
}

read_employeeProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? items = prefs.getStringList(('employeeCredentials'));
  return items;
}

save_employeeProfile(
    employeeName,
    department,
    email,
    password,
    guid,
    imageString,
    userType,
    key,
    employeeID,
    approver,
    approverName,
    remainingLeaves, shiftTimeIn, shiftTimeOut, monday,tuesday,wednesday,thursday,friday,saturday,sunday) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('employeeCredentials', <String>[
    employeeName,
    department,
    email,
    password,
    guid,
    imageString,
    userType,
    key,
    employeeID,
    approverName,
    approver,
    remainingLeaves, shiftTimeIn, shiftTimeOut, monday,tuesday,wednesday,thursday,friday,saturday,sunday
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
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      //.add(Duration(hours: 8));
      return DateFormat(format).format(date.toLocal());
    }
  } else {
    return 'No Data';
  }
}

String convertDateFormat(String dateString) {
  // Parse the input date string into a DateTime object
  DateTime date = DateFormat('EEEE, MMMM d, y').parse(dateString);

  // Format the DateTime object into the desired output format
  String formattedDate = DateFormat('MM/dd/yyyy').format(date);

  return formattedDate;
}

isEmployeeExist(guid, documents) {
  bool isExist = false;
  for (var i = 0; i < documents.length; i++) {
    if (documents[i].guid == guid) {
      isExist = true;
    }
  }
  return isExist;
}

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date);
}

String longformatDate(DateTime date) {
  return DateFormat('EEEE, MMMM d, yyyy').format(date);
}

String formatTime(TimeOfDay date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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
        DateTime.fromMillisecondsSinceEpoch(startDate1.millisecondsSinceEpoch);
    //.add(Duration(hours: 8));
    Duration difference = now.difference(date);
    if (difference <= Duration(days: 15)) {
      return true;
    } else {
      return false;
    }
  }).toList();
}

computeTotalHours(startTIme, endTime) {
  DateTime start =
      DateTime.fromMillisecondsSinceEpoch(int.parse(startTIme.toString()));
  DateTime end =
      DateTime.fromMillisecondsSinceEpoch(int.parse(endTime.toString()));

  // Calculate the difference in hours
  Duration difference = end.difference(start);
  double totalHours = difference.inHours.toDouble();
  double remainingMinutes = difference.inMinutes.remainder(60).toDouble();
  double remainingSeconds = difference.inSeconds.remainder(60).toDouble();

  // Convert the remaining minutes and seconds into fractions of an hour
  double minutesFraction = remainingMinutes / 60.0;
  double secondsFraction = remainingSeconds / 3600.0;

  // Add the fractions to the total hours
  totalHours += (minutesFraction + secondsFraction);

  return totalHours.toStringAsFixed(2);
}

convertStringDateToUnix(date, selectedTime, docType, isTimeTo, otFrom) {
  int unixTimestamp = 0;
  if (docType == 'Correction' || docType == 'Overtime') {
    DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);
    DateFormat timeFormat = DateFormat('HH:mm');
    DateTime time = timeFormat.parse(selectedTime);
    DateTime otTimeFrom =
        DateTime.fromMillisecondsSinceEpoch(int.parse(otFrom.toString()));
    int day = isTimeTo && (otTimeFrom.hour > time.hour)
        ? dateTime.day + 1
        : dateTime.day;

    DateTime convertedTime = DateTime(dateTime.year, dateTime.month, day,
        time.hour, time.minute, time.second);

    // Convert to Unix timestamp
    unixTimestamp = convertedTime.millisecondsSinceEpoch;
  } else if (docType == 'Leave') {
    DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);

    // Convert to Unix timestamp
    unixTimestamp = dateTime.millisecondsSinceEpoch;
  } else {}

  return unixTimestamp;
}

getDateDiff(dateTime) {
  DateTime now = DateTime.now();
  DateTime? startDate1 =
      DateFormat('MM/dd/yyyy HH:mm a').parse(dateTime.toString());
  final date =
      DateTime.fromMillisecondsSinceEpoch(startDate1.millisecondsSinceEpoch);
  //.add(Duration(hours: 8));
  final difference = now.difference(date).abs();
  if (difference <= Duration(days: 1)) {
    return true;
  } else {
    return false;
  }
}

logoutUser(context) {
  FirebaseAuth.instance.signOut();
  save_credentials_pref('', '');
  save_employeeProfile('', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','');
  Navigator.pushReplacementNamed(context, 'Login');
}

getDateRange(dropdownvalue, startDate, endDate, List<Attendance> logs) {
  List<Attendance> ownLogs = [];
  if (dropdownvalue != null && dropdownvalue != '') {
    String startDateString = formatDate(startDate);
    String endDateString = formatDate(endDate);
    DateTime? startDate1 = DateFormat('MM/dd/yyyy').parse(startDateString);
    DateTime? endDate1 = DateFormat('MM/dd/yyyy')
        .parse(endDateString)
        .add(const Duration(days: 1));
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
    var dateTimeA;
    var dateTimeB;

    if (a.timeIn != 'No Data') {
      dateTimeA =
          DateFormat("MM/dd/yyyy HH:mm a").parse(a.dateIn! + ' ' + a.timeIn!);
    } else {
      dateTimeA = DateFormat("MM/dd/yyyy").parse(a.dateIn!);
    }

    if (b.timeIn != 'No Data') {
      dateTimeB =
          DateFormat("MM/dd/yyyy HH:mm a").parse(b.dateIn! + ' ' + b.timeIn!);
    } else {
      dateTimeB = DateFormat("MM/dd/yyyy").parse(b.dateIn!);
    }

    return dateTimeB.compareTo(dateTimeA);
  });

  return attendance;
}

int? getHighestUniqueId(List<codeTable> itemList) {
  itemList.sort((a, b) => b.uniqueId!.compareTo(a.uniqueId!));
  return itemList.isNotEmpty ? itemList.first.uniqueId! + 1 : 1;
}

bool isDateFromBeforeDateTo(String dateFrom, String dateTo) {
  final dateFormat = 'MM/dd/yyyy';
  DateTime from = DateTime.parse(dateFrom);
  DateTime to = DateTime.parse(dateTo);
  if (from.isBefore(to) || from.isAtSameMomentAs(to)) {
    return true;
  } else {
    return false;
  }
}

bool isTimeFromBeforeTimeTo(int dateFrom, int dateTo) {
  print(dateFrom);
  return false;
  // final dateFormat = 'HH:mm';
  // DateTime from = DateTime.parse(dateFrom);
  // DateTime to = DateTime.parse(dateTo);
  // if (from.isBefore(to) || from.isAtSameMomentAs(to)) {
  //   return true;
  // } else {
  //   return false;
  // }
}

sortDocs(List<FilingDocument> docs) {
  docs.sort((a, b) {
    var dateA = DateFormat("EEEE, MMMM d, yyyy").parse(a.date!);
    var dateB = DateFormat("EEEE, MMMM d, yyyy").parse(b.date!);
    return dateB.compareTo(dateA);
  });

  return docs;
}

DateTime parseCustomDate(String dateString) {
  final List<String> months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final parts = dateString.split(' ');
  final weekday = parts[0];
  final month = months.indexOf(parts[1]);
  final day = int.parse(parts[2].replaceAll(',', ''));
  final year = int.parse(parts[3]);

  return DateTime(year, month, day);
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
