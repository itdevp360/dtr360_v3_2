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
      key;

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
}
