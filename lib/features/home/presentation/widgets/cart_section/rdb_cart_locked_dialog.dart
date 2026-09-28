import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/rdb_pending_payment.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/rdb_payment_dialog.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart' show navigatorKey;

/// رسالة "لديك طلب لم يُدفع بعد".
///
/// تظهر عند أي محاولة لتعديل السلة (إضافة، حذف، تعديل، تحويل إلى السلة
/// القديمة) ما دامت هناك دفعة RDB معلّقة، لأن الباك يرفض هذه العمليات بالرمز
/// 409. هذا هو سلوك الموقع نفسه: لا شيء يظهر في السلة حتى يحاول الزبون التعديل.
Future<void> showRdbCartLockedDialog(
  BuildContext context, {
  required String requestReference,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _RdbCartLockedDialog(requestReference: requestReference),
  );
}

bool _globalDialogOpen = false;

/// يعرض الرسالة فوق أي صفحة كانت.
///
/// التعديل على السلة لا يحدث في صفحة السلة وحدها: زرّ الإضافة موجود في تفاصيل
/// المنتج وفي قوائم المنتجات وفي الرئيسية. لذلك يُستدعى هذا من معترض الشبكة
/// عند أي رفض 409 بسبب دفعة معلّقة، فتظهر الرسالة أينما كان الزبون. الحارس
/// يمنع تكدّس النوافذ إن تتالت الرفوض.
Future<void> showRdbCartLockedDialogGlobally({
  required String requestReference,
}) async {
  if (_globalDialogOpen) return;
  final BuildContext? context = navigatorKey.currentContext;
  if (context == null) return;
  _globalDialogOpen = true;
  try {
    await showRdbCartLockedDialog(context, requestReference: requestReference);
  } finally {
    _globalDialogOpen = false;
  }
}

class _RdbCartLockedDialog extends StatefulWidget {
  const _RdbCartLockedDialog({required this.requestReference});

  final String requestReference;

  @override
  State<_RdbCartLockedDialog> createState() => _RdbCartLockedDialogState();
}

class _RdbCartLockedDialogState extends State<_RdbCartLockedDialog> {
  bool _cancelling = false;

  void _continuePayment() {
    final NavigatorState navigator = Navigator.of(context);
    final BuildContext pageContext = navigator.context;
    navigator.pop();
    showRdbPaymentDialog(
      pageContext,
      requestReference: widget.requestReference,
    );
  }

  /// يلغي الدفعة فتعود السلة قابلة للتعديل فوراً.
  Future<void> _cancelPayment() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    final result = await GetIt.I<HomeRepository>().cancelRdbPaymentRequest(
      requestReference: widget.requestReference,
    );
    if (!mounted) return;
    setState(() => _cancelling = false);
    result.fold(
      (failure) {
        // 409 هنا تعني أنّ الدفعة تمّت قبل الإلغاء: افتح النافذة ليرى النتيجة.
        if (failure.statusCode == 409) {
          _continuePayment();
          return;
        }
        showMessage(
          failure.message,
          hasError: true,
          showInRelease: true,
          context: context,
        );
      },
      (_) {
        RdbPendingPayment.clear();
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());
        Navigator.of(context).pop();
        showMessage(LocaleKeys.rdb_payment_cancelled.tr(), showInRelease: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 40.h,
              color: const Color(0xff388CFF),
            ),
            SizedBox(height: 10.h),
            Text(
              LocaleKeys.rdb_payment_in_progress.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.sbt.copyWith(
                color: const Color(0xff1D1D1D),
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.rdb_cart_locked_message.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelling ? null : _continuePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff388CFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.rdb_continue_payment.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _cancelling ? null : _cancelPayment,
                child: _cancelling
                    ? TrydosLoader(size: 18.h)
                    : Text(
                        LocaleKeys.rdb_cancel_payment.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xffE02020),
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _cancelling
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(
                  LocaleKeys.rdb_close.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff8D8D8D),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
