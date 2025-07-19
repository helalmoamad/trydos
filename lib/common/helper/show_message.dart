import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:trydos/common/constant/constant.dart';

import '../../features/app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../features/app/my_text_widget.dart';
import '../../main.dart'; // لاستخدام navigatorKey

FToast fToast = FToast();

// دالة مساعدة للتحقق من الاتجاه
bool _isRTL(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl;
}

// دالة للحصول على النص المترجم
String _getLocalizedTitle(BuildContext context) {
  try {
    return 'alert'.tr();
  } catch (e) {
    return 'تنبيه'; // fallback
  }
}

showMessage(
  String message, {
  bool hasError = false,
  bool showInRelease = false,
  Color? backGroundColor,
  Color? foreGroundColor,
  Toast timeShowing = Toast.LENGTH_LONG,
  BuildContext? context,
}) {
  if (kDebugMode || showInRelease) {
    final currentContext = context ?? navigatorKey.currentState?.context;

    if (currentContext != null) {
      try {
        if (hasError) {
          showErrorMessage(currentContext, message);
        } else {
          showSuccessMessage(currentContext, message);
        }
      } catch (e) {
        print("Error in showMessage: $e");
        try {
          _showCustomToast(currentContext, message, isSuccess: !hasError);
        } catch (e2) {
          Fluttertoast.cancel().then((value) => Fluttertoast.showToast(
                msg: message,
                backgroundColor: hasError ? Colors.red : Colors.green,
                textColor: Colors.white,
                fontSize: 16,
                toastLength: timeShowing,
                gravity: ToastGravity.TOP,
              ));
        }
      }
    } else {
      Fluttertoast.cancel().then((value) => Fluttertoast.showToast(
            msg: message,
            backgroundColor: hasError ? Colors.red : Colors.green,
            textColor: Colors.white,
            fontSize: 16,
            toastLength: timeShowing,
            gravity: ToastGravity.TOP,
          ));
    }
  }
}

showSuccessMessage(BuildContext context, String message,
    {String? actionText, VoidCallback? onActionPressed}) {
  // استخدام Overlay بدلاً من Dialog لتجنب إغلاق الصفحة
  OverlayState? overlayState = Overlay.of(context);

  if (overlayState == null) {
    // إذا لم نتمكن من الحصول على Overlay، استخدم Dialog كبديل
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        Timer(Duration(seconds: 3), () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });

        return _buildSuccessWidget(context, message, () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });
      },
    );
    return;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _buildSuccessWidget(context, message, () {
      overlayEntry.remove();
    }),
  );

  overlayState.insert(overlayEntry);

  // إغلاق تلقائي بعد 3 ثوانٍ
  Timer(Duration(seconds: 3), () {
    try {
      overlayEntry.remove();
    } catch (e) {
      // تجاهل الأخطاء إذا كان الـ overlay محذوف بالفعل
    }
  });
}

Widget _buildSuccessWidget(
    BuildContext context, String message, VoidCallback onClose) {
  return Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            10, // إضافة padding للـ status bar
        left: 16,
        right: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h), // تقليل margin
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE2FFF1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF2CDD92), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextWidget(
                    _getLocalizedTitle(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  MyTextWidget(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: _isRTL(context) ? null : 0,
              left: _isRTL(context) ? 0 : null,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: const Color(0xFF666666),
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

showErrorMessage(BuildContext context, String message,
    {String? actionText, VoidCallback? onActionPressed}) {
  // استخدام Overlay بدلاً من Dialog لتجنب إغلاق الصفحة
  OverlayState? overlayState = Overlay.of(context);

  if (overlayState == null) {
    // إذا لم نتمكن من الحصول على Overlay، استخدم Dialog كبديل
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        Timer(Duration(seconds: 3), () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });

        return _buildErrorWidget(context, message, () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });
      },
    );
    return;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _buildErrorWidget(context, message, () {
      overlayEntry.remove();
    }),
  );

  overlayState.insert(overlayEntry);

  // إغلاق تلقائي بعد 3 ثوانٍ
  Timer(Duration(seconds: 3), () {
    try {
      overlayEntry.remove();
    } catch (e) {
      // تجاهل الأخطاء إذا كان الـ overlay محذوف بالفعل
    }
  });
}

