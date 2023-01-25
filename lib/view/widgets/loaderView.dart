import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

class LoaderView extends StatelessWidget {
  final Widget child;
  final bool showLoader;

  LoaderView({required this.child, required this.showLoader})
      : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      opacity: 1.0,
      child: this.child,
      blur: 10,
      inAsyncCall: showLoader,
      progressIndicator: SpinKitWave(
        color: Colors.white,
        size: 10.0.w,
      ),
    );
  }
}
