import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../widgets/fillingDocs/approverDocumentList.dart';

class ApprovalListScreen extends StatelessWidget {
  const ApprovalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiple Select ListView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApproverListWidget(),
    );
  }
}