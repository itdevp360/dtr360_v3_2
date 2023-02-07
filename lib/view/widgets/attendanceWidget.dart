import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/users.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:dtr360_version3_2/utils/firebase_functions.dart';
import 'package:dtr360_version3_2/view/widgets/loaderView.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AttendanceWidget> {
  List<Attendance>? logs;
  List<Attendance>? ownLogs;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<Employees>? employeeList;
  String? dropdownvalue;
  var employeeProfile;
  bool loaded = false;
  bool isDateSelected = false;
  bool isEmployee = false;
  double screenH = 50.h;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logs = await fetchAttendance();
      employeeList = await fetchAllEmployees();
      sortListAlphabetical(employeeList!);
      employeeProfile = await read_employeeProfile();
      ownLogs = logs!.where((log) => log.guID == employeeProfile[4]).toList();
      ownLogs = sortList(fetchLatestWeeks(ownLogs!));
      if (employeeProfile[6] == 'Employee') {
        isEmployee = true;
        screenH = 60.h;
      } else if (employeeProfile[6] == 'Approver') {
        employeeList = employeeList!
            .where((empList) =>
                employeeProfile[1].toString().contains(empList.dept!))
            .toList();
      }

      setState(() {
        loaded = true;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        if (isEmployee) {
          ownLogs = sortList(
              getDateRange(employeeProfile[0], startDate, endDate, logs!));
        } else {
          ownLogs =
              sortList(getDateRange(dropdownvalue, startDate, endDate, logs!));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        if (isEmployee) {
          ownLogs = sortList(
              getDateRange(employeeProfile[0], startDate, endDate, logs!));
        } else {
          ownLogs =
              sortList(getDateRange(dropdownvalue, startDate, endDate, logs!));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderView(
        child: Container(
            width: 100.w,
            child: Column(
              children: [
                Visibility(
                    visible: isEmployee == false,
                    child: Container(
                        child: DropdownButton(
                      value: dropdownvalue,
                      items: employeeList != null
                          ? employeeList?.map((e) {
                              return DropdownMenuItem(
                                value: e.empName!,
                                child: Text(e.empName!),
                              );
                            }).toList()
                          : [],
                      onChanged: (values) {
                        setState(() {
                          dropdownvalue = values as String?;

                          ownLogs = logs!
                              .where((log) => log.empName == dropdownvalue)
                              .toList();
                          if (isDateSelected == false) {
                            ownLogs = sortList(ownLogs!);
                            isDateSelected = true;
                          } else {
                            ownLogs = sortList(getDateRange(
                                dropdownvalue, startDate, endDate, ownLogs!));
                          }
                        });
                      },
                    ))),
                TextField(
                  keyboardType: TextInputType.none,
                  decoration: InputDecoration(labelText: 'Date'),
                  onTap: () => _selectDate(context),
                  controller:
                      TextEditingController(text: formatDate(startDate)),
                ),
                TextField(
                  keyboardType: TextInputType.none,
                  decoration: InputDecoration(labelText: 'Date'),
                  onTap: () => _selectEndDate(context),
                  controller: TextEditingController(text: formatDate(endDate)),
                ),
                Container(
                    width: 100.w,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: DataTable(
                          dataRowHeight: 5.h,
                          columns: [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Time In')),
                            DataColumn(label: Text('Time Out'))
                          ],
                          rows: [],
                        ))),
                Container(
                    width: 100.w,
                    height: screenH,
                    child: SingleChildScrollView(
                        child: DataTable(
                      headingRowHeight: 0,
                      dataRowHeight: 6.h,
                      columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Time In')),
                        DataColumn(label: Text('Time Out'))
                      ],
                      rows: loaded != true
                          ? []
                          : ownLogs!
                              .map((log) => DataRow(cells: [
                                    DataCell(Text(log.dateIn!)),
                                    DataCell(Text(log.timeIn!)),
                                    DataCell(Text(log.timeOut!.toString()))
                                  ]))
                              .toList(),
                    )))
              ],
            )),
        showLoader: loaded == false);
  }
}
