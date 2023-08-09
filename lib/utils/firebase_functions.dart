import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:intl/intl.dart';

import '../model/approver.dart';

fetchSelectedEmployeesAttendance(documents) async {
  List<Attendance> _listKeys = [];
  final logRef = FirebaseDatabase.instance.ref().child('Logs');

  await logRef.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Attendance logs = Attendance();
        logs.attendanceKey = key.toString();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn =
            timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        logs.userType = value['usertype'].toString();
        logs.iswfh = value['isWfh'].toString();
        if (isEmployeeExist(logs.empName, documents) &&
            value['usertype'].toString() != 'Former Employee') {
          _listKeys.add(logs);
        }
      });
    }
  });

  return _listKeys;
}

fileLeave(key, filingDocKey, context, empKey, noOfDays, approverName) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('Logs/' + key);
  await databaseReference.update({
    'isLeave': true,
  }).then((value) async {
    await updateRemainingLeaves(empKey, noOfDays).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  });
}

updateRemainingLeaves(empKey, noOfDays) async {
  final ref = FirebaseDatabase.instance.ref().child('Employee/' + empKey);
  final snapshot = await ref.get();
  if (snapshot.exists) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    if (values != null && values.containsKey('remainingLeaves')) {
      double remainingLeave = values['remainingLeaves'].toDouble();
      remainingLeave = remainingLeave - double.parse(noOfDays);
      await ref.update({
        'remainingLeaves': remainingLeave,
      });
    }
  }
}

fileOvertime(
    key, filingDocKey, context, otType, hoursNo, empKey, approverName) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('Logs/' + key);
  await databaseReference.update(
      {'otType': otType, 'hoursNo': hoursNo, 'isOt': true}).then((value) async {
    await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
  });
}

attendanceCorrection(
    key, date, time, isOut, filingDocKey, context, empKey, approverName) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('Logs/' + key);
  String dateTimeString = '$date $time';
  DateFormat dateFormat = DateFormat('MM/dd/yyyy HH:mm');
  DateTime dateTime = dateFormat.parse(dateTimeString);

  int unixTimestamp = dateTime.millisecondsSinceEpoch;
  if (isOut) {
    await databaseReference.update({
      'timeOut': unixTimestamp,
    }).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  } else {
    await databaseReference.update({
      'timeIn': unixTimestamp,
    }).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  }
}

updateFilingDocStatus(key, context, empKey, approverName) async {
  String today = DateTime.now().toString();
  final databaseReference =
      FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference.update({
    'isApproved': true,
    'approveRejectDate': today,
    'approveRejectBy': approverName
  }).then((value) async {
    // await success_box(context, 'Document approved');
  });
}

createAttendance(
    key, context, empKey, correctDate, correctTime, isOut, approverName) async {
  var emp = await read_employeeProfile();
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs');
  DateTime selectedDate = DateFormat("EEEE, MMMM dd, yyyy").parse(correctDate);
  DateTime selectedTime = DateFormat("HH:mm").parse(correctTime);
  DateTime combinedDate = DateTime(selectedDate.year, selectedDate.month,
      selectedDate.day, selectedTime.hour, selectedTime.minute);
  int timestamp = combinedDate.millisecondsSinceEpoch;
  if (isOut) {
    databaseReference.push().set({
      'dateTimeIn': timestamp,
      'department': emp[1],
      'employeeID': emp[8],
      'employeeName': emp[0],
      'guid': emp[4],
      'timeOut': timestamp,
      'userType': emp[6],
      'isWfh': false,
    }).then(
      (value) {
        updateFilingDocStatus(key, context, empKey, approverName);
      },
    );
  } else {
    databaseReference.push().set({
      'dateTimeIn': timestamp,
      'department': emp[1],
      'employeeID': emp[8],
      'employeeName': emp[0],
      'guid': emp[4],
      'timeIn': timestamp,
      'userType': emp[6],
      'isWfh': false,
    }).then(
      (value) {
        updateFilingDocStatus(key, context, empKey, approverName);
      },
    );
  }
}

