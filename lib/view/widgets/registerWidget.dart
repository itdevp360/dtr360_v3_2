import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../model/users.dart';
import '../../utils/firebase_functions.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidget();
}

List<String> list = <String>['Admin', 'Employee', 'IT', 'Approver', 'IT/Admin'];

class _RegisterWidget extends State<RegisterWidget> {
  TextEditingController employeeId = TextEditingController();
  TextEditingController employeeName = TextEditingController();
  TextEditingController department = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpass = TextEditingController();
  TextEditingController approver = TextEditingController();
  TextEditingController absences = TextEditingController();

  List<Employees>? approverList;
  Employees selectedApprover = Employees();
  String? approverDropdownValue;

  bool _isChecked = false;
  String dropdownValue = list.first;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      approverList = await fetchApprover();
      sortListAlphabetical(approverList!);
      if (this.mounted) {
        setState(() {
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("DTR360 v3.2.0"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Lottie.asset('assets/json_files/register_icon.json',
                width: 150, height: 150),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                  print(dropdownValue);
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 0,
              bottom: 0,
            ),
            child: TextField(
              controller: employeeId,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                  labelText: 'Employee ID'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              controller: employeeName,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                  border: OutlineInputBorder(),
                  labelText: 'Employee Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              controller: department,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.corporate_fare),
                  border: OutlineInputBorder(),
                  labelText: 'Department'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              controller: email,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  labelText: 'Email Address'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  labelText: 'Password'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              controller: confirmpass,
              obscureText: true,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 10,
              bottom: 0,
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: absences,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                prefixIcon: Icon(Icons.person_remove),
                border: OutlineInputBorder(),
                labelText: 'Absences',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 28.0,
              right: 28.0,
              top: 20,
              bottom: 0,
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: approverDropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
              underline: Container(
                height: 2,
                color: Color.fromARGB(255, 57, 57, 231),
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  approverDropdownValue = value!;
                  selectedApprover = approverList!
                      .where((element) => element.guid == approverDropdownValue)
                      .first;
                  print(selectedApprover.key);
                });
              },
              items: approverList != null
                  ? approverList!.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.guid!,
                        child: Text(e.empName!),
                      );
                    }).toList()
                  : [],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(
                left: 28.0,
                right: 28.0,
                top: 10,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                        print(_isChecked);
                      });
                    },
                  ),
                  Text('Work from Home'),
                ],
              )),
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
                if (employeeId.text != '' &&
                    employeeName.text != '' &&
                    department.text != '' &&
                    email.text != '' &&
                    password.text != '' &&
                    (password.text == confirmpass.text)) {
                  String message = await registerWithEmailAndPassword(
                      email.text, password.text);
                  String guId = generateGUID();
                  String data = await generateQRBase64String(guId);
                  if (message == 'Account successfully created') {
                    insertNewEmployee(
                      department.text,
                      email.text,
                      employeeId.text,
                      employeeName.text,
                      guId,
                      data,
                      dropdownValue,
                      approverDropdownValue,
                      selectedApprover.employeeName,
                      absences.text,
                      _isChecked,
                    );
                    success_box(context, message);
                    department.text = '';
                    email.text = '';
                    employeeId.text = '';
                    employeeName.text = '';
                    department.text = '';
                    password.text = '';
                    confirmpass.text = '';
                    absences.text = '';
                    _isChecked = false;
                  } else {
                    warning_box(context, message);
                  }
                } else {
                  warning_box(context, 'Please fill all the required fields.');
                }

                // Navigator.push(context,
                //     MaterialPageRoute(builder: (_) => const HomePage()));
              },
              label: const Text(
                'Register',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
        ],
      ))),
    );
  }
}
