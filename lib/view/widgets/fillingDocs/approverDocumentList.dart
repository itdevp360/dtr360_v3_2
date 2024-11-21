import 'dart:math';

import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/fileDocuments_functions.dart';
import 'package:dtr360_version3_2/view/widgets/loaderView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../utils/alertbox.dart';
import '../../../utils/firebase_functions.dart';
import '../../../utils/utilities.dart';

class ApproverListWidget extends StatefulWidget {
  const ApproverListWidget({super.key});

  @override
  State<ApproverListWidget> createState() => _ApproverListWidgetState();
}

class _ApproverListWidgetState extends State<ApproverListWidget> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  String? selectedValue = 'All';
  List<FilingDocument>? documents;
  var employeeProfile;
  List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  TextEditingController rejectionReason = new TextEditingController();
  late List<bool> selectedItems;
  List<int> selectedIndexes = [];
  bool isLoaded = false;
  bool isSelected = false;
  bool _loaded = true;

  void deleteSelectedItems() {
    setState(() {
      for (int index in selectedIndexes) {
        selectedItems[index] = false;
      }
      selectedIndexes.clear();
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
    });
  }

  Color _getColorForDocType(String docType) {
    final Map<String, Color> colorMap = {
      'Leave': Colors.green,
      'Correction': Colors.yellow,
      'Overtime': Colors.red,
    };

    return colorMap[docType] ?? Colors.grey;
  }

  IconData _getIconForDocType(String docType) {
    final Map<String, IconData> iconMap = {
      'Leave': Icons.checklist_rounded,
      'Correction': Icons.edit,
      'Overtime': Icons.timer,
    };

    return iconMap[docType] ?? Icons.error;
  }

  void runFunction() async {}

  @override
  Widget build(BuildContext context) {
    var dropdownValue;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Approver Page'),
          backgroundColor: Colors.redAccent,
          leading: selectedIndexes.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedIndexes.clear();
                      selectedItems =
                          List.generate(documents!.length, (index) => false);
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
          actions: [
            if (selectedIndexes.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.approval_rounded),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm Approval'),
                        content:
                            Text('You selected: ${selectedIndexes.length}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                                            _showRejectAllModal(context);
                              
                            },
                            child: const Text('Reject All'),
                          ),
                          TextButton(
                            onPressed: () async {
                              setLoadedFalse();
                              var isTrue = await updateFilingDocs(selectedItems,
                                  documents, context, employeeProfile[0]);
                              if (isTrue == true) {
                                _listKey.currentState?.setState(() {
                                  documents = documents!
                                      .where((item) =>
                                          item.docType == selectedValue)
                                      .toList();
                                });
                                setState(() {
                                  documents = null;
                                  // selectedItems = List.generate(
                                  //     documents!.length, (index) => false);
                                  selectedIndexes.clear();
                                  _loaded = true;
                                });
                                Navigator.of(context).pop();
                                _showSecondaryAlertDialog(
                                    context, 'Documents Approved');
                              }
                            },
                            child: const Text('Approve All'),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
          ],
        ),
        body: LoaderView(showLoader: _loaded == false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 28.0,
                right: 28.0,
                top: 10,
                bottom: 0,
              ),
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                underline: Container(
                  height: 2,
                  color: const Color.fromARGB(255, 57, 57, 231),
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
            Flexible(
                child: FutureBuilder(
              future: fetchFilingDocuments(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  if(documents == null){
                    documents = snapshot.data! as List<FilingDocument>?;
                    documents = sortDocs(documents!);
                    selectedItems =
                        List.generate(documents!.length, (index) => false);
                  }
                  
                  if (selectedValue != 'All') {
                    if(isSelected){
                      selectedIndexes.clear();
                      documents = snapshot.data! as List<FilingDocument>?;
                      documents = sortDocs(documents!);
                    }
                    
                    documents = documents!
                        .where((item) => item.docType == selectedValue)
                        .toList();
                  }
                  else{
                    if(isSelected){
                      selectedIndexes.clear();
                      documents = snapshot.data! as List<FilingDocument>?;
                      documents = sortDocs(documents!);
                    }
                  }


                  
                  if (isSelected) {
                    selectedItems =
                        List.generate(documents!.length, (index) => false);
                    isSelected = false;
                  }

                  if (!isLoaded) {
                    selectedItems =
                        List.generate(documents!.length, (index) => false);
                    isLoaded = true;
                  }
                  return ListView.builder(
                    key: _listKey,
                    itemCount: documents!.length,
                    itemBuilder: (context, index) {
                      final document = documents![index];
                      return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              selectedIndexes.add(index);
                              selectedItems[index] = true;
                              print(selectedItems[index]);
                            });
                          },
                          onTap: () {
                            if (selectedIndexes.isNotEmpty) {
                              setState(() {
                                if (selectedIndexes.contains(index)) {
                                  selectedIndexes.remove(index);
                                  selectedItems[index] = false;
                                  print('Index no.: ' + documents![index].uniqueId);
                                } else {
                                  selectedIndexes.add(index);
                                  selectedItems[index] = true;
                                  print('ELSE Index no.: ' + documents![index].uniqueId);
                                }
                              });
                            } else {
                              // Show modal pop-up for single item press
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
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          'Name:',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        Text(
                                          document.employeeName,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Builder(
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.6,
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Reason:',
                                                        style: TextStyle(
                                                          fontSize: 11.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        document.reason,
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                                Row(children: const [
                                                  SizedBox(height: 15)
                                                ]),
                                                Row(children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Department:',
                                                        style: TextStyle(
                                                          fontSize: 11.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        document.dept,
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                                Row(children: const [
                                                  SizedBox(height: 15)
                                                ]),
                                                Row(children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Date Applied:',
                                                        style: TextStyle(
                                                          fontSize: 11.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        document.date,
                                                        style: const TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                                Row(children: const [
                                                  SizedBox(height: 15)
                                                ]),
                                                if (document.isHalfday ==
                                                        true &&
                                                    document.docType == 'Leave')
                                                  Column(
                                                    children: [
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: const [
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
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'AM/PM:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.isAm
                                                                  ? 'AM'
                                                                  : 'PM',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
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
                                                            const Text(
                                                              'Start Date:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.dateFrom,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'End Date:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.dateTo,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Leave Type:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document
                                                                  .leaveType,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                            const Text(
                                                              'Correction Date:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document
                                                                  .correctDate,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Correct Time:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document
                                                                  .correctTime,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      document.correctBothTime != "" ? Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Correct Time Out:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document
                                                                  .correctBothTime,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]) : SizedBox(height: 0),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text(
                                                                'Time In/Out:',
                                                                style: TextStyle(
                                                                  fontSize: 11.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                document.isOut
                                                                    ? (document.correctBothTime != "" ? 'Both' : 'Time Out')
                                                                    : 'Time In',
                                                                style: const TextStyle(
                                                                  fontSize: 15.0,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                Row(children: const [
                                                  SizedBox(height: 15)
                                                ]),
                                                if (document.docType ==
                                                    'Overtime')
                                                  Column(
                                                    children: [
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'OT Type:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.otType,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Overnight OT?:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.isOvernightOt
                                                                  ? "Yes"
                                                                  : 'No',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'OT Date:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              document.otDate,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Time from:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              timestampToDateString(
                                                                  document
                                                                      .otfrom,
                                                                  'hh:mm a'),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                      Row(children: const [
                                                        SizedBox(height: 15)
                                                      ]),
                                                      Row(children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Time To:',
                                                              style: TextStyle(
                                                                fontSize: 11.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              timestampToDateString(
                                                                  document.otTo,
                                                                  'hh:mm a'),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                    ],
                                                  ),
                                                Row(children: const [
                                                  SizedBox(height: 15)
                                                ]),
                                                Row(children: [
                                                  const Flexible(
                                                      child: Text(
                                                    'Status: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                  Text(
                                                    (document.isApproved
                                                        ? 'Approved'
                                                        : 'Pending'),
                                                    style: TextStyle(
                                                        color:
                                                            document.isApproved
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
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _showRejectModal(
                                                context, document.key);
                                            //  _showSecondaryAlertDialog(context);
                                          },
                                          child: const Text('Reject')),
                                      TextButton(
                                          onPressed: () async {
                                            setLoadedFalse();
                                            selectedIndexes.add(index);
                                            selectedItems[index] = true;
                                            var result = await updateFilingDocs(
                                                selectedItems,
                                                documents,
                                                context,
                                                employeeProfile[0]);
                                            _listKey.currentState?.setState(() {
                                              documents = documents!
                                                  .where((item) =>
                                                      item.docType ==
                                                      selectedValue)
                                                  .toList();
                                            });
                                            setState(() {
                                              documents = null;
                                              // selectedItems = [];
                                              // selectedItems = List.generate(
                                              //     documents!.length,
                                              //     (index) => false);
                                              selectedIndexes.clear();
                                              _loaded = true;
                                            });

                                            Navigator.of(context).pop();
                                            _showSecondaryAlertDialog(
                                                context, 'Document Approved');
                                            // await success_box(context, "Document Approved");
                                          },
                                          child: const Text('Approve'))
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
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
                                contentPadding: const EdgeInsets.only(
                                    left: 15, top: 8, bottom: 8, right: 8),
                                title: Text('AP No. ' + document.uniqueId),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Application for: ' +
                                            document.docType)
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
                                    )
                                  ],
                                ),
                                tileColor: selectedItems[index]
                                    ? Colors.blue
                                    : Colors.grey[200],
                              ),
                            ),
                          ));
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
            ))
          ],
        )));
  }

  void setLoadedFalse(){
    setState(() {
      _loaded = false;
    });
  }

  void _showModalPopup(String selectedItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selected Item'),
          content: Text('You selected: $selectedItem'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  void _showRejectAllModal(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Builder(builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.assignment_late_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Confirmation'),
                ],
              ),
              content: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Reason',
                    ),
                    controller: rejectionReason,
                  ),
                ),
              ]),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      rejectionReason.text = '';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    setLoadedFalse();
                    var isTrue = await rejectAllDocs(selectedItems, documents, context, rejectionReason.text,employeeProfile[0]);
                    if (isTrue == true) {
                      _listKey.currentState?.setState(() {
                        documents = documents!.where((item) =>  item.docType == selectedValue).toList();
                      });
                    setState(() {
                      documents = null;
                      // selectedItems = [];
                      // selectedItems = List.generate(documents!.length, (index) => false);
                      selectedIndexes.clear();
                      rejectionReason.clear();
                      _loaded = true;
                    });
                    Navigator.of(context).pop();
                    _showRejectionSuccess(context);
                    }
                    
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          });
        },
      );
    });
  }

  void _showRejectModal(BuildContext context, String selectedItem) {
    Future.delayed(const Duration(milliseconds: 10), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Builder(builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.assignment_late_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Confirmation'),
                ],
              ),
              content: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Reason',
                    ),
                    controller: rejectionReason,
                  ),
                ),
              ]),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      rejectionReason.text = '';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {

                    setLoadedFalse();
                    await rejectApplication(
                        selectedItem, rejectionReason.text, employeeProfile[0]);
                    _listKey.currentState?.setState(() {
                      documents = documents!
                          .where((item) => item.docType == selectedValue)
                          .toList();
                    });
                    setState(() {
                      documents = null;
                      // selectedItems = [];
                      // selectedItems =
                      //     List.generate(documents!.length, (index) => false);
                      selectedIndexes.clear();
                      rejectionReason.clear();
                      _loaded = true;
                    });
                    Navigator.of(context).pop();
                    _showRejectionSuccess(context);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          });
        },
      );
    });
  }

  void _showRejectionSuccess(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Builder(builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: const Text('Document Rejected!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the secondary AlertDialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      );
    });
  }

  void _showSecondaryAlertDialog(BuildContext context, String status) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Builder(builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: Text(status),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the secondary AlertDialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      );
    });
  }

  void _showDeleteDialog(List<String> selectedItems) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to delete the selected items?'),
              const SizedBox(height: 16),
              Text('Selected items: ${selectedItems.join(", ")}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform delete action here
                // ...
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
