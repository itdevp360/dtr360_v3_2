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
  var email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if (credentials != null && credentials[0] != '') {
        email = credentials[0] != null ? credentials[0] : '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        "Placeholder Names",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.sp),
                      ),
                      Text(
                        "Placeholder Department",
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
                  width: 40.w,
                  height: 20.h,
                  child: Image.asset('assets/people360.png'))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 15.h)),
            Center(
              child: SizedBox(
                  width: 25.w,
                  height: 25.w,
                  child: TextButton(
                    onPressed: () {
                      print('left');
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
                  width: 25.w,
                  height: 25.w,
                  child: TextButton(
                    onPressed: () {
                      fetchEmployees(email);
                      print('right');
                    },
                    child: Image.asset('assets/redclock.png'),
                  )),
            ),
          ],
        )
      ],
    ));
  }
}
