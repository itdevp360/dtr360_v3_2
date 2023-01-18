import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class qrWidget extends StatefulWidget {
  const qrWidget({super.key});

  @override
  State<qrWidget> createState() => _qrWidgetState();
}

class _qrWidgetState extends State<qrWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: const <Widget>[
        Expanded(
          child: Text('Deliver features faster', textAlign: TextAlign.center),
        ),
        Expanded(
          child: Text('Craft beautiful UIs', textAlign: TextAlign.center),
        ),
        Expanded(
          child: FittedBox(
            child: FlutterLogo(),
          ),
        ),
      ],
    ));
  }
}
