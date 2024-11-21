
import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/model/holidays.dart';
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
        logs.dateTimeIn = timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        logs.userType = value['userType'].toString();
        logs.iswfh = value['isWfh'].toString();
        if (isEmployeeExist(logs.getGuid, documents) && value['userType'].toString() != 'Former Employee') {
          _listKeys.add(logs);
        }
      });
    }
  });

  return _listKeys;
}

fileLeave(key, filingDocKey, context, empKey, noOfDays, approverName) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs/' + key);
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
    if (values != null && values.containsKey('remainingLeaves') && noOfDays != '' && noOfDays != null) {
      // double? remainingLeave = double.tryParse(values['remainingLeaves']);
      var remainingLeavesValue = values['remainingLeaves'];
      double remainingLeave;
      if (remainingLeavesValue is double) {
        // If it's already a double, no need to parse
        remainingLeave = remainingLeavesValue;
      }
      else if(remainingLeavesValue is int){
        remainingLeave = remainingLeavesValue.toDouble();
      }
       else if (remainingLeavesValue is String) {
        // If it's a string, parse it to double
        remainingLeave = double.tryParse(remainingLeavesValue) ?? 0.0; // Default to 0.0 if parsing fails
      } else {
        // Handle other cases if necessary
        remainingLeave = 0.0; // Default value or handle as needed
      }
      remainingLeave = remainingLeave! - double.parse(noOfDays);
      await ref.update({
        'remainingLeaves': remainingLeave,
      });
    }
  }
}

fileOvertime(key, filingDocKey, context, otType, hoursNo, empKey, approverName) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs/' + key);
  await databaseReference.update({'otType': otType, 'hoursNo': hoursNo, 'isOt': true}).then((value) async {
    await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
  });
}

attendanceCorrection(key, date, time, isOut, filingDocKey, context, empKey, approverName, correctBothTime) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs/' + key);
  String dateTimeString = '$date $time';
  DateTime selectedDate = DateFormat("MM/dd/yyyy").parse(date);
  DateFormat dateFormat = DateFormat('MM/dd/yyyy HH:mm');
  DateTime selectedCorrectBothTime = (correctBothTime != null && correctBothTime != '')
    ? DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateFormat("HH:mm").parse(correctBothTime).hour,
        DateFormat("HH:mm").parse(correctBothTime).minute,
      )
    : DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
  DateTime dateTime = dateFormat.parse(dateTimeString);
  int unixBothTime = selectedCorrectBothTime.millisecondsSinceEpoch;
  int unixTimestamp = dateTime.millisecondsSinceEpoch;
  if (isOut  && correctBothTime == "") {
    await databaseReference.update({
      'timeOut': unixTimestamp,
    }).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  }
  else if(isOut && correctBothTime != ""){
    await databaseReference.update({
      'timeIn': unixTimestamp,
      'timeOut': unixBothTime,
    }).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  }
  else {
    await databaseReference.update({
      'timeIn': unixTimestamp,
    }).then((value) async {
      await updateFilingDocStatus(filingDocKey, context, empKey, approverName);
    });
  }
}

updateFilingDocStatus(key, context, empKey, approverName) async {
  String today = DateTime.now().toString();
  final databaseReference = FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference.update({'isApproved': true, 'approveRejectDate': today, 'approveRejectBy': approverName}).then((value) async {
    // await success_box(context, 'Document approved');
  });
}

