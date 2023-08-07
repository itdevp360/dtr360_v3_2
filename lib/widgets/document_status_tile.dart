import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/cupertino.dart';

import '../model/filingdocument.dart';

class DocumentStatusTileWidget extends StatelessWidget{

  final FilingDocument document;

  DocumentStatusTileWidget({required this.document});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 1, horizontal: 5),
        child: Card(
          child: ListTile(
            leading: Icon(
              document.docType == 'Leave'? Icons.time_to_leave_outlined
              : document.docType == 'Correction' ? Icons.edit_calendar_sharp
              : document.docType == 'Overtime' ? Icons.access_time_rounded
              : Icons.check,
              color: Colors.red,
              size: 30,
            ),
            contentPadding: EdgeInsets.only(
              left: 15, top: 8, bottom: 8, right: 8),
              title: Text('AP No. ' + document.uniqueId),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Application for: ' + document.docType,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    children: [
                       Text('Employee Name: ' + document.employeeName)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Date filed: ' + document.date)
                    ],
                  ),
                  Row(
                    children: [
                      Text('Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text((!document.isCancelled ? (document.isApproved != null && !document.isApproved
                        ? (document.isRejected ? 'Rejected' : 'Pending') : 'Approved') : 'Cancelled'),
                        style: TextStyle(
                          color: !document.isCancelled ? (document.isApproved != null &&
                            !document.isApproved  ? (document.isRejected  ? Colors.red  : Colors.orange)  : Colors.green)  : Colors.grey))
                    ],
                  )
                ],
              ),
              tileColor: Colors.grey[200],
          ),
      ),
    );
  }

}