import 'package:dtr360_version3_2/model/codeTable.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/attendance.dart';
import '../model/filingdocument.dart';
import 'firebase_functions.dart';

getRefNumber() async {
  final uniqueIdReference = FirebaseDatabase.instance.ref().child('codeTable');
  List<codeTable> uniqueIds = [];
  int? data = 0;
  try {
    final snapshot = await uniqueIdReference.get().then((snapshot) {
      if (snapshot != null) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        values!.forEach((key, value) {
          codeTable id = new codeTable();
          id.uniqueId = value['uniqueId'] != null ? value['uniqueId'] : '';
          uniqueIds.add(id);
        });
        data = getHighestUniqueId(uniqueIds);
      } else {
        data = 1;
      }
    });

    return data;
  } catch (e) {
    return 1;
  }
}

saveId(uid, docType, context) async {
  final databaseReference = FirebaseDatabase.instance.ref().child('codeTable');
  databaseReference.push().set({'uniqueId': uid}).then((value) =>
      success_box(context, 'Your application for ${docType} has been filed'));
}

fileDocument(FilingDocument file, context) async {
  final databaseReference =
      FirebaseDatabase.instance.ref().child('FilingDocuments');
  DateTime today = DateTime.now();
  int numId = await getRefNumber();
  String numString = (numId.toString().length) > 1
      ? (numId.toString().length) > 2
          ? numId.toString()
          : '0' + numId.toString()
      : '00' + numId.toString();
  String uid = today.year.toString() +
      today.month.toString() +
      today.day.toString() +
      '-' +
      numString;
  databaseReference.push().set({
    'uniqueId': uid,
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
    'otDate': file.otDate,
    'correctDate': file.correctDate,
    'isOvernightOt': file.isOvernightOt,
    'empKey': file.empKey
  }).then((value) => saveId(numId, file.docType, context));
}

rejectAllDocs(selectedItems, documents, context) async {
  String today = DateTime.now().toString();
  for (var i = 0; i < selectedItems.length; i++) {
    if (selectedItems[i] != false) {
      final databaseReference = FirebaseDatabase.instance
          .ref()
          .child('FilingDocuments/' + documents[i].key);
      await databaseReference.update({
        'isRejected': true,
        'approveRejectDate': today,
      }).then((value) async {
        // await success_box(context, 'Document approved');
      });
    }
  }
  return true;
}

updateFilingDocs(selectedItems, documents, context, approverName) async {
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
              .where((element) =>
                  element.getDateIn ==
                  convertDateFormat(documents![i].correctDate))
              .toList();
          selectedData.isEmpty
              ? await createAttendance(
                  documents[i].key, context, documents[i].empKey, documents![i].correctDate, documents[i].correctTime, documents[i].isOut, approverName)
              : await attendanceCorrection(
                  selectedData[0].getKey,
                  selectedData[0].getDateIn,
                  documents[i].correctTime,
                  documents[i].isOut,
                  documents[i].key,
                  context,
                  documents[i].empKey, approverName);
        } else if (documents![i].docType == 'Leave') {
          var selectedData = attendance
              .where((element) => element.getDateIn == documents![i].date)
              .toList();
          selectedData.isEmpty
              ? await updateRemainingLeaves(
                      documents[i].empKey, documents[i].noOfDay)
                  .then((value) async {
                  await updateFilingDocStatus(
                      documents[i].key, context, documents[i].empKey, approverName);
                })
              : await fileLeave(selectedData[0].getKey, documents[i].key,
                  context, documents[i].empKey, documents[i].noOfDay, approverName);
        } else {
          var selectedData = attendance
              .where((element) => element.getDateIn == documents![i].otDate)
              .toList();
          selectedData.isEmpty
              ? await updateFilingDocStatus(
                  documents[i].key, context, documents[i].empKey, approverName)
              : await fileOvertime(
                  selectedData[0].getKey,
                  documents[i].key,
                  context,
                  documents[i].otType,
                  documents[i].hoursNo,
                  documents[i].empKey, approverName);
        }
      }
    }
  }
  return true;
}

