import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:line_icons/line_icons.dart';
import 'package:dtr360_version3_2/view/screens/register_model.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dtr360_version3_2/view/widgets/qrWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, });


  @override
  State<HomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends State<HomeWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    qrWidget(),
    Text(
      'Likes',
      style: optionStyle,
    ),
    Text(
      'Search',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
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
            return [
              PopupMenuItem<int>(
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
                  }),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("User Edit"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Change password"),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) async {
            switch (value) {
              case 0:
                print("My 1 menu is selected.");
                break;
              case 1:
                print("My 2 menu is selected.");
                break;
              case 2:
                print("My 3 menu is selected.");
                break;
              case 3:
                print("My 4 menu is selected.");
                await FirebaseAuth.instance.signOut();
                save_credentials_pref('','');
                Navigator.pushReplacementNamed(context, 'Login');
                break;
            }
          }),
        ],
      ),
    );
  }
}
