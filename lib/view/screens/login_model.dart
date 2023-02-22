import 'package:dtr360_version3_2/view/widgets/loginWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginWidget(title: 'DTR360 v3.2.0');
  }
}