//documentStatus widget
fetchEmployeeDocument() async {
  List<FilingDocument> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('FilingDocuments');
  final empProfile = await read_employeeProfile();
  DateTime now = DateTime.now();
  DateTime cutoffStart;
  DateTime cutoffEnd;
  DateTime previousCutoffStart;
  DateTime previousCutoffEnd;

  if (now.day <= 10) {
    cutoffStart = DateTime(now.year, now.month - 1, 25);
    cutoffEnd = DateTime(now.year, now.month, 11);
    previousCutoffStart = DateTime(now.year, now.month - 1, 10);
    previousCutoffEnd = DateTime(now.year, now.month - 1, 26);
  } else {
    cutoffStart = DateTime(now.year, now.month, 10);
    cutoffEnd = DateTime(now.year, now.month, 26);
    previousCutoffStart = DateTime(now.year, now.month - 1, 25);
    previousCutoffEnd = DateTime(now.year, now.month, 11);
  }

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
        file.uniqueId = value['uniqueId'] != null ? value['uniqueId'] : '';
        file.employeeName = value['employeeName'].toString();
        file.date = longformatDate(DateTime.parse(value['date'])).toString();
        file.otDate = value['otDate'] == null || value['otDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['otDate'])).toString();
        file.otType = value['otType'] == null || value['otType'] == ''
            ? ''
            : value['otType'].toString();
        file.otfrom = value['otfrom'] is String
            ? int.tryParse(value['otfrom']) ?? 0
            : value['otfrom'] ?? 0;
        file.otTo = value['otTo'] is String
            ? int.tryParse(value['otTo']) ?? 0
            : value['otTo'] ?? 0;

        file.correctDate = value['correctDate'] == null ||
                value['correctDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['correctDate'])).toString();
        file.deductLeave = value['deductLeave'];
        file.rejectionReason = value['rejectionReason'] ?? '';
        file.cancellationDate =
            value['cancellationDate'] == null || value['cancellationDate'] == ''
                ? ''
                : longformatDate(DateTime.parse(value['cancellationDate']))
                    .toString();
        file.approveRejectDate = value['approveRejectDate'] == null ||
                value['approveRejectDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['approveRejectDate']))
                .toString();
        file.isRejected = value['isRejected'] ?? false;
        file.isOvernightOt = value['isOvernightOt'] ?? false;
        file.guid = value['guid'].toString();
        file.location = value['location'].toString();
        file.hoursNo = value['hoursNo'].toString();
        file.isApproved = value['isApproved'];
        file.isAm = value['isAm'] ?? false;
        file.isCancelled = value['isCancelled'] ?? false;
        file.isHalfday = value['isHalfday'] ?? false;
        file.isOut = value['isOut'];
        file.leaveType = value['leaveType'].toString();
        file.noOfDay = value['noOfDay'].toString();
        file.notifyStatus = value['notifyStatus'].toString();
        file.empKey = value['empKey'].toString();
        file.reason = value['reason'].toString();
        file.approveRejectBy = value['approveRejectBy'].toString();
        file.dateFrom = value['dateFrom'] == null || value['dateFrom'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['dateFrom'])).toString();
        file.dateTo = value['dateTo'] == null || value['dateTo'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['dateTo'])).toString();

        if (empProfile[6] == 'Approver' &&
                empProfile[1].toString().contains(file.dept) &&
                file.isCancelled == false &&
                (parseCustomDate(file.date).isAfter(cutoffStart)) ||
            (parseCustomDate(file.date).isAfter(previousCutoffStart) &&
                parseCustomDate(file.date).isBefore(previousCutoffEnd))) {
          _listKeys.add(file);
        } else if (file.guid == empProfile[4] &&
            ((parseCustomDate(file.date).isAfter(cutoffStart)) ||
                (parseCustomDate(file.date).isAfter(previousCutoffStart) &&
                    parseCustomDate(file.date).isBefore(previousCutoffEnd)))) {
          _listKeys.add(file);
        }
      });
    }
  });
  return _listKeys;
}

//approverScreen
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
        file.uniqueId = value['uniqueId'] != null ? value['uniqueId'] : '';
        file.employeeName = value['employeeName'].toString();
        file.date = longformatDate(DateTime.parse(value['date'])).toString();
        file.otDate = value['otDate'] == null || value['otDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['otDate'])).toString();
        file.otType = value['otType'] == null || value['otType'] == ''
            ? ''
            : value['otType'].toString();
        file.otfrom = value['otfrom'] is String
            ? int.tryParse(value['otfrom']) ?? 0
            : value['otfrom'] ?? 0;
        file.otTo = value['otTo'] is String
            ? int.tryParse(value['otTo']) ?? 0
            : value['otTo'] ?? 0;
        file.correctDate = value['correctDate'] == null ||
                value['correctDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['correctDate'])).toString();
        file.deductLeave = value['deductLeave'];
        file.rejectionReason = value['rejectionReason'] ?? '';
        file.approveRejectDate = value['approveRejectDate'] == null ||
                value['approveRejectDate'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['approveRejectDate']))
                .toString();
        file.cancellationDate =
            value['cancellationDate'] == null || value['cancellationDate'] == ''
                ? ''
                : longformatDate(DateTime.parse(value['cancellationDate']))
                    .toString();
        file.isRejected = value['isRejected'] ?? false;
        file.guid = value['guid'].toString();
        file.location = value['location'].toString();
        file.isOvernightOt = value['isOvernightOt'] ?? false;
        file.hoursNo = value['hoursNo'].toString();
        file.isApproved = value['isApproved'];
        file.isAm = value['isAm'] ?? false;
        file.isCancelled = value['isCancelled'] ?? false;
        file.isHalfday = value['isHalfday'] ?? false;
        file.isOut = value['isOut'];
        file.leaveType = value['leaveType'].toString();
        file.noOfDay = value['noOfDay'].toString();
        file.notifyStatus = value['notifyStatus'].toString();
        file.empKey = value['empKey'].toString();
        file.reason = value['reason'].toString();
        file.dateFrom = value['dateFrom'] == null || value['dateFrom'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['dateFrom'])).toString();
        file.dateTo = value['dateTo'] == null || value['dateTo'] == ''
            ? ''
            : longformatDate(DateTime.parse(value['dateTo'])).toString();
        if (empProfile[1].toString().contains(file.dept) &&
            !file.isApproved &&
            !file.isRejected) {
          _listKeys.add(file);
        }
      });
    }
  });
  return _listKeys;
}
