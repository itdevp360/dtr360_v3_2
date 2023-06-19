import 'package:dtr360_version3_2/view/widgets/fillingDocs/attendanceCorrectionWidget.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/leaveWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class FileDocumentsWidget extends StatefulWidget {
  const FileDocumentsWidget({super.key});

  @override
  State<FileDocumentsWidget> createState() => fileDocumentState();
}

class fileDocumentState extends State<FileDocumentsWidget> {
  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: <Widget>[
        leaveWidget(),
        AttendanceCorrection(),
        Center(
          child: Text("It's sunny here"),
        ),
      ],
    );
  }
}