createAttendance(key, context, empKey, correctDate, correctTime, isOut, approverName, nextDay, correctBothTime) async {
  Employees emp = await fetchEmployeeByKey(empKey);
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs');
  DateTime selectedDate = DateFormat("EEE, MMM d, yyyy").parse(correctDate);
  DateTime selectedTime = DateFormat("HH:mm").parse(correctTime);
  DateTime selectedCorrectBothTime = (correctBothTime != null && correctBothTime != '') 
    ? DateFormat("HH:mm").parse(correctBothTime) 
    : DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0); // Default to 00:00

  DateTime combinedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
  DateTime combinedDateOut = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedCorrectBothTime.hour, selectedCorrectBothTime.minute);
  int timestamp = combinedDate.millisecondsSinceEpoch;
  int nextDayOut = nextDay 
    ? DateTime(
        selectedDate.year, 
        selectedDate.month, 
        selectedDate.day + 1, 
        (correctBothTime != null && correctBothTime != '') 
            ? selectedCorrectBothTime.hour 
            : selectedTime.hour, 
        (correctBothTime != null && correctBothTime != '') 
            ? selectedCorrectBothTime.minute 
            : selectedTime.minute
      ).millisecondsSinceEpoch 
    : (correctBothTime == "" ? combinedDate.millisecondsSinceEpoch : combinedDateOut.millisecondsSinceEpoch);
  if (isOut && correctBothTime == "") {
    databaseReference.push().set({
      'dateTimeIn': timestamp,
      'department': emp.dept,
      'employeeID': emp.empId,
      'employeeName': emp.empName,
      'guid': emp.guid,
      'timeOut': nextDayOut,
      'userType': emp.usrType,
      'isWfh': false,
    }).then(
      (value) async {
        await updateFilingDocStatus(key, context, empKey, approverName);
      },
    );
  }
  else if(isOut && correctBothTime != ""){
    databaseReference.push().set({
      'dateTimeIn': timestamp,
      'department': emp.dept,
      'employeeID': emp.empId,
      'employeeName': emp.empName,
      'guid': emp.guid,
      'timeIn': timestamp,
      'timeOut': nextDayOut,
      'userType': emp.usrType,
      'isWfh': false,
    }).then(
      (value) async {
        await updateFilingDocStatus(key, context, empKey, approverName);
      },
    );
  }
   else {
    databaseReference.push().set({
      'dateTimeIn': timestamp,
      'department': emp.dept,
      'employeeID': emp.empId,
      'employeeName': emp.empName,
      'guid': emp.guid,
      'timeIn': timestamp,
      'userType': emp.usrType,
      'isWfh': false,
    }).then(
      (value) async{
        await updateFilingDocStatus(key, context, empKey, approverName);
      },
    );
  }
}

cancelFilingStatus(key) async {
  String today = DateTime.now().toString();
  final databaseReference = FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference.update({'isCancelled': true, 'cancellationDate': today}).then((value) async {
    // await success_box(context, 'Document approved');
    var empData = databaseReference.get().then((snapshot) {
      if(snapshot.exists){
        Map<dynamic,dynamic>? values = snapshot.value as Map?;
        var docType = values?['docType'] ?? '';
        var isApproved = values?['docType'] ?? '';
        var deductLeave = values?['deductLeave'] ?? false;
        int noOfDays = int.tryParse(values?['noOfDay']) ?? 0;
        var empKey = values?['empKey'] ?? '';
        if(docType == 'Leave' && deductLeave && isApproved){
          final empDbref = FirebaseDatabase.instance.ref().child('Employee/' + empKey);
          empDbref.get().then((snapshot) async{
            if(snapshot.key != null){
              Map<dynamic,dynamic>? empData = snapshot.value as Map?;

              //Revised
              if (empData != null) {
                // Access 'remainingLeaves' from empData with null safety operator
                dynamic remainingLeaves = empData['remainingLeaves'];

                // Check if remainingLeaves is not null and is convertible to double
                if (remainingLeaves != null && remainingLeaves is num) {
                  double currLeave = remainingLeaves.toDouble();
                  double newLeaves = currLeave + noOfDays;
                  await empDbref.update({'remainingLeaves': newLeaves});
                  // Use currLeave variable as needed
                } else {
                  print('Error: remainingLeaves is null or not convertible to double');
                }
              } else {
                print('Error: empData is null');
              }
              //Original code
              // double currLeave = empData?['remainingLeaves'] as double;
              // double newLeaves = currLeave + noOfDays;
              // await empDbref.update({'remainingLeaves': newLeaves});
            }
          });
        }
      }
    },);
  });
}

