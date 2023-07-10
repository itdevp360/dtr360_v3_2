import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/attendance.dart';
import '../model/filingdocument.dart';
import 'firebase_functions.dart';

fileDocument(FilingDocument file, context) {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('FilingDocuments');

  databaseReference.push().set({
    'guid': file.guid,
    'docType': file.docType,
    'date': file.date,
    'dateFrom': file.dateFrom,
    'dateTo': file.dateTo,
    'reason': file.reason,
    'leaveType': file.leaveType,
    'noOfDay': file.noOfDay,
    'deductLeave': file.deductLeave,
    'attachmentName': file.attachmentName,
    'fileId': file.fileId,
    'isOut': file.isOut,
    'correctTime': file.correctTime,
    'hoursNo': file.hoursNo,
    'isApproved': file.isApproved,
    'notifyStatus': file.notifyStatus,
    'finalDate': file.finalDate,
    'employeeName': file.employeeName,
    'otfrom': file.otfrom,
    'isAm': file.isAm,
    'isHalfday': file.isHalfday,
    'otTo': file.otTo,
    'otType': file.otType,
    'dept': file.dept,
    'location': file.location,
    'otDate' : file.otDate,
    'correctDate' : file.correctDate,
    'empKey': file.empKey
  }).then((value) => success_box(
      context, 'Your application for ${file.docType} has been filed'));
}

updateFilingDocs(selectedItems, documents, context) async {
  List<Attendance> attendance =
      await fetchSelectedEmployeesAttendance(documents);
  if (selectedItems.isNotEmpty) {
    for (var i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i] != false) {
        print(documents![i].employeeName);
        print(documents![i].docType);
        print(documents![i].date);
        
        if (documents![i].docType == 'Correction') {
          var selectedData = attendance
            .where((element) => element.getDateIn == documents![i].correctDate)
            .toList();
          selectedData.isEmpty
              ? await updateFilingDocStatus(
                  documents[i].key, context, documents[i].empKey)
              : await attendanceCorrection(
                  selectedData[0].getKey,
                  selectedData[0].getDateIn,
                  documents[i].correctTime,
                  documents[i].isOut,
                  documents[i].key,
                  context,
                  documents[i].empKey);
        } else if (documents![i].docType == 'Leave') {
          var selectedData = attendance
            .where((element) => element.getDateIn == documents![i].date)
            .toList();
          selectedData.isEmpty
              ? await updateRemainingLeaves(
                      documents[i].empKey, documents[i].noOfDay)
                  .then((value) async {
                  await updateFilingDocStatus(
                      documents[i].key, context, documents[i].empKey);
                })
              : await fileLeave(selectedData[0].getKey, documents[i].key,
                  context, documents[i].empKey, documents[i].noOfDay);
        } else {
          var selectedData = attendance
            .where((element) => element.getDateIn == documents![i].otDate)
            .toList();
          selectedData.isEmpty
              ? await updateFilingDocStatus(
                  documents[i].key, context, documents[i].empKey)
              : await fileOvertime(
                  selectedData[0].getKey,
                  documents[i].key,
                  context,
                  documents[i].otType,
                  documents[i].hoursNo,
                  documents[i].empKey);
        }
      }
    }
  }
  return true;
}

