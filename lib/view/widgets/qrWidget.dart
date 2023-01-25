import 'dart:convert';

import 'package:dtr360_version3_2/model/users.dart';
import 'package:dtr360_version3_2/view/widgets/loaderView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

import '../../utils/utilities.dart';

class qrWidget extends StatefulWidget {
  const qrWidget({super.key});

  @override
  State<qrWidget> createState() => _qrWidgetState();
}

class _qrWidgetState extends State<qrWidget> {
  var credentials;
  var email, qrCode;
  Uint8List? bytes;
  Employees emp = Employees();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if (credentials != null && credentials[0] != '') {
        email = credentials[0] != null ? credentials[0] : '';
        emp = await fetchEmployees(email);

        setState(() {
          _loaded = true;
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
              padding: EdgeInsets.symmetric(vertical: 10.h),
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
                      height: 24.h,
                      child: _loaded
                          ? imageFromBase64String(emp.imageString.toString())
                          : Image.asset('assets/people360.png'))),
            ),
            Visibility(
                visible: _loaded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 15.h)),
                    Center(
                      child: SizedBox(
                          width: 20.w,
                          height: 25.w,
                          child: TextButton(
                            onPressed: () {
                              print(emp.empName);
                              print(emp.guid);
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
                            onPressed: () {
                              print('right');
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
