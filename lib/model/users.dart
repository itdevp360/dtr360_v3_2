class Employees {
  String? empId, empName, emailAdd, guid, dept, imgStr, passW, usrType, wfh;

  String? get getId{
    return empId;
  }
  set employeeID(String employeeID){
    empId = employeeID;
  }

  String? get employeeName{
    return empName;
  }
  set employeeName(String? empname){
    empName = empname;
  }

  String? get email{
    return emailAdd;
  }
  set email(String? email){
    emailAdd = email;
  }

  String? get getguid{
    return guid;
  }
  void set setguid(String? guID){
    guid = guID;
  }

  String? get department{
    return dept;
  }
  set department(String? department){
    dept = department;
  }

  String? get imageString{
    return imgStr;
  }
  set imageString(String? imageString){
    imgStr = imageString;
  }

  String? get isWfh{
    return wfh;
  }
  set isWfh(String? isWfh){
    wfh = isWfh;
  }

  String? get password{
    return passW;
  }
  set password(String? pass){
    passW = pass;
  }

  String? get usertype{
    return usrType;
  }
  set usertype(String? usertype){
    usrType = usertype;
  }


  
}

