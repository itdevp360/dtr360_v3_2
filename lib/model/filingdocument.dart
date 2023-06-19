import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class FilingDocument extends ChangeNotifier {
  String _reason = '';
  String _guid = '';
  String _date = '';
  bool _isApproved = false;
  String _notifyStatus = '';
  String _dept = '';
  //Leaves
  String _leaveType = '';
  String _noOfDay = '';
  String _docType = '';
  String _attachmentName = '';
  String _fileId = '';
  bool _deductLeave = true;

  //Attendance Correction
  bool _isOut = false;
  String _correctTime = '';

  //OT
  String _hoursNo = '';

  String get reason => _reason;
  String get guid => _guid;
  String get date => _date;
  String get dept => _dept;
  String get leaveType => _leaveType;
  String get noOfDay => _noOfDay;
  bool get isApproved => _isApproved;
  String get notifyStatus => _notifyStatus;
  String get fileId => _fileId;
  String get docType => _docType;
  String get attachmentName => _attachmentName;
  bool get deductLeave => _deductLeave;
  bool get isOut => _isOut;
  String get correctTime => _correctTime;
  String get hoursNo => _hoursNo;

  set guid(String newData) {
    _guid = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set fileId(String newData) {
    _fileId = newData;
    notifyListeners();
  }

  set dept(String newData) {
    _dept = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set reason(String newData) {
    _reason = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set date(String newData) {
    _date = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set leaveType(String newData) {
    _leaveType = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set noOfDay(String newData) {
    _noOfDay = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set isApproved(bool newData) {
    _isApproved = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set notifyStatus(String newData) {
    _notifyStatus = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set docType(String newData) {
    _docType = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set attachmentName(String newData) {
    _attachmentName = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set deductLeave(bool newData) {
    _deductLeave = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set isOut(bool newData) {
    _isOut = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set correctTime(String newData) {
    _correctTime = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set hoursNo(String newData) {
    _hoursNo = newData;
    notifyListeners(); // Notify listeners when the data changes
  }
}