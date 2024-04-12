import 'package:flutter/cupertino.dart';

class ModalDetailsWidget extends StatelessWidget{
  final String textData;
  final String textLabel;

  ModalDetailsWidget({required this.textData, required this.textLabel});

  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Text(
              textLabel,
              style: TextStyle(fontSize: 11.0,),
            ),
            Text(
              textData,
              style: TextStyle(fontSize: 15.0,fontWeight:FontWeight.bold,),
            ),
          ],
        ),
    ]);
  }

}