cancelFilingStatus(key) async {
  String today = DateTime.now().toString();
  final databaseReference =
      FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference.update(
      {'isCancelled': true, 'cancellationDate': today}).then((value) async {
    // await success_box(context, 'Document approved');
  });
}

checkIfValidDate(
    desiredDate, guid, isOt, timeFrom, timeTo, isOvernightOt, isOut) async {
  Attendance logs = new Attendance();
  DateTime queryDate = DateTime.parse(desiredDate);
  DateTime dateTimeFrom = DateTime.fromMillisecondsSinceEpoch(timeFrom);
  DateTime dateTimeTo = DateTime.fromMillisecondsSinceEpoch(timeTo);

  int month = queryDate.month;
  int day = queryDate.day;
  int year = queryDate.year;
  int finalTimeFrom =
      DateTime(year, month, day, dateTimeFrom.hour, dateTimeFrom.minute)
          .millisecondsSinceEpoch;
  int finalTimeTo =
      DateTime(year, month, dateTimeTo.day, dateTimeTo.hour, dateTimeTo.minute)
          .millisecondsSinceEpoch;
  bool isBeyondTime = false;
  final int startTimestamp = queryDate
      .subtract(Duration(
          hours: queryDate.hour,
          minutes: queryDate.minute,
          seconds: queryDate.second))
      .millisecondsSinceEpoch;

  final int endTimestamp = queryDate
      .add(Duration(days: 1))
      .subtract(Duration(
          hours: queryDate.hour,
          minutes: queryDate.minute,
          seconds: queryDate.second))
      .millisecondsSinceEpoch;

  final databaseReference = await FirebaseDatabase.instance
      .ref()
      .child('Logs')
      .orderByChild('dateTimeIn')
      .startAt(startTimestamp)
      .endAt(endTimestamp)
      .get()
      .then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        logs.attendanceKey = key.toString();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn =
            timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = value['timeOut'] != null
            ? timestampToDateString(value['timeOut'], 'hh:mm a')
            : '';
        logs.userType = value['usertype'].toString();
        logs.iswfh = value['isWfh'].toString();
        if (isOt) {
          FilingDocument dataModel = FilingDocument();
          if (value['timeOut'] != null && guid == logs.getGuid) {
            int timeOut = value['timeOut'];
            DateTime convertedTimeOut =
                DateTime.fromMillisecondsSinceEpoch(timeOut);
            int timeIn = value['timeIn'];
            DateTime convertedTimeIn =
                DateTime.fromMillisecondsSinceEpoch(timeIn);
            int desiredTime =
                DateTime(year, month, day, 18, 00).millisecondsSinceEpoch;
            int finalDay = convertedTimeOut.day > convertedTimeIn.day
                ? convertedTimeIn.day + 1
                : convertedTimeIn.day;
            int finalTimeOut = DateTime(
                    convertedTimeOut.year,
                    convertedTimeOut.month,
                    finalDay,
                    convertedTimeOut.hour,
                    convertedTimeOut.minute)
                .millisecondsSinceEpoch;
            if (finalTimeFrom < finalTimeOut && finalTimeTo <= finalTimeOut) {
              if (isOvernightOt) {
                isBeyondTime = true;
              } else {
                isBeyondTime =
                    timeOut >= desiredTime && finalTimeTo >= desiredTime;
              }
            } else {}
          }
        } else {
          if (guid == logs.getGuid) {
            isBeyondTime = true;
          }
        }
      });
    } else {
      if (!isOt) {
        isBeyondTime = true;
      }
    }
  });

  return isBeyondTime;
}

rejectApplication(key, reason, approverName) async {
  String today = DateTime.now().toString();
  final databaseReference =
      FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference.update({
    'isRejected': true,
    'approveRejectDate': today,
    'rejectionReason': reason,
    'approveRejectBy': approverName
  }).then((value) async {
    // await success_box(context, 'Document approved');
  });
}

