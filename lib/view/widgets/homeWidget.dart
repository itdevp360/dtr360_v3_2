import 'package:dtr360_version3_2/view/screens/login_model.dart';
import 'package:dtr360_version3_2/view/screens/register_model.dart';
import 'package:dtr360_version3_2/view/widgets/qrWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: qrWidget(),
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
                Navigator.pushReplacementNamed(context, 'Login');
                break;
            }
          }),
        ],
      ),
    );
  }
}
