import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

import '../../../model/filingdocument.dart';
import '../../../utils/fileDocuments_functions.dart';
import '../../../utils/firebase_functions.dart';
import '../../../utils/utilities.dart';

class OvertimeWidget extends StatefulWidget {
  const OvertimeWidget({super.key});

  @override
  State<OvertimeWidget> createState() => _OvertimeWidgetState();
}

class _OvertimeWidgetState extends State<OvertimeWidget> {
  
  final FilingDocument dataModel = FilingDocument();
  DateTime startDate = DateTime.now();
  var employeeProfile;
  String? selectedOtType;
  TimeOfDay initialTimeFrom = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay initialTimeTo = const TimeOfDay(hour: 0, minute: 0);
  TextEditingController reason = TextEditingController();
  TextEditingController totalHours = TextEditingController();
  List<String> otType = [
    'Regular',
    'Rest Day',
    'Holiday'
  ];

  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      dataModel.guid = employeeProfile[4] ?? '';
      dataModel.dept = employeeProfile[1] ?? '';
      dataModel.employeeName = employeeProfile[0] ?? '';
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
        dataModel.date = startDate.toString();
      });
    }
  }

  Future<void> _selectTimeFrom(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTimeFrom);
    if (picked != null && picked != initialTimeFrom) {
      setState(() {
        initialTimeFrom = picked;
        dataModel.otfrom = convertStringDateToUnix(dataModel.date, formatTime(initialTimeFrom), 'Overtime');
        if(dataModel.otfrom != null && dataModel.otTo != null){
          String totalNoHours = computeTotalHours(dataModel.otfrom, dataModel.otTo);
          totalHours.text = totalNoHours;
          dataModel.hoursNo = totalNoHours;
        }
        
      });
    }
  }

  Future<void> _selectTimeTo(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTimeTo);
    if (picked != null && picked != initialTimeTo) {
      setState(() {
        initialTimeTo = picked;
        dataModel.otTo = convertStringDateToUnix(dataModel.date, formatTime(initialTimeTo), 'Overtime');
        if(dataModel.otfrom != '' && dataModel.otTo != ''){
          String totalNoHours = computeTotalHours(dataModel.otfrom, dataModel.otTo);
          totalHours.text = totalNoHours;
          dataModel.hoursNo = totalNoHours;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Container(
      margin: const EdgeInsets.all(24),
      child: 
      Column(children: [
        const Text('Attendance Correction', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        const SizedBox(height: 20,),
        DropdownButtonFormField<String>(
              value: selectedOtType,
              decoration: const InputDecoration(
                labelText: 'OT Type',
              ),
              onChanged: (newValue) {
                setState(() {
                  selectedOtType = newValue;
                  dataModel.otType = newValue!;
                });
              },
              items: otType.map((dropdownValue) {
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
          decoration: const InputDecoration(labelText: 'From'),
          onTap: () {
            _selectTimeFrom(context);
          },
          controller: TextEditingController(text: formatTime(initialTimeFrom)),
        ),
        TextField(
          keyboardType: TextInputType.none,
          decoration: const InputDecoration(labelText: 'To'),
          onTap: () {
            _selectTimeTo(context);
          },
          controller: TextEditingController(text: formatTime(initialTimeTo)),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Total Hours'),
          onChanged: (value) {
            setState(() {
              dataModel.reason = value;
            });
          },
          controller: totalHours,
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
              color: Colors.orange, borderRadius: BorderRadius.circular(20)),
          child: TextButton.icon(
            icon: const Icon(
              Icons.file_copy,
              color: Color.fromARGB(255, 141, 105, 105),
            ),
            onPressed: () {
              
              dataModel.docType = 'Overtime';
              fileDocument(dataModel, context);
            },
            label: const Text(
              'Submit',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
        )
        

      ],)
      
    ),);
  }
}