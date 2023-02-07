import 'dart:convert';

import 'package:dtr360_version3_2/model/users.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/view/widgets/loaderView.dart';
import 'package:dtr360_version3_2/view/widgets/qrScannerWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';
import '../../utils/firebase_functions.dart';
import '../../utils/utilities.dart';

class qrWidget extends StatefulWidget {
  const qrWidget({super.key});

  @override
  State<qrWidget> createState() => _qrWidgetState();
}

class _qrWidgetState extends State<qrWidget> {
  var credentials, employeeProfile;
  var qrCodeResult;
  var email, qrCode;
  Uint8List? bytes;
  List<Employees> empList = [];
  Employees emp = Employees();
  bool _loaded = false;
  bool _isWfh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if (credentials != null && credentials[0] != '') {
        email = credentials[0] ?? '';
        employeeProfile = await read_employeeProfile();
        empList = await fetchEmployees();
        emp = empList.firstWhere((element) => element.emailAdd == email);
        save_employeeProfile(emp.empName, emp.dept, emp.emailAdd, emp.passW,
            emp.guid, emp.imgStr, emp.usrType, emp.key, emp.empId);
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
          _loaded = true;
          _isWfh = emp.wfh == "null" || emp.wfh == '' ? false : true;
          print(emp.key);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderView(
        child: Container(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                  child: Container(
                      width: 100.w,
                      height: 9.h,
                      child: Column(
                        children: [
                          Text(
                            _loaded
                                ? emp.employeeName.toString()
                                : 'Employee Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.sp),
                          ),
                          Text(
                            _loaded ? emp.department.toString() : 'Department',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.sp),
                          )
                        ],
                      ))),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: Center(
                  child: Container(
                      width: 50.w,
                      height: 22.h,
                      child: _loaded
                          ? imageFromBase64String(emp.imageString.toString())
                          : Image.asset('assets/people360.png'))),
            ),
            Visibility(
                visible: _isWfh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 15.h)),
                    Center(
                      child: SizedBox(
                          width: 20.w,
                          height: 25.w,
                          child: TextButton(
                            onPressed: () async {
                              if (emp.usrType.toString() == 'Employee' ||
                                  emp.usrType.toString() == 'Approver') {
                                await updateAttendance(
                                    emp.guid.toString(), context, true, emp);
                              } else {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRViewExample()),
                                );
                                if (result != null) {
                                  setState(() {
                                    print("GUID " + result.toString());
                                  });
                                }
                                Employees scannedEmp = empList.firstWhere(
                                    (element) => element.guid == result);
                                var newres = await updateAttendance(
                                    result, context, true, scannedEmp);
                              }
                            },
                            child: Image.asset('assets/greenclock.png'),
                          )),
                    ),
                    Center(
                      child: SizedBox(
                        width: 25.w,
                        height: 25.w,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                          width: 20.w,
                          height: 25.w,
                          child: TextButton(
                            onPressed: () async {
                              if (emp.usrType.toString() == 'Employee' ||
                                  emp.usrType.toString() == 'Approver') {
                                await updateAttendance(
                                    emp.guid.toString(), context, false, emp);
                              } else {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRViewExample()),
                                );
                                if (result != null) {
                                  setState(() {});
                                }
                                Employees scannedEmp = empList.firstWhere(
                                    (element) => element.guid == result);
                                var newres = await updateAttendance(
                                    result, context, false, scannedEmp);
                              }
                            },
                            child: Image.asset('assets/redclock.png'),
                          )),
                    ),
                  ],
                ))
          ],
        )),
        showLoader: _loaded == false);
  }
}
