import 'dart:async';
// easy_localization يصدّر TextDirection من intl، وهو غير الذي تحتاجه الودجات.
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/installed_apps.dart';
import 'package:trydos/common/helper/rdb_pending_payment.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/rdb_payment_request_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/rdbPaymentCubit/rdb_payment_cubit.dart';
import 'package:trydos/features/home/presentation/pages/Order/orders_page.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/rdb_cart_locked_dialog.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/successful_order.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// يفتح نافذة الدفع عبر Ramaaz Digital Bank فوق الصفحة الحالية.
///
/// إمّا بطلب دفع جديد ([addressId])، أو بمتابعة طلب معلّق ([requestReference]).
Future<void> showRdbPaymentDialog(
  BuildContext context, {
  int? addressId,
  String? requestReference,
  String orderNote = 'orderNote',
  RdbCheckoutSuccessArgs? successArgs,
}) {
  return showDialog<void>(
    context: context,
    // الإغلاق يكون بزرّ ظاهر، لا بضغطة خارج النافذة أثناء انتظار الدفع.
    barrierDismissible: false,
    builder: (_) => RdbPaymentDialog(
      addressId: addressId,
      requestReference: requestReference,
      orderNote: orderNote,
      successArgs: successArgs,
    ),
  );
}

/// نافذة الدفع عبر Ramaaz Digital Bank، بالتصميم نفسه المعتمد في الموقع:
/// عنوان، رمز QR، الكود العشري تحته، ثم المؤقّت ومعلومات الطلب.
///
/// التطبيق لا يتصل بـ RDB: الباك ينشئ طلب الدفع ويعطينا الكود، يدخله الزبون في
/// تطبيق RDB أو يمسح الرمز ويؤكّد، ونحن نسأل الباك عن الحالة حتى تصبح مدفوعة.
class RdbPaymentDialog extends StatefulWidget {
  const RdbPaymentDialog({
    super.key,
    this.addressId,
    this.requestReference,
    this.orderNote = 'orderNote',
    this.successArgs,
  }) : assert(
         addressId != null || requestReference != null,
         'RdbPaymentDialog needs an address to create a request, or a reference '
         'to follow an existing one',
       );

  final int? addressId;
  final String? requestReference;
  final String orderNote;

  /// بيانات السلة التي تعرضها شاشة نجاح الطلب. تصل من صفحة تأكيد الطلب. حين
  /// تُفتح الشاشة من شريط السلة لا تتوفّر، فننتقل حينها إلى قائمة الطلبات.
  final RdbCheckoutSuccessArgs? successArgs;

  @override
  State<RdbPaymentDialog> createState() => _RdbPaymentDialogState();
}

/// ما تحتاجه شاشة نجاح الطلب ولا يأتي في استجابة طلب الدفع.
class RdbCheckoutSuccessArgs {
  const RdbCheckoutSuccessArgs({
    required this.cartImages,
    required this.totalPrice,
    required this.paymentMethods,
    required this.availablePaymentMethod,
    required this.currencySymbol,
    required this.customerAddressesInfo,
    required this.decimalPointSetting,
  });

  final List<Map<String, String>> cartImages;
  final double totalPrice;
  final ValueNotifier<List<String>> paymentMethods;
  final List<String> availablePaymentMethod;
  final String currencySymbol;
  final CustomerAddressesInfo customerAddressesInfo;
  final double decimalPointSetting;
}

