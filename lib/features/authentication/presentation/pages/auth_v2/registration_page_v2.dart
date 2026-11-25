/// صفحةُ الدخول بالتصميم الجديد — تُدير شاشاتِ `auth_v2` على **منطق
/// التسجيل القائم بعينه**.
///
/// > «الاختلافُ تصاميمُ، أمّا المنطقُ فهو نفسُه.»
///
/// فكلُّ حدثٍ وكلُّ شرطٍ وكلُّ رقمٍ أدناه مقروءٌ من المسار القديم:
/// `first_registeration_page.dart` و`insert_phone_tab.dart` و
/// `verification_methods.dart` و`verify_otp.dart` و`adding_name.dart`
/// وصفحاتِ النتيجة الأربع. وفي كلّ موضعٍ يُسمّى مصدرُه.
///
/// والفرقُ في الشكل لا في الحكم: ما كان في القديم صفحةً مستقلّةً يُنتقل
/// إليها بـ`context.go` (غيرُ مسجَّل · مسجَّلٌ سلفاً · دخولٌ ناجح · تمّ
/// التسجيل) صار **خطوةً** في المسرح، كما يرسمه التصميم الجديد. ومقصدُها
/// الأخيرُ واحد: صفحةُ التطبيق.
library;

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/qr_account_import.dart';
import 'package:trydos/features/wallet/presentation/pages/wallet_pin_boxes.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

import 'auth_stage_v2.dart';
import 'enter_phone_screen_v2.dart';
import 'enter_pin_screen_v2.dart';
import 'get_started_screen_v2.dart';
import 'input_name_screen_v2.dart';
import 'outcome_screen_v2.dart';
import 'qr_sheet_v2.dart';
import 'select_method_screen_v2.dart';
import 'success_screen_v2.dart';
import 'terms_screen_v2.dart';

class RegistrationPageV2 extends StatefulWidget {
  const RegistrationPageV2({super.key, this.fromLogOut = false});

  /// خروجٌ من الحساب: لا إغلاقَ للصفحة ولا رجوع — كما في القديم.
  final bool? fromLogOut;

  @override
  State<RegistrationPageV2> createState() => _RegistrationPageV2State();
}

class _RegistrationPageV2State extends State<RegistrationPageV2> {
  final PrefsRepository _prefs = GetIt.I<PrefsRepository>();
  late final AuthBloc _auth = BlocProvider.of<AuthBloc>(context);
  late final AppBloc _app = BlocProvider.of<AppBloc>(context);

  AuthStep _step = AuthStep.getStarted;
  bool _forward = true;

  /// `fromLogin` في القديم: دخولٌ أم إنشاءُ حساب.
  AuthFlow _flow = AuthFlow.signUp;
  AuthMethod _method = AuthMethod.sms;

  /// الرقمُ كما يُكتب: أرقامٌ فقط، ومفتاحُ الدولة في أوّله بلا «+» — وهو ما
  /// يأخذه الحقلُ القديم ويُمرّره بعد حذف الفراغات.
  String _typed = '';
  String _name = '';

  /// نافذةُ QR مفتوحة.
  bool _qr = false;

  /// رسالةٌ تحت الحقل أو تحت صناديق الرمز.
  String? _error;

  WalletPinState _pin = WalletPinState.typing;

  /// يُعاد تركيبُ الصناديق لتفرغ بعد رمزٍ خاطئ — `key` في الويب.
  int _round = 0;

  // ── المؤقّت والمحاولات: أرقامُ `verify_otp.dart` ومفاتيحُه نفسُها ──────

  /// نافذةُ المؤقّت دقيقتان.
  static const int _windowSeconds = 120;

  /// وخمسُ محاولاتٍ في كلّ نافذة، يُحفظ ما تبقّى منها مع المؤقّت نفسِه كي
  /// لا يُستعاد العدّادُ كاملاً بإغلاق الشاشة وفتحها.
  static const int _maxAttemptsPerWindow = 5;

  int _left = 0;
  int _attemptsLeft = _maxAttemptsPerWindow;
  int _attempt = 1;
  Timer? _tick;

