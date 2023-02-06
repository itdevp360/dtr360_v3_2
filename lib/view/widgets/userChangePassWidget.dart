import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/firebase_functions.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../model/users.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ChangePasswordWidget> {
  var credentials, email, employeeProfile, empKey;
  TextEditingController newEmail = TextEditingController();
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmNewPass = TextEditingController();
  String? dropdownValue;
  String? userTypeDropdown;
  bool loaded = false;
  bool _changeEmail = false;
  bool _changePassword = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if (credentials != null && credentials[0] != '') {
        email = credentials[0] ?? '';
        employeeProfile = await read_employeeProfile();
        // if(employeeProfile != null && employeeProfile[0] != ''){
        //   emp.empName = employeeProfile[0] ?? '';
        //   emp.dept = employeeProfile[1] ?? '';
        //   emp.emailAdd = employeeProfile[2] ?? '';
        //   emp.passW = employeeProfile[3] ?? '';
        //   emp.guid = employeeProfile[4] ?? '';
        //   emp.imgStr = employeeProfile[5] ?? '';
        //   emp.usrType = employeeProfile[6] ?? '';
        // }
        // else{
        //   emp = await fetchEmployees(email);
        //   save_employeeProfile(emp.empName, emp.dept, emp.emailAdd, emp.passW, emp.guid, emp.imgStr, emp.usrType);
        // }

        setState(() {
          loaded = true;
          empKey = employeeProfile[7];
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
                width: 50.w,
                height: 50.w,
                child: Lottie.asset('assets/json_files/security.json')),
          ),
          Padding(
              padding:
                  EdgeInsets.only(left: 18.0, right: 28.0, top: 0, bottom: 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _changeEmail,
                    onChanged: (value) {
                      setState(() {
                        _changeEmail = value!;
                        print(_changeEmail);
                      });
                    },
                  ),
                  Text('Change Email', style: TextStyle(fontSize: 20)),
                ],
              )),
          Visibility(
              visible: _changeEmail == true,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 28.0, right: 28.0, top: 20, bottom: 0),
                child: TextField(
                  controller: newEmail,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      prefixIcon: Icon(Icons.mail),
                      border: OutlineInputBorder(),
                      labelText: 'Enter new Email Address'),
                ),
              )),
          Padding(
              padding:
                  EdgeInsets.only(left: 18.0, right: 28.0, top: 20, bottom: 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _changePassword,
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value!;
                        print(_changePassword);
                      });
                    },
                  ),
                  Text('Change Password', style: TextStyle(fontSize: 20)),
                ],
              )),
          Visibility(
              visible: _changePassword == true,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 28.0, right: 28.0, top: 20, bottom: 0),
                child: TextField(
                  controller: newPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      labelText: 'New Password'),
                ),
              )),
          Visibility(
              visible: _changePassword == true,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 28.0, right: 28.0, top: 20, bottom: 0),
                child: TextField(
                  controller: confirmNewPass,
                  obscureText: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      prefixIcon: Icon(Icons.check),
                      border: OutlineInputBorder(),
                      labelText: 'Confirm New Password'),
                ),
              )),
          Padding(padding: EdgeInsets.only(top: 20)),
          Container(
            height: 6.h,
            width: 80.w,
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(20)),
            child: TextButton.icon(
                icon: Icon(
                  Icons.person_add,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (_changeEmail || _changePassword) {
                    if (_changeEmail && !_changePassword) {
                      if (newEmail.text != '') {
                        await changeCredential(empKey, newEmail.text, context,
                            1, newPassword.text);
                        newEmail.text = '';
                      } else {
                        warning_box(context, 'Please enter a new email.');
                      }
                    } else if (!_changeEmail && _changePassword) {
                      if (newPassword.text != '' &&
                          confirmNewPass.text != '' &&
                          confirmNewPass.text == newPassword.text) {
                        await changeCredential(empKey, newEmail.text, context,
                            2, newPassword.text);
                        newPassword.text = '';
                        confirmNewPass.text = '';
                      } else {
                        warning_box(
                            context, 'Password fields are empty or not match.');
                      }
                    } else {
                      if (newEmail.text != '' &&
                          newPassword.text != '' &&
                          confirmNewPass.text == newPassword.text) {
                        await changeCredential(empKey, newEmail.text, context,
                            3, newPassword.text);
                        newPassword.text = '';
                        confirmNewPass.text = '';
                        newEmail.text = '';
                      } else {
                        warning_box(
                            context, 'Please fill all the empty fields');
                      }
                    }
                  } else {
                    warning_box(context, 'Please select an option');
                  }
                },
                label: Text('Change login access',
                    style: TextStyle(fontSize: 20, color: Colors.white))),
          ),
        ],
      ))),
    );
  }
}
