import 'dart:math';

import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/fileDocuments_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../utils/alertbox.dart';
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
  late List<bool> selectedItems;
  List<int> selectedIndexes = [];
  bool isLoaded = false;
  bool isSelected = false;

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
          title: Text('Approver Page'),
          backgroundColor: Colors.redAccent,
          leading: selectedIndexes.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedIndexes.clear();
                      selectedItems =
                          List.generate(documents!.length, (index) => false);
                    });
                  },
                )
              : null,
          actions: [
            if (selectedIndexes.isNotEmpty)
              IconButton(
                icon: Icon(Icons.approval_rounded),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Confirm Approval'),
                        content: Text('You selected: ' + selectedIndexes.length.toString()),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async{
                              var isTrue =
                                  await updateFilingDocs(selectedItems, documents, context);
                              if (isTrue == true) {
                                _listKey.currentState?.setState(() {
                                  documents = documents!
                                    .where((item) =>
                                    item.docType == selectedValue).toList();
                                  
                                });
                                setState(() {
                                  selectedItems = List.generate(documents!.length,(index) => false);
                                  selectedIndexes.clear();
                                });
                                Navigator.of(context).pop();
                                _showSecondaryAlertDialog(context);
                                
                              }
                            },
                            child: Text('Approve All'),
                          ),
                        ],
                      );
                    },
                  );
                  
                },
              )
          ],
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
              future: fetchFilingDocuments(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  documents = snapshot.data! as List<FilingDocument>?;
                  if(selectedValue != 'All'){
                    documents = documents!
                      .where((item) => item.docType == selectedValue)
                      .toList();
                  }
                  
                  documents = sortDocs(documents!);
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
                              } else {
                                selectedIndexes.add(index);
                                selectedItems[index] = true;
                              }
                            });
                          } else {
                            // Show modal pop-up for single item press
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Item Pressed'),
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
                                        child: Text('Cancel')),
                                    TextButton(
                                        onPressed: () async {
                                          selectedIndexes.add(index);
                                          selectedItems[index] = true;
                                          var result = await updateFilingDocs(
                                              selectedItems,
                                              documents,
                                              context);
                                          _listKey.currentState?.setState(() {
                                            documents = documents!
                                                .where((item) =>
                                                    item.docType ==
                                                    selectedValue)
                                                .toList();
                                            
                                          });
                                          setState(() {
                                            selectedItems = List.generate(
                                                documents!.length,
                                                (index) => false);
                                            selectedIndexes.clear();
                                          });
                                          Navigator.of(context).pop();
                                          _showSecondaryAlertDialog(context);
                                          // await success_box(context, "Document Approved");
                                        },
                                        child: Text('Approve'))
                                  ],
                                );
                              },
                            );
                          }
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
                          title: Text('Application for ' + document.docType),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      'Employee Name: ' + document.employeeName)
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Date filed: ' + document.date)
                                ],
                              )
                            ],
                          ),
                          tileColor: selectedItems[index] ? Colors.blue : null,
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

  void _showModalPopup(String selectedItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selected Item'),
          content: Text('You selected: $selectedItem'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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

  void _showDeleteDialog(List<String> selectedItems) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete the selected items?'),
              SizedBox(height: 16),
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
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
