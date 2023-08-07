import 'package:flutter/widgets.dart';

class UserEditController {
  final TextEditingController controller = TextEditingController();

  UserEditController();
}

class UserController {
  UserEditController employeeId = UserEditController();
  UserEditController employeeName = UserEditController();
  UserEditController department = UserEditController();
  UserEditController approver = UserEditController();
  UserEditController absences = UserEditController();
}