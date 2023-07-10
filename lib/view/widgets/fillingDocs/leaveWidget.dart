import 'package:dtr360_version3_2/view/widgets/fillingDocs/fileUploadWidget.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/leaveDataWidget.dart';
import 'package:flutter/material.dart';

import '../../../model/filingdocument.dart';
import '../../../utils/utilities.dart';

class leaveWidget extends StatefulWidget {
  const leaveWidget({super.key});

  @override
  State<leaveWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<leaveWidget> {
  final FilingDocument dataModel = FilingDocument();
  var employeeProfile;
  String? remainingLeave;
  String? selectedLeaveType;
  String? isAm;
  bool isChecked = false;
  bool isHalfday = false;
  TextEditingController reason = new TextEditingController();
  TextEditingController location = new TextEditingController();
  TextEditingController noOfDays = new TextEditingController();
  List<String> leaveTypes = [
    'Vacation',
    'Sick Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Birthday Leave'
  ];
  List<String> amPmList = [
    'AM',
    'PM',
  ];

  @override
  void initState() {
    super.initState();
    //Initialize the Employee Profile during Leave Widget rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      setState(() {
        dataModel.guid = employeeProfile[4] ?? '';
        dataModel.dept = employeeProfile[1] ?? '';
        dataModel.empKey = employeeProfile[7] ?? '';
        dataModel.employeeName = employeeProfile[0] ?? '';
        remainingLeave = employeeProfile[11] ?? 0;
        dataModel.date = startDate.toString();
        dataModel.dateFrom = dateFrom.toString();
        dataModel.dateTo = dateTo.toString();
      });
    });
  }

  void resetFields(){
    setState(() {
      reason.text = '';
      location.text = '';
      noOfDays.text = '';
      isChecked = false;
      isHalfday = false;
      selectedLeaveType = null;
      startDate = DateTime.now();
      dateFrom = DateTime.now();
      dateTo = DateTime.now();
      dataModel.date = startDate.toString();
      dataModel.dateFrom = dateFrom.toString();
      dataModel.dateTo = dateTo.toString();
    });
  }

  DateTime startDate = DateTime.now();
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
        dataModel.date = startDate.toString();
      });
    }
  }

  DateTime dateFrom = DateTime.now();
  Future<void> _dateFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFrom,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateFrom) {
      setState(() {
        dateFrom = picked;
        dataModel.dateFrom = dateFrom.toString();
      });
    }
  }

  DateTime dateTo = DateTime.now();
  Future<void> _dateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTo,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateTo) {
      setState(() {
        dateTo = picked;
        dataModel.dateTo = dateTo.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Application for Leave',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Remaining Leaves: $remainingLeave',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            TextField(
              keyboardType: TextInputType.none,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date of Filing'),
              controller: TextEditingController(text: formatDate(startDate)),
            ),
            TextField(
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(labelText: 'Date from'),
              onTap: () => _dateFrom(context),
              controller: TextEditingController(text: formatDate(dateFrom)),
            ),
            TextField(
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(labelText: 'Date to'),
              onTap: () => _dateTo(context),
              controller: TextEditingController(text: formatDate(dateTo)),
            ),
            DropdownButtonFormField<String>(
              value: selectedLeaveType,
              decoration: const InputDecoration(
                labelText: 'Leave Type',
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedLeaveType = newValue as String?;
                  dataModel.leaveType = newValue as String;
                });
              },
              items: leaveTypes.map((leaveType) {
                return DropdownMenuItem<String>(
                  value: leaveType,
                  child: Text(leaveType),
                );
              }).toList(),
            ),
            dataModel!.leaveType == 'Vacation'
            ? TextField(
              decoration: const InputDecoration(labelText: 'Location'),
              controller: location,
              onChanged: (value) {
                setState(() {
                  dataModel.location = value;
                });
              },
            ): SizedBox(height: 0),
            TextField(
              decoration: const InputDecoration(labelText: 'Reason'),
              controller: reason,
              onChanged: (value) {
                setState(() {
                  dataModel.reason = value;
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    }),
                const Text(
                  'Deduct on leave credits',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
            isChecked ? TextField(
              decoration: const InputDecoration(labelText: 'No. of days'),
              controller: noOfDays,
              onChanged: (value) {
                setState(() {
                  dataModel.noOfDay = value;
                });
              },
            ): SizedBox(height: 0),
             Row(
              children: [
                Checkbox(
                    value: isHalfday,
                    onChanged: (bool? value) {
                      setState(() {
                        isHalfday = value!;
                        dataModel.isHalfday = isHalfday;
                      });
                    }),
                const Text(
                  'Half day leave',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
            isHalfday ? DropdownButtonFormField<String>(
              value: isAm,
              decoration: const InputDecoration(
                labelText: 'AM/PM',
              ),
              onChanged: (newValue) {
                setState(() {
                
                  isAm = newValue as String;
                  dataModel.isAm = isAm == 'AM' ? true : false;
                });
              },
              items: amPmList.map((leaveType) {
                return DropdownMenuItem<String>(
                  value: leaveType,
                  child: Text(leaveType),
                );
              }).toList(),
            ): SizedBox(height: 0),
            LeaveDataWidget(dataModel: dataModel, child: FilePickerWidget(resetFields)),
          ],
        ),
      ),
    );
  }
}