  /// مهلةُ إعادة المحاولة بعد فشل الإرسال — 60 ثانية في
  /// `verification_methods.dart`.
  static const int _retrySeconds = 60;
  int _retryLeft = 0;
  Timer? _retryTick;

  @override
  void initState() {
    super.initState();
    // صفحةٌ تُفتح والمؤقّتُ ما زال يعمل: نُكمل على ما تبقّى من وقتٍ
    // ومحاولات، ولا نبدأ نافذةً جديدة — شرطُ `verify_otp.dart` نفسُه.
    if (_prefs.isTimerForOtpRunning ?? false) _resumeWindowOrStart();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFFFFF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // القديمُ يُطفئ عَلَمَ المؤقّت عند مغادرة الصفحة.
    _prefs.setTimerForOtpRunning(false);
    _tick?.cancel();
    _retryTick?.cancel();
    super.dispose();
  }

  // ── الرقمُ ودولتُه: قاعدةُ `insert_phone_tab.dart` بحروفها ──────────────

  static const Country _noCountry = Country(
    name: '',
    flag: '',
    code: '',
    dialCode: '',
    minLength: 0,
    maxLength: 0,
  );

  Country get _country => countries.firstWhere(
    (Country c) => '+$_typed'.toLowerCase().startsWith(c.dialCode.toLowerCase()),
    orElse: () => _noCountry,
  );

  /// يصلح للإرسال: الدولةُ معروفةٌ وطولُ الرقم بين حدَّيها بثلاثةٍ سماحاً من
  /// كلّ طرف — القاعدةُ نفسُها، فلا يتبدّل ما يُقبل.
  bool get _phoneValid {
    if (_typed.isEmpty) return false;
    final Country c = _country;
    if (c.code.isEmpty) return false;
    final int len = _typed.replaceAll(' ', '').length;
    return len >= (c.minLength + c.dialCode.length - 3) &&
        len <= (c.maxLength + c.dialCode.length + 3);
  }

  /// الرقمُ كما يذهب إلى الخادم: بلا فراغات — `phoneNumber.replaceAll(' ','')`.
  String get _phone => _typed.replaceAll(' ', '');

  // ── المؤقّت ────────────────────────────────────────────────────────────

  /// نافذةٌ جديدة: دقيقتان ومحاولاتٌ كاملة — `_onResendSucceed`.
  void _newWindow() {
    final int end =
        DateTime.now().millisecondsSinceEpoch + 1000 * _windowSeconds;
    _prefs.setOtpTimerEndTime(end);
    _prefs.setTimerForOtpRunning(true);
    _resetAttempts();
    _runClock(end);
    setState(() {
      _error = null;
      _pin = WalletPinState.typing;
      _round += 1;
    });
  }

