import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class FilingDocument extends ChangeNotifier {
  String _reason = '';
  String _key = '';
  String _guid = '';
  String _date = '';
  String _employeeName = '';
  int _finalDate = 0;
  bool _isApproved = false;
  String _notifyStatus = '';
  String _empKey = '';
  String _dept = '';
  //Leaves
  String _leaveType = '';
  String _dateFrom = '';
  bool _isHalfday = false;
  bool _isAm = false;
  String _dateTo = '';
  String _noOfDay = '';
  String _docType = '';
  String _location = '';
  String _attachmentName = '';
  String _fileId = '';
  bool _deductLeave = true;

  //Attendance Correction
  String _correctDate = '';
  bool _isOut = false;
  String _correctTime = '';

  //OT
  String _otDate = '';
  int _otfrom = 0;
  int _otTo = 0;
  String _otType = '';
  String _hoursNo = '';

  int get otfrom => _otfrom;
  int get otTo => _otTo;
  String get correctDate => _correctDate;
  String get otDate => _otDate;
  String get otType => _otType;
  String get reason => _reason;
  String get guid => _guid;
  String get date => _date;
  String get dateFrom => _dateFrom;
  String get dateTo => _dateTo;
  String get dept => _dept;
  String get empKey => _empKey;
  String get location => _location;
  String get key => _key;
  String get employeeName => _employeeName;
  String get leaveType => _leaveType;
  String get noOfDay => _noOfDay;
  bool get isApproved => _isApproved;
  bool get isHalfday => _isHalfday;
  bool get isAm => _isAm;
  int get finalDate => _finalDate;
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

  set key(String newData) {
    _key = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set empKey(String newData) {
    _empKey = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set location(String newData) {
    _location = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set otDate(String newData) {
    _otDate = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set correctDate(String newData) {
    _correctDate = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set otfrom(int newData) {
    _otfrom = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set otTo(int newData) {
    _otTo = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set otType(String newData) {
    _otType = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set employeeName(String newData) {
    _employeeName = newData;
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

  set finalDate(int newData) {
    _finalDate = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set date(String newData) {
    _date = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set dateFrom(String newData) {
    _dateFrom = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set dateTo(String newData) {
    _dateTo = newData;
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

  set isHalfday(bool newData) {
    _isHalfday = newData;
    notifyListeners(); // Notify listeners when the data changes
  }

  set isAm(bool newData) {
    _isAm = newData;
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


  void resetProperties(){
    reason = '';
    key = '';
    date = '';
    finalDate = 0;
    isApproved = false;
    notifyStatus = '';
    //Leaves
    leaveType = '';
    dateFrom = '';
    isHalfday = false;
    isAm = false;
    dateTo = '';
    noOfDay = '';
    docType = '';
    location = '';
    attachmentName = '';
    fileId = '';
    deductLeave = true;

    //Attendance Correction
    isOut = false;
    correctTime = '';

    //OT
    otDate = '';
    otfrom = 0;
    correctDate = '';
    otTo = 0;
    otType = '';
    hoursNo = '';
  }
}
