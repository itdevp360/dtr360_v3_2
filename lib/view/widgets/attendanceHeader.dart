import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

class AttendanceHeaderWidget extends StatefulWidget {
  const AttendanceHeaderWidget({super.key});

  @override
  State<AttendanceHeaderWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AttendanceHeaderWidget> {
  bool loaded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.w,
        child: SingleChildScrollView(
            child: DataTable(
          dataRowHeight: 5.h,
          columns: [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time In')),
            DataColumn(label: Text('Time Out'))
          ],
          rows: [],
        )));
  }
}
