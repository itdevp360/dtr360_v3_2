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
    'employeeName' : file.employeeName,
    'otfrom': file.otfrom,
    'otTo': file.otTo,
    'otType': file.otType,
    'dept': file.dept
    
  }).then((value) => success_box(
      context, 'Your application for ${file.docType} has been filed'));
}


updateFilingDocs(selectedItems, documents, context) async{
  List<Attendance> attendance = await fetchSelectedEmployeesAttendance(documents);
  if(selectedItems.isNotEmpty){
    for(var i=0; i < selectedItems.length; i++){
      if(selectedItems[i] != false){
        print(documents![i].employeeName);
        print(documents![i].docType);
        print(documents![i].date);
        if(documents![i].docType == 'Correction'){
          var selectedData = attendance.where((element) => element.getDateIn == documents![i].date).toList();
          attendanceCorrection(selectedData[0].getKey, selectedData[0].getDateIn, documents[i].correctTime, documents[i].isOut, documents[i].key, context);
        }
      }
    }
  }
}


fetchFilingDocuments() async{
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
        file.date =  formatDate(DateTime.parse(value['date'])).toString();
        file.deductLeave = value['deductLeave'];
        file.guid = value['guid'].toString();
        file.hoursNo = value['hoursNo'].toString();
        file.isApproved = value['isApproved'];
        file.isOut = value['isOut'];
        file.leaveType = value['leaveType'].toString();
        file.noOfDay = value['noOfDay'].toString();
        file.notifyStatus = value['notifyStatus'];
        file.reason = value['reason'];
        if(file.dept == empProfile[1] && !file.isApproved){
          _listKeys.add(file);
        }
        
      });
    }
  });
  return _listKeys;
}