checkIfValidDate(desiredDate, guid, isOt, timeFrom, timeTo, isOvernightOt, isOut, isValidateDate, isFlexi) async {
  Attendance logs = new Attendance();
  DateTime queryDate = DateTime.parse(desiredDate);
  DateTime dateTimeFrom = DateTime.fromMillisecondsSinceEpoch(timeFrom);
  DateTime dateTimeTo = DateTime.fromMillisecondsSinceEpoch(timeTo);
  String dayOfWeek = getDayOfWeek(dateTimeTo.weekday);
  final empProfile = await read_employeeProfile();
  final holidays = await fetchHolidays();
  int month = queryDate.month;
  int day = queryDate.day;
  int year = queryDate.year;
  int finalTimeFrom = DateTime(year, month, day, dateTimeFrom.hour, dateTimeFrom.minute).millisecondsSinceEpoch;
  int finalTimeTo = DateTime(year, month, dateTimeTo.day, dateTimeTo.hour, dateTimeTo.minute).millisecondsSinceEpoch;
  bool isBeyondTime = false;
  var columnName = !isOvernightOt ? 'dateTimeIn' : 'timeOut';


  var finalValue;
  final int startTimestamp = !isOvernightOt
      ? queryDate.subtract(Duration(hours: queryDate.hour, minutes: queryDate.minute, seconds: queryDate.second)).millisecondsSinceEpoch
      : queryDate.subtract(Duration(days: 1, hours: queryDate.hour, minutes: queryDate.minute, seconds: queryDate.second)).millisecondsSinceEpoch;

  final int endTimestamp =
      queryDate.add(Duration(days: 1)).subtract(Duration(hours: queryDate.hour, minutes: queryDate.minute, seconds: queryDate.second)).millisecondsSinceEpoch;

  final databaseReference =
      await FirebaseDatabase.instance.ref().child('Logs').orderByChild(columnName).startAt(startTimestamp).endAt(endTimestamp).get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        logs.attendanceKey = key.toString();
        logs.employeeID = value['employeeID'] ?? '';
        logs.employeeName = value['employeeName'] ?? '';
        logs.guid = value['guid'] ?? '';
        logs.dateTimeIn = timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = value['timeOut'] != null ? timestampToDateString(value['timeOut'], 'hh:mm a') : '';
        logs.userType = value['usertype'] ?? '';
        // logs.iswfh = value['isWfh'] ?? '';
        if (isOt) {
          FilingDocument dataModel = FilingDocument();
          if (value['timeOut'] != null && guid == logs.getGuid) {
            int timeOut = value['timeOut'];
            DateTime convertedTimeOut = DateTime.fromMillisecondsSinceEpoch(timeOut);
            int timeIn = value['timeIn'];
            DateTime convertedTimeIn = DateTime.fromMillisecondsSinceEpoch(timeIn);
            int desiredTime = DateTime(year, month, day, 18, 00).millisecondsSinceEpoch;
            int finalDay = convertedTimeOut.day > convertedTimeIn.day ? convertedTimeIn.day + 1 : convertedTimeIn.day;
            int finalTimeOut =
                DateTime(convertedTimeOut.year, convertedTimeOut.month, finalDay, convertedTimeOut.hour, convertedTimeOut.minute).millisecondsSinceEpoch;
            var shiftIn = empProfile[12].toString().split(':');
            var shiftOut = empProfile[13].toString().split(':');
            int unixShiftIn = DateTime(year, month, day, int.parse(shiftIn[0]), int.parse(shiftIn[1])).millisecondsSinceEpoch;
            int unixShiftOut = DateTime(year, month, day, int.parse(shiftOut[0]), int.parse(shiftOut[1])).millisecondsSinceEpoch;
            //Final Time from = OT From
            //Final Time Out = Attendance time out
            //Final Time To = OT To
            if (finalTimeFrom < finalTimeOut && finalTimeTo <= finalTimeOut && !isFlexi) {
              if (isOvernightOt && isValidateDate) {

                finalValue = true;
              } 
              else {
                if ((dayOfWeek == 'Monday' && (empProfile[14] == '0')) ||
                    (dayOfWeek == 'Tuesday' && (empProfile[15] == '0')) ||
                    (dayOfWeek == 'Wednesday' && (empProfile[16] == '0')) ||
                    (dayOfWeek == 'Thursday' && (empProfile[17] == '0')) ||
                    (dayOfWeek == 'Friday' && (empProfile[18] == '0')) ||
                    (dayOfWeek == 'Saturday' && (empProfile[19] == '0')) ||
                    (dayOfWeek == 'Sunday' && (empProfile[20] == '0'))) {
                  if (isValidateDate) {
                    finalValue = true;
                  } else {
                    var stringTimeOut = timestampToDateString(timeTo, 'MM/dd/yyyy');
                    finalValue = 'Rest Day';
                    for (var i = 0; i < holidays.length; i++) {
                      if (holidays[i].holidayDate == stringTimeOut) {
                        finalValue = 'Rest Day ' + holidays[i].holidayType;
                      }
                    }
                  }
                } else {
                  if (isValidateDate) {
                    
                    if (((unixShiftOut <= finalTimeFrom || timeFrom < unixShiftIn) && timeOut >= timeTo) || isFlexi == true) {
                      finalValue = true;
                    } else {
                      finalValue = false;
                    }
                  } else {
                    var stringTimeOut = timestampToDateString(timeTo, 'MM/dd/yyyy');
                    finalValue = 'Regular Overtime';
                    for (var i = 0; i < holidays.length; i++) {
                      if (holidays[i].holidayDate == stringTimeOut) {
                        finalValue = holidays[i].holidayType;
                      }
                    }
                  }
                  // isBeyondTime = timeOut >= desiredTime && finalTimeTo >= desiredTime;
                }
              }
            } else {
              if(isValidateDate && isFlexi){
                finalValue = true;
              }
              else{
                if(isFlexi){
                  if ((dayOfWeek == 'Monday' && (empProfile[14] == '0')) ||
                    (dayOfWeek == 'Tuesday' && (empProfile[15] == '0')) ||
                    (dayOfWeek == 'Wednesday' && (empProfile[16] == '0')) ||
                    (dayOfWeek == 'Thursday' && (empProfile[17] == '0')) ||
                    (dayOfWeek == 'Friday' && (empProfile[18] == '0')) ||
                    (dayOfWeek == 'Saturday' && (empProfile[19] == '0')) ||
                    (dayOfWeek == 'Sunday' && (empProfile[20] == '0'))) {

                    var stringTimeOut = timestampToDateString(timeTo, 'MM/dd/yyyy');
                      finalValue = 'Rest Day';
                      for (var i = 0; i < holidays.length; i++) {
                        if (holidays[i].holidayDate == stringTimeOut) {
                          finalValue = 'Rest Day ' + holidays[i].holidayType;
                        }
                      }
                } else {
                  var stringTimeOut = timestampToDateString(timeTo, 'MM/dd/yyyy');
                    finalValue = 'Regular Overtime';
                    for (var i = 0; i < holidays.length; i++) {
                      if (holidays[i].holidayDate == stringTimeOut) {
                        finalValue = holidays[i].holidayType;
                      }
                    }
                  // isBeyondTime = timeOut >= desiredTime && finalTimeTo >= desiredTime;
                }
                }
                else{
                  finalValue = false;
                }
                
              }
            }
          }
        } else {
          if (!isOt) {
            finalValue = true;
          }
        }
      });
    } else {
      if (!isOt) {
        finalValue = true;
      }
      else{
        finalValue = false;
      }
    }
  });

  return finalValue;
}