  /// أو تُستأنف نافذةٌ جارية — `initState` في القديم: إن كان المؤقّتُ يعمل
  /// نُكمل على ما تبقّى من محاولاتٍ ومن وقت.
  void _resumeWindowOrStart() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int? saved = _prefs.otpTimerEndTime;
    if ((_prefs.isTimerForOtpRunning ?? false) && saved != null && saved > now) {
      _attemptsLeft = _prefs.otpAttemptsLeft ?? _maxAttemptsPerWindow;
      _runClock(saved);
      return;
    }
    _newWindow();
  }

  void _runClock(int endMillis) {
    _tick?.cancel();
    void update() {
      final int left =
          ((endMillis - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
      if (!mounted) return;
      setState(() => _left = left > 0 ? left : 0);
      if (_left == 0) _onEnd();
    }

    update();
    _tick = Timer.periodic(const Duration(seconds: 1), (Timer _) => update());
  }

  /// انتهى الوقت — `onEnd`: يُطفأ العلمُ ويُمحى الوقتُ ويُفتح «أعد الإرسال».
  void _onEnd() {
    _tick?.cancel();
    _prefs.setTimerForOtpRunning(false);
    _prefs.removeOtpTimerEndTime();
    _log(
      AuthScreenConst.OTP_INPUT_SCREEN,
      AnalyticsEventsConst.TIMER_EXPIRED,
      extra: <String, String>{'mission_name': _mission, 'method': _methodWord},
    );
  }

  void _resetAttempts() {
    _attemptsLeft = _maxAttemptsPerWindow;
    _prefs.setOtpAttemptsLeft(_maxAttemptsPerWindow);
  }

  /// محاولةٌ خاطئةٌ واحدة، مع كلّ رمزٍ يرفضه الخادم — `_consumeAttempt`.
  void _consumeAttempt() {
    final int left = _attemptsLeft - 1;
    _attemptsLeft = left < 0 ? 0 : left;
    _prefs.setOtpAttemptsLeft(_attemptsLeft);
  }

  /// نفدت المحاولاتُ: يُقفل الإدخالُ حتّى ينتهي الوقتُ ويُطلب رمزٌ جديد.
  bool get _locked => _attemptsLeft <= 0;


  // ── التحليلات: الأحداثُ نفسُها بأسمائها وحقولها، في مواضعها نفسِها ─────

  /// «login» أو «signup» — `mission_name` في كلّ حقيبةٍ قديمة.
  String get _mission => _flow == AuthFlow.signIn ? 'login' : 'signup';

  /// «whatsapp» أو «sms» — `method`.
  String get _methodWord =>
      _method == AuthMethod.whatsapp ? 'whatsapp' : 'sms';

  void _log(
    String screen,
    String event, {
    Map<String, String> extra = const <String, String>{},
  }) => FirebaseAnalyticsService.logEventForSession(
    executedEventName: screen,
    eventName: event,
    extraParams: extra,
  );

  /// تُسجَّل مرّةً واحدةً لكلّ دخولٍ إلى شاشة الرمز — `_eventLogged`.
  bool _pinScreenLogged = false;

  void _logPinScreenOnce() {
    if (_pinScreenLogged) return;
    _pinScreenLogged = true;
    _log(
      AuthScreenConst.OTP_INPUT_SCREEN,
      AnalyticsEventsConst.SCREEN_VIEW,
      extra: <String, String>{
        'screen_name': AuthScreenConst.OTP_INPUT_SCREEN,
        'screen_path': '',
        'platform': GlobalPlatform.MOBILE,
      },
    );
  }

  // ── الأحداث ────────────────────────────────────────────────────────────

  void _go(AuthStep step, {bool forward = true}) => setState(() {
    _step = step;
    _forward = forward;
    _error = null;
  });

  /// «لاحقاً» و«ألغِ»: تسجيلُ زائرٍ ثمّ صفحةُ التطبيق — منطقُ زرّ الإلغاء في
  /// `first_registeration_page.dart` و`number_not_registered.dart`.
  Future<void> _leave() async {
    _log(
      AnalyticsButtonsEventNameConst.register_cancel_button,
      _flow == AuthFlow.signIn
          ? AnalyticsEventsConst.CANCEL_LOGIN
          : AnalyticsEventsConst.CANCEL_SIGNUP,
      extra: <String, String>{
        'button_name': AnalyticsButtonsEventNameConst.register_cancel_button,
      },
    );
    final String? deviceId = await HelperFunctions.getDeviceId();
    if (!mounted) return;
    _auth.add(
      RegisterGuestEvent(
        oldGuestUserId: _prefs.myMarketId.toString(),
        deviceId: deviceId!,
      ),
    );
    Future<void>.delayed(
      const Duration(microseconds: 300),
      () {
        if (mounted) context.go(GRouter.config.applicationRoutes.kBasePage);
      },
    );
  }

  void _toBase() => context.go(GRouter.config.applicationRoutes.kBasePage);

  /// إرسالُ الرمز — `sendOtp` في `verification_methods.dart`.
  void _sendOtp(AuthMethod method) {
    setState(() {
      _method = method;
      _error = null;
    });
    _attempt += 1;
    _auth.add(
      SendOtpEvent(
        phone: _phone,
        isViaWhatsApp: method == AuthMethod.whatsapp ? 1 : 0,
      ),
    );
    // أوّلُ إرسالٍ هو اختيارُ الطريقة، وما بعده إعادةٌ — وهذا ما يُسجّله
    // `_onResendSucceed`.
    if (_attempt > 2) {
      _log(
        AuthScreenConst.OTP_INPUT_SCREEN,
        AnalyticsEventsConst.RESEND_OTP,
        extra: <String, String>{
          'mission_name': _mission,
          'method': _methodWord,
          'button_name': AnalyticsButtonsEventNameConst.RESEND_OTP_BUTTON,
          'attempt': _attempt.toString(),
        },
      );
    }
  }

  void _startRetryClock() {
    if (_retryTick?.isActive ?? false) return;
    _retryLeft = _retrySeconds;
    _retryTick = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() => _retryLeft -= 1);
      if (_retryLeft <= 0) t.cancel();
    });
  }

  /// اكتملت الأرقامُ الستّة — فروعُ `verify_otp.dart` نفسُها.
  ///
  /// ولا يُرسَل شيءٌ ما لم يكن `verificationId` محفوظاً، كما يشترط القديم.
  void _submitCode(String code) {
    final String? id = _prefs.verificationId;
    if (id == null || _locked) return;
    if (_flow == AuthFlow.signIn) {
      _auth.add(
        VerifyOtpSignInEvent(verificationId: id, otp: code, phone: _phone),
      );
      _log(
        AuthScreenConst.OTP_INPUT_SCREEN,
        AnalyticsEventsConst.VERIFY_OTP_SIGNIN,
        extra: <String, String>{
          'mission_name': _mission,
          'method': _methodWord,
        },
      );
      return;
    }
    _auth.add(VerifyOtpSignUpEvent(verificationId: id, otp: code));
    _log(
      AuthScreenConst.OTP_INPUT_SCREEN,
      AnalyticsEventsConst.VERIFY_OTP_SIGNUP,
      extra: <String, String>{
        'mission_name': _mission,
        'method': _methodWord,
      },
    );
  }

  /// رمزٌ صحيح: الصناديقُ تخضرّ، ثمّ بعد 700مث تُسلّم — تأخيرُ القديم نفسُه.
  void _codeAccepted() {
    _log(
      AuthScreenConst.OTP_INPUT_SCREEN,
      AnalyticsEventsConst.VERIFY_OTP,
      extra: <String, String>{
        'status': 'success',
        'attempt': _attempt.toString(),
        'mission_name': _mission,
        'method': _methodWord,
      },
    );
    setState(() => _pin = WalletPinState.valid);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _go(
        _flow == AuthFlow.signIn ? AuthStep.loginSuccess : AuthStep.inputName,
      );
    });
  }

  /// رمزٌ خاطئ: الصناديقُ تحمرّ وتُستنفد محاولة، ثمّ تفرغ.
  void _codeRejected() {
    _log(
      AuthScreenConst.OTP_INPUT_SCREEN,
      AnalyticsEventsConst.EXCEPTION,
      extra: <String, String>{
        'description': 'otp Failed',
        'context': _mission,
        'mission_name': _mission,
      },
    );
    _consumeAttempt();
    setState(() => _pin = WalletPinState.invalid);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _round += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) => _back(),
      child: MultiBlocListener(
        listeners: <BlocListener<AuthBloc, AuthState>>[
          // ذهب الرمز → خطوةُ الرمز بنافذةٍ جديدة. وفشل الإرسال → مهلةُ
          // ستّين ثانية، كما في `verification_methods.dart`.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (AuthState p, AuthState c) =>
                p.sendOtpStatus != c.sendOtpStatus,
            listener: (BuildContext context, AuthState state) {
              if (state.sendOtpStatus == SendOtpStatus.success) {
                _retryTick?.cancel();
                _retryLeft = 0;
                _newWindow();
                if (_step != AuthStep.enterPin) _go(AuthStep.enterPin);
                return;
              }
              if (state.sendOtpStatus == SendOtpStatus.failure) {
                _startRetryClock();
              }
            },
          ),
          // دخولٌ: `auth-001` تعني رقماً غيرَ مسجَّل.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (AuthState p, AuthState c) =>
                p.verifyOtpSignInStatus != c.verifyOtpSignInStatus,
            listener: (BuildContext context, AuthState state) {
              if (state.verifyOtpSignInStatus ==
                  VerifyOtpSignInStatus.failure) {
                if (state.signInErrorMessage == 'auth-001') {
                  _log(
                    AuthScreenConst.OTP_INPUT_SCREEN,
                    AnalyticsEventsConst.EXCEPTION,
                    extra: <String, String>{
                      'description': 'phone Number Not Registered',
                      'context': _mission,
                      'mission_name': _mission,
                    },
                  );
                  _go(AuthStep.notRegistered);
                  return;
                }
                _codeRejected();
                return;
              }
              if (state.verifyOtpSignInStatus ==
                  VerifyOtpSignInStatus.success) {
                _codeAccepted();
              }
            },
          ),
          // وإنشاءُ حساب: `auth-001` تعني رقماً مسجَّلاً سلفاً.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (AuthState p, AuthState c) =>
                p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
            listener: (BuildContext context, AuthState state) {
              if (state.verifyOtpSignUpStatus ==
                  VerifyOtpSignUpStatus.failure) {
                if (state.signUpErrorMessage == 'auth-001') {
                  _log(
                    AuthScreenConst.OTP_INPUT_SCREEN,
                    AnalyticsEventsConst.EXCEPTION,
                    extra: <String, String>{
                      'description': 'user Already Exists',
                      'context': _mission,
                      'mission_name': _mission,
                    },
                  );
                  _go(AuthStep.alreadyRegistered);
                  return;
                }
                _codeRejected();
                return;
              }
              if (state.verifyOtpSignUpStatus ==
                  VerifyOtpSignUpStatus.success) {
                _codeAccepted();
              }
            },
          ),
          // الاسم — `adding_name.dart`.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (AuthState p, AuthState c) =>
                p.updateNameStatus != c.updateNameStatus,
            listener: (BuildContext context, AuthState state) {
              if (state.updateNameStatus == UpdateNameStatus.failure) {
                showWarningMessage(
                  context,
                  LocaleKeys.failed_to_save_name.tr(),
                );
                return;
              }
              if (state.updateNameStatus == UpdateNameStatus.success) {
                _go(AuthStep.signupSuccess);
              }
            },
          ),
        ],
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AuthStageV2(
                  step: _step,
                  forward: _forward,
                  child: _screen(),
                ),
              ),
              // نافذةُ QR فوق الكلّ.
              QrSheetV2(
                open: _qr,
                onClose: () => setState(() => _qr = false),
                onPayload: (String raw) async {
                  final bool ok = await importQrAccount(raw);
                  if (ok && mounted) {
                    setState(() => _qr = false);
                    _toBase();
                  }
                  return ok;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// زرُّ الرجوع والإكس: من الهاتف أو الشروط → «ابدأ»، ومن الطريقة أو الرمز
  /// أو الاسم → الهاتف. وفي «ابدأ» يُخرج من المسار — خريطةُ
  /// `first_registeration_page.dart` نفسُها (2|1 → 0، و3..5 → 2).
  void _back() {
    if (widget.fromLogOut ?? false) return;
    switch (_step) {
      case AuthStep.terms:
      case AuthStep.enterPhone:
        _go(AuthStep.getStarted, forward: false);
      case AuthStep.selectMethod:
      case AuthStep.enterPin:
      case AuthStep.inputName:
      case AuthStep.notRegistered:
      case AuthStep.alreadyRegistered:
        _go(AuthStep.enterPhone, forward: false);
      case AuthStep.getStarted:
        _leave();
      // النجاحُ لا رجوعَ منه، والمعاينةُ والمنتقي وQR ليسا خطوتي مسار هنا.
      case AuthStep.loginSuccess:
      case AuthStep.signupSuccess:
      case AuthStep.quickPreview:
      case AuthStep.countryPicker:
      case AuthStep.qrLogin:
        break;
    }
  }

  Widget _screen() {
    switch (_step) {
      case AuthStep.getStarted:
      case AuthStep.quickPreview:
      case AuthStep.countryPicker:
      case AuthStep.qrLogin:
        return GetStartedScreenV2(
          onExistingAccount: () {
            setState(() => _flow = AuthFlow.signIn);
            _go(AuthStep.enterPhone);
          },
          onNewCustomer: () {
            setState(() => _flow = AuthFlow.signUp);
            _go(AuthStep.terms);
          },
          onLater: _leave,
          onScanQr: () => setState(() => _qr = true),
        );

      case AuthStep.terms:
        return TermsScreenV2(
          onAgree: () => _go(AuthStep.enterPhone),
          onLater: _leave,
        );

      case AuthStep.enterPhone:
        final Country c = _country;
        return EnterPhoneScreenV2(
          flow: _flow,
          phone: _typed,
          onPhone: (String v) => setState(() => _typed = v),
          onSubmit: () {
            if (!_phoneValid) return;
            FocusScope.of(context).unfocus();
            _log(
              AuthScreenConst.PHONE_NUMBER_INPUT_SCREEN,
              AnalyticsEventsConst.CONFIRM_PHONE_NUMBER,
              extra: <String, String>{
                'button_name':
                    AnalyticsButtonsEventNameConst.CONFIRM_PHONE_NUMBER_BUTTON,
                'input_valid': 'true',
                'mission_name': _mission,
              },
            );
            _go(AuthStep.selectMethod);
          },
          // مفتاحُ الدولة يُرسم بـ«+» في الحقل، فيُمرَّر بلا واحدة.
          dialCode: c.dialCode.replaceFirst('+', ''),
          flag: c.code,
          valid: _phoneValid,
          onClose: _back,
        );

      case AuthStep.selectMethod:
        return SelectMethodScreenV2(
          flow: _flow,
          phone: _phone,
          method: _method,
          onMethod: _sendOtp,
          onChangeNumber: () => _go(AuthStep.enterPhone, forward: false),
          onClose: _back,
          blocked: _retryLeft > 0,
          error: _retryLeft > 0
              ? '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()} ${_retryLeft}s'
              : null,
        );

      case AuthStep.enterPin:
        _logPinScreenOnce();
        return EnterPinScreenV2(
          key: ValueKey<int>(_round),
          flow: _flow,
          phone: _phone,
          method: _method,
          secondsLeft: _left,
          state: _pin,
          expired: _left == 0,
          error: _locked
              ? LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()
              : _error,
          onComplete: _submitCode,
          onResend: _left == 0 ? () => _sendOtp(_method) : null,
          onChangeNumber: () => _go(AuthStep.enterPhone, forward: false),
          onChangeMethod: () => _go(AuthStep.selectMethod, forward: false),
          onClose: _back,
        );

      case AuthStep.notRegistered:
        // «أنشئ حساباً جديداً وتابع» → خطوةُ الاسم، كما ينتقل اللوحُ القديم
        // إلى `AddingName` في صفحته.
        return OutcomeScreenV2(
          outcome: AuthOutcome.notRegistered,
          phone: _phone,
          onPrimary: () {
            setState(() => _flow = AuthFlow.signUp);
            _go(AuthStep.inputName);
          },
          onCancel: _leave,
          onClose: _back,
        );

      case AuthStep.alreadyRegistered:
        // «ادخل وتابع» → صفحةُ التطبيق، كما يفعل زرُّ اللوح القديم.
        return OutcomeScreenV2(
          outcome: AuthOutcome.alreadyRegistered,
          phone: _phone,
          onPrimary: _toBase,
          onCancel: _leave,
          onClose: _back,
        );

      case AuthStep.inputName:
        return InputNameScreenV2(
          name: _name,
          onName: (String v) => setState(() => _name = v),
          onSubmit: () {
            if (_name.trim().isEmpty) return;
            FocusScope.of(context).unfocus();
            _auth.add(UpdateNameEvent(name: _name));
          },
          onClose: _back,
        );

      case AuthStep.loginSuccess:
        // ثانيةٌ ثمّ صفحةُ التطبيق — مهلةُ `login_successfully.dart` نفسُها.
        return SuccessScreenV2(
          variant: AuthSuccess.login,
          name: _prefs.myMarketName,
          delay: const Duration(seconds: 1),
          onDone: _toBase,
        );

      case AuthStep.signupSuccess:
        // ولوحُ «تمّ التسجيل» ينتظر لمسةً في القديم، وفي الجديد يمضي وحدَه.
        // ومقصدُه مقصدُ زرّه الثاني: صفحةُ التطبيق بلا تبديل تبويب.
        return SuccessScreenV2(
          variant: AuthSuccess.signup,
          onDone: () {
            _app.add(ChangeBasePage(0));
            _toBase();
          },
        );
    }
  }
}