Widget _buildErrorWidget(
    BuildContext context, String message, VoidCallback onClose) {
  return Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            10, // إضافة padding للـ status bar
        left: 16,
        right: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h), // تقليل margin
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDE2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF402CDD), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextWidget(
                    _getLocalizedTitle(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  MyTextWidget(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: _isRTL(context) ? null : 0,
              left: _isRTL(context) ? 0 : null,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: const Color(0xFF666666),
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

showWarningMessage(BuildContext context, String message,
    {String? actionText, VoidCallback? onActionPressed}) {
  // استخدام Overlay بدلاً من Dialog لتجنب إغلاق الصفحة
  OverlayState? overlayState = Overlay.of(context);

  if (overlayState == null) {
    // إذا لم نتمكن من الحصول على Overlay، استخدم Dialog كبديل
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        Timer(Duration(seconds: 3), () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });

        return _buildWarningWidget(context, message, () {
          try {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          } catch (e) {
            // تجاهل الأخطاء
          }
        });
      },
    );
    return;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _buildWarningWidget(context, message, () {
      overlayEntry.remove();
    }),
  );

  overlayState.insert(overlayEntry);

  // إغلاق تلقائي بعد 3 ثوانٍ
  Timer(Duration(seconds: 3), () {
    try {
      overlayEntry.remove();
    } catch (e) {
      // تجاهل الأخطاء إذا كان الـ overlay محذوف بالفعل
    }
  });
}

Widget _buildWarningWidget(
    BuildContext context, String message, VoidCallback onClose) {
  return Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            10, // إضافة padding للـ status bar
        left: 16,
        right: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h), // تقليل margin
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDE2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF402CDD), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextWidget(
                    _getLocalizedTitle(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  MyTextWidget(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: _isRTL(context) ? null : 0,
              left: _isRTL(context) ? 0 : null,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: const Color(0xFF666666),
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showCustomToast(BuildContext context, String message,
    {bool isSuccess = true}) {
  OverlayState? overlayState;
  BuildContext? workingContext = context;

  try {
    overlayState = Overlay.of(context);
  } catch (e) {
    try {
      overlayState = Overlay.of(context, rootOverlay: true);
    } catch (e2) {
      try {
        if (navigatorKey.currentState?.context != null) {
          workingContext = navigatorKey.currentState!.context;
          overlayState = Overlay.of(workingContext!);
        }
      } catch (e3) {
        try {
          if (navigatorKey.currentState?.context != null) {
            workingContext = navigatorKey.currentState!.context;
            overlayState = Overlay.of(workingContext!, rootOverlay: true);
          }
        } catch (e4) {
          _showDialogToast(workingContext ?? context, message, isSuccess);
          return;
        }
      }
    }
  }

  if (overlayState == null) {
    _showDialogToast(workingContext ?? context, message, isSuccess);
    return;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              10, // إضافة padding للـ status bar
          left: 16,
          right: 16,
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.h), // تقليل margin
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFFE2FFF1)
                      : const Color(0xFFFFEDE2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: isSuccess
                          ? const Color(0xFF2CDD92)
                          : const Color(0xFF402CDD),
                      width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextWidget(
                      _getLocalizedTitle(context),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    MyTextWidget(
                      message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: _isRTL(context) ? null : 0,
                left: _isRTL(context) ? 0 : null,
                child: GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: const Color(0xFF666666),
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  Timer(Duration(seconds: 3), () {
    try {
      overlayEntry.remove();
    } catch (e) {
      // تجاهل الخطأ إذا تم حذف الـ overlay بالفعل
    }
  });
}

void _showDialogToast(BuildContext context, String message, bool isSuccess) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (BuildContext dialogContext) {
      Timer(Duration(seconds: 3), () {
        if (Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      });

      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                10, // إضافة padding للـ status bar
            left: 16,
            right: 16,
          ),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 8.h), // تقليل margin
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? const Color(0xFFE2FFF1)
                        : const Color(0xFFFFEDE2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: isSuccess
                            ? const Color(0xFF2CDD92)
                            : const Color(0xFF402CDD),
                        width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextWidget(
                        _getLocalizedTitle(context),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      MyTextWidget(
                        message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: _isRTL(context) ? null : 0,
                  left: _isRTL(context) ? 0 : null,
                  child: GestureDetector(
                    onTap: () {
                      try {
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (e) {
                        // تجاهل الأخطاء
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF666666),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
