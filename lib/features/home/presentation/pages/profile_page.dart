//import 'dart:convert';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as transform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
//import 'package:qr_flutter/qr_flutter.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/guest_phone_verification_dialog.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart'
    as dashboard;
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/presentation/pages/become_seller/become_seller_page.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/language_profile.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:trydos/service/language_service.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
// import 'package:trydos_wallet/trydos_wallet.dart';
import '../../../../common/helper/helper_functions.dart';
import '../manager/orderBloc/order_bloc.dart';
import 'Order/orders_page.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/features/chat/presentation/widgets/contact_card.dart'
    show shareInviteLink;
import 'package:trydos/features/home/presentation/pages/profile_v2/profile_tab_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/profile_menu_page_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/client_info_page_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/personal_info_page_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/body_page_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/address_list_page_v2.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/address_form_host_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/photo_page_v2.dart';
import 'package:trydos/features/home/presentation/pages/profile_v2/client_id_page_v2.dart';
import 'package:trydos/features/wallet/presentation/pages/wallet_page_v2.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart'
    show User;

class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({super.key});

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  late HomeBloc homeBloc;
  late dashboard.DashboardBloc dashboardBloc;
  late AuthBloc authBloc;
  late OrderBloc orderBloc;

  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  //late StreamSubscription walletEvents;

  // لإدارة الموارد بشكل آمن
  bool _isWalletInitialized = false;
  @override
  void initState() {
    LastPagesTracker.push("ProfileHome Page");
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    dashboardBloc = BlocProvider.of<dashboard.DashboardBloc>(context);
    //authBloc.add(CreateWalletEvent());
    orderBloc = BlocProvider.of<OrderBloc>(context);
    // طلب عملات المحفظة ثم رصيدها من سيرفر المحفظة (RDB). لا محفظة للمستخدم
    // في هذا التطبيق ولا رصيد يُعرض، فالطلب ألغي.
    /* homeBloc.add(
      GetCurrenciesForWalletEvent(
        currencySymbol:
            homeBloc.state.getCurrencyForCountryModel?.data?.currency?.code ??
            "",
      ),
    );*/
    authBloc.add(GetCustomerInfoEvent());
    dashboardBloc.add(dashboard.GetUserPermissionEvent());
    orderBloc.add(GetOrdersEvent(status: "", getWithPagination: false));
    // عناوين المستخدم: بطاقةُ العميل تعرض الافتراضيَّ منها.
    //
    // و`setDefault` يجعل البلوك نفسه يُثبّت الافتراضيّ على الخادم: يأخذ ما
    // `isDefault == 1` وإلّا أوّلَها ويُرسل `SetCustomerAddressDefaultEvent`
    // — وهو ما تفعله السلّة وشاشةُ عنوان التوصيل. فلا زرَّ «اجعله
    // الافتراضيّ» في اللوح الجديد، ولا حاجة إليه.
    orderBloc.add(GetCustomerAddressesEvent(setDefault: true));
    homeBloc.add(UpdateProfileEvent(changeStatusToInit: true));
    // walletEvents = authEvents.listen((evt) async {
    //   if (evt.toString() == 'AuthEvent.unauthenticated' &&
    //       (prefsRepository.isVerifiedPhone ?? false)) {
    //     prefsRepository.setVerifiedPhone(false);
    //     prefsRepository.setVerifiedPhonePeforeExpiredToken(true);
    //     await Future.delayed(const Duration(seconds: 1));

    //     // استخدم SchedulerBinding لتأخير العملية بعد انتهاء البناء
    //     if (mounted) {
    //       SchedulerBinding.instance.addPostFrameCallback((_) {
    //         if (mounted && Navigator.of(context).canPop()) {
    //           Navigator.of(context).pop();
    //         }
    //       });
    //     }

    //     await Future.delayed(const Duration(seconds: 1));
    //     isVerified.value = false;

    //     authBloc.add(
    //       SendOtpEvent(phone: prefsRepository.myPhoneNumber!, isViaWhatsApp: 1),
    //     );
    //   }
    // });

    // لاحقًا إذا لم تعد بحاجة:

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //  walletEvents.cancel();

    // تنظيف موارد المحفظة
    _cleanupWallet();

    super.dispose();
  }

  /// تنظيف موارد المحفظة بشكل آمن
  Future<void> _cleanupWallet() async {
    if (_isWalletInitialized) {
      try {
        // يمكنك إضافة طلب لإغلاق المحفظة إذا كانت المكتبة توفرها
        // await TrydosWallet.dispose();
        _isWalletInitialized = false;
      } catch (e) {
        devLog('Error cleaning up wallet: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _profileV2();
  }

  /// Refresh after a guest verifies their phone through
  /// [GuestPhoneVerificationDialog].
  void _onGuestVerified() {
    // لا طلب لرصيد المحفظة بعد الآن (سيرفر RDB معطّل من جهتنا).
    /* homeBloc.add(
      GetCurrenciesForWalletEvent(
        currencySymbol:
            homeBloc.state.getCurrencyForCountryModel?.data?.currency?.code ??
            "",
      ),
    );*/
    orderBloc.add(GetOrdersEvent(status: "", getWithPagination: false));
    dashboardBloc.add(dashboard.GetUserPermissionEvent());
  }

  /*  void _showShareAccountViaQr(BuildContext context) {
    if (prefsRepository.isVerifiedPhone == false) {
      showWarningMessage(context, LocaleKeys.you_must_login_first.tr());
      return;
    }
    final qrPayload = jsonEncode(_buildShareableAccountPayload());
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.share_account_via_qr_title.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1D1D1D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  LocaleKeys.share_account_via_qr_hint.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: const Color(0xff8D8D8D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xffF0F0F0)),
                  ),
                  child: QrImageView(
                    data: qrPayload,
                    size: 220.r,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1D1D1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
*/
  /*Map<String, dynamic> _buildShareableAccountPayload() {
    return {
      "idToken": prefsRepository.idToken ?? "",
      "name": prefsRepository.myMarketName ?? "",
      "userMarketPhone": prefsRepository.myPhoneNumber ?? "",
      "userMarketId": prefsRepository.myMarketId ?? "",
      "userCountryIso": prefsRepository.countryIso ?? "",
      "userMarketToken": prefsRepository.marketToken ?? "",
      "language": prefsRepository.language ?? "",
      "userVerifiedPhone": prefsRepository.isVerifiedPhone ?? "",
      "userUserChoosedCountryIso": prefsRepository.userChoosedCountryIso ?? "",
    };
  }*/

  /// فتح المحفظة بشكل آمن مع ضمان الإغلاق
  // فتح شاشة المحفظة الخارجية. معطّلة مع باقي ما يخصّ المحفظة.
  /*
  Future<void> _initializeAndOpenWallet() async {
    if (!mounted) return;

    // try {
    //   // تهيئة المحفظة
    //   TrydosWallet.init(
    //     TrydosWalletConfig(
    //       baseUrl: dotenv.env['WALLET_URL'] ?? '', // رابط الـ API
    //       token: prefsRepository.walletToken, // استخدم القيمة الفعلية
    //       languageCode: LanguageService.languageCode, // استخدم اللغة الحالية
    //       allowBadCertificate: true, // true للتطوير فقط عند خطأ SSL
    //     ),
    //   );

    //   _isWalletInitialized = true;

    //   // فتح المحفظة
    //   if (mounted) {
    //     await Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) => BlocProvider(
    //           create: (context) => WalletBloc(),
    //           child: const TrydosWalletWelcomeScreen(),
    //         ),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   print('Error initializing wallet: $e');
    //   if (mounted) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text('خطأ في فتح المحفظة: $e')));
    //   }
    // } finally {
    //   // التأكد من تنظيف الموارد حتى عند حدوث خطأ
    //   if (_isWalletInitialized && !mounted) {
    //     await _cleanupWallet();
    //   }
    // }
  }
  */
  /* --------------------------- تبويب الملفّ الجديد -------------------------- */

  /// تبويب الملفّ بتصميم الويب — [ProfileTabV2].
  ///
  /// الصفحة تصميمٌ خالص، والمنطق كلّه هنا كما كان. وما في الصفحة القديمة
  /// ولا موضع له في اللوح الجديد بقي معلَّقاً في [_profileV2Dropped] ليُقرأ،
  /// لا محذوفاً.
  Widget _profileV2() {
    return Scaffold(
      backgroundColor: XdColors.white,
      body: SafeArea(
        // الجسم يمتدّ تحت الشريط السفليّ، والغرفة داخل [ProfileTabV2].
        bottom: false,
        child: SingleChildScrollView(
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) =>
                p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
                p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus ||
                p.verifyOtpFromGuestStatus != c.verifyOtpFromGuestStatus ||
                p.getCustomerInfoStatus != c.getCustomerInfoStatus,
            builder: (context, _) {
              return BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) =>
                    p.updateProfileStatus != c.updateProfileStatus ||
                    // معلوماتُ المستخدم تحمل التوثيق، وبه تسقط بطاقةُ
                    // «حساب غير موثّق».
                    p.userInfo != c.userInfo ||
                    p.getStartingSettingsStatus != c.getStartingSettingsStatus,
                builder: (context, homeState) {
                  return BlocBuilder<OrderBloc, OrderState>(
                    buildWhen: (p, c) =>
                        p.orderTotalSize != c.orderTotalSize ||
                        p.listOfAddressInfoClassToSave?.length !=
                            c.listOfAddressInfoClassToSave?.length ||
                        p.getOrdersModel?[""]?.paginationStatus !=
                            c.getOrdersModel?[""]?.paginationStatus,
                    builder: (context, orderState) => ProfileTabV2(
                      clientId: prefsRepository.myMarketId ?? '',
                      name: prefsRepository.myMarketName ?? '',
                      phone: _phoneV2(),
                      address: _addressV2(),
                      photo: prefsRepository.myProfilePhoto ?? '',
                      ordersValue:
                          '${orderState.orderTotalSize} '
                          '${LocaleKeys.action.tr()}',
                      // رصيد المحفظة: لا طلب له (سيرفر RDB معطّل من جهتنا)،
                      // فيبقى السطر فارغاً حتّى يُعاد الطلب. الويب يكتب
                      // `${walletUsd} USD`.
                      walletValue: '',
                      languageName: _languageNameV2(homeState),
                      onOpenCard: _openProfileMenuV2,
                      onOpenQr: _openClientIdV2,
                      onOpenPhoto: _openPhotoV2,
                      onOpenOrders: _openOrdersV2,
                      onOpenWallet: _openWalletV2,
                      onOpenPromo: _openPromoV2,
                      onRow: _openRowV2,
                      onOpenAddress: _openAddressesV2,
                      onOpenName: _openUserInfoV2,
                      verified: _verifiedV2,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// الحساب موثَّق.
  ///
  /// مصدران: `isPhoneVerified` من الخادم في نموذج المستخدم، و`isVerifiedPhone`
  /// علَمٌ محلّيّ في التفضيلات. وأحدُهما يكفي — فالعلَم المحلّيّ قد يتخلّف عن
  /// الخادم بعد توثيقٍ جرى في جهازٍ آخر أو قبل أن يُحدَّث.
  bool get _verifiedV2 =>
      homeBloc.state.userInfo?.isPhoneVerified == 1 ||
      (prefsRepository.isVerifiedPhone ?? false);

  /// الهاتف كما كانت الصفحة القديمة تكتبه: أقلّ من أربعة أرقامٍ لا يُكتب،
  /// وغيرُ المصدَّر بـ`+` يُصدَّر به.
  String _phoneV2() {
    final String phone = prefsRepository.myPhoneNumber ?? '';
    if (phone.length < 4) return '';
    return phone.startsWith('+') ? phone : '+$phone';
  }

  /// عنوان المستخدم الأوّل، أو فراغٌ فيكتب التصميم «أضف عنواناً !».
  ///
  /// من `OrderState` لا `HomeState`: هناك تعيش قائمةُ العناوين فعلاً
  /// (`listOfAdressInfoClassToSave` في `HomeState` معامِلٌ في `copyWith` بلا
  /// حقلٍ يحمله). والافتراضيُّ أوّلاً إن وُجد، وإلّا الأوّل.
  String _addressV2() {
    final List<CustomerAddressesInfo> list =
        orderBloc.state.listOfAddressInfoClassToSave ??
        <CustomerAddressesInfo>[];
    if (list.isEmpty) return '';
    for (final CustomerAddressesInfo a in list) {
      if (a.isDefault == 1) return a.address ?? '';
    }
    return list.first.address ?? '';
  }

  /// اسم اللغة بلغتها — منطق `_languageWidget` نفسه.
  String _languageNameV2(HomeState state) {
    final List<Language> languages = state.startingSetting?.languages ?? [];
    final int at = languages.indexWhere(
      (Language e) =>
          e.code ==
          (LanguageService.isKurdish ? "ku" : LanguageService.languageCode),
    );
    if (at == -1) return '';
    return languages[at].name ?? '';
  }

  /// بطاقة العميل: حارسُ الزائر من `_personInfoWidget` نفسه، ثمّ قائمةُ
  /// الملفّ — `settings/profile` في الويب.
  void _openProfileMenuV2() {
    if (!(prefsRepository.isVerifiedPhone ?? false)) {
      GuestPhoneVerificationDialog.show(context, onVerified: _onGuestVerified);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileMenuPageV2(
          onClientInfo: _openClientInfoV2,
          onPersonalInfo: _openUserInfoV2,
          onBody: _openBodyV2,
          onAddress: _openAddressesV2,
        ),
      ),
    );
  }

  /// صورة الحساب — `settings/photo`.
  ///
  /// الإضافة والتغيير والإزالة، بمنطق `AddPhotoProfilePage` نفسه.
  void _openPhotoV2() {
    if (!(prefsRepository.isVerifiedPhone ?? false)) {
      GuestPhoneVerificationDialog.show(context, onVerified: _onGuestVerified);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PhotoPageV2()))
        .then((_) => setState(() {}));
  }

  /// معرّف العميل — `settings/client-id`.
  void _openClientIdV2() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientIdPageV2(
          clientId: prefsRepository.myMarketId ?? '',
          name: prefsRepository.myMarketName ?? '',
          phone: _phoneV2(),
          verified: _verifiedV2,
        ),
      ),
    );
  }

  /// معلومات العميل — `settings/profile/client-info`.
  ///
  /// قراءةٌ فقط. و«عميل منذ» فارغٌ: لا حقل عندنا لتاريخ إنشاء الحساب
  /// (`profile.clientSince` في الويب). وزرّا الطلب بلا فعل — والويب نفسه
  /// يقول إنّ «لا خدمة تستقبل هذين الطلبين بعد».
  void _openClientInfoV2() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientInfoPageV2(
          clientId: prefsRepository.myMarketId ?? '',
          phone: _phoneV2(),
          verified: _verifiedV2,
          onOpenQr: _openClientIdV2,
        ),
      ),
    );
  }

  /// العناوين — `settings/profile/address`.
  ///
  /// البيانات والأحداث من `OrderBloc` كما كانت في `ProfileAddressInfoPage`:
  /// الجلب والحذف، والإضافة والتعديل عبر [AddressFormHostV2].
  ///
  /// و«الافتراضيّ» لا يرسمه اللوح ولا يحتاج زرّاً: `setDefault` يجعل البلوك
  /// يُثبّته بنفسه بعد كلّ جلب، كما تفعل السلّة.
  void _openAddressesV2() {
    orderBloc.add(GetCustomerAddressesEvent(setDefault: true));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocBuilder<OrderBloc, OrderState>(
          buildWhen: (p, c) =>
              p.listOfAddressInfoClassToSave?.length !=
              c.listOfAddressInfoClassToSave?.length,
          builder: (context, state) => AddressListPageV2(
            addresses: _addressRowsV2(state),
            onAdd: () => _openAddressFormV2(null),
            onEdit: (AddressRowV2 a) =>
                _openAddressFormV2(_addressByIdV2(state, a.id)),
            onDelete: (AddressRowV2 a) => orderBloc.add(
              DeleteAdressInfoClassEvent(adressInfoClassId: int.tryParse(a.id)),
            ),
          ),
        ),
      ),
    );
  }

  /// يفتح نموذج العنوان — `settings/profile/address/new`.
  ///
  /// بخريطتنا الحقيقيّة بدل صورة الملفّ، وبدولنا المسموحة بدل الأربع
  /// الوهميّة — انظر [AddressFormHostV2].
  void _openAddressFormV2(CustomerAddressesInfo? editing) {
    final String? iso = prefsRepository.userCountryIsAvailable == 1
        ? prefsRepository.userChoosedCountryIso
        : prefsRepository.countryIso;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddressFormHostV2(
          countries:
              homeBloc.state.getAllowedCountriesModel?.data?.countries ??
              <Country>[],
          initialIso: iso?.toLowerCase(),
          editing: editing,
        ),
      ),
    );
  }

  /// العنوان الذي يحمل هذا المعرّف في حالة الطلبات.
  CustomerAddressesInfo? _addressByIdV2(OrderState state, String id) {
    for (final CustomerAddressesInfo a
        in state.listOfAddressInfoClassToSave ?? <CustomerAddressesInfo>[]) {
      if (a.id?.toString() == id) return a;
    }
    return null;
  }

  /// يُحوّل عناوين `OrderState` إلى ما تعرضه الشاشة.
  ///
  /// وسطرُ المنطقة في الملفّ خمسةُ أجزاء: الشارع والبلدة عاديّان، ثمّ
  /// القضاء والمحافظة والدولة Medium — فتُقرأ من `regionDetails` بالترتيب
  /// نفسه، ويُسقَط الفارغ منها.
  List<AddressRowV2> _addressRowsV2(OrderState state) {
    final List<CustomerAddressesInfo> list =
        state.listOfAddressInfoClassToSave ?? <CustomerAddressesInfo>[];
    return list.map((CustomerAddressesInfo a) {
      final RegionDetails? r = a.regionDetails;
      final List<String> area = <String?>[
        r?.street,
        r?.town,
        r?.city,
        r?.province,
        r?.country,
      ].whereType<String>().where((String e) => e.isNotEmpty).toList();
      return AddressRowV2(
        id: a.id?.toString() ?? '',
        title: a.address ?? '',
        area: area,
        detail: a.addressDetail ?? '',
      );
    }).toList();
  }

  /// قياسات الجسم — `settings/profile/body`.
  ///
  /// لا زرّ حفظٍ في اللوح، فيُرسَل `UpdateProfileEvent` عند المغادرة إن تغيّر
  /// شيء. ومقاسُ القدم تصميمٌ فقط: لا حقل له في `UpdateProfileEvent`.
  void _openBodyV2() {
    final User? info = homeBloc.state.userInfo;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BodyPageV2(
          height: info?.tall?.toString() ?? '',
          weight: info?.weight?.toString() ?? '',
          foot: '',
          onSave: ({required String height, required String weight}) {
            homeBloc.add(UpdateProfileEvent(tall: height, weight: weight));
          },
        ),
      ),
    );
  }

  /// المعلومات الشخصيّة — `settings/profile/personal-info`.
  ///
  /// الصفحة تصميمٌ خالص، والحفظ هنا: `UpdateProfileEvent` نفسه الذي كان
  /// يرسله `ProfilePersonalInfoPage`، بترميز الجنس نفسه (1 و2 و3).
  ///
  /// ولا هاتف في هذا اللوح — الويب يضعه في «معلومات العميل» وتغييرُه طلبٌ —
  /// فلا يلزم توثيقُ الرقم الجديد الذي كانت الصفحة القديمة تفتحه.
  void _openUserInfoV2() {
    if (!(prefsRepository.isVerifiedPhone ?? false)) {
      GuestPhoneVerificationDialog.show(context, onVerified: _onGuestVerified);
      return;
    }
    final User? info = homeBloc.state.userInfo;
    // حسابُ الزائر يحمل اسم "guest" وبريداً على "@guest.com": لا يُعرضان.
    final String name = info?.name == 'guest' ? '' : (info?.name ?? '');
    final String email = (info?.email?.contains('@guest.com') ?? false)
        ? ''
        : (info?.email ?? '');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) => p.updateProfileStatus != c.updateProfileStatus,
          builder: (context, state) => PersonalInfoPageV2(
            name: name,
            email: email,
            gender: PersonalGenderV2.fromName(info?.gender?.name),
            // لا حقل لتوثيق البريد في نموذجنا، والويب يُرمّد غير الموثَّق.
            // فيُعدّ موجوداً موثَّقاً حتّى يصير للخادم رأيٌ فيه.
            emailVerified: email.isNotEmpty,
            busy: state.updateProfileStatus == UpdateProfileStatus.loading,
            saved: state.updateProfileStatus == UpdateProfileStatus.success,
            onSave:
                ({
                  required String name,
                  required String email,
                  required PersonalGenderV2? gender,
                }) {
                  homeBloc.add(
                    UpdateProfileEvent(
                      name: name,
                      email: email,
                      gender: gender?.code,
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }

  /// بطاقة الطلبات: منطق `_ordersWidget` نفسه.
  void _openOrdersV2() {
    if (!(prefsRepository.isVerifiedPhone ?? false)) {
      GuestPhoneVerificationDialog.show(context, onVerified: _onGuestVerified);
      return;
    }
    HelperFunctions.slidingNavigation(context, OrdersPage());
  }

  /// بطاقة المحفظة تفتح رصيد Trydos — `settings/wallet` في الويب.
  ///
  /// وشاشتُها تصميمٌ على بيانات الملفّ حتّى تجهز مسارات الخادم؛ طبقةُ
  /// البيانات والبلوك قائمةٌ في `features/wallet/`، وتشغيلُها سطرٌ واحد
  /// (`kWalletApisLive`).
  void _openWalletV2() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WalletPageV2()));
  }

  /// بطاقات العروض الثلاث.
  void _openPromoV2(int index) {
    switch (index) {
      // «أنشئ ملف قياساتك» → `settings/profile/body`.
      case 0:
        _openBodyV2();
      // «حساب غير موثّق» → `settings/profile/personal-info`، وهي عندنا
      // شاشةُ معلومات المستخدم.
      case 1:
        _openUserInfoV2();
      // «احصل على Trydos للأعمال» — لا فعل لها في الويب، وهي عندنا مكانُ صفّ
      // «كن بائعاً في Trydos» القديم: منطقُه نفسه، في موضعه من اللوح الجديد.
      case 2:
        _openBecomeSellerV2();
    }
  }

  /// منطق صفّ «كن بائعاً» القديم حرفياً.
  void _openBecomeSellerV2() {
    if (!(prefsRepository.isVerifiedPhone ?? false)) {
      GuestPhoneVerificationDialog.show(context, onVerified: _onGuestVerified);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const BecomeSellerPage(),
        ),
      ),
    );
  }

  /// صفوف القائمة الثمانية.
  void _openRowV2(int index) {
    switch (index) {
      // الإعدادات وشروط الاستخدام والمعلومات القانونيّة ومن نحن: لا فعل لها
      // في الويب، ولم يكن لها فعلٌ عندنا أصلاً (`_actionWidget` بلا لمسة).
      case 0:
      case 1:
      case 2:
      case 3:
        break;
      // مشاركة التطبيق: الويب يشارك عنوان الموقع، ونحن نشارك رابط الدعوة —
      // وهو رابط التطبيق نفسه ببلد المستخدم ولغته.
      case 4:
        shareInviteLink();
      // اللغة: الصفحة نفسها التي كان يفتحها `_languageWidget`.
      case 5:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfileLanguagePage()),
        );
      // سجلّ الدخول: صفٌّ جديد في اللوح، ولا شاشة له عندنا.
      case 6:
        break;
      // تسجيل الخروج: صفٌّ جديد في اللوح. وتسجيلُ الخروج عندنا لا يوجد إلّا
      // في حوار أدوات المطوّر (`_showDevToolsV2` في الشريط السفليّ)، فلم
      // يُربَط بزرٍّ للمستخدم. تصميمٌ فقط حتّى يُقرَّر.
      case 7:
        break;
    }
  }

  // ما كان في الصفحة القديمة ولا موضع له في اللوح الجديد.
  //
  // معلَّقٌ لا محذوف، فمنطقُه قائمٌ ومواضعُ استعماله باقية:
  //
  //  - **بطاقة البائعين** (`SelectShopPage`): كانت تظهر لمن له متاجر.
  //  - **قائمة التحقّق** (`ChecklistPage`).
  //  - **مقارنة المنتجات** (`CompareProductsPage`).
  //  - **مُنتقي البلد** (`ProfileCountryPage`): اللوح الجديد يُبقي اللغة
  //    وحدها صفّاً.
  //
  // و«كن بائعاً» لم يسقط: صار بطاقة العرض الثالثة ([_openBecomeSellerV2]).
  // وأمّا الصفحة القديمة كلُّها فهي في تاريخ المستودع، على فرع `dev_new`.
}
