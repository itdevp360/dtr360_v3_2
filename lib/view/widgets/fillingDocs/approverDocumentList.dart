import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ApproverListWidget extends StatefulWidget {
  const ApproverListWidget({super.key});

  @override
  State<ApproverListWidget> createState() => _ApproverListWidgetState();
}

class _ApproverListWidgetState extends State<ApproverListWidget> {

  List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  List<bool> selectedItems = List.generate(20, (index) => false);
  List<int> selectedIndexes = [];

  void deleteSelectedItems() {
    setState(() {
      for (int index in selectedIndexes) {
        selectedItems[index] = false;
      }
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndexes.isNotEmpty) {
          setState(() {
            selectedIndexes.clear();
            selectedItems = List.generate(20, (index) => false);
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Multiple Selection ListView'),
          leading: selectedIndexes.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedIndexes.clear();
                      selectedItems = List.generate(20, (index) => false);
                    });
                  },
                )
              : null,
          actions: [
            if (selectedIndexes.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteSelectedItems();
                },
              ),
          ],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                setState(() {
                  selectedIndexes.add(index);
                  selectedItems[index] = true;
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
                        content: Text(items[index]),
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
                title: Text(items[index]),
                tileColor: selectedItems[index] ? Colors.blue : null,
              ),
            );
          },
        ),
      ),
    );
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