checkIfDuplicate(
    dateFrom, dateTo, correctDate, otDate, docType, guid, isOut) async {
  var isDuplicate = false;
  if (docType == 'Leave') {
    final databaseReference = await FirebaseDatabase.instance
        .ref()
        .child('FilingDocuments')
        .orderByChild('dateFrom')
        .endAt(dateTo)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        DateTime selectedDate = DateTime.parse(dateFrom);
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          var isRejected = value['isRejected'] ?? false;
          var isCancelled = value['isCancelled'] ?? false;

          String dateFromString = value['dateFrom'] == null ||
                  value['dateFrom'] == ''
              ? ''
              : longformatDate(DateTime.parse(value['dateFrom'])).toString();

          if (value['guid'] == guid &&
              (isCancelled == false && isRejected == false) &&
              dateFromString != '' &&
              value['docType'] == 'Leave') {
            DateTime dateFromData = DateTime.parse(value['dateFrom']);
            DateTime dateFromTo = DateTime.parse(value['dateTo']);
            if (selectedDate.isAfter(dateFromData) &&
                selectedDate.isBefore(dateFromTo.add(Duration(days: 1)))) {
              isDuplicate = true;
            } else if (selectedDate.isAtSameMomentAs(dateFromData)) {
              isDuplicate = true;
            }
          }
        });
      }
    });
  } else if (docType == 'Correction') {
    final databaseReference = await FirebaseDatabase.instance
        .ref()
        .child('FilingDocuments')
        .orderByChild('correctDate')
        .equalTo(correctDate)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          var isRejected = value['isRejected'] ?? false;
          var isCancelled = value['isCancelled'] ?? false;
          var isApproved = value['isApproved'] ?? false;
          var isOutData = value['isOut'] ?? false;
          if (value['guid'] == guid &&
              ((!isApproved && !isRejected) || (isApproved && !isCancelled)) &&
              value['docType'] == 'Correction' &&
              isOut == isOutData) {
            isDuplicate = true;
          }
        });
      }
    });
  } else {
    final databaseReference = await FirebaseDatabase.instance
        .ref()
        .child('FilingDocuments')
        .orderByChild('otDate')
        .equalTo(otDate)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          print("OT Dateee: " + value['otDate']);
          var isRejected = value['isRejected'] ?? false;
          var isCancelled = value['isCancelled'] ?? false;
          if (value['guid'] == guid &&
              (isCancelled == false &&
                  isRejected == false &&
                  value['docType'] == 'Overtime')) {
            isDuplicate = true;
          }
        });
      }
    });
  }

  return isDuplicate;
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
        logs.attendanceKey = key.toString();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn =
            timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        logs.userType = value['usertype'].toString();
        logs.iswfh = value['isWfh'].toString();
        if (value['usertype'].toString() != 'Former Employee') {
          _listKeys.add(logs);
        }
      });
    }
  });

  return _listKeys;
}

login_user(context, email, password) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    final credential = await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) => save_credentials_pref(email, password))
        .then((value) => Navigator.pushReplacementNamed(context, 'Home'));
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
      warning_box(context, e.code);
    } else if (e.code == 'wrong-password') {
      warning_box(context, e.code);
      print('Wrong password provided for that user.');
    }
  }
}

fetchAllEmployees(bool isAttendance) async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Employees emp1 = Employees();
        emp1.itemKey = key.toString();
        emp1.employeeID = value['employeeID'].toString();
        emp1.department = value['department'].toString();
        emp1.email = value['email'].toString();
        emp1.employeeName = value['employeeName'].toString();
        emp1.setguid = value['guid'].toString();
        emp1.imageString = value['imageString'].toString();
        emp1.isWfh = value['isWfh'].toString();
        emp1.password = value['password'].toString();
        emp1.usertype = value['usertype'].toString();
        emp1.appId = value['approver'].toString();
        emp1.appName = value['approverName'].toString();
        emp1.absences = value['remainingLeaves'].toString();
        if (isAttendance == false) {
          _listKeys.add(emp1);
        } else {
          if (value['usertype'].toString() != 'Former Employee') {
            _listKeys.add(emp1);
          }
        }
      });
    }
  });
  return _listKeys;
}

