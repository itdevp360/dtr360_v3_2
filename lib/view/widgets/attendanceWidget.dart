import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/model/filingdocument.dart';
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
  List<FilingDocument>? leaves;
  DateTime startDate = DateTime.now().subtract(Duration(days: 15));
  DateTime endDate = DateTime.now();
  List<Employees>? employeeList;
  String? dropdownvalue;
  var employeeProfile;
  bool loaded = false;
  bool isDateSelected = false;
  bool isEmployee = false;
  double screenH = 48.h;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
      employeeProfile = await read_employeeProfile();
      String departmentFilter = employeeProfile[1].toString();
      
      if (employeeProfile[6] == 'Employee') {
        isEmployee = true;
        screenH = 60.h;
        employeeList = await fetchAllEmployees(false, true, departmentFilter: departmentFilter);
        logs = await fetchAttendance(dept: employeeProfile[1], guid: employeeProfile[4]);
      } else if (employeeProfile[6] == 'Approver') {
        employeeList = await fetchAllEmployees(true, true, departmentFilter: departmentFilter);
        logs = await fetchAttendance(dept: employeeProfile[1], isApprover: true);
      } else if (employeeProfile[6] == 'IT/Admin') {
        employeeList = await fetchAllEmployees(false, true, departmentFilter: departmentFilter);
        logs = await fetchAttendance(isAdmin: true);
      }
      // leaves = await fetchLeaves(dept: employeeProfile[1], guid: employeeProfile[4]);
      sortListAlphabetical(employeeList!);
      // logs = await fetchAttendance();
      ownLogs = logs!.where((log) => log.guID == employeeProfile[4]).toList();
      ownLogs = sortList(fetchLatestWeeks(ownLogs!));
      setState(() {
        if(employeeProfile[6] == 'Approver'){
          ownLogs = logs!.where((log) => log.empName == dropdownvalue).toList();
        }
        
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
        isDateSelected = true;
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
        isDateSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderView(
        showLoader: loaded == false,
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
                          // if (isDateSelected == false) {
                          //   ownLogs = sortList(ownLogs!);
                            
                          // } else {
                          //   ownLogs = sortList(getDateRange(
                          //       dropdownvalue, startDate, endDate, ownLogs!));
                          // }
                          ownLogs = sortList(getDateRange(
                                dropdownvalue, startDate, endDate, ownLogs!));
                        });
                      },
                    ))),
                Padding(padding: const EdgeInsets.only(left: 20, right: 20), child: TextField(
                  keyboardType: TextInputType.none,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () => _selectDate(context),
                  controller:
                      TextEditingController(text: formatDate(startDate)),
                ),)  ,  
                Padding(padding: const EdgeInsets.only(left: 20, right: 20), child: TextField(
                  keyboardType: TextInputType.none,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () => _selectEndDate(context),
                  controller: TextEditingController(text: formatDate(endDate)),
                ),)  , 
                
                Container(
                    width: 100.w,
                    child: Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: DataTable(
                          dataRowHeight: 5.h,
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Time In')),
                            DataColumn(label: Text('Time Out'))
                          ],
                          rows: const [],
                        ))),
                Container(
                    width: 100.w,
                    height: screenH,
                    child: SingleChildScrollView(
                        child: DataTable(
                      headingRowHeight: 0,
                      dataRowHeight: 6.h,
                      columns: const [
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
                                  ],
                                  color: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (log.timeIn == 'Leave') {
                                        return Colors.grey.shade300; // Change row color to grey
                                      }
                                      return null; // Use default color
                                    },
                                  ),
                                  ))
                              .toList(),
                    )))
              ],
            )));
  }
}
