import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../features/app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../features/app/my_text_widget.dart';

FToast fToast = FToast();

// showCustomMessageWithContext(
//   String message,
//   BuildContext context, {
//   int seconds = 2,
//   bool hasError = true,
// }) {
//   fToast.init(context);
//   fToast.removeQueuedCustomToasts();
//
//
//   Widget toast = Container(
//     padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(25.0),
//       color: hasError ? ColorsApp.danger : ColorsApp.grey,
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(hasError ? Icons.error_outline : Icons.check),
//         const SizedBox(width: 12.0),
//         MyTextWidget(
//           message,
//           style: TextStyle(
//             color: ColorsApp.white,
//             fontSize: FontSize.large,
//           ).medium,
//         ),
//       ],
//     ),
//   );
//
//   fToast.showToast(
//       child: toast,
//       toastDuration: Duration(seconds: seconds),
//       gravity: ToastGravity.BOTTOM);
// }

showMessage(
  String message, {
  bool hasError = true,
  bool showInRelease = false,
  Color? backGroundColor,
  Color? foreGroundColor,
  Toast timeShowing = Toast.LENGTH_LONG,
}) {
  if (kDebugMode || showInRelease) {
    Fluttertoast.cancel().then((value) => Fluttertoast.showToast(
          msg: message,
          backgroundColor: backGroundColor ?? Colors.white,
          textColor: foreGroundColor ?? Colors.red,
          fontSize: 16,
          toastLength: timeShowing,
          gravity: ToastGravity.TOP,
        ));
  }
}

Future<void> callInProgressDialog(BuildContext context) async {
  await showDialog<String>(
      context: context,
      barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      builder: (BuildContext context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: IntrinsicHeight(
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18.0))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MyTextWidget(
                      'The call is being set up...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TrydosLoader()
                  ],
                ),
              ),
            ),
          ));
}
