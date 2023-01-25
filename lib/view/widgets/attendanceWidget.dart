import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AttendanceWidget> {
  List<Attendance>? logs;
  List<Attendance>? ownLogs;
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logs = await fetchAttendance();
      ownLogs = logs!
          .where((log) => log.guID == '8f966bcd-bf64-4574-a607-a4925bbad21a')
          .toList();

      setState(() {
        loaded = true;
      });
    });
  }

  _asyncMethod() async {
    logs = await fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.w,
        height: 78.h,
        child: SingleChildScrollView(
            child: DataTable(
          headingRowHeight: 0,
          dataRowHeight: 5.h,
          columns: [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time In')),
            DataColumn(label: Text('Time Out'))
          ],
          rows: loaded != true
              ? []
              : ownLogs!
                  .map((log) => DataRow(cells: [
                        DataCell(Text(log.empName!)),
                        DataCell(Text(log.timeIn!.toString())),
                        DataCell(Text(log.timeOut!.toString()))
                      ]))
                  .toList(),
        )));
  }
}