class _RdbPaymentDialogState extends State<RdbPaymentDialog>
    with WidgetsBindingObserver {
  late final RdbPaymentCubit _cubit;

  /// نبضة الثانية لعدّاد الوقت المتبقّي فقط، لا علاقة لها بسؤال الحالة.
  Timer? _ticker;

  /// الانتقال إلى شاشة النجاح يحدث مرّة واحدة مهما تكرّر السؤال عن الحالة.
  bool _navigatedToSuccess = false;

  /// زرّ "فتح تطبيق المحفظة" لا يظهر إلا إذا كان التطبيق مثبّتاً فعلاً، وإلا
  /// لفتح الرابط في المتصفّح ولم ينفع الزبون بشيء.
  bool _walletAppInstalled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = RdbPaymentCubit();
    _start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _checkWalletApp();
  }

  Future<void> _checkWalletApp() async {
    final bool installed = await InstalledApps.isInstalled(
      InstalledApps.rdbWalletPackageId,
    );
    if (!mounted) return;
    setState(() => _walletAppInstalled = installed);
  }

  void _start() {
    if (widget.requestReference != null) {
      _cubit.openExisting(widget.requestReference!);
    } else {
      _cubit.createRequest(
        addressId: widget.addressId!,
        orderNote: widget.orderNote,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // الزبون عاد من تطبيق RDB: اسأل فوراً بدل انتظار النبضة التالية. وقد يكون
    // خرج ليثبّت المحفظة، فنعيد فحص التثبيت أيضاً ليظهر الزر عند عودته.
    if (state == AppLifecycleState.resumed) {
      _cubit.refreshNow();
      _checkWalletApp();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _cubit.close();
    super.dispose();
  }

  String _timeLeft(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final Duration left = expiresAt.difference(DateTime.now());
    if (left.isNegative) return '00:00';
    final String minutes = left.inMinutes.remainder(60).toString().padLeft(
      2,
      '0',
    );
    final String seconds = left.inSeconds.remainder(60).toString().padLeft(
      2,
      '0',
    );
    if (left.inHours > 0) {
      return '${left.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// ما يُرمَّز في الـ QR: `MERPAY:` + `request_code`.
  ///
  /// هذه هي الصيغة نفسها التي يرمّزها موقعنا ويقرأها ماسح تطبيق Ramaaz Digital
  /// Bank، مثل `MERPAY:mp.cwewkCUKhUSP-MjXRCTJxg`. الكود العشري
  /// (`short_code`) للكتابة اليدوية فقط، ولا يُرمَّز هنا لأن الماسح لا يفهمه.
  static const String _qrPrefix = 'MERPAY:';

  String? _qrPayload(RdbPaymentRequestModel request) {
    final String? requestCode = request.requestCode;
    if (requestCode == null || requestCode.isEmpty) return null;
    return '$_qrPrefix$requestCode';
  }

  /// الرابط العميق الذي يفتح تطبيق Ramaaz Digital Bank ومعه كود الدفع.
  ///
  /// الرابط نفسه جاهز من طرف RDB، ونحن نعلّق عليه الحمولة نفسها التي يحملها
  /// رمز الـ QR في المعامل `code`، فلا يكون هناك عقدان مختلفان.
  static const String _walletDeepLink = 'https://rdb-ms.yazan-adnof.workers.dev';

  String? _walletAppUrl(RdbPaymentRequestModel request) {
    final String? payload = _qrPayload(request);
    if (payload == null) return null;
    return '$_walletDeepLink/?code=${Uri.encodeComponent(payload)}';
  }

  /// المبلغ برقمين بعد الفاصلة: القيمة قد تصل بكسور أطول أو بلا كسور أصلاً.
  String _formattedAmount(RdbPaymentRequestModel request) {
    final double? value = double.tryParse(request.amount);
    final String amount = value == null
        ? request.amount
        : value.toStringAsFixed(2);
    return '$amount ${request.currency ?? ''}'.trim();
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    showMessage(
      LocaleKeys.rdb_code_copied.tr(),
      showInRelease: true,
      context: context,
    );
  }

  /// بعد نجاح الدفع.
  ///
  /// تُعرض شاشة نجاح الطلب المعتادة. `order_group_id` لا يأتي في استجابة طلب
  /// الدفع بعد (الاستجابة تعطي `order_ids` فقط)، فيُمرَّر فارغاً إلى أن يضيفه
  /// الباك. إن فُتحت الشاشة من شريط السلة فلا بيانات سلة معنا، فننتقل إلى
  /// قائمة الطلبات بدلاً من ذلك.
  void _goToSuccess(RdbPaymentRequestModel request) {
    GetIt.I<HomeBloc>().add(const GetCartItemEvent());
    GetIt.I<OrderBloc>().add(
      GetOrdersEvent(status: "", getWithPagination: false),
    );

    // تُغلق النافذة أولاً ثم تُفتح الشاشة التالية على الملّاح نفسه.
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();

    final RdbCheckoutSuccessArgs? args = widget.successArgs;
    if (args == null) {
      navigator.push(MaterialPageRoute<void>(builder: (_) => OrdersPage()));
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SuccessfullOrder(
          cartImages: args.cartImages,
          currencySympole: args.currencySymbol,
          currencySymbol: args.currencySymbol,
          availablePaymentMethod: args.availablePaymentMethod,
          customerAddressesInfo: args.customerAddressesInfo,
          paymentMethods: args.paymentMethods,
          totalPrice: args.totalPrice,
          decimalPointSetting: args.decimalPointSetting,
          orderAmount: double.tryParse(request.amount) ?? args.totalPrice,
          // لا دفع جزئي في هذا المسار.
          partialPaymentByWallet: 0,
          // فارغ ريثما يرسله الباك مع استجابة طلب الدفع.
          orderGroupId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RdbPaymentCubit>.value(
      value: _cubit,
      child: BlocConsumer<RdbPaymentCubit, RdbPaymentState>(
        listenWhen: (previous, current) => previous.phase != current.phase,
        listener: (context, state) {
          // نجح الدفع: ننتقل فوراً إلى شاشة نجاح الطلب بلا خطوة وسيطة.
          if (state.phase == RdbPaymentPhase.paid && !_navigatedToSuccess) {
            _navigatedToSuccess = true;
            RdbPendingPayment.clear();
            _goToSuccess(state.request!);
            return;
          }
          // للزبون دفعة معلّقة: نغلق هذه النافذة ونعرض رسالة التنبيه نفسها
          // التي تظهر عند تعديل السلة، ففيها متابعة الدفع أو إلغاؤه.
          if (state.phase == RdbPaymentPhase.blockedByPendingRequest) {
            final String? reference = RdbPendingPayment.requestReference;
            Navigator.of(context).pop();
            if (reference != null) {
              showRdbCartLockedDialogGlobally(requestReference: reference);
            } else {
              // الدفعة المعلّقة أُنشئت خارج هذا الجهاز (الموقع مثلاً)، فلا
              // مرجع لدينا نتابع به أو نلغي، ولا يرسله الباك في جسم الرفض.
              // على الأقل يعرف الزبون لماذا لم يُنشأ الطلب.
              showMessage(
                state.errorMessage?.isNotEmpty == true
                    ? state.errorMessage!
                    : LocaleKeys.rdb_cart_locked_message.tr(),
                hasError: true,
                showInRelease: true,
              );
            }
          }
        },
        builder: (context, state) {
          // نافذة منبثقة لا صفحة كاملة، مطابقةً لصفحة الدفع في الموقع.
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.rdb_payment_title.tr(),
                          style: context.textTheme.bodyLarge?.sbt.copyWith(
                            fontSize: 16.sp,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                      ),
                      // إغلاق النافذة لا يلغي الطلب: الطلب يبقى معلّقاً
                      // ويستطيع الزبون العودة إليه، وله زرّ إلغاء صريح أسفلها.
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22.h,
                          color: const Color(0xff8D8D8D),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Flexible(child: _buildBody(state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(RdbPaymentState state) {
    switch (state.phase) {
      case RdbPaymentPhase.loading:
        return Center(child: TrydosLoader(size: 40.h));
      case RdbPaymentPhase.awaitingPayment:
        return _buildAwaitingPayment(state);
      case RdbPaymentPhase.paid:
      case RdbPaymentPhase.blockedByPendingRequest:
        // ومضة ريثما ينفّذ المستمع الانتقال أو إغلاق النافذة.
        return Center(child: TrydosLoader(size: 40.h));
      case RdbPaymentPhase.expired:
        return _buildResult(
          icon: Icons.timer_off_rounded,
          color: const Color(0xff8D8D8D),
          message: LocaleKeys.rdb_payment_expired.tr(),
          actionLabel: LocaleKeys.rdb_close.tr(),
          onAction: () => Navigator.of(context).pop(),
        );
      case RdbPaymentPhase.cancelled:
        return _buildResult(
          icon: Icons.cancel_rounded,
          color: const Color(0xff8D8D8D),
          message: LocaleKeys.rdb_payment_cancelled.tr(),
          actionLabel: LocaleKeys.rdb_close.tr(),
          onAction: () => Navigator.of(context).pop(),
        );
      case RdbPaymentPhase.failed:
        return _buildResult(
          icon: Icons.error_rounded,
          color: const Color(0xffE02020),
          message: state.request?.failureReason?.isNotEmpty == true
              ? '${LocaleKeys.rdb_payment_failed.tr()}\n${state.request!.failureReason}'
              : LocaleKeys.rdb_payment_failed.tr(),
          actionLabel: LocaleKeys.rdb_close.tr(),
          onAction: () => Navigator.of(context).pop(),
        );
      case RdbPaymentPhase.error:
        return _buildResult(
          icon: Icons.wifi_off_rounded,
          color: const Color(0xffE02020),
          message: state.errorMessage?.isNotEmpty == true
              ? state.errorMessage!
              : LocaleKeys.rdb_payment_failed.tr(),
          actionLabel: LocaleKeys.try_again.tr(),
          onAction: _start,
        );
    }
  }

  Widget _buildAwaitingPayment(RdbPaymentState state) {
    final RdbPaymentRequestModel request = state.request!;
    final String code = request.shortCode ?? '';
    final String? payUrl = request.payPageUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          Text(
            LocaleKeys.rdb_amount_to_pay.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff8D8D8D),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _formattedAmount(request),
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.sbt.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 16.h),
          // صندوق الكود مضغوط في سطر واحد: العنوان والأرقام وزر النسخ. الرمز
          // هو ما يجب أن تقع عليه العين أولاً، لا الأرقام.
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xffF6F9FF),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xff388CFF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.rdb_payment_code.tr(),
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    textDirection: ui.TextDirection.ltr,
                    style: context.textTheme.bodyLarge?.sbt.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 17.sp,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                InkWell(
                  onTap: code.isEmpty ? null : () => _copyCode(code),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16.h,
                      color: const Color(0xff388CFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // رمز QR ليمسحه الزبون بتطبيق Ramaaz Digital Bank بدل كتابة الكود.
          //
          // ما دام RDB لم يفعّل صفحة الدفع فحقول `payment_url` و`qr_payload`
          // و`deep_link` تصل فارغة، فلا يبقى إلا الكود نفسه. حين يصل الرابط
          // يُرمَّز مكانه تلقائياً بلا أي تعديل هنا.
          if (_qrPayload(request) != null) ...[
            SizedBox(height: 18.h),
            Center(
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xffE5E5E5)),
                ),
                child: QrImageView(
                  data: _qrPayload(request)!,
                  size: 180.w,
                  backgroundColor: Colors.white,
                  // M بدل الافتراضي L: الرمز يُمسح عن شاشة قد تكون معتمة أو
                  // فيها انعكاس، فهامش التصحيح الأعلى يستحق بضع وحدات إضافية.
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.rdb_scan_code.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                fontSize: 12.sp,
              ),
            ),
          ],
          // نصّا "افتح تطبيق RDB…" و"يستطيع أي شخص…" أُزيلا من الواجهة بطلب
          // العميل؛ مفتاحاهما (rdb_payment_instructions و
          // rdb_payment_someone_else) باقيان في ملفات الترجمة.
          //
          // زرّ صغير يفتح تطبيق المحفظة مباشرة بالرابط العميق وعليه كود الدفع،
          // لمن لا يريد مسح الرمز ولا كتابة الأرقام.
          if (_walletAppInstalled && _walletAppUrl(request) != null) ...[
            SizedBox(height: 12.h),
            Center(
              child: TextButton.icon(
                onPressed: () => HelperFunctions.urlLauncherApplication(
                  _walletAppUrl(request)!,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff388CFF),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: const BorderSide(color: Color(0xff388CFF)),
                  ),
                ),
                icon: Icon(Icons.account_balance_wallet_outlined, size: 16.h),
                label: Text(
                  LocaleKeys.rdb_open_wallet_app.tr(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ),
          ],
          if (payUrl != null) ...[
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: () => HelperFunctions.urlLauncherApplication(payUrl),
              child: Text(LocaleKeys.rdb_open_payment_page.tr()),
            ),
          ],
          SizedBox(height: 18.h),
          if (request.expiresAt != null)
            Text(
              '${LocaleKeys.rdb_time_left.tr()}  ${_timeLeft(request.expiresAt)}',
              textAlign: TextAlign.center,
              textDirection: ui.TextDirection.ltr,
              style: context.textTheme.bodyMedium?.sbt.copyWith(
                color: const Color(0xff1D1D1D),
                fontSize: 14.sp,
              ),
            ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrydosLoader(size: 16.h),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.rdb_waiting_payment.tr(),
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff8D8D8D),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          TextButton(
            onPressed: state.isCancelling ? null : () => _cubit.cancel(),
            child: state.isCancelling
                ? TrydosLoader(size: 18.h)
                : Text(
                    LocaleKeys.rdb_cancel_payment.tr(),
                    style: context.textTheme.bodyMedium?.sbt.copyWith(
                      color: const Color(0xffE02020),
                      fontSize: 14.sp,
                    ),
                  ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildResult({
    required IconData icon,
    required Color color,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64.h, color: color),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 15.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff388CFF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
