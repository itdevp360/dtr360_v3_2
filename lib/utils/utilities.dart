
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

save_credentials_pref(
    email, password) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('credentials',
      <String>[email, password]);

}

login_user(context, email,password) async{
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    final credential = await auth.signInWithEmailAndPassword(
    email: email,
    password: password);
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

fetchEmployees(String email) async{
  print(email);
  List<Employees> _listKeys = [];
  final ref = FirebaseDatabase.instance.ref().child('Employee');
  final snapshot = await ref.get().then((snapshot) {
  if (snapshot.exists) {
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
          values!.forEach((key, value) {
            if(value['email'] == email){
              Employees emp = Employees();
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
              _listKeys.add(emp);
            }
        }); 
  }
  });
  print(_listKeys[0].empName);
}