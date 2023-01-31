import 'package:dtr360_version3_2/view/widgets/attendanceWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sizer/sizer.dart';

/// Example without a datasource
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      child: AttendanceWidget(),
    );
  }
}
