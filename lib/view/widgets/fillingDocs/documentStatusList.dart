import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/firebase_functions.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:dtr360_version3_2/widgets/document_status_tile.dart';
import 'package:dtr360_version3_2/widgets/modal_details_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
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
  String? dateFilter = 'Date Filed';
  String? currentMonth = DateFormat('MMM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    //Initialize the Employee Profile during Leave Widget rendering
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      _employeesFuture = await fetchAllEmployees(false, true, departmentFilter: employeeProfile[1]);
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
            Padding(
                padding: const EdgeInsets.only(
                  left: 28.0,
                  right: 28.0,
                  top: 20,
                  bottom: 0,
                ),
                child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style:
                        const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                    underline: Container(
                      height: 2,
                      color: Color.fromARGB(255, 57, 57, 231),
                ),
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
            ),
            Padding(
                padding: const EdgeInsets.only(
                  left: 28.0,
                  right: 28.0,
                  bottom: 0,
                ),
                child: 
                DropdownButton<String>(
                value: dateFilter,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style:const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 57, 57, 231),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dateFilter = newValue!;
                  });
                },
                items: <String>[
                  'Date Filed',
                  'Effectivity Date',
                  'OT Date',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(
                  left: 28.0,
                  right: 28.0,
                  bottom: 0,
                ),
                child: 
                DropdownButton<String>(
                value: currentMonth,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style:const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 57, 57, 231),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    currentMonth = newValue!;
                  });
                },
                items: <String>[
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            isApprover ? 
            FutureBuilder<dynamic>(
              future: fetchAllEmployees(false, true, departmentFilter: employeeProfile[1]), // Replace with your own method to fetch list data
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                List<Employees> employees = snapshot.data as List<Employees>;
                Employees allEmp = new Employees();
                allEmp.empName = 'All';
                employees = sortListAlphabetical(employees!.where((empList) => employeeProfile[1].toString()
                  .contains(empList.dept!)).toList());
                employees.insert(0, allEmp);

                return Padding(
                  padding: const EdgeInsets.only(left: 28.0,right: 28.0,bottom: 0,), 
                  child:  DropdownButton<String>(
                    value: empNames,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style:const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                    underline: Container(height: 2,color: Color.fromARGB(255, 57, 57, 231),),
                    items: employees != null ? employees!.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee.empName!,
                        child: Text(employee.empName!),
                      );}).toList()
                    : [],
                    onChanged: (selectedName) {
                      setState(() {
                        empNames = selectedName!;
                      });
                    },
                    hint: Text('Select a name'),
                  )
                );    
              },
            )
            : SizedBox(height: 0),
            Flexible(child: 
              FutureBuilder(future: fetchEmployeeDocument(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    documents = snapshot.data! as List<FilingDocument>?;
                    if (selectedValue != 'All') {
                      if (empNames != '' && empNames != null) {
                        if (empNames != 'All') {
                          if(dateFilter == 'Date Filed'){
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.employeeName == empNames &&
                                item.date.contains(currentMonth!))
                            .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.employeeName == empNames &&
                                item.dateFrom.contains(currentMonth!))
                            .toList();
                          }
                          else{
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.employeeName == empNames &&
                                item.otDate.contains(currentMonth!))
                            .toList();
                          }
                          
                      } else {
                        if(dateFilter == 'Date Filed'){
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.date.contains(currentMonth!))
                            .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.dateFrom.contains(currentMonth!))
                            .toList();
                          }
                          else{
                            documents = documents!
                            .where((item) =>
                                item.docType == selectedValue &&
                                item.otDate.contains(currentMonth!))
                            .toList();
                          }
                        
                      }
                    } else {
                      if(dateFilter == 'Date Filed'){
                            documents = documents!
                          .where((item) =>
                              item.docType == selectedValue &&
                              item.date.contains(currentMonth!))
                          .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                          .where((item) =>
                              item.docType == selectedValue &&
                              item.dateFrom.contains(currentMonth!))
                          .toList();
                          }
                          else{
                            documents = documents!
                          .where((item) =>
                              item.docType == selectedValue &&
                              item.otDate.contains(currentMonth!))
                          .toList();
                          }
                      
                    }
                  } else {
                    if (empNames != '' && empNames != null) {
                      if (empNames != 'All') {
                        if(dateFilter == 'Date Filed'){
                            documents = documents!
                            .where((item) =>
                                item.employeeName == empNames &&
                                item.date.contains(currentMonth!))
                            .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                            .where((item) =>
                                item.employeeName == empNames &&
                                item.dateFrom.contains(currentMonth!))
                            .toList();
                          }
                          else{
                            documents = documents!
                            .where((item) =>
                                item.employeeName == empNames &&
                                item.otDate.contains(currentMonth!))
                            .toList();
                          }
                        
                      } else {
                        if(dateFilter == 'Date Filed'){
                            documents = documents!
                            .where((item) => item.date.contains(currentMonth!))
                            .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                            .where((item) => item.dateFrom.contains(currentMonth!))
                            .toList();
                          }
                          else{
                            documents = documents!
                            .where((item) => item.otDate.contains(currentMonth!))
                            .toList();
                          }
                        
                      }
                    } else {
                      if(dateFilter == 'Date Filed'){
                            documents = documents!
                          .where((item) => item.date.contains(currentMonth!))
                          .toList();
                          }
                          else if(dateFilter == 'Effectivity Date'){
                            documents = documents!
                          .where((item) => item.dateFrom.contains(currentMonth!))
                          .toList();
                          }
                          else{
                            documents = documents!
                          .where((item) => item.otDate.contains(currentMonth!))
                          .toList();
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
                                            ModalDetailsWidget(textData: document.reason, textLabel: 'Reason'),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            ModalDetailsWidget(textData: document.dept, textLabel: 'Department'),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            ModalDetailsWidget(textData: document.date, textLabel: 'Date Applied'),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isHalfday == true &&
                                                document.docType == 'Leave')
                                              Column(
                                                children: [
                                                  ModalDetailsWidget(textData: 'Yes', textLabel: 'Halfday'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.isAm ? 'AM' : 'PM', textLabel: 'AM/PM:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                ],
                                              ),
                                            if (document.docType == 'Leave')
                                              Column(
                                                children: [
                                                  ModalDetailsWidget(textData: document.dateFrom, textLabel: 'Start Date:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.dateTo, textLabel: 'End Date:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.leaveType, textLabel: 'Leave Type:'),
                                                ],
                                              ),
                                            if (document.docType ==
                                                'Correction')
                                              Column(
                                                children: [
                                                  ModalDetailsWidget(textData: document.correctDate, textLabel: 'Correction Date:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.correctTime, textLabel: 'Correct Time:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  document.correctBothTime != "" ? ModalDetailsWidget(textData: document.correctBothTime, textLabel: 'Correct Time Out:') : SizedBox(height: 0),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(
                                                    textData: document.isOut
                                                        ? (document.correctBothTime != "" ? 'Both' : 'Time Out')
                                                        : 'Time In',
                                                    textLabel: 'Time In/Out:',
                                                  ),
                                                ],
                                              ),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.docType == 'Overtime')
                                              Column(
                                                children: [
                                                  ModalDetailsWidget(textData: document.otType, textLabel: 'OT Type:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.otDate, textLabel: 'OT Date:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: document.isOvernightOt ? "Yes" : 'No', textLabel: 'Overnight OT?:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: timestampToDateString(document.otfrom, 'hh:mm a'), textLabel: 'Time from:'),
                                                  Row(children: [
                                                    SizedBox(height: 15)
                                                  ]),
                                                  ModalDetailsWidget(textData: timestampToDateString(document.otTo, 'hh:mm a'), textLabel: 'Time To:'),
                                                  
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
                                              ModalDetailsWidget(textData: document.cancellationDate, textLabel: 'Date Cancelled:'),
                                            if (document.isRejected)
                                              ModalDetailsWidget(textData: document.approveRejectBy, textLabel: 'Rejected by:'),
                                            if (document.isApproved && !document.isCancelled)
                                              ModalDetailsWidget(textData: document.approveRejectBy, textLabel: 'Approved by:'),
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isApproved && !document.isCancelled)
                                              ModalDetailsWidget(textData: document.approveRejectDate, textLabel: 'Date Approved:'),
                                            if (document.isRejected)
                                              ModalDetailsWidget(textData: document.approveRejectDate, textLabel: 'Date Rejected:'),
                                              
                                            Row(children: [
                                              SizedBox(height: 15)
                                            ]),
                                            if (document.isRejected)
                                              ModalDetailsWidget(textData: '', textLabel: 'Rejection Reason:'),  
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
                                     (employeeProfile[6] != 'Approver' && !document.isApproved && !document.isRejected) || employeeProfile[6] == 'Approver' ? TextButton(
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
                                        : SizedBox(height: 15,)
                                  ],
                                );
                              },
                            );
                          },
                          child: DocumentStatusTileWidget(document: document));
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
