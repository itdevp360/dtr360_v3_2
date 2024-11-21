import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:dtr360_version3_2/view/screens/approvalListScreen.dart';
import 'package:dtr360_version3_2/view/screens/attendance_model.dart';
import 'package:dtr360_version3_2/view/screens/changepass_model.dart';
import 'package:dtr360_version3_2/view/screens/documentfiling_model.dart';
import 'package:dtr360_version3_2/view/widgets/fileDocumentsWidget.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/approverDocumentList.dart';
import 'package:dtr360_version3_2/view/widgets/fillingDocs/documentStatusList.dart';
import 'package:dtr360_version3_2/view/widgets/userEditWidget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:dtr360_version3_2/view/screens/register_model.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dtr360_version3_2/view/widgets/qrWidget.dart';
import 'package:flutter/material.dart';
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
        empList = await fetchEmployees(emailAdd: email);
        emp = empList.firstWhere((element) => element.emailAdd == email);
        save_employeeProfile(
            emp.empName,
            emp.dept,
            emp.emailAdd,
            emp.passW,
            emp.guid,
            emp.imgStr,
            emp.usrType,
            emp.key,
            emp.empId,
            emp.appId,
            emp.appName,
            emp.absences,
            emp.timeIn,
            emp.timeOut,
            emp.mon,
            emp.tues,
            emp.wed,
            emp.thurs,
            emp.fri,
            emp.sat,
            emp.sun);
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
          if (emp.usrType == 'Former Employee') {
            logoutUser(context);
          }
          _loaded = true;
          _isWfh = emp.wfh == "null" || emp.wfh == '' ? false : true;
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
    documentFillingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
            body: _selectedIndex != 2
                ? _widgetOptions.elementAt(_selectedIndex)
                : const FileDocumentsWidget(),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 0,
                  activeColor: Colors.black,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: const [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: LineIcons.user,
                      text: 'Attendance',
                    ),
                    GButton(
                      icon: LineIcons.fileUpload,
                      text: 'Applications',
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
            appBar: AppBar(
              title: const Text("DTR360 v3.3.7"),
              backgroundColor: Colors.redAccent,
              bottom: _selectedIndex == 2
                  ? const TabBar(
                      tabs: <Widget>[
                        Tab(
                          icon: Icon(Icons.filter_frames_rounded),
                        ),
                        Tab(
                          icon: Icon(Icons.checklist_rtl),
                        ),
                        Tab(
                          icon: Icon(Icons.timer_sharp),
                        ),
                      ],
                    )
                  : null,
              actions: [
                PopupMenuButton(
                    // add icon, by default "3 dot" icon
                    // icon: Icon(Icons.book)
                    itemBuilder: (context) {
                  var items = <PopupMenuItem>[];
                  if (emp.usrType == 'IT/Admin' ||
                      emp.usrType == 'Admin' ||
                      emp.usrType == 'IT') {
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
                        child: const Text("User Edit"),
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
                  if (emp.usrType == 'Approver') {
                    items.add(PopupMenuItem<int>(
                      value: 2,
                      child: const Text("For Approval"),
                      onTap: () {
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ApproverListWidget();
                              },
                            ),
                          );
                        });
                      },
                    ));
                  }
                  items.add(PopupMenuItem<int>(
                    value: 3,
                    child: const Text("Document Status"),
                    onTap: () {
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const DocumentStatusWidget();
                            },
                          ),
                        );
                      });
                    },
                  ));
                  items.add(PopupMenuItem<int>(
                    value: 4,
                    child: const Text("Change password"),
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
                    value: 5,
                    child: const Text("Logout"),
                    onTap: () {},
                  ));
                  return items;
                }, onSelected: (value) {
                  switch (value) {
                    case 0:
                      break;
                    case 1:
                    case 2:
                      break;
                    case 5:
                      logoutUser(context);

                      break;
                  }
                }),
              ],
            )));
  }
}
