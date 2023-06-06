import 'package:dtr360_version3_2/view/widgets/fileDocumentsWidget.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

class documentFillingScreen extends StatelessWidget {
  const documentFillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      child: FileDocumentsWidget(),
    );
  }
}