rejectApplication(key, reason, approverName) async {
  String today = DateTime.now().toString();
  final databaseReference = FirebaseDatabase.instance.ref().child('FilingDocuments/' + key);
  await databaseReference
      .update({'isRejected': true, 'approveRejectDate': today, 'rejectionReason': reason, 'approveRejectBy': approverName}).then((value) async {
    // await success_box(context, 'Document approved');
  });
}

checkIfDuplicate(dateFrom, dateTo, correctDate, otDate, docType, guid, isOut, otFrom) async {
  var isDuplicate = false;
  if (docType == 'Leave') {
    final databaseReference = await FirebaseDatabase.instance.ref().child('FilingDocuments').orderByChild('dateFrom').endAt(dateTo).get().then((snapshot) {
      if (snapshot.exists) {
        DateTime selectedDate = DateTime.parse(dateFrom);
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          var isRejected = value['isRejected'] ?? false;
          var isCancelled = value['isCancelled'] ?? false;

          String dateFromString = value['dateFrom'] == null || value['dateFrom'] == '' ? '' : longformatDate(DateTime.parse(value['dateFrom'])).toString();

          if (value['guid'] == guid && (isCancelled == false && isRejected == false) && dateFromString != '' && value['docType'] == 'Leave') {
            DateTime dateFromData = DateTime.parse(value['dateFrom']);
            DateTime dateFromTo = DateTime.parse(value['dateTo']);
            if (selectedDate.isAfter(dateFromData) && selectedDate.isBefore(dateFromTo.add(Duration(days: 1)))) {
              isDuplicate = true;
            } else if (selectedDate.isAtSameMomentAs(dateFromData)) {
              isDuplicate = true;
            }
          }
        });
      }
    });
  } else if (docType == 'Correction') {
    final databaseReference =
        await FirebaseDatabase.instance.ref().child('FilingDocuments').orderByChild('correctDate').equalTo(correctDate).get().then((snapshot) {
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
            // isDuplicate = true;
          }
        });
      }
    });
  } else {
    final databaseReference = await FirebaseDatabase.instance.ref().child('FilingDocuments').orderByChild('otDate').equalTo(otDate).get().then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          print("OT Dateee: " + value['otDate']);
          var isRejected = value['isRejected'] ?? false;
          //Fetched OT From
          DateTime dateOtFrom = DateTime.fromMillisecondsSinceEpoch(value['otfrom']);
          //Current OT From
          DateTime filedOtFrom = DateTime.fromMillisecondsSinceEpoch(otFrom);
          var isCancelled = value['isCancelled'] ?? false;
          if (value['guid'] == guid && (isCancelled == false && isRejected == false && value['docType'] == 'Overtime' && value['isApproved'] == false) && dateOtFrom.hour == filedOtFrom.hour) {
            isDuplicate = true;
          }
        });
      }
    });
  }

  return isDuplicate;
}

