import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// نافذة انتظار عملة البلد بعد تغييره.
///
/// الأسعار كلها تُضرب بسعر صرف البلد، فعرضها بعملة البلد السابق خطأ مالي
/// ظاهر للزبون. لذلك تُحجب الشاشة حتى تصل العملة الجديدة: لا زرّ إغلاق ولا
/// رجوع، والطلب يُعاد في الخلفية حتى ينجح.
///
/// تظهر فقط بعد تغيير البلد (أو اختياره أوّل مرّة). أي فشل آخر لطلب العملة لا
/// يحجب شيئاً، فالتطبيق يعمل بلا اتصال بالعملة المحفوظة.
Future<void> showCountryCurrencyLoadingDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const CountryCurrencyLoadingDialog(),
  );
}

class CountryCurrencyLoadingDialog extends StatelessWidget {
  const CountryCurrencyLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.awaitingCountryCurrency != current.awaitingCountryCurrency,
        listener: (context, state) {
          // وصلت العملة الجديدة: تُغلق النافذة من تلقائها.
          if (!state.awaitingCountryCurrency) Navigator.of(context).pop();
        },
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrydosLoader(size: 32.h),
                SizedBox(height: 14.h),
                Text(
                  LocaleKeys.getting_country_currency.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
