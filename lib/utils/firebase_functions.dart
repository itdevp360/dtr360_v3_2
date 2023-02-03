
import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';


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
        logs.userType = value['usertype'].toString();
        logs.iswfh = value['isWfh'].toString();
        if(value['usertype'].toString() != 'Former Employee'){
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


fetchAllEmployees() async {
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
        if(value['usertype'].toString() != 'Former Employee'){
          _listKeys.add(emp1);
        }
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
        if (value['email'] == email && value['usertype'].toString() != 'Former Employee' ) {
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

updateEmployeeDetails(key, department, employeeID, employeeName, isWfh, userType) async{
  final databaseReference = FirebaseDatabase.instance.ref().child('Employee/' + key);
  await databaseReference.update({
    'department' : department,
    'employeeID' : employeeID,
    'employeeName' : employeeName,
    'usertype' : userType,
    'isWfh' : isWfh == true ? 'Work from Home' : '',
  });
}

insertNewEmployee(department, email, employeeID, employeeName, guid, imageString, userType, _isChecked){
  final databaseReference = FirebaseDatabase.instance.ref().child('Employee');

  databaseReference.push().set({
    'department' : department,
    'email' : email,
    'employeeID' : employeeID,
    'employeeName' : employeeName,
    'guid' : guid,
    'imageString' : imageString,
    'usertype' : userType,
    'isWfh' : _isChecked == true ? 'Work from Home' : '',
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