Future<List<Attendance>> fetchLeaves({String? dept, bool? isApprover, bool? isAdmin, String? guid}) async {
  List<FilingDocument> _listKeys = [];
  final logRef = FirebaseDatabase.instance.ref().child('FilingDocuments');
  List<Attendance> dateRange = [];

  List<String> departments = [];
  if (dept != null && dept.isNotEmpty) {
    departments = dept.split('/').map((d) => d.trim()).toList();
  }

  List<DataSnapshot> snapshots = [];

  if (isAdmin ?? false) {
    // Admin gets all logs
    final snapshot = await logRef.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  } else if (isApprover ?? false && departments.isNotEmpty) {
    // Approver gets logs for each specified department
    for (String department in departments) {
      Query query = logRef.orderByChild('dept').equalTo(department);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
    if(departments.length > 1){
      Query query = logRef.orderByChild('dept').equalTo(dept);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
  } else if (guid != null) {
    // Regular user gets logs for a specific guid
    Query query = logRef.orderByChild('guid').equalTo(guid);
    final snapshot = await query.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  } else {
    // If no parameters are provided, fetch all logs
    final snapshot = await logRef.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  }

  for (var snapshot in snapshots) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    if (values != null) {
      values.forEach((key, value) {
        FilingDocument docs = FilingDocument();
        if (value['docType'].toString() == "Leave" && value['isCancelled'] != false) {
          docs.key = key.toString();
          docs.approveRejectBy = value['approveRejectBy'].toString();
          docs.approveRejectDate = value['approveRejectDate'].toString();
          docs.date = value['date'].toString();
          docs.dateFrom = value['dateFrom'].toString();
          docs.dateTo = value['dateTo'].toString();
          docs.docType = value['docType'].toString();
          docs.empKey = value['empKey'].toString();
          docs.employeeName = value['employeeName'].toString();
          docs.guid = value['guid'].toString();
          docs.isAm = value['isAm'];
          docs.isApproved = value['isApproved'];
          docs.isCancelled = value['isCancelled'] ?? false;
          docs.isHalfday = value['isHalfday'] ?? false;
          docs.leaveType = value['leaveType'].toString();
          docs.noOfDay = value['noOfDay'].toString();
          docs.reason = value['reason'].toString();
          docs.uniqueId = value['uniqueId'].toString();
          if (docs.isApproved != false) {
            dateRange += convertDateRange(docs.dateFrom, docs.dateTo, docs.guid, docs.employeeName, docs.dept);
          }
        }
      });
    }
  }

  return dateRange;
}


Future<List<Attendance>> fetchAttendance({String? dept, bool? isApprover, bool? isAdmin, String? guid, bool? isTimeInOut}) async {
  List<Attendance> _listKeys = [];
  final logRef = FirebaseDatabase.instance.ref().child('Logs');

  List<String> departments = [];
  if (dept != null && dept.isNotEmpty) {
    departments = dept.split('/').map((d) => d.trim()).toList();
  }

  List<DataSnapshot> snapshots = [];

  if (isAdmin ?? false) {
    // Admin gets all logs
    final snapshot = await logRef.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  } else if (isApprover ?? false && departments.isNotEmpty) {
    // Approver gets logs for each specified department
    for (String department in departments) {
      Query query = logRef.orderByChild('department').equalTo(department);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
    if(departments.length > 1){
      Query query = logRef.orderByChild('department').equalTo(dept);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
  } else if (guid != null) {
    // Regular user gets logs for a specific guid
    Query query = logRef.orderByChild('guid').equalTo(guid);
    final snapshot = await query.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  } else {
    // If no parameters are provided, fetch all logs
    final snapshot = await logRef.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  }

  for (var snapshot in snapshots) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    if (values != null) {
      values.forEach((key, value) {
        Attendance logs = Attendance();
        logs.attendanceKey = key.toString();
        logs.employeeID = value['employeeID'].toString();
        logs.employeeName = value['employeeName'].toString();
        logs.guid = value['guid'].toString();
        logs.dateTimeIn = timestampToDateString(value['dateTimeIn'], 'MM/dd/yyyy');
        logs.timeIn = timestampToDateString(value['timeIn'], 'hh:mm a');
        logs.timeOut = timestampToDateString(value['timeOut'], 'hh:mm a');
        logs.userType = value['usertype'].toString();
        logs.iswfh = value['isWfh'].toString();
        if (value['usertype'].toString() != 'Former Employee') {
          _listKeys.add(logs);
        }
      });
    }
  }

  if(!isTimeInOut!){
    List<Attendance> additionalLogs = await fetchLeaves(dept: dept, guid: guid, isAdmin: isAdmin, isApprover: isApprover);
    _listKeys += additionalLogs;
  }
  
  
  return _listKeys;
}

fetchHolidays() async {
  List<Holidays> _listKeys = [];
  final holidayRef = FirebaseDatabase.instance.ref().child('Holidays');

  final ss = await holidayRef.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        Holidays logs = Holidays();
        logs.key = key.toString();
        logs.holidayDate = value['holidayDate'].toString();
        logs.holidayType = value['holidayType'].toString();
        _listKeys.add(logs);
      });
    }
  });

  return _listKeys;
}

