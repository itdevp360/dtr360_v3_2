import 'package:dtr360_version3_2/model/attendance.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:dtr360_version3_2/view/screens/attendance_model.dart';
import 'package:dtr360_version3_2/view/screens/changepass_model.dart';
import 'package:dtr360_version3_2/view/screens/useredit_model.dart';
import 'package:dtr360_version3_2/view/widgets/attendanceWidget.dart';
import 'package:dtr360_version3_2/view/widgets/userEditWidget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:dtr360_version3_2/view/screens/register_model.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dtr360_version3_2/view/widgets/qrWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/users.dart';
import '../../utils/firebase_functions.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({
    super.key,
  });

  @override
  State<HomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends State<HomeWidget> {
  var credentials, employeeProfile;
  var qrCodeResult;
  var email, qrCode;
  List<Employees> empList = [];
  Employees emp = Employees();
  bool _loaded = false;
  bool _isWfh = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if (credentials != null && credentials[0] != '') {
        email = credentials[0] ?? '';
        employeeProfile = await read_employeeProfile();
        empList = await fetchEmployees();
        emp = empList.firstWhere((element) => element.emailAdd == email);
        save_employeeProfile(emp.empName, emp.dept, emp.emailAdd, emp.passW,
            emp.guid, emp.imgStr, emp.usrType, emp.key, emp.empId);
        // if(employeeProfile != null && employeeProfile[0] != ''){
        //   emp.empName = employeeProfile[0] ?? '';
        //   emp.dept = employeeProfile[1] ?? '';
        //   emp.emailAdd = employeeProfile[2] ?? '';
        //   emp.passW = employeeProfile[3] ?? '';
        //   emp.guid = employeeProfile[4] ?? '';
        //   emp.imgStr = employeeProfile[5] ?? '';
        //   emp.usrType = employeeProfile[6] ?? '';
        // }
        // else{
        //   emp = await fetchEmployees(email);
        //   save_employeeProfile(emp.empName, emp.dept, emp.emailAdd, emp.passW, emp.guid, emp.imgStr, emp.usrType);
        // }

        setState(() {
          if(emp.usrType == 'Former Employee'){
            logoutUser(context);
          }
          _loaded = true;
          _isWfh = emp.wfh == "null" || emp.wfh == '' ? false : true;
          print(emp.key);
        });
      }
    });
  }




  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    qrWidget(),
    AttendanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 0,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Attendance',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("DTR360 v3.2.0"),
        backgroundColor: Colors.redAccent,
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              // icon: Icon(Icons.book)
              itemBuilder: (context) {
                var items = <PopupMenuItem>[];
                if(emp.usrType == 'IT/Admin' || emp.usrType == 'Admin' || emp.usrType == 'IT'){
                  items.add(PopupMenuItem<int>(
                  value: 0,
                  child: const Text("Register"),
                  onTap: () {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const RegisterScreen();
                          },
                        ),
                      );
                    });
                  }));
                  items.add(PopupMenuItem<int>(
                  value: 1,
                  child: Text("User Edit"),
                  onTap: () {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const UserEditWidget();
                          },
                        ),
                      );
                    });
                  }));
                }
                items.add(PopupMenuItem<int>(
                value: 2,
                child: Text("Change password"),
                onTap: () {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const ChangePassScreen();
                        },
                      ),
                    );
                  });
                },
              ));
              items.add(PopupMenuItem<int>(
                value: 3,
                child: Text("Logout"),
                onTap: (){
                  
                },
              ));
            return items;
          }, onSelected: (value) {
            switch (value) {
              case 0:
                print("My 1 menu is selected.");
                break;
              case 1:
              case 2:
                print("My 3 menu is selected.");
                break;
              case 3:
                logoutUser(context);
                print("My 4 menu is selected.");

                break;
            }
          }),
        ],
      ),
    );
  }
}
