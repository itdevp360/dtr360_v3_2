import 'package:dtr360_version3_2/model/filingdocument.dart';
import 'package:dtr360_version3_2/utils/fileDocuments_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../utils/utilities.dart';

class ApproverListWidget extends StatefulWidget {
  const ApproverListWidget({super.key});

  @override
  State<ApproverListWidget> createState() => _ApproverListWidgetState();
}

class _ApproverListWidgetState extends State<ApproverListWidget> {

  
  String? selectedValue = 'Leave';
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

  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    var dropdownValue;
    return Scaffold(appBar: AppBar(
        title: Text('Approver Page'),
        leading: selectedIndexes.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedIndexes.clear();
                      selectedItems = List.generate(documents!.length, (index) => false);
                    });
                  },
                )
        : null,
        actions: [
          if(selectedIndexes.isNotEmpty)
            IconButton(
                  icon: Icon(Icons.approval_rounded),
                  onPressed: () async{
                    await updateFilingDocs(selectedItems, documents, context);
                  },
                )
          
        ],
      ),
      body: Column(children: [
        DropdownButton<String>(
            value: selectedValue,
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue!;
                isSelected = true;
                
              });
            },
            items: <String>[
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
          Flexible(child: FutureBuilder(future: fetchFilingDocuments(), builder: ((context, snapshot) {
      if(snapshot.hasData){
        documents = snapshot.data! as List<FilingDocument>?;
        documents = documents!.where((item) => item.docType == selectedValue).toList();
        if(isSelected){
          selectedItems = List.generate(documents!.length, (index) => false);
          isSelected = false;
        }
        
        if(!isLoaded){
          selectedItems = List.generate(documents!.length, (index) => false);
          isLoaded = true;
        }   
        return ListView.builder(
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
                            content: SizedBox(
                              height: 100, 
                              width: 60, 
                              child: Column(children: [Row(children: [Text('Application Type: ' + document.docType)]),
                              Row(children: [Text('Employee Name: ' + document.employeeName)])],),),
                            actions: [
                              TextButton(onPressed: () {
                                  Navigator.of(context).pop();
                                }, child: Text('OK'))
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    title: Text('Application for ' + document.docType),
                    subtitle: Column(mainAxisAlignment: MainAxisAlignment.start, 
                    children: [Row(children: [Text('Employee Name: ' + document.employeeName)],),
                    Row(children: [Text('Date filed: ' + document.date)],)],) ,
                    
                    tileColor: selectedItems[index] ? Colors.blue : null,
                  ),
                );
              },
            );
      }
      else if(snapshot.hasError){
        return Text('Error: ${snapshot.error}');
      }
      else{
        return Center(child: CircularProgressIndicator());
      }
    }),))
      ],));
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