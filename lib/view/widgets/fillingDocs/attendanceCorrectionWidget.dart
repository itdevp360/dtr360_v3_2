import 'package:dtr360_version3_2/utils/alertbox.dart';
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
  DateTime correctDate = DateTime.now();
  bool isNextDayTimeOut = false;
  bool isProcessing = false;
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
      TimeOfDay timeOfDay = TimeOfDay(hour: 0, minute: 0);
      String formattedTime = DateFormat.Hm().format(DateTime(2023, 1, 1, timeOfDay.hour, timeOfDay.minute));
      setState(() {
        dataModel.date = startDate.toString();
        dataModel.correctDate = correctDate.toString();
        dataModel.correctTime = formattedTime;
      });
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null && picked != initialTime) {
      setState(() {
        initialTime = picked;
        dataModel.correctTime = formatTime(initialTime);
      });
    }
  }

  Future<void> _correctDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: correctDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != correctDate) {
      setState(() {
        correctDate = picked;
        dataModel.correctDate = correctDate.toString();
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
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Date of Filing'),
                readOnly: true,
                controller: TextEditingController(text: formatDate(startDate)),
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
              dataModel.isOut ? Row(
                children: [
                  Checkbox(
                      value: isNextDayTimeOut,
                      onChanged: (bool? value) {
                        setState(() {
                          isNextDayTimeOut = value!;
                          // dataModel.isFlexi = value!;
                        });
                      }),
                  const Text(
                    'Next day Time Out',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ) : SizedBox(height: 10,),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Correction Date'),
                onTap: () {
                  _correctDate(context);
                },
                controller: TextEditingController(text: formatDate(correctDate)),
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Correct Time'),
                onTap: () {
                  _selectTime(context);
                },
                controller: TextEditingController(text: formatTime(initialTime)),
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
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.file_copy,
                    color: Color.fromARGB(255, 141, 105, 105),
                  ),
                  onPressed: () async {
                    if(isProcessing == false){
                      
                    
                      dataModel.finalDate = convertStringDateToUnix(dataModel.correctDate, dataModel.correctTime, 'Correction', false, dataModel.otfrom);
                      dataModel.docType = 'Correction';
                      var isDupe = await checkIfDuplicate(dataModel.dateFrom, dataModel.dateTo, dataModel.correctDate, dataModel.otDate, dataModel.docType,
                          dataModel.guid, dataModel.isOut, dataModel.otfrom);

                      if (reason.text != '' && selectedInOrOut != '') {
                        bool isValid = await checkIfValidDate(
                            dataModel.correctDate, employeeProfile[4], false, dataModel.otfrom, dataModel.otTo, dataModel.isOvernightOt, dataModel.isOut, true, dataModel.isFlexi);
                        if (isValid) {
                          if (!isDupe) {
                            setState(() {
                              isProcessing = true;
                            });
                            await fileDocument(dataModel, context);
                            setState(() {
                              isProcessing = false;
                              dataModel.resetProperties();
                              reason.text = '';
                              startDate = DateTime.now();
                              correctDate = DateTime.now();
                              dataModel.date = startDate.toString();
                              dataModel.correctDate = correctDate.toString();
                              initialTime = const TimeOfDay(hour: 0, minute: 0);
                              
                            });
                          } else {
                            warning_box(context, 'There is already an application on this date');
                          }
                        } else {
                          warning_box(context, 'Invalid date. No attendance.');
                        }
                      } else {
                        warning_box(context, 'Please complete the fields.');
                      }
                    }
                    else{
                      warning_box(context, 'Request is already in process');
                    }
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
