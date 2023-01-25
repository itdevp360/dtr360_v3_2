class Attendance {
  String? dept, empId, empName, guID, uType, dateIn, timeIn, timeOut, wfh;

  String? get getDept {
    return dept;
  }

  set department(String? depart) {
    dept = depart;
  }

  String? get getEmpId {
    return empId;
  }

  set employeeID(String? empid) {
    empId = empid;
  }

  String? get getEmpName {
    return empName;
  }

  set employeeName(String? empname) {
    empName = empname;
  }

  String? get getGuid {
    return guID;
  }

  set guid(String? gid) {
    guID = gid;
  }

  String? get getUtype {
    return uType;
  }

  set userType(String? utype) {
    uType = utype;
  }

  String? get getDateIn {
    return dateIn;
  }

  set dateTimeIn(String? datein) {
    dateIn = datein;
  }

  String? get getTimeIn {
    return timeIn;
  }

  set timein(String? time) {
    timeIn = time;
  }

  String? get getTimeOut {
    return timeOut;
  }

  set timeout(String? time) {
    timeOut = time;
  }

  String? get getwfh {
    return wfh;
  }

  set iswfh(String isWfh) {
    wfh = isWfh;
  }
}
