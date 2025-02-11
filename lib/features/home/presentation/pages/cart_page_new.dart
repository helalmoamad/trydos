import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_sheet_header.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class CartPage extends StatefulWidget {
  final bool? fromeFilters;
  final bool? fromeNotification;

  const CartPage({Key? key, this.fromeFilters, this.fromeNotification});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late HomeBloc homeBloc;
  final PageController pageController = PageController();
  late AppBloc appBloc;
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  late AuthBloc authBloc;
  bool showDialogToResetSession = true;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  final ValueNotifier<bool> moreInfo = ValueNotifier(false);
  final PanelController panelController = PanelController();

  bool? fromForGroundNotification;

  @override
  void initState() {
    isExpanded.value = false;
    appBloc = BlocProvider.of<AppBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetCartItemEvent());
    homeBloc.add(GetCustomerAddressesEvent());
    fromForGroundNotification =
        appBloc.state.isFromForGroundNotification ?? false;
    print("${widget.fromeNotification}" + "${fromForGroundNotification}");

    super.initState();
  }

  @override
  void didChangeDependencies() {
    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.cartScreen,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    List<Map<String, String>> cartImages = [];
    return WillPopScope(
      onWillPop: () async {
        if (focusNode.hasFocus) {
          focusNode.previousFocus();
        }

        // didCallOnWillPop = true;
        if (Navigator.canPop(context)) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();

            appBloc.add(ChangeBasePage(0));
            return false;
            // منع الإغلاق بعد تنفيذ pop
          }

          // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

          appBloc.add(ChangeBasePage(0));
          homeBloc.add(ResetAllSelectedAppliedFilterEvent());
          return false;
        } else {
          appBloc.add(ChangeBasePage(0));
          return true;
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              return previous.getCartItemsStatus !=
                      current.getCartItemsStatus ||
                  previous.getCurrencyForCountryModel !=
                      current.getCurrencyForCountryModel ||
                  previous.deleteItemInCartStatus !=
                      current.deleteItemInCartStatus ||
                  previous.getOldCartItemsStatus !=
                      current.getOldCartItemsStatus ||
                  previous.convertItemFromOldcartToCartStatus !=
                      current.convertItemFromOldcartToCartStatus ||
                  previous.hideItemInOldCartStatus !=
                      current.hideItemInOldCartStatus ||
                  previous.addItemInCartStatus != current.addItemInCartStatus ||
                  previous.updateItemInCartStatus !=
                      current.updateItemInCartStatus ||
                  previous.cartCollection!.length !=
                      current.cartCollection?.length ||
                  previous.oldcartCollection?.length !=
                      current.oldcartCollection!.length;
            },
            builder: (context, state) {
              cartImages = [];

              state.cartCollection?.forEach(
                (element) {
                  for (var i = 0; i < (element.quantity ?? 0); i++) {
                    cartImages.add({
                      "image": element.image ?? "",
                      "size": element.variations?.isNullOrEmpty ?? false
                          ? ""
                          : element.variations?[0].size ?? "",
                      "color": element.variations?.isNullOrEmpty ?? false
                          ? ""
                          : element.variations?[0].color ?? ""
                    });
                  }
                },
              );
              /*if ((prefsRepository.isTokenExpired ??
                      false ||
                          prefsRepository.marketToken == "" ||
                          prefsRepository.marketToken == null) &&
                  showDialogToResetSession &&
                  GetIt.I<AuthBloc>().state.registerGuestStatus !=
                      RegisterGuestStatus.loading) {
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 400,
                    height: 300,
                    child: AlertDialog(
                      title: MyTextWidget(
                        "${LocaleKeys.it_has_been_along_time_since_your_account.tr()}",
                      ),
                      actions: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 300,
                          child: Row(
                            mainAxisAlignment: (prefsRepository
                                        .isVerifiedPhonePeforeExpiredToken ??
                                    false)
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceAround,
                            children: [
                              (prefsRepository
                                          .isVerifiedPhonePeforeExpiredToken ??
                                      false)
                                  ? SizedBox.shrink()
                                  : Container(
                                      alignment: Alignment.center,
                                      width: 130,
                                      child: AppElevatedButton(
                                        textStyle: TextStyle(fontSize: 16),
                                        onPressed: () async {
                                          showDialogToResetSession = false;

                                          String? deviceId =
                                              await HelperFunctions
                                                  .getDeviceId();

                                          GetIt.I<AuthBloc>().add(
                                              RegisterGuestEvent(
                                                  oldGuestUserId:
                                                      prefsRepository.myMarketId
                                                          .toString(),
                                                  deviceId: deviceId!));
                                          setState(() {});
                                        },
                                        text:
                                            "${LocaleKeys.reset_your_count.tr()}",
                                      ),
                                    ),
                              Container(
                                alignment: Alignment.center,
                                width: 130,
                                child: AppElevatedButton(
                                  textStyle: TextStyle(fontSize: 16),
                                  onPressed: () {
                                    showDialogToResetSession = false;

                                    Future.delayed(
                                      Duration(microseconds: 300),
                                      () {
                                        Navigator.of(context)
                                            .push(PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              RegistrationPage(
                                            fromExpiredToken: true,
                                          ),
                                        ));
                                      },
                                    );
                                  },
                                  text: '${LocaleKeys.go_to_log_in.tr()}',
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }*/
              if (state.cartCollection == null ||
                  state.cartCollection!.isEmpty) {
                isExpanded.value = false;
                isVerified.value = true;
              }
              if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                  (state.getCartShippingItemsModel == null)) {
                return Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: TryAgainWidget(tryAgain: () {
                    BlocProvider.of<HomeBloc>(context).add(GetCartItemEvent());
                  })),
                );
              }

              if (state.getCartShippingItemsModel == null &&
                      state.getCartItemsStatus != GetCartItemsStatus.success ||
                  (state.getOldCartModel == null &&
                      state.getOldCartItemsStatus !=
                          GetOLdCartItemsStatus.success)) {
                print("-------------------------------${(state.getOldCartModel == null && state.getOldCartItemsStatus != GetOLdCartItemsStatus.success)}------------------------------------------${state.getCartShippingItemsModel == null && state.getCartItemsStatus != GetCartItemsStatus.success}" +
                    "   ////////////////${state.getCartShippingItemsModel == null && state.getCartItemsStatus != GetCartItemsStatus.success}");
                return Center(
                  child: TrydosLoader(),
                );
              }

              double totlalOfferPrice = 0;
              double totlalPrice = 0;
              String? priceSymbol;
              double totlalQuantity = 0;
              double totlalDiscount = 0;

              state.cartCollection!.forEach((element) {
                totlalQuantity = totlalQuantity + (element.quantity ?? 0);
                priceSymbol =
                    state.getCurrencyForCountryModel!.data!.currency!.symbol ??
                        "";

                totlalOfferPrice =
                    totlalOfferPrice + element.offerPrice! * element.quantity!;
                totlalPrice = totlalPrice + element.price! * element.quantity!;
                totlalDiscount = totlalDiscount +
                    (element.price! - element.offerPrice!) * element.quantity!;
              });
              totlalOfferPrice = totlalOfferPrice *
                  state.getCurrencyForCountryModel!.data!.currency!
                      .exchangeRate!;
              totlalPrice = totlalPrice *
                  state.getCurrencyForCountryModel!.data!.currency!
                      .exchangeRate!;
              totlalDiscount = totlalDiscount *
                  state.getCurrencyForCountryModel!.data!.currency!
                      .exchangeRate!;

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 60),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: 1.sw,
                    height: 50.h,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 50.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  // didCallOnWillPop = true;
                                  if (Navigator.canPop(context)) {
                                    if (focusNode.hasFocus) {
                                      focusNode.previousFocus();
                                    }
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                      return;
                                      // منع الإغلاق بعد تنفيذ pop
                                    }

                                    // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                    appBloc.add(ChangeBasePage(0));
                                    homeBloc.add(
                                        ResetAllSelectedAppliedFilterEvent());
                                    return;
                                  } else {
                                    appBloc.add(ChangeBasePage(0));
                                    return;
                                  }
                                },
                                child: !(LanguageService.languageCode != "ar")
                                    ? Transform.rotate(
                                        angle: pi,
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 40,
                                          child: SvgPicture.asset(
                                            AppAssets.backIconArrowSvg,
                                            height: 20,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 40,
                                        child: SvgPicture.asset(
                                          AppAssets.backIconArrowSvg,
                                          height: 20,
                                        ),
                                      ),
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppAssets.bagsSvg,
                                height: 20,
                              ),
                              SizedBox(
                                width: 7.w,
                              ),
                              Text(
                                "${LocaleKeys.shopping_bag.tr()} ",
                                style: context.textTheme.bodyMedium?.ra
                                    .copyWith(
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        fontSize: 13,
                                        height: 1.33),
                              ),
                              Text(
                                "${state.cartCollection?.length} ",
                                style: context.textTheme.bodyMedium?.br
                                    .copyWith(
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        fontSize: 13,
                                        height: 1.33),
                              ),
                              Text(
                                "${LocaleKeys.item.tr()}",
                                strutStyle: LanguageService.languageCode != "ar"
                                    ? null
                                    : StrutStyle(height: 1.2, leading: 0.3),
                                style: context.textTheme.bodyMedium?.br
                                    .copyWith(
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        fontSize: 14,
                                        height: 1.33),
                              ),
                              SizedBox(
                                width: LanguageService.languageCode != "ar"
                                    ? 0
                                    : 20.w,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppAssets.shareSvg,
                                height: 20,
                                width: 20,
                                color: Color(0xff3C3C3C),
                              )
                            ],
                          ),
                        ),
                        /*container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffF8F8F8)),
                            margin: EdgeInsets.only(top: 5.h),
                            height: 30.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                    onTap: () {
                                      /* HelperFunctions.slidingNavigation(
                                                context,
                                                CartPage2(
                                                  getCartShippingItemsModel: state
                                                      .getCartShippingItemsModel!,
                                                ));*/
                                    },
                                    child: SvgPicture.asset(
                                        AppAssets.countItemSvg)),
                                Text(" ${state.cartCollection!.length} ",
                                    style: context.textTheme.bodyMedium?.mr
                                        .copyWith(
                                            fontSize: 13,
                                            color: const Color(0xff5D5C5D),
                                            letterSpacing: 0.18,
                                            height: 1.33)),
                                Text(
                                  "item ",
                                  style: context.textTheme.bodyMedium?.la
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                                Text(
                                  "${totlaPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}",
                                  style: context.textTheme.bodyMedium?.mr
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                                Text(
                                  " ${priceSymbol ?? '\$'} ",
                                  style: context.textTheme.bodyMedium?.la
                                      .copyWith(
                                          fontSize: 13,
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          height: 1.33),
                                ),
                              ],
                            ),
                          ),*/
                      ],
                    ),
                  ),
                  Container(
                    color: Color.fromARGB(255, 255, 255, 255),
                    child: Container(
                      color: ((state.cartCollection == null ||
                                  state.cartCollection!.isEmpty) &&
                              (state.oldcartCollection == null ||
                                  state.oldcartCollection!.isEmpty))
                          ? Color(0xffF8F8F8)
                          : Color(0xffFEFEFE),
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: [
                          ((state.cartCollection == null ||
                                      state.cartCollection!.isEmpty) &&
                                  (state.oldcartCollection == null ||
                                      state.oldcartCollection!.isEmpty))
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: (1.sh / 2) -
                                            ((widget.fromeFilters ?? false)
                                                ? 140
                                                : 200),
                                      ),
                                      Container(
                                        height: 20,
                                        child: SvgPicture.asset(
                                          AppAssets.cartSvg,
                                          color: const Color(0xff8E8E8E),
                                          height: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          "${LocaleKeys.your_cart_empty.tr()}",
                                          style: context
                                              .textTheme.bodyMedium?.mr
                                              .copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      const Color(0xff8E8E8E),
                                                  letterSpacing: 0.18,
                                                  height: 1.33),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          "${LocaleKeys.see_our_many_offers.tr()}",
                                          style: context
                                              .textTheme.bodyMedium?.ra
                                              .copyWith(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xff505050),
                                                  letterSpacing: 0.18,
                                                  height: 1.33),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 370.h,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  height: widget.fromeFilters ?? false
                                      ? (1.sh - 140.h)
                                      : 1.sh - 210.h,
                                  child: ListView(
                                    padding: EdgeInsets.only(top: 0),
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      (state.cartCollection == null ||
                                              state.cartCollection!.isEmpty)
                                          ? SizedBox.shrink()
                                          : ProductCollectionInCartPage1(
                                              isOldCart: false,
                                              oldCartCollection:
                                                  state.oldcartCollection ?? [],
                                              cartCollection:
                                                  state.cartCollection ?? [],
                                              priceSymbol: priceSymbol,
                                            ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      state.oldcartCollection != null
                                          ? !state.oldcartCollection!.isEmpty
                                              ? Center(
                                                  child: MyTextWidget(
                                                  "${LocaleKeys.old_cart.tr()}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 24),
                                                ))
                                              : SizedBox.shrink()
                                          : SizedBox.shrink(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      state.oldcartCollection != null
                                          ? !state.oldcartCollection!.isEmpty
                                              ? Container(
                                                  height: 70.h,
                                                  padding: EdgeInsets.all(20.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            GetIt.I<HomeBloc>().add(
                                                                HideItemInOldCartEvent(
                                                              hideAll: true,
                                                            ));
                                                          },
                                                          child: MyTextWidget(
                                                            "${LocaleKeys.hide_all.tr()}",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 14),
                                                          ))
                                                    ],
                                                  ))
                                              : SizedBox.shrink()
                                          : SizedBox.shrink(),
                                      (state.oldcartCollection == null ||
                                              state.oldcartCollection!.isEmpty)
                                          ? SizedBox.shrink()
                                          : ProductCollectionInCartPage1(
                                              isOldCart: true,
                                              oldCartCollection:
                                                  state.oldcartCollection ?? [],
                                              cartCollection:
                                                  state.cartCollection ?? [],
                                              priceSymbol: priceSymbol,
                                            ),
                                    ],
                                  ),
                                ),
                          ValueListenableBuilder<bool>(
                              valueListenable: moreInfo,
                              builder: (context, isMoreInfo, _) {
                                return ValueListenableBuilder<bool>(
                                    valueListenable: isExpanded,
                                    builder: (context, expanded, _) {
                                      return !(expanded || isMoreInfo)
                                          ? SizedBox.shrink()
                                          : InkWell(
                                              onTap: () {
                                                isExpanded.value = false;
                                                moreInfo.value = false;
                                                Future.delayed(
                                                  Duration(microseconds: 300),
                                                  () {
                                                    panelController.close();
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: 600,
                                                color: Color.fromRGBO(
                                                    29, 29, 29, 0.6),
                                              ),
                                            );
                                    });
                              }),
                          ValueListenableBuilder<bool>(
                              valueListenable: moreInfo,
                              builder: (context, isMoreInfo, _) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: isVerified,
                                  builder: (context, isverified, _) {
                                    return ValueListenableBuilder<bool>(
                                        valueListenable: isExpanded,
                                        builder: (context, expanded, _) {
                                          return Positioned(
                                            bottom: -10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      ((state.cartCollection ==
                                                                  null ||
                                                              state
                                                                  .cartCollection!
                                                                  .isEmpty))
                                                          ? null
                                                          : BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(30),
                                                              topRight:
                                                                  Radius
                                                                      .circular(
                                                                          30))),
                                              height: isMoreInfo ? 670.h : null,
                                              width: 1.sw,
                                              child: SlidingUpPanel(
                                                controller: panelController,
                                                borderRadius:
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? null
                                                        : BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    30),
                                                            topRight:
                                                                Radius.circular(
                                                                    30)),
                                                isDraggable: true,
                                                slideDirection:
                                                    SlideDirection.UP,
                                                onPanelClosed: () {
                                                  isExpanded.value = false;
                                                  moreInfo.value = false;
                                                },
                                                onPanelOpened: () => isExpanded
                                                        .value =
                                                    ((state.cartCollection ==
                                                                    null ||
                                                                state
                                                                    .cartCollection!
                                                                    .isEmpty)) ||
                                                            isMoreInfo
                                                        ? false
                                                        : true,
                                                minHeight:
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? 100.h
                                                        : !isverified
                                                            ? 610.h
                                                            : 236.h,
                                                maxHeight: isMoreInfo
                                                    ? 756.h
                                                    : ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? 120.h
                                                        : !isverified
                                                            ? 780.h
                                                            : 485.h,
                                                panelBuilder: (sc) => Container(
                                                  alignment: Alignment.topLeft,
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color(
                                                                0xffF8F8F8),
                                                            spreadRadius: 0.1,
                                                            blurRadius: 0.1)
                                                      ],
                                                      border: Border.all(
                                                          color: Color(
                                                              0xffF8F8F8)),
                                                      color: Color(0xffFFFFFF),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(30),
                                                              topRight: Radius
                                                                  .circular(
                                                                      30))),
                                                  height:
                                                      ((state.cartCollection ==
                                                                  null ||
                                                              state
                                                                  .cartCollection!
                                                                  .isEmpty))
                                                          ? 100.h
                                                          : expanded
                                                              ? !isverified
                                                                  ? 780.h
                                                                  : 485.h
                                                              : !isverified
                                                                  ? 610.h
                                                                  : 236.h,
                                                  width: 1.sw,
                                                  child: Container(
                                                    decoration: ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? null
                                                        : BoxDecoration(
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xffFFFFFF)),
                                                            color: Color(
                                                                0xffFFFFFF),
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        30),
                                                                topRight:
                                                                    Radius.circular(
                                                                        30))),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ((state.cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? SizedBox
                                                                  .shrink()
                                                              : SizedBox(
                                                                  height: 10,
                                                                ),
                                                          ((state.cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? SizedBox
                                                                  .shrink()
                                                              : InkWell(
                                                                  onTap: () {
                                                                    if (isverified) {
                                                                      moreInfo.value =
                                                                          true;
                                                                      Future
                                                                          .delayed(
                                                                        Duration(
                                                                            microseconds:
                                                                                500),
                                                                        () {
                                                                          panelController
                                                                              .open();
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Center(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      AppAssets
                                                                          .chatWithQuestionSvg,
                                                                      height:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                          ((state.cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? SizedBox
                                                                  .shrink()
                                                              : SizedBox(
                                                                  height: 5,
                                                                ),
                                                          ((state.cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? SizedBox
                                                                  .shrink()
                                                              : Container(
                                                                  height: 27,
                                                                  child:
                                                                      CartDetailsSheetHeader(),
                                                                ),
                                                          !isMoreInfo
                                                              ? SizedBox
                                                                  .shrink()
                                                              : SizedBox(
                                                                  height: 1.sh /
                                                                      2.1,
                                                                ),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Color(
                                                                          0xffF8F8F8),
                                                                    ),
                                                                    color: Color(
                                                                        0xffF8F8F8),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(30))),
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        margin:
                                                                            EdgeInsets.all(18),
                                                                        width:
                                                                            65,
                                                                        height:
                                                                            18,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              AppAssets.countItemSvg,
                                                                              color: Color(0xff1D1D1D),
                                                                              height: 12,
                                                                            ),
                                                                            Text(
                                                                              " ${LocaleKeys.item.tr()} ",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                            ),
                                                                            Text(
                                                                              "${totlalQuantity.round()}",
                                                                              style: context.textTheme.bodyMedium?.ba.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        width:
                                                                            400.w,
                                                                        height:
                                                                            50.h,
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 10.w
                                                                              : 0,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? 0
                                                                              : 10.w,
                                                                        ),
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.w),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  height: 17.h,
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                    left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                                  ),
                                                                                  child: Text(
                                                                                    "${LocaleKeys.details.tr()} ",
                                                                                    strutStyle: LanguageService.languageCode != "ar" ? null : StrutStyle(height: 0.1, leading: 0.1),
                                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: LanguageService.languageCode != "ar" ? 1.33 : 1),
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Text(
                                                                                  " ${totlalPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${priceSymbol ?? "\$"}",
                                                                                  style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.normal_price.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(fontSize: 11, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : SizedBox(
                                                                        height:
                                                                            5.h,
                                                                      ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 10.w
                                                                              : 0,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? 0
                                                                              : 10.w,
                                                                        ),
                                                                        width:
                                                                            400.w,
                                                                        height:
                                                                            50.h,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.w),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 4,
                                                                                    left: LanguageService.languageCode != "ar" ? 2 : 8.w,
                                                                                  ),
                                                                                  child: SvgPicture.asset(
                                                                                    AppAssets.totalDiscountCartSvg,
                                                                                    color: Color(0xffFE0364),
                                                                                    height: 12,
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 17.h,
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 2,
                                                                                    left: LanguageService.languageCode != "ar" ? 2 : 10.w,
                                                                                  ),
                                                                                  child: Text(
                                                                                    "${LocaleKeys.total_discount.tr()} ${(totlalPrice == 0 ? 0 : ((totlalDiscount) / totlalPrice) * 100).toStringAsFixed(1)}% ",
                                                                                    strutStyle: LanguageService.languageCode != "ar" ? null : StrutStyle(height: 0.1, leading: 0.1),
                                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xffA28E5B), letterSpacing: 0.18, height: LanguageService.languageCode != "ar" ? 1.33 : 1),
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Text(
                                                                                  "- ${(totlalDiscount).toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 13, color: const Color(0xffA28E5B), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${priceSymbol ?? "\$"}",
                                                                                  style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xffA28E5B), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.all_inclusve_without_addition.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(fontSize: 11, color: const Color(0xffA28E5B), letterSpacing: 0.18, height: 1.33),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : SizedBox(
                                                                        height:
                                                                            5.h,
                                                                      ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 10.w
                                                                              : 2,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? 2
                                                                              : 10.w,
                                                                        ),
                                                                        width:
                                                                            400.w,
                                                                        height:
                                                                            50.h,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.w),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(right: LanguageService.languageCode != "ar" ? 10.w : 2, left: LanguageService.languageCode != "ar" ? 2 : 10.w),
                                                                                  child: SvgPicture.asset(
                                                                                    AppAssets.giftCartSvg,
                                                                                    color: Color(0xff5BA260),
                                                                                    height: 12,
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 17.h,
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 2,
                                                                                    left: LanguageService.languageCode != "ar" ? 2 : 10.w,
                                                                                  ),
                                                                                  child: Text(
                                                                                    "${LocaleKeys.gift.tr()}",
                                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff5BA260), letterSpacing: 0.18, height: 1.33),
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Text(
                                                                                  "- ${0}  ",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 13, color: const Color(0xff5BA260), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${priceSymbol ?? "\$"}",
                                                                                  style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff5BA260), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.first_shopping.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(fontSize: 11, color: const Color(0xff5BA260), letterSpacing: 0.18, height: 1.33),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                SizedBox(
                                                                  height: 5.h,
                                                                ),
                                                                !expanded
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 10.w
                                                                              : 2,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? 2
                                                                              : 10.w,
                                                                        ),
                                                                        width:
                                                                            400.w,
                                                                        height:
                                                                            50.h,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.w),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(right: LanguageService.languageCode != "ar" ? 10 : 2, left: LanguageService.languageCode != "ar" ? 2 : 10),
                                                                                  child: SvgPicture.asset(
                                                                                    AppAssets.shappingCartSvg,
                                                                                    color: Color(0xffBEF4CD),
                                                                                    height: 12,
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 17.h,
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 2,
                                                                                    left: LanguageService.languageCode != "ar" ? 2 : 10.w,
                                                                                  ),
                                                                                  child: Text(
                                                                                    "${LocaleKeys.shipping.tr()} ",
                                                                                    strutStyle: LanguageService.languageCode != "ar" ? null : StrutStyle(height: 0.1, leading: 0.1),
                                                                                    style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff2FA52F), letterSpacing: 0.18, height: LanguageService.languageCode != "ar" ? 1.33 : 1),
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Text(
                                                                                  "0",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(decoration: TextDecoration.lineThrough, decorationColor: const Color(0xff2FA52F), color: const Color(0xff2FA52F), fontSize: 13, letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  " 0,00  ",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 13, color: const Color(0xff2FA52F), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${priceSymbol ?? "\$"}",
                                                                                  style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 13, color: const Color(0xff2FA52F), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.shipping_is_completely_free_without_any_extras.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(fontSize: 11, color: const Color(0xff2FA52F), letterSpacing: 0.18, height: 1.33),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                SizedBox(
                                                                  height:
                                                                      expanded
                                                                          ? 0
                                                                          : 10.h,
                                                                ),
                                                                ((state.cartCollection ==
                                                                            null ||
                                                                        state
                                                                            .cartCollection!
                                                                            .isEmpty))
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        width:
                                                                            400.w,
                                                                        height:
                                                                            50.h,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(0xffF8F8F8),
                                                                            borderRadius: BorderRadius.all(Radius.circular(12))),
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 10.w
                                                                              : 2,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? 2
                                                                              : 10.w,
                                                                        ),
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.w),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  height: 17.h,
                                                                                  margin: EdgeInsets.only(
                                                                                    right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                    left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                                  ),
                                                                                  child: Text(
                                                                                    "${LocaleKeys.total.tr()}",
                                                                                    style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 13, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Text(
                                                                                  "${totlalPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                                  style: context.textTheme.bodyMedium?.ra.copyWith(decoration: TextDecoration.lineThrough, fontSize: 16, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${totlalOfferPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}  ",
                                                                                  style: context.textTheme.bodyMedium?.br.copyWith(fontSize: 16, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                Text(
                                                                                  "${priceSymbol ?? "\$"}",
                                                                                  style: context.textTheme.bodyMedium?.mr.copyWith(fontSize: 16, color: const Color(0xff1D1D1D), letterSpacing: 0.18, height: 1.33),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 5.w,
                                                                                ),
                                                                                Container(
                                                                                    width: 20,
                                                                                    height: 20,
                                                                                    child: Container(
                                                                                        alignment: Alignment.centerRight,
                                                                                        height: 14,
                                                                                        child: SvgPicture.asset(
                                                                                          AppAssets.chatWithQuestionSvg,
                                                                                          color: Color(0xff8E8E8E),
                                                                                          height: 14,
                                                                                        ))),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right: LanguageService.languageCode != "ar" ? 10.w : 25,
                                                                                left: LanguageService.languageCode != "ar" ? 25 : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.click_to_show_all_discount.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(fontSize: 11, color: const Color(0xff8D8D8D), letterSpacing: 0.18, height: 1.33),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: expanded
                                                                ? 8
                                                                : ((state.cartCollection ==
                                                                            null ||
                                                                        state
                                                                            .cartCollection!
                                                                            .isEmpty))
                                                                    ? 0
                                                                    : 20,
                                                          ),
                                                          !isverified
                                                              ? Container(
                                                                  height: 200,
                                                                  child: Stack(
                                                                      children: [
                                                                        PageView(
                                                                            physics:
                                                                                NeverScrollableScrollPhysics(),
                                                                            controller:
                                                                                pageController,
                                                                            children: (prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)
                                                                                ? [
                                                                                    VerifyOtp(
                                                                                        fromCart: true,
                                                                                        isVisWhatsApp: 1,
                                                                                        navigateToAddName: () {},
                                                                                        navigateTocart: () {
                                                                                          isVerified.value = true;
                                                                                        },
                                                                                        fromLogin: false,
                                                                                        onLoginFailed: () {
                                                                                          //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        },
                                                                                        goBack: () {
                                                                                          // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        },
                                                                                        methodIcon: AppAssets.whatsappSvg,
                                                                                        phoneNumber: prefsRepository.myPhoneNumber!),
                                                                                  ]
                                                                                : [
                                                                                    InsertPhoneTab(
                                                                                      fromLogin: false,
                                                                                      focusNode: focusNode,
                                                                                      moveToNextStep: (String phoneNumber) {
                                                                                        this.phoneNumber = phoneNumber.replaceAll(' ', '');
                                                                                        pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        setState(() {});
                                                                                      },
                                                                                    ),
                                                                                    VerificationMethods(
                                                                                      phoneNumber: phoneNumber,
                                                                                      onChooseWhatsapp: () {
                                                                                        isVisWhatsApp = 1;
                                                                                        print("###################33333#${isVisWhatsApp}");
                                                                                        pageController.animateToPage(2, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);

                                                                                        if (prefsRepository.isTimerForOtpRunning ?? false) {
                                                                                          showMessage('${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}');
                                                                                          return;
                                                                                        }
                                                                                        authBloc.add(SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));
                                                                                      },
                                                                                      goBackToPhone: () {
                                                                                        pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                      },
                                                                                      onChooseSms: () {
                                                                                        isVisWhatsApp = 0;
                                                                                        pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        authBloc.add(SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));
                                                                                      },
                                                                                    ),
                                                                                    VerifyOtp(
                                                                                        fromCart: true,
                                                                                        isVisWhatsApp: isVisWhatsApp,
                                                                                        navigateToAddName: () {},
                                                                                        navigateTocart: () {
                                                                                          isVerified.value = true;
                                                                                        },
                                                                                        fromLogin: false,
                                                                                        onLoginFailed: () {
                                                                                          pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        },
                                                                                        goBack: () {
                                                                                          pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                                                                        },
                                                                                        methodIcon: isVisWhatsApp == 1 ? AppAssets.whatsappSvg : AppAssets.smsSvg,
                                                                                        phoneNumber: phoneNumber),
                                                                                  ]),
                                                                        Positioned(
                                                                          top:
                                                                              0,
                                                                          left: LanguageService.languageCode != "ar"
                                                                              ? null
                                                                              : 0,
                                                                          right: LanguageService.languageCode != "ar"
                                                                              ? 0
                                                                              : null,
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                EdgeInsets.all(10),
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                40,
                                                                            child: InkWell(
                                                                                onTap: () => isVerified.value = true,
                                                                                child: SvgPicture.asset(
                                                                                  AppAssets.closeSvg,
                                                                                  height: 15,
                                                                                  width: 30,
                                                                                  color: Color(0xffFF5F61),
                                                                                )),
                                                                          ),
                                                                        )
                                                                      ]),
                                                                )
                                                              : Container(
                                                                  margin: EdgeInsets.only(
                                                                      bottom: ((state.cartCollection == null ||
                                                                              state.cartCollection!.isEmpty))
                                                                          ? 20
                                                                          : 10),
                                                                  height: 70.h,
                                                                  child: BlocBuilder<
                                                                      AuthBloc,
                                                                      AuthState>(
                                                                    buildWhen: (p,
                                                                            c) =>
                                                                        p.verifyOtpSignInStatus != c.verifyOtpSignInStatus ||
                                                                        p.verifyOtpSignUpStatus !=
                                                                            c
                                                                                .verifyOtpSignUpStatus ||
                                                                        c.verifyGuestPhoneStatus !=
                                                                            p.verifyGuestPhoneStatus,
                                                                    builder:
                                                                        (context,
                                                                            authState) {
                                                                      return (authState.verifyGuestPhoneStatus == VerifyGuestPhoneStatus.loading ||
                                                                              authState.verifyOtpSignInStatus == VerifyOtpSignInStatus.loading ||
                                                                              authState.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading ||
                                                                              state.addItemInCartStatus == AddItemInCartStatus.loading ||
                                                                              state.deleteItemInCartStatus == DeleteItemInCartStatus.loading ||
                                                                              state.updateItemInCartStatus == UpdateItemInCartStatus.loading)
                                                                          ? Shimmer.fromColors(
                                                                              baseColor: Colors.grey[200]!,
                                                                              highlightColor: Colors.grey[100]!,
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          "${LocaleKeys.confirm.tr()} ",
                                                                                          style: context.textTheme.bodyMedium?.la.copyWith(
                                                                                            fontSize: 18,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "&",
                                                                                          style: context.textTheme.bodyMedium?.ld.copyWith(
                                                                                            fontSize: 18,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          " ${LocaleKeys.continues.tr()}",
                                                                                          style: context.textTheme.bodyMedium?.la.copyWith(
                                                                                            fontSize: 18,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          "${totlalQuantity.round()} ",
                                                                                          style: context.textTheme.bodyMedium?.ba.copyWith(
                                                                                            fontSize: 14,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          "${LocaleKeys.item.tr()}",
                                                                                          style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                            fontSize: 14,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          " ${totlalOfferPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                                                          style: context.textTheme.bodyMedium?.ba.copyWith(
                                                                                            fontSize: 14,
                                                                                            color: const Color(0xffFEFEFE),
                                                                                            letterSpacing: 0.18,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          priceSymbol ?? ' \$',
                                                                                          style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                            decorationColor: Color(0xffFEFEFE),
                                                                                            fontSize: 14,
                                                                                            color: Color(0xffFEFEFE),
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                margin: EdgeInsets.symmetric(horizontal: 20.w),
                                                                                width: 390.w,
                                                                                height: 70.h,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: Color(0xff3C3C3C),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : InkWell(
                                                                              onTap: () {
                                                                                if ((state.cartCollection == null || state.cartCollection!.isEmpty)) {
                                                                                  // didCallOnWillPop = true;
                                                                                  if (Navigator.canPop(context)) {
                                                                                    if (Navigator.of(context).canPop()) {
                                                                                      Navigator.of(context).pop();
                                                                                      return;
                                                                                      // منع الإغلاق بعد تنفيذ pop
                                                                                    }

                                                                                    // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                                                                    appBloc.add(ChangeBasePage(0));
                                                                                    homeBloc.add(ResetAllSelectedAppliedFilterEvent());
                                                                                    return;
                                                                                  } else {
                                                                                    appBloc.add(ChangeBasePage(0));
                                                                                    return;
                                                                                  }
                                                                                } else {
                                                                                  if (prefsRepository.isVerifiedPhone != true) {
                                                                                    if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)) {
                                                                                      authBloc.add(SendOtpEvent(phone: prefsRepository.myPhoneNumber!, isViaWhatsApp: 1));
                                                                                      ;
                                                                                    }
                                                                                    isVerified.value = false;
                                                                                  } else {
                                                                                    HelperFunctions.slidingNavigation(
                                                                                      context,
                                                                                      CartDelivaryAddress(
                                                                                        cartImages: cartImages,
                                                                                        totalPrice: totlalOfferPrice,
                                                                                        currencySympole: priceSymbol ?? ' \$',
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                child: ((state.cartCollection == null || state.cartCollection!.isEmpty))
                                                                                    ? Text(
                                                                                        "${LocaleKeys.back_to_home.tr()}",
                                                                                        style: context.textTheme.bodyMedium?.la.copyWith(
                                                                                          fontSize: 18,
                                                                                          color: const Color(0xffFEFEFE),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      )
                                                                                    : Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${LocaleKeys.confirm.tr()} ",
                                                                                                style: context.textTheme.bodyMedium?.la.copyWith(
                                                                                                  fontSize: 18,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                "&",
                                                                                                style: context.textTheme.bodyMedium?.ld.copyWith(
                                                                                                  fontSize: 18,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                " ${LocaleKeys.continues.tr()}",
                                                                                                style: context.textTheme.bodyMedium?.la.copyWith(
                                                                                                  fontSize: 18,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Text(
                                                                                                "${totlalQuantity.round()} ",
                                                                                                style: context.textTheme.bodyMedium?.ba.copyWith(
                                                                                                  fontSize: 14,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                "${LocaleKeys.item.tr()}",
                                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                                  fontSize: 14,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                " ${totlalOfferPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)} ",
                                                                                                style: context.textTheme.bodyMedium?.ba.copyWith(
                                                                                                  fontSize: 14,
                                                                                                  color: const Color(0xffFEFEFE),
                                                                                                  letterSpacing: 0.18,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                priceSymbol ?? ' \$',
                                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                                  decorationColor: Color(0xffFEFEFE),
                                                                                                  fontSize: 14,
                                                                                                  color: Color(0xffFEFEFE),
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                margin: EdgeInsets.symmetric(horizontal: 20.w),
                                                                                width: 390.w,
                                                                                height: 70.h,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: Color(0xff3C3C3C),
                                                                                ),
                                                                              ),
                                                                            );
                                                                    },
                                                                  ),
                                                                ),
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          )),
    );
  }
}
