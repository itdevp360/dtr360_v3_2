import 'package:flutter/cupertino.dart';

import '../../../model/filingdocument.dart';

class LeaveDataWidget extends InheritedWidget {
  final FilingDocument dataModel;

  LeaveDataWidget({required this.dataModel, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(LeaveDataWidget oldWidget) {
    return oldWidget.dataModel != dataModel;
  }

  static LeaveDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LeaveDataWidget>();
  }
}
