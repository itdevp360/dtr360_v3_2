import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../model/filingdocument.dart';
import '../../../utils/fileDocuments_functions.dart';
import '../../../utils/firebase_functions.dart';
import '../../../utils/utilities.dart';

class AttendanceCorrection extends StatefulWidget {
  const AttendanceCorrection({super.key});

  @override
  State<AttendanceCorrection> createState() => _AttendanceCorrectionState();
}

class _AttendanceCorrectionState extends State<AttendanceCorrection> {
  final FilingDocument dataModel = FilingDocument();
  String? selectedInOrOut;
  var employeeProfile;
  DateTime startDate = DateTime.now();
  TimeOfDay initialTime = const TimeOfDay(hour: 0, minute: 0);
  TextEditingController reason = TextEditingController();
  List<String> inOrOut = [
    'Time In',
    'Time Out',
  ];

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      dataModel.guid = employeeProfile[4] ?? '';
      dataModel.dept = employeeProfile[1] ?? '';
      dataModel.empKey = employeeProfile[7] ?? '';
      dataModel.employeeName = employeeProfile[0] ?? '';
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null && picked != initialTime) {
      setState(() {
        initialTime = picked;
        dataModel.correctTime = formatTime(initialTime);
      });
    }
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
        dataModel.date = startDate.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Attendance Correction',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<String>(
                value: selectedInOrOut,
                decoration: const InputDecoration(
                  labelText: 'Time In/Out',
                ),
                onChanged: (newValue) {
                  setState(() {
                    selectedInOrOut = newValue;
                    dataModel.isOut = newValue == 'Time In' ? false : true;
                  });
                },
                items: inOrOut.map((dropdownValue) {
                  return DropdownMenuItem<String>(
                    value: dropdownValue,
                    child: Text(dropdownValue),
                  );
                }).toList(),
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () {
                  _selectDate(context);
                },
                controller: TextEditingController(text: formatDate(startDate)),
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Correct Time'),
                onTap: () {
                  _selectTime(context);
                },
                controller:
                    TextEditingController(text: formatTime(initialTime)),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Reason'),
                onChanged: (value) {
                  setState(() {
                    dataModel.reason = value;
                  });
                },
                controller: reason,
              ),
              const SizedBox(height: 40),
              Container(
                height: 6.h,
                width: 80.w,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.file_copy,
                    color: Color.fromARGB(255, 141, 105, 105),
                  ),
                  onPressed: () {
                    dataModel.finalDate = convertStringDateToUnix(
                        dataModel.date, dataModel.correctTime, 'Correction');
                    dataModel.docType = 'Correction';
                    fileDocument(dataModel, context);
                  },
                  label: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
