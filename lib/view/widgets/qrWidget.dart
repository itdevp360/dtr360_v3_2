import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../utils/utilities.dart';

class qrWidget extends StatefulWidget {
  const qrWidget({super.key});

  @override
  State<qrWidget> createState() => _qrWidgetState();
}

class _qrWidgetState extends State<qrWidget> {
  var credentials;
  var email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      credentials = await read_credentials_pref();
      if(credentials != null && credentials[0] != ''){
        email = credentials[0] != null ? credentials[0] : '';
        
      }
      
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 100.0),
        child: Center(child: Container(
          width: 400,
          height: 130,
          child: Column(children: [Text("Placeholder Names", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),), Text("Placeholder Department", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),)],
          )
        )),
        ),
        Padding(padding: const EdgeInsets.only(top: 0.0),
        child: Center(child: Container(
          width: 170,
          height: 170,
          child: Image.asset('assets/people360.png')
        )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Padding(padding: const EdgeInsets.only(top:130)),
          Center(
             child: SizedBox(width: 100, height: 100, child: TextButton(
              onPressed: (){
                print('left');
              }, 
              child: Image.asset('assets/greenclock.png'),)),
          ),
          Center(
             child: SizedBox(width: 100, height: 100, ),
          ),
          Center(
             child: SizedBox(width: 100, height: 100, child: TextButton(
              onPressed: (){
                fetchEmployees(email);
                print('right');
              }, 
              child: Image.asset('assets/redclock.png'),)),
          ),
          
          
        ],)
      ],
    ));
  }
}
