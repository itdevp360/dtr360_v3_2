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
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<FilingDocument>? documents;
  var employeeProfile;
  bool loaded = false;
  bool isRefresh = false;
  bool isSelected = false;
  double screenH = 48.h;
  String? selectedValue = 'All';

  @override
  void initState() {
    super.initState();
    //Initialize the Employee Profile during Leave Widget rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Color _getColorForDocType(String docType) {
    final Map<String, Color> colorMap = {
      'Leave': Colors.green,
      'Correction': Colors.yellow,
      'Overtime': Colors.red,
    };

    return colorMap[docType] ?? Colors.grey;
  }

  void _showSecondaryAlertDialog(BuildContext context) {
    Future.delayed(Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Builder(builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: Text('Document Approved!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the secondary AlertDialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
        },
      );
    });
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
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  isSelected = true;
                });
              },
              items: <String>[
                'All',
                'Leave',
                'Correction',
                'Overtime',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Flexible(
                child: FutureBuilder(
              future: fetchEmployeeDocument(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  documents = snapshot.data! as List<FilingDocument>?;
                  if(selectedValue != 'All'){
                    documents = documents!
                      .where((item) => item.docType == selectedValue)
                      .toList();
                  }
                  documents = sortDocs(documents!);
                  return ListView.builder(
                    key: _listKey,
                    itemCount: documents!.length,
                    itemBuilder: (context, index) {
                      var document = documents![index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Text('Application for ' + document.docType),
                                  content: Builder(
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Flexible(child: Text(
                                                  'Employee Name: ' +
                                                      document.employeeName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))
                                              
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                            Row(children: [
                                              Flexible(child: Text(
                                                  'Department: ' +
                                                      document.dept,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))                              
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                            Row(children: [
                                              Flexible(child: Text(
                                                  'Date filed: ' +
                                                      document.date,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))             
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                            if(document.isHalfday == true && document.docType == 'Leave')
                                              Column(children: [
                                                Row(children: [
                                                Flexible(child: Text(
                                                    'Halfday: Yes' 
                                                        ,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'AM/PM: ' +
                                                        (document.isAm ? 'AM' : 'PM'),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                              ],),
                                            if (document.docType == 'Leave')
                                              
                                              Column(children: [
                                                Row(children: [
                                                Flexible(child: Text(
                                                    'Date from: ' +
                                                        document.dateFrom,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))   
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Date to: ' +
                                                        document.dateTo,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Leave Type: ' +
                                                        document.leaveType,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                                
                                              ]),
                                              ],),
                                              
                                              Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                            if(document.docType == 'Correction')
                                              Column(children: [
                                                Row(children: [
                                                Flexible(child: Text(
                                                    'Correction Date: ' +
                                                        document.correctDate,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))   
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Correction Time: ' +
                                                        document.correctTime,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Time In/Out: ' +
                                                        (document.isOut == true ? 'Time Out' : 'Time In'),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                                
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              ],),
                                            if(document.docType == 'Overtime')
                                              Column(children: [
                                                Row(children: [
                                                Flexible(child: Text(
                                                    'OT Type: ' +
                                                        document.otType,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))   
                                              ]),
                                                Row(children: [
                                                Flexible(child: Text(
                                                    'OT Date: ' +
                                                        document.otDate,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))   
                                              ]),
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Time from: ' +
                                                        timestampToDateString(document.otfrom, 'hh:mm a'),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              Row(children: [
                                                Flexible(child: Text(
                                                    'Time To: ' +
                                                        timestampToDateString(document.otTo, 'hh:mm a'),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))      
                                              ]),
                                              
                                              Row(children: [
                                                SizedBox(height: 5)                             
                                              ]),
                                              ],),
                                            Row(children: [
                                              Flexible(child: Text('Reason: ' + document.reason,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)))
                                              
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 5)                             
                                            ]),
                                            Row(children: [
                                              Flexible(child: Text(
                                                'Status: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),)
                                              
                                              ),
                                              Text(
                                                (document.isApproved
                                                    ? 'Approved'
                                                    : 'Pending'),
                                                style: TextStyle(
                                                    color: document.isApproved
                                                        ? Colors.green
                                                        : Colors.red),
                                              )
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
                                        child: Text(employeeProfile[6] == 'Approver' ? 'Cancel' : 'Ok')),
                                    employeeProfile[6] == 'Approver' ? TextButton(
                                        onPressed: () async {
                                          isRefresh = false;
                                          print(document.key);
                                          await cancelFilingStatus(document.key);
                                          _listKey.currentState?.setState(() {
                                            
                                          });
                                          setState(() {
                                            isRefresh = true;
                                          });
                                          Navigator.of(context).pop();
                                          _showSecondaryAlertDialog(context);
                                          // await success_box(context, "Document Approved");
                                        },
                                        child: Text('Approve')) : SizedBox(height: 0)
                                  ],
                                  
                                );
                            },
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorForDocType(document.docType),
                            radius: 30,
                            child: const FittedBox(
                              child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child:  Icon(Icons.checklist_rounded)),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            'Application for ' + document.docType,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(
                                    'Employee Name: ' + document.employeeName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ))
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Date filed: ' + document.date,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      (document.isApproved
                                          ? 'Approved'
                                          : 'Pending'),
                                      style: TextStyle(
                                          color: document.isApproved
                                              ? Colors.green
                                              : Colors.red))
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