fetchEmployees() async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Employees emp = Employees();
        emp.itemKey = key.toString();
        emp.employeeID = value['employeeID'].toString();
        emp.department = value['department'].toString();
        emp.email = value['email'].toString();
        emp.employeeName = value['employeeName'].toString();
        emp.setguid = value['guid'].toString();
        emp.imageString = value['imageString'].toString();
        emp.isWfh = value['isWfh'].toString();
        emp.password = value['password'].toString();
        emp.usertype = value['usertype'].toString();
        emp.appId = value['approver'].toString();
        emp.appName = value['approverName'].toString();
        emp.absences = value['remainingLeaves'].toString();
        _listKeys.add(emp);
      });
    }
  });
  print('done');
  return _listKeys;
}

fetchApprover() async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Employees emp = Employees();
        emp.itemKey = key.toString();
        emp.employeeID = value['employeeID'].toString();
        emp.department = value['department'].toString();
        emp.email = value['email'].toString();
        emp.employeeName = value['employeeName'].toString();
        emp.setguid = value['guid'].toString();
        emp.imageString = value['imageString'].toString();
        emp.isWfh = value['isWfh'].toString();
        emp.password = value['password'].toString();
        emp.usertype = value['usertype'].toString();
        emp.appId = value['approver'].toString();
        emp.appName = value['approverName'].toString();
        if (value['usertype'].toString() == 'Approver') {
          _listKeys.add(emp);
        }
      });
    }
  });
  // print(_listKeys);
  return _listKeys;
}

updateEmployeeDetails(key, department, employeeID, employeeName, isWfh,
    userType, approver, approverName, absences, approvers) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('Employee/' + key);
  await databaseReference.update({
    'department': department,
    'employeeID': employeeID,
    'employeeName': employeeName,
    'usertype': userType,
    'approver': approver,
    'approverName': approverName,
    'remainingLeaves': absences,
    'isWfh': isWfh == true ? 'Work from Home' : '',
  }).then((value) async {
    final dbRef = FirebaseDatabase.instance.ref().child('Approver');
    var approverList = dbRef.orderByChild('empKey').equalTo(key);
    final snapshot =
        await dbRef.orderByChild('empKey').equalTo(key).get().then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          dbRef.child(key).remove();
        });
      }
    });
    for (approver in approvers) {
      await dbRef.push().set({
        'empKey': key,
        'guid': approver.guid,
      });
    }
  });
}

fetchApprovers() async {
  final dbRef = FirebaseDatabase.instance.ref().child('Approver');
  List<Approver> approvers = [];
  final snapshot = await dbRef.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Approver approverDetails = new Approver();
        approverDetails.setKey(key);
        approverDetails.setEmpKey(value['empKey'] ?? '');
        approverDetails.setGuid(value['guid'] ?? '');
        approvers.add(approverDetails);
      });
    }
  });
  return approvers;
}

insertNewEmployee(department, email, employeeID, employeeName, guid,
    imageString, userType, approver, approverName, absences, _isChecked) {
  final databaseReference = FirebaseDatabase.instance.ref().child('Employee');

  databaseReference.push().set({
    'department': department,
    'email': email,
    'employeeID': employeeID,
    'employeeName': employeeName,
    'guid': guid,
    'imageString': imageString,
    'usertype': userType,
    'approver': approver,
    'approverName': approverName,
    'remainingLeaves': absences,
    'isWfh': _isChecked == true ? 'Work from Home' : '',
  }).then((value) => print('success saving'));
}

