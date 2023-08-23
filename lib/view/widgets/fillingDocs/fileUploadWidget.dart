import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/leaveDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/fileDocuments_functions.dart';
import '../../../utils/file_utilities.dart';
import '../../../utils/firebase_functions.dart';
import '../../../utils/utilities.dart';

class FilePickerWidget extends StatefulWidget {
  final VoidCallback resetCallback;
  FilePickerWidget(this.resetCallback);

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
    if (parentData!.reason != '' && parentData.leaveType != '') {
      var test = fetchFile('16yfuIyvJqjom8etz-TFSMK2XqafYY4p0');
      // List<String> fileName = [];
      if (_resultFilePath != null) {
        final fileName = await uploadToDrive(_resultFilePath!);
        parentData?.fileId = fileName[0];
        parentData?.attachmentName = fileName[1];
      }

      parentData?.docType = 'Leave';
      parentData?.date = (parentData?.date == '' ? DateTime.now().toString() : parentData?.date)!;
      // parentData?.finalDate = convertStringDateToUnix(parentData.date, parentData.correctTime, 'Leave');

      //
      //Save document file to firebase
      var isDupe = await checkIfDuplicate(parentData.dateFrom, parentData.dateTo, parentData.correctDate, parentData.otDate, parentData.docType,
          parentData.guid, parentData.isOut, parentData.otfrom);
      if (isDateFromBeforeDateTo(parentData.dateFrom, parentData.dateTo)) {
        if (!isDupe) {
          await fileDocument(parentData!, context);
          parentData.resetProperties();
          widget.resetCallback();
        } else {
          warning_box(context, 'There is already an application on this date');
        }
      } else {
        warning_box(context, 'Date From should not be greater than Date To');
      }
    } else {
      warning_box(context, 'Please complete the fields.');
    }
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
        parentData!.leaveType == 'Sick Leave' ? Text('Selected File: $_fileName') : SizedBox(height: 16),
        SizedBox(height: 16),
        Container(
          height: 6.h,
          width: 80.w,
          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
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
