import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/firebase_functions.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/fileDocuments_functions.dart';
import '../loaderView.dart';

class DocumentStatusWidget extends StatefulWidget {
  const DocumentStatusWidget({super.key});

  @override
  State<DocumentStatusWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DocumentStatusWidget> {
  List<FilingDocument>? documents;
  bool loaded = false;
  double screenH = 48.h;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Documents Status"),
          backgroundColor: Colors.redAccent,
        ),
        body: Column(
          children: [
            Flexible(
                child: FutureBuilder(
              future: fetchEmployeeDocument(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  documents = snapshot.data! as List<FilingDocument>?;
                  return ListView.builder(
                    itemCount: documents!.length,
                    itemBuilder: (context, index) {
                      final document = documents![index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    Text('Application for ' + document.docType),
                                content: Builder(
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Text('Department: ' +
                                                  document.dept)
                                            ]),
                                            Row(children: [
                                              Text('Date filed: ' +
                                                  document.date)
                                            ]),
                                            if (document.docType == 'Leave')
                                              Row(children: [
                                                Text('Date from: ' +
                                                    document.dateFrom)
                                              ]),
                                            if (document.docType == 'Leave')
                                              Row(children: [
                                                Text('Date to: ' +
                                                    document.dateTo)
                                              ]),
                                            if (document.docType == 'Leave')
                                              Row(children: [
                                                Text('Leave Type: ' +
                                                    document.leaveType)
                                              ]),
                                            Row(children: [
                                              Text('Reason: ' + document.reason)
                                            ]),
                                            Row(children: [
                                              Text('Status: ' +
                                                  (document.isApproved
                                                      ? 'Approved'
                                                      : 'Pending'))
                                            ]),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Ok'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text('Application for ' + document.docType),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Date filed: ' + document.date)
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Status: ' +
                                      (document.isApproved
                                          ? 'Approved'
                                          : 'Pending'))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
            ))
          ],
        ));
  }
}
