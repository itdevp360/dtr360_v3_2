import 'package:dtr360_version3_2/view/widgets/attendanceHeader.dart';
import 'package:dtr360_version3_2/view/widgets/attendanceWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sizer/sizer.dart';

/// Example without a datasource
class DataTable2SimpleDemo extends StatelessWidget {
  const DataTable2SimpleDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [AttendanceHeaderWidget(), AttendanceWidget()]),
    );
  }
}