login_user(context, email, password) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    // save_credentials_pref(email, password)
    //     .then((value) => Navigator.pushReplacementNamed(context, 'Home'));

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

Future<List<Employees>> fetchAllEmployees(bool isTrue, bool isAttendance, {String? departmentFilter}) async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');

  List<String> departments = [];
  if (departmentFilter != null && departmentFilter.isNotEmpty) {
    departments = departmentFilter.split('/').map((d) => d.trim()).toList();
  }
  
  List<DataSnapshot> snapshots = [];

  if (isTrue && departments.isNotEmpty) {
    // Query for each department and gather results
    for (String department in departments) {
      Query query = ref.orderByChild('department').equalTo(department);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
    if(departments.length > 1){
      Query query = ref.orderByChild('department').equalTo(departmentFilter);
      final snapshot = await query.get();
      if (snapshot.exists) {
        snapshots.add(snapshot);
      }
    }
    
  } else {
    // Fetch all employees if no department filter is provided
    final snapshot = await ref.get();
    if (snapshot.exists) {
      snapshots.add(snapshot);
    }
  }

  for (var snapshot in snapshots) {
    Map<dynamic, dynamic>? values = snapshot.value as Map?;
    if (values != null) {
      values.forEach((key, value) {
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
        emp1.timeIn = value['shiftTimeIn'].toString();
        emp1.timeOut = value['shiftTimeOut'].toString();
        emp1.mon = value['monday'].toString();
        emp1.tues = value['tuesday'].toString();
        emp1.wed = value['wednesday'].toString();
        emp1.thurs = value['thursday'].toString();
        emp1.fri = value['friday'].toString();
        emp1.sat = value['saturday'].toString();
        emp1.sun = value['sunday'].toString();

        if (isAttendance == false) {
          _listKeys.add(emp1);
        } else {
          if (value['usertype'].toString() != 'Former Employee') {
            _listKeys.add(emp1);
          }
        }
      });
    }
  }

  return _listKeys;
}

