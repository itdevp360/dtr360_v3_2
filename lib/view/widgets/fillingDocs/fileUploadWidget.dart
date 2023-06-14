import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/leaveDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/file_utilities.dart';
import '../../../utils/firebase_functions.dart';

class FilePickerWidget extends StatefulWidget {
  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _fileName;
  String? _fileType;
  FilePickerResult? _fileResult;
  String? _resultFilePath;

  void _openFilePicker() async {
    _fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Specify the file types you want to allow
      allowedExtensions: ['pdf', 'doc', 'xls'],
    );

    if (_fileResult != null) {
      setState(() {
        _resultFilePath = _fileResult?.files.single.path;
        _fileName = _fileResult?.files.first.name;
        _fileType = _fileResult?.files.first.extension;
      });
    }
  }

  void runFile() async {
    final parentData = LeaveDataWidget.of(context)?.dataModel;
    var test = fetchFile('16yfuIyvJqjom8etz-TFSMK2XqafYY4p0');
    final fileName = await uploadToDrive(_resultFilePath!);
    parentData?.docType = 'Leave';
    parentData?.fileId = fileName[0];
    parentData?.attachmentName = fileName[1];
    //
    //Save document file to firebase
    fileDocument(parentData!, context);
  }

  @override
  Widget build(BuildContext context) {
    final parentData = LeaveDataWidget.of(context)?.dataModel;
    return Column(
      children: [
        parentData!.leaveType == 'Sick Leave'
            ? TextButton.icon(
                icon: const Icon(
                  Icons.save_alt_outlined,
                  color: Colors.black,
                ),
                onPressed: _openFilePicker,
                label: const Text(
                  'Browse',
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
              )
            : SizedBox(height: 16),
        parentData!.leaveType == 'Sick Leave'
            ? Text('Selected File: $_fileName')
            : SizedBox(height: 16),
        SizedBox(height: 16),
        Container(
          height: 6.h,
          width: 80.w,
          decoration: BoxDecoration(
              color: Colors.orange, borderRadius: BorderRadius.circular(20)),
          child: TextButton.icon(
            icon: const Icon(
              Icons.file_copy,
              color: Colors.white,
            ),
            onPressed: runFile,
            label: const Text(
              'Submit',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
        )
      ],
    );
  }
}
