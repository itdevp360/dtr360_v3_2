import 'package:dtr360_version3_2/view/widgets/fileUploadWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:file_picker/file_picker.dart';

import '../../../utils/utilities.dart';

class leaveWidget extends StatefulWidget {
  const leaveWidget({super.key});

  @override
  State<leaveWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<leaveWidget> {
  int remainingLeave = 5;
  String? selectedLeaveType;
  bool isChecked = false;
  TextEditingController reason = new TextEditingController();
  TextEditingController noOfDays = new TextEditingController();
  List<String> leaveTypes = [
    'Vacation',
    'Sick Leave',
    'Maternity Leave',
    'Paternity Leave'
  ];

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
          Text('Remaining Leaves: $remainingLeave',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          TextField(
            keyboardType: TextInputType.none,
            decoration: const InputDecoration(labelText: 'Date'),
            onTap: () => _selectDate(context),
            controller: TextEditingController(text: formatDate(startDate)),
          ),
          DropdownButtonFormField<String>(
            value: selectedLeaveType,
            decoration: const InputDecoration(
              labelText: 'Leave Type',
            ),
            onChanged: (newValue) {
              setState(() {
                selectedLeaveType = newValue as String?;
              });
            },
            items: leaveTypes.map((leaveType) {
              return DropdownMenuItem<String>(
                value: leaveType,
                child: Text(leaveType),
              );
            }).toList(),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Reason'),
            controller: reason,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'No. of days'),
            controller: noOfDays,
          ),
          Row( children: [
            Checkbox(value: isChecked, onChanged: (bool? value){
              setState(() {
                isChecked = value!;
              });
            }),
            const Text('Deduct on leave credits', style: TextStyle(fontSize: 16),)
          ],),
          FilePickerWidget(),
          
          
        ],
      ),
    ),
    ); 
  }
}