registerWithEmailAndPassword(String email, String password) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    var result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return 'Account successfully created';
    // Register the user in the Realtime Database
  } catch (e) {
    if (e is FirebaseAuthException) {
      return e.message;
    } else {
      rethrow;
    }
    // Handle error
  }
}

changeCredential(empKey, newEmail, context, choice, password) async {
  var credentials = await read_credentials_pref();
  FirebaseAuth auth = FirebaseAuth.instance;
  final credential = await auth.signInWithEmailAndPassword(
      email: credentials[0], password: credentials[1]);
  var user = await FirebaseAuth.instance.currentUser;

  if (choice == 1 || choice == 3) {
    user?.updateEmail(newEmail).then((_) async {
      final databaseReference =
          FirebaseDatabase.instance.ref().child('Employee/' + empKey);
      await databaseReference.update({
        'email': newEmail,
      });

      if (choice == 3) {
        changePass(password, context, credentials);
        await save_credentials_pref(newEmail, password);
        success_box(context, "Successfully updated email and password");
      } else {
        await save_credentials_pref(newEmail, credentials[1]);
        success_box(context, "Successfully updated email");
      }
    }).catchError((error) {
      warning_box(context, "Error updating email: $error");
    });
  } else {
    changePass(password, context, credentials);
    await save_credentials_pref(credentials[0], password);
    success_box(context, "Successfully updated password");
  }
}

changePass(password, context, credentials) async {
  var user = await FirebaseAuth.instance.currentUser;
  user?.updatePassword(password).then((_) async {}).catchError((error) {
    warning_box(context, "Error updating password: $error");
  });
}

insertAttendance(iswfh, context, Employees emp) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs');
  DateTime today = DateTime.now();
  int timestamp = today.millisecondsSinceEpoch;
  databaseReference.push().set({
    'dateTimeIn': timestamp,
    'department': emp.dept,
    'employeeID': emp.empId,
    'employeeName': emp.empName,
    'guid': emp.guid,
    'timeIn': timestamp,
    'userType': emp.usrType,
    'isWfh': iswfh.toString(),
  });
  return 'Successfully timed in at: ' +
      timestampToDateString(timestamp, 'hh:mm a');
}

updateTimeOut(key) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('Logs/' + key);
  DateTime today = DateTime.now();
  int timestamp = today.millisecondsSinceEpoch;

  await databaseReference.update({
    'timeOut': timestamp,
  });

  return timestampToDateString(timestamp, 'hh:mm a');
}

updateAttendance(guid, context, isTimeIn, Employees emp) async {
  List<Attendance>? logs = await fetchAttendance();
  List<Attendance>? newLogs = [];
  newLogs = sortList(logs!
      .where((element) =>
          (element.guID == guid) ||
          (element.empName == guid) ||
          (element.empId == guid))
      .toList());
  var result;
  //result = newLogs![0].getKey;
  if (newLogs!.length > 0) {
    if (isTimeIn == true) {
      if (newLogs[0].timeOut != 'No Data') {
        String message = await insertAttendance(context, 'No', emp);
        success_box(context, message);
      } else {
        if (getDateDiff(newLogs[0].dateIn.toString() +
            ' ' +
            newLogs[0].timeIn.toString())) {
          warning_box(context, 'Please time out first.');
        } else {
          String message = await insertAttendance(context, 'No', emp);
          success_box(context, message);
        }
      }
    } else {
      if (newLogs[0].timeOut == 'No Data') {
        var resultKey = newLogs[0].getKey;
        var timeToday = await updateTimeOut(resultKey);
        success_box(context, 'Successfully timed out: ' + timeToday);
      } else {
        error_box(
            context, 'Already timed out: ' + newLogs[0].timeOut.toString());
      }
    }
  } else {
    String message = await insertAttendance(context, 'No', emp);
    success_box(context, message);
  }
  return result;
}
