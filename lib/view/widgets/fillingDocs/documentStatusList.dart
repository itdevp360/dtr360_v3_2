import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/firebase_functions.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../../model/users.dart';
import '../../../utils/fileDocuments_functions.dart';
import '../loaderView.dart';

class DocumentStatusWidget extends StatefulWidget {
  const DocumentStatusWidget({super.key});

  @override
  State<DocumentStatusWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DocumentStatusWidget> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<FilingDocument>? documents, empDocuments;
  List<Employees>? _employeesFuture;
  Employees? selectedEmp;
  var employeeProfile;
  List<Employees>? employeeList;
  bool loaded = false;
  bool isRefresh = false;
  bool isSelected = false;
  bool isApprover = false;
  double screenH = 48.h;
  String? selectedValue = 'All';
  String? empNames = null;

  @override
  void initState() {
    super.initState();
    //Initialize the Employee Profile during Leave Widget rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      _employeesFuture = await fetchAllEmployees(true);
      setState(() {
        isApprover = employeeProfile[6] == 'Approver' ? true : false;
      });
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
            isApprover
                ? FutureBuilder<dynamic>(
                    future: fetchAllEmployees(
                        true), // Replace with your own method to fetch list data
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      List<Employees> employees =
                          snapshot.data as List<Employees>;
                      Employees allEmp = new Employees();
                      allEmp.empName = 'All';
                      employees = sortListAlphabetical(employees!
                          .where((empList) => employeeProfile[1]
                              .toString()
                              .contains(empList.dept!))
                          .toList());
                      employees.insert(0, allEmp);
                      return DropdownButton<String>(
                        value: empNames,
                        items: employees != null
                            ? employees!.map((employee) {
                                return DropdownMenuItem<String>(
                                  value: employee.empName!,
                                  child: Text(employee.empName!),
                                );
                              }).toList()
                            : [],
                        onChanged: (selectedName) {
                          setState(() {
                            empNames = selectedName!;
                          });
                        },
                        hint: Text('Select a name'),
                      );
                    },
                  )
                : SizedBox(height: 0),
            Flexible(
                child: FutureBuilder(
              future: fetchEmployeeDocument(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  documents = snapshot.data! as List<FilingDocument>?;
                  if (selectedValue != 'All') {
                    if (empNames != '' && empNames != null) {
                      if (empNames != 'All') {
                        documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.employeeName == empNames)
                            .toList();
                      } else {
                        documents = documents!
                            .where((item) => item.docType == selectedValue)
                            .toList();
                      }
                    } else {
                      documents = documents!
                          .where((item) => item.docType == selectedValue)
                          .toList();
                    }
                  } else {
                    if (empNames != '' && empNames != null) {
                      if (empNames != 'All') {
                        documents = documents!
                            .where((item) => item.employeeName == empNames)
                            .toList();
                      } else {
                        documents = documents!;
                      }
                    }
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
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AP No. ' + document.uniqueId,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Name:',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        document.employeeName,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Builder(
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Reason:',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    document.reason,
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            Row(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Department:',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    document.dept,
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            Row(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Date Applied:',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    document.date,
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isHalfday == true &&
                                                document.docType == 'Leave')
                                              Column(
                                                children: [
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Halfday:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'AM/PM:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.isAm
                                                              ? 'AM'
                                                              : 'PM',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                ],
                                              ),
                                            if (document.docType == 'Leave')
                                              Column(
                                                children: [
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Start Date:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.dateFrom,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'End Date:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.dateTo,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Leave Type:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.leaveType,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            if (document.docType ==
                                                'Correction')
                                              Column(
                                                children: [
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Correction Date:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.correctDate,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Correct Time:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.correctTime,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Time In/Out:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.isOut == true
                                                              ? 'Time Out'
                                                              : 'Time In',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.docType == 'Overtime')
                                              Column(
                                                children: [
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'OT Type:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.otType,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'OT Date:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          document.otDate,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Time from:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          timestampToDateString(
                                                              document.otfrom,
                                                              'hh:mm a'),
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  Row(children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Time To:',
                                                          style: TextStyle(
                                                            fontSize: 11.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          timestampToDateString(
                                                              document.otTo,
                                                              'hh:mm a'),
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            Row(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Status:',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    (!document.isCancelled
                                                        ? (document.isApproved !=
                                                                    null &&
                                                                !document
                                                                    .isApproved
                                                            ? (document
                                                                    .isRejected
                                                                ? 'Rejected'
                                                                : 'Pending')
                                                            : 'Approved')
                                                        : 'Cancelled'),
                                                    style: TextStyle(
                                                        color: !document
                                                                .isCancelled
                                                            ? (document.isApproved !=
                                                                        null &&
                                                                    !document
                                                                        .isApproved
                                                                ? (document
                                                                        .isRejected
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .orange)
                                                                : Colors.green)
                                                            : Colors.grey),
                                                  )
                                                ],
                                              ),
                                            ]),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isCancelled)
                                              Row(children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Date Cancelled:',
                                                      style: TextStyle(
                                                        fontSize: 11.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      document.cancellationDate,
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                            if (document.isRejected)
                                              Row(children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Date Rejected:',
                                                      style: TextStyle(
                                                        fontSize: 11.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      document
                                                          .approveRejectDate,
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isRejected)
                                              Row(children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Rejection Reason:',
                                                      style: TextStyle(
                                                        fontSize: 11.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                            Text(
                                              document.rejectionReason,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                            employeeProfile[6] == 'Approver'
                                                ? document.isApproved
                                                    ? 'Cancel'
                                                    : 'Ok'
                                                : 'Ok')),
                                    employeeProfile[6] == 'Approver' &&
                                            document.isApproved
                                        ? TextButton(
                                            onPressed: () async {
                                              isRefresh = false;
                                              print(document.key);
                                              await cancelFilingStatus(
                                                  document.key);
                                              _listKey.currentState
                                                  ?.setState(() {});
                                              setState(() {
                                                isRefresh = true;
                                              });
                                              Navigator.of(context).pop();
                                              _showSecondaryAlertDialog(
                                                  context);
                                              // await success_box(context, "Document Approved");
                                            },
                                            child: Text('Retract'))
                                        : SizedBox(height: 0)
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 1, horizontal: 5),
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  document.docType == 'Leave'
                                      ? Icons.time_to_leave_outlined
                                      : document.docType == 'Correction'
                                          ? Icons.edit_calendar_sharp
                                          : document.docType == 'Overtime'
                                              ? Icons.access_time_rounded
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
                                        Text(
                                          'Application for: ' +
                                              document.docType,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Employee Name: ' +
                                            document.employeeName)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Date filed: ' + document.date)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Status: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            (!document.isCancelled
                                                ? (document.isApproved !=
                                                            null &&
                                                        !document.isApproved
                                                    ? (document.isRejected
                                                        ? 'Rejected'
                                                        : 'Pending')
                                                    : 'Approved')
                                                : 'Cancelled'),
                                            style: TextStyle(
                                                color: !document.isCancelled
                                                    ? (document.isApproved !=
                                                                null &&
                                                            !document.isApproved
                                                        ? (document.isRejected
                                                            ? Colors.red
                                                            : Colors.orange)
                                                        : Colors.green)
                                                    : Colors.grey))
                                      ],
                                    )
                                  ],
                                ),
                                tileColor: Colors.grey[200],
                              ),
                            ),
                          ));
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