fetchEmployees({String? emailAdd}) async {
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');
  Query query;
  if(emailAdd != null){
     query = ref.orderByChild('email').equalTo(emailAdd);
  }
  else{
     query = ref;
  }
  
  final snapshot = await query.get().then((snapshot) {
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
        emp.timeIn = value['shiftTimeIn'].toString();
        emp.timeOut = value['shiftTimeOut'].toString();
        emp.mon = value['monday'].toString();
        emp.tues = value['tuesday'].toString();
        emp.wed = value['wednesday'].toString();
        emp.thurs = value['thursday'].toString();
        emp.fri = value['friday'].toString();
        emp.sat = value['saturday'].toString();
        emp.sun = value['sunday'].toString();
        _listKeys.add(emp);
      });
    }
  });
  print('done');
  return _listKeys;
}

fetchEmployeeByKey(empkey) async {
  final ref = FirebaseDatabase.instance.ref().child('Employee/' + empkey);
  Employees emp = Employees();
  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      emp.employeeID = values!['employeeID'].toString();
      emp.department = values['department'].toString();
      emp.employeeName = values['employeeName'].toString();
      emp.setguid = values['guid'].toString();
      emp.usertype = values['usertype'].toString();
    }
  });
  return emp;
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

updateEmployeeDetails(key, department, employeeID, employeeName, isWfh, userType, approver, approverName, absences, approvers) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Employee/' + key);
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
    final snapshot = await dbRef.orderByChild('empKey').equalTo(key).get().then((snapshot) {
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

insertNewEmployee(department, email, employeeID, employeeName, guid, imageString, userType, approver, approverName, absences, _isChecked, approvers) {
  final databaseReference = FirebaseDatabase.instance.ref().child('Employee');
  final DatabaseReference newRef = databaseReference.push();
  var newKey = newRef.key;
  newRef.set({
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
  }).then((value) async {
    final dbRef = FirebaseDatabase.instance.ref().child('Approver');

    for (approver in approvers) {
      await dbRef.push().set({
        'empKey': newKey,
        'guid': approver.guid,
      });
    }
  });
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
  final credential = await auth.signInWithEmailAndPassword(email: credentials[0], password: credentials[1]);
  var user = await FirebaseAuth.instance.currentUser;

  if (choice == 1 || choice == 3) {
    user?.updateEmail(newEmail).then((_) async {
      final databaseReference = FirebaseDatabase.instance.ref().child('Employee/' + empKey);
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
  return 'Successfully timed in at: ' + timestampToDateString(timestamp, 'hh:mm a');
}

updateTimeOut(key) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('Logs/' + key);
  DateTime today = DateTime.now();
  int timestamp = today.millisecondsSinceEpoch;

  await databaseReference.update({
    'timeOut': timestamp,
  });

  return timestampToDateString(timestamp, 'hh:mm a');
}

updateAttendance(guid, context, isTimeIn, Employees emp) async {
  List<Attendance>? logs = await fetchAttendance(dept: '', isApprover: false, isAdmin: false, guid : guid, isTimeInOut: true);
  List<Attendance>? newLogs = [];
  newLogs = sortList(logs!.where((element) => (element.guID == guid) || (element.empName == guid) || (element.empId == guid)).toList());
  var result;
  //result = newLogs![0].getKey;
  if (newLogs!.length > 0) {
    if (isTimeIn == true) {
      if (newLogs[0].timeOut != 'No Data') {
        String message = await insertAttendance(context, 'No', emp);
        success_box(context, message);
      } else {
        if (getDateDiff(newLogs[0].dateIn.toString() + ' ' + newLogs[0].timeIn.toString())) {
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
        error_box(context, 'Already timed out: ' + newLogs[0].timeOut.toString());
      }
    }
  } else {
    String message = await insertAttendance(context, 'No', emp);
    success_box(context, message);
  }
  return result;
}

filterDate(documents, dateFilter, selectedValue, currentMonth){
  documents = documents!
    .where((item) {
        String dateToCheck;

        // Determine which date field to use based on the dateFilter
        if (dateFilter == 'Date Filed') {
            dateToCheck = item.date;
        } else if (dateFilter == 'Effectivity Date') {
            dateToCheck = item.dateFrom;
        } else if (dateFilter == 'OT Date') {
            dateToCheck = item.otDate;
        } else {
            // If dateFilter doesn't match any expected value, return false to exclude this item
            return false;
        }

        // Apply the filter based on the selectedValue and the determined date field
        return item.docType == selectedValue && dateToCheck.contains(currentMonth!);
    })
    .toList();
}