fetchEmployeeDocument() async {
  List<FilingDocument> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('FilingDocuments');
  final empProfile = await read_employeeProfile();

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        FilingDocument file = FilingDocument();
        file.key = key.toString();
        file.attachmentName = value['attachmentName'].toString();
        file.dept = value['dept'].toString();
        file.correctTime = value['correctTime'].toString();
        file.docType = value['docType'].toString();
        file.employeeName = value['employeeName'].toString();
        file.date = formatDate(DateTime.parse(value['date'])).toString();
        file.otDate = value['otDate'] == null || value['otDate'] == '' ? '' : formatDate(DateTime.parse(value['otDate'])).toString();
        file.otType = value['otType'] == null || value['otType'] == '' ? '' : value['otType'].toString();
        file.otfrom = value['otfrom'] is String ? int.tryParse(value['otfrom']) ?? 0 : value['otfrom'] ?? 0;
        file.otTo = value['otTo'] is String ? int.tryParse(value['otTo']) ?? 0 : value['otTo'] ?? 0;
        
        file.correctDate = value['correctDate'] == null || value['correctDate'] == '' ? '' : formatDate(DateTime.parse(value['correctDate'])).toString();
        file.deductLeave = value['deductLeave'];
        file.guid = value['guid'].toString();
        file.location = value['location'].toString();
        file.hoursNo = value['hoursNo'].toString();
        file.isApproved = value['isApproved'];
        file.isAm = value['isAm'] == null || value['isAm'] == ''
            ? false
            : true;
        file.isHalfday = value['isHalfday'] == null || value['isHalfday'] == ''
            ? false
            : true;
        file.isOut = value['isOut'];
        file.leaveType = value['leaveType'].toString();
        file.noOfDay = value['noOfDay'].toString();
        file.notifyStatus = value['notifyStatus'].toString();
        file.empKey = value['empKey'].toString();
        file.reason = value['reason'].toString();
        file.dateFrom = value['dateFrom'] == null || value['dateFrom'] == ''
            ? ''
            : formatDate(DateTime.parse(value['dateFrom'])).toString();
        file.dateTo = value['dateTo'] == null || value['dateTo'] == ''
            ? ''
            : formatDate(DateTime.parse(value['dateTo'])).toString();
        if (file.guid == empProfile[4]) {
          _listKeys.add(file);
        }
        else if(empProfile[6] == 'Approver' && empProfile[1].toString().contains(file.dept)){
          _listKeys.add(file);
        }
      });
    }
  });
  return _listKeys;
}

fetchFilingDocuments() async {
  List<FilingDocument> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('FilingDocuments');
  final empProfile = await read_employeeProfile();

  final snapshot = await ref.get().then((snapshot) {
    if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      values!.forEach((key, value) {
        FilingDocument file = FilingDocument();
        file.key = key.toString();
        file.attachmentName = value['attachmentName'].toString();
        file.dept = value['dept'].toString();
        file.correctTime = value['correctTime'].toString();
        file.docType = value['docType'].toString();
        file.employeeName = value['employeeName'].toString();
        file.date = formatDate(DateTime.parse(value['date'])).toString();
        file.otDate = value['otDate'] == null || value['otDate'] == '' ? '' : formatDate(DateTime.parse(value['otDate'])).toString();
        file.otType = value['otType'] == null || value['otType'] == '' ? '' : value['otType'].toString();
        file.otfrom = value['otfrom'] is String ? int.tryParse(value['otfrom']) ?? 0 : value['otfrom'] ?? 0;
        file.otTo = value['otTo'] is String ? int.tryParse(value['otTo']) ?? 0 : value['otTo'] ?? 0;
        file.correctDate = value['correctDate'] == null || value['correctDate'] == '' ? '' : formatDate(DateTime.parse(value['correctDate'])).toString();
        file.deductLeave = value['deductLeave'];
        file.guid = value['guid'].toString();
        file.location = value['location'].toString();
        file.hoursNo = value['hoursNo'].toString();
        file.isApproved = value['isApproved'];
        file.isAm = value['isAm'] == null || value['isAm'] == ''
            ? false
            : true;
        file.isHalfday = value['isHalfday'] == null || value['isHalfday'] == ''
            ? false
            : true;
        file.isOut = value['isOut'];
        file.leaveType = value['leaveType'].toString();
        file.noOfDay = value['noOfDay'].toString();
        file.notifyStatus = value['notifyStatus'].toString();
        file.empKey = value['empKey'].toString();
        file.reason = value['reason'].toString();
        file.dateFrom = value['dateFrom'] == null || value['dateFrom'] == ''
            ? ''
            : formatDate(DateTime.parse(value['dateFrom'])).toString();
        file.dateTo = value['dateTo'] == null || value['dateTo'] == ''
            ? ''
            : formatDate(DateTime.parse(value['dateTo'])).toString();
        if (file.dept == empProfile[1] && !file.isApproved) {
          _listKeys.add(file);
        }
      });
    }
  });
  return _listKeys;
}
