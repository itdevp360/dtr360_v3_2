import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

success_box(context, message) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.rightSlide,
    title: 'SUCCESS',
    desc: message.toString(),
    btnOkOnPress: () async {
    },
  )..show();
}

error_box(context, message) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    btnOkColor: Colors.red,
    animType: AnimType.rightSlide,
    title: 'ERROR',
    desc: message.toString(),
    btnOkOnPress: () async {
    },
  )..show();
}

warning_box(context, message) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    btnOkColor: Colors.orange,
    animType: AnimType.rightSlide,
    title: 'WARNING!',
    desc: message.toString(),

    btnOkOnPress: () async {
    },
  )..show();
}

forgotpassword_box(context, message) {
  TextEditingController forgotPassword = new TextEditingController();
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    btnOkColor: Colors.blue,
    btnCancelColor: Colors.grey,
    animType: AnimType.rightSlide,
    title: 'WARNING!',
    desc: message.toString(),
    body: Padding(
            padding:
                EdgeInsets.only(left: 28.0, right: 28.0, top: 10, bottom: 0),
            child: TextField(
              controller: forgotPassword,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  labelText: 'Enter Email Address'),
            ),
          ),
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(email: forgotPassword.text);
        success_box(context, "Password reset has been sent to your email.");
      }
      catch(e){

        if (e is FirebaseAuthException) {
          error_box(context, e.message);
        } else {
          error_box(context, e.toString());
        }
        
      }
     
    },
    
  )..show();
}

confirm_address(context, message, address, lattitude, longitude) {
  AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'SUCCESS',
      desc: message.toString(),
      btnCancelText: "Retry",
      btnOkOnPress: () async {
        success_box(context, "Settings successfully updated.");
      },
      btnCancelOnPress: () async {})
    ..show();
}

