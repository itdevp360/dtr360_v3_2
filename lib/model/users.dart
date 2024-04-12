class Employees {
  String? empId,
      empName,
      emailAdd,
      guid,
      dept,
      imgStr,
      passW,
      usrType,
      wfh,
      appId,
      appName,
      absences,
      key,
      timeIn,
      timeOut,
      mon,
      tues,
      wed,
      thurs,
      fri,
      sat,
      sun;

  String? get getAbsences {
    return absences;
  }

  set leaves(String absences) {
    absences = absences;
  }

  String? get getAppId {
    return appId;
  }

  set approverID(String approverID) {
    appId = approverID;
  }

  String? get getApproverId {
    return appName;
  }

  set approverName(String appName) {
    appName = appName;
  }

  String? get getId {
    return empId;
  }

  set employeeID(String employeeID) {
    empId = employeeID;
  }

  String? get getKey {
    return key;
  }

  set itemKey(String itemkey) {
    key = itemkey;
  }

  String? get employeeName {
    return empName;
  }

  set employeeName(String? empname) {
    empName = empname;
  }

  String? get email {
    return emailAdd;
  }

  set email(String? email) {
    emailAdd = email;
  }

  String? get getguid {
    return guid;
  }

  set setguid(String? guID) {
    guid = guID;
  }

  String? get department {
    return dept;
  }

  set department(String? department) {
    dept = department;
  }

  String? get imageString {
    return imgStr;
  }

  set imageString(String? imageString) {
    imgStr = imageString;
  }

  String? get isWfh {
    return wfh;
  }

  set isWfh(String? isWfh) {
    wfh = isWfh;
  }

  String? get password {
    return passW;
  }

  set password(String? pass) {
    passW = pass;
  }

  String? get usertype {
    return usrType;
  }

  set usertype(String? usertype) {
    usrType = usertype;
  }

  String? get getShiftTimeIn {
    return timeIn;
  }

  set shiftTimeIn(String timein) {
    timeIn = timein;
  }

  String? get getShiftTimeOut {
    return timeOut;
  }

  set shiftTimeOut(String timeout) {
    timeOut = timeout;
  }

  String? get getMonday {
    return mon;
  }

  set monday(String _monday) {
    mon = _monday;
  }

  String? get getTuesday {
    return tues;
  }

  set tuesday(String _tuesday) {
    tues = _tuesday;
  }

  String? get getWednesday {
    return wed;
  }

  set wednesday(String _wednesday) {
    wed = _wednesday;
  }

  String? get getThursday {
    return thurs;
  }

  set thursday(String _thursday) {
    thurs = _thursday;
  }

  String? get getFriday {
    return fri;
  }

  set friday(String _friday) {
    fri = _friday;
  }

  String? get getSaturday {
    return sat;
  }

  set saturday(String _saturday) {
    sat = _saturday;
  }

  String? get getSunday {
    return sun;
  }

  set sunday(String _sunday) {
    sun = _sunday;
  }
}
