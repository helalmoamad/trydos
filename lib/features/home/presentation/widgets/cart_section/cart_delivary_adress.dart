import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_elvated_button.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/chat/domain/use_cases/get_image_width_and_height_usecase.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/place_order.dart';

import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class CartDelivaryAdress extends StatefulWidget {
  final List<Map<String, String>> cartImages;
  final String totalPrice;
  final String currencySympole;
  const CartDelivaryAdress({
    required this.totalPrice,
    required this.cartImages,
    required this.currencySympole,
    Key? key,
  });
  @override
  State<CartDelivaryAdress> createState() => _CartDelivaryAdressState();
}

class _CartDelivaryAdressState extends State<CartDelivaryAdress> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  final ValueNotifier<bool> showDeleteAddress = ValueNotifier(false);
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<String> paymentMethod = ValueNotifier("");
  final PanelController panelController = PanelController();
  late HomeBloc homeBloc;
  bool showDialogToResetSession = true;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int indexToDelete = 0;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

//    appBloc = BlocProvider.of<AppBloc>(context);

    // homeBloc = BlocProvider.of<HomeBloc>(context);

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
    return WillPopScope(
      onWillPop: () async {
        // didCallOnWillPop = true;
        if (Navigator.canPop(context)) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();

            return false;
            // منع الإغلاق بعد تنفيذ pop
          }

          // يسمح بالإغلاق إذا لم تنطبق أي من الشروط
        }
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
                previous.getCustomerAddressStatus !=
                    current.getCustomerAddressStatus ||
                previous.editAddressToOrderStatus !=
                    current.editAddressToOrderStatus ||
                previous.addAddressToOrderStatus !=
                    current.addAddressToOrderStatus ||
                previous.removeAddressToOrderStatus !=
                    current.removeAddressToOrderStatus,
            builder: (context, state) {
              /*  if ((prefsRepository.isTokenExpired ??
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
              return ValueListenableBuilder<bool>(
                  valueListenable: showDeleteAddress,
                  builder: (context, _showDeleteAddress, _) {
                    return Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 60),
                              width: 1.sw,
                              height: 50.h,
                              child: Column(
                                children: [
                                  Container(
                                    height: 50.h,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            // didCallOnWillPop = true;
                                            if (Navigator.canPop(context)) {
                                              if (Navigator.of(context)
                                                  .canPop()) {
                                                Navigator.of(context).pop();
                                                return;
                                                // منع الإغلاق بعد تنفيذ pop
                                              }

                                              // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                              return;
                                            } else {}
                                          },
                                          child: Container(
                                            width: 40,
                                            child: Transform.rotate(
                                              angle: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? pi
                                                  : 0,
                                              child: SvgPicture.asset(
                                                AppAssets.backIconArrowSvg,
                                                height: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        SvgPicture.asset(
                                          AppAssets.deliveryAddressSvg,
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        Text(
                                            !(state.listOfAddressInfoClassToSave
                                                    .isNullOrEmpty)
                                                ? "${LocaleKeys.shipping_payment.tr()} "
                                                : "${LocaleKeys.bag_shipping_delivery_address.tr()} ",
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff1D1D1D),
                                                    letterSpacing: 0.2,
                                                    fontSize: 14,
                                                    height: 1.33)),
                                        SizedBox(
                                          width: LanguageService.languageCode ==
                                                  "ar"
                                              ? !(state
                                                      .listOfAddressInfoClassToSave
                                                      .isNullOrEmpty)
                                                  ? 180.w
                                                  : 120.w
                                              : !(state
                                                      .listOfAddressInfoClassToSave
                                                      .isNullOrEmpty)
                                                  ? 140.w
                                                  : 80.w,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<int>(
                                valueListenable: indexTap,
                                builder: (context, _indexTap, _) {
                                  return Container(
                                    height: 1.sh - 120.h,
                                    child: Stack(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            child: Container(
                                                height: 1.sh - 110.h,
                                                alignment: Alignment.topCenter,
                                                child: Center(
                                                    child: ListView(
                                                        physics:
                                                            ClampingScrollPhysics(),
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ValueListenableBuilder<
                                                              bool>(
                                                          valueListenable:
                                                              isExpanded,
                                                          builder: (context,
                                                              expanded, _) {
                                                            return AnimatedContainer(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              curve: Curves
                                                                  .easeInOut,
                                                              child: Container(
                                                                  height:
                                                                      expanded
                                                                          ? 200
                                                                          : 50
                                                                              .h,
                                                                  width: 1.sw,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                      border: Border.all(
                                                                          color:
                                                                              Color(0xffC4C2C2))),
                                                                  child: Column(
                                                                    children: [
                                                                      InkWell(
                                                                        onTap: () =>
                                                                            isExpanded.value =
                                                                                !expanded,
                                                                        child: Container(
                                                                            margin: EdgeInsets.all(10),
                                                                            height: 20,
                                                                            child: Row(children: [
                                                                              SvgPicture.asset(
                                                                                AppAssets.bagsSvg,
                                                                                height: 20,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 7.w,
                                                                              ),
                                                                              Text(
                                                                                "${LocaleKeys.your_shopping_bag.tr()} ",
                                                                                style: context.textTheme.bodyMedium?.ra.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 14, height: 1.33),
                                                                              ),
                                                                              Text(
                                                                                "${widget.cartImages.length} item",
                                                                                style: context.textTheme.bodyMedium?.br.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 13, height: 1.33),
                                                                              ),
                                                                              Spacer(),
                                                                              Transform.rotate(
                                                                                  angle: expanded ? pi : 0,
                                                                                  child: SvgPicture.asset(
                                                                                    AppAssets.expandDetaileSvg,
                                                                                    height: 8,
                                                                                    width: 12,
                                                                                    color: Color(0xff8D8D8D),
                                                                                  )),
                                                                            ])),
                                                                      ),
                                                                      !expanded
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                      !expanded
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : Container(
                                                                              margin: EdgeInsets.only(left: (LanguageService.languageCode == "ar") ? 0 : 10, right: (LanguageService.languageCode == "ar") ? 10 : 0),
                                                                              height: 150,
                                                                              child: ListView.separated(
                                                                                  separatorBuilder: (context, index) => SizedBox(
                                                                                        width: 5,
                                                                                      ),
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  itemCount: widget.cartImages.length,
                                                                                  itemBuilder: (context, index) => Container(
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(15),
                                                                                          color: Color(0x707070),
                                                                                        ),
                                                                                        width: 91.w,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Container(
                                                                                              height: 125.h,
                                                                                              child: ProductDetailsImageWidget(
                                                                                                withBackGroundShadow: true,
                                                                                                withInnerShadow: false,
                                                                                                imageFit: BoxFit.cover,
                                                                                                blurRadius: 0,
                                                                                                imageUrl: widget.cartImages[index]["image"],
                                                                                                width: 91.w,
                                                                                                radius: 15,
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 2,
                                                                                            ),
                                                                                            Text(
                                                                                              '${widget.cartImages[index]["size"]}',
                                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 10, height: 1.33),
                                                                                            ),
                                                                                            Text(
                                                                                              '${widget.cartImages[index]["color"]}',
                                                                                              style: context.textTheme.bodyMedium?.rr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 10, height: 1.33),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )),
                                                                            )
                                                                    ],
                                                                  )),
                                                            );
                                                          }),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                          height: !(state
                                                                  .listOfAddressInfoClassToSave
                                                                  .isNullOrEmpty)
                                                              ? 220.h
                                                              : 203,
                                                          width: 1.sw,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              border: Border.all(
                                                                  color: Color(
                                                                      0xffC4C2C2))),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                  child: Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          AppAssets
                                                                              .deliveryAddressSvg,
                                                                          height:
                                                                              16,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              7.w,
                                                                        ),
                                                                        Text(
                                                                          "${LocaleKeys.shipping_delivery_address.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                              color: const Color(0xff1D1D1D),
                                                                              letterSpacing: 0.18,
                                                                              fontSize: 14,
                                                                              height: 0.8),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5.w,
                                                                        ),
                                                                        SvgPicture
                                                                            .asset(
                                                                          AppAssets
                                                                              .freeShippingSvg,
                                                                        )
                                                                      ])),
                                                              SizedBox(
                                                                height: 5.h,
                                                              ),
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              35.w),
                                                                  child: Text(
                                                                    !(state.listOfAddressInfoClassToSave
                                                                            .isNullOrEmpty)
                                                                        ? "${LocaleKeys.shipment_will_be_sent_to_the_address_below.tr()} "
                                                                        : "${LocaleKeys.please_enter_shipping_address_to_receive_your_bag.tr()} ",
                                                                    style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                        color: const Color(
                                                                            0xff8D8D8D),
                                                                        letterSpacing:
                                                                            0.18,
                                                                        fontSize:
                                                                            12,
                                                                        height:
                                                                            0.8),
                                                                  )),
                                                              SizedBox(
                                                                height: 12.h,
                                                              ),
                                                              !state.listOfAddressInfoClassToSave
                                                                      .isNullOrEmpty
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          AddressInfoWithContactInfoCart(
                                                                        cartChoosed:
                                                                            true,
                                                                        isDelete:
                                                                            false,
                                                                        customerAddressesInfo:
                                                                            state.listOfAddressInfoClassToSave![_indexTap],
                                                                        context:
                                                                            context,
                                                                        index:
                                                                            -1,
                                                                        indexTap:
                                                                            _indexTap,
                                                                        onTapDelete:
                                                                            () {},
                                                                        onTapEdit:
                                                                            () {
                                                                          ;
                                                                        },
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      height:
                                                                          85.h,
                                                                      width:
                                                                          1.sw,
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              0),
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          color: Color(
                                                                              0xffF8F8F8),
                                                                          borderRadius: BorderRadius.circular(
                                                                              15),
                                                                          border:
                                                                              Border.all(color: !state.listOfAddressInfoClassToSave.isNullOrEmpty ? Color(0xff388CFF) : Color(0xffF8F8F8))),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                8.h,
                                                                          ),
                                                                          SvgPicture
                                                                              .asset(
                                                                            AppAssets.chatWithQuestionSvg,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                18.h,
                                                                          ),
                                                                          Text(
                                                                            "${LocaleKeys.your_address_list_is_empty.tr()} ",
                                                                            style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                color: const Color(0xffC4C2C2),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 12,
                                                                                height: 0.8),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                8.h,
                                                                          ),
                                                                          Text(
                                                                            "${LocaleKeys.you_can_also_create_multiple_addresses_to_use.tr()} ",
                                                                            style: context.textTheme.bodyMedium?.ra.copyWith(
                                                                                color: const Color(0xffC4C2C2),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 12,
                                                                                height: 0.8),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                              SizedBox(
                                                                height: !(state
                                                                        .listOfAddressInfoClassToSave
                                                                        .isNullOrEmpty)
                                                                    ? 10
                                                                    : 20.h,
                                                              ),
                                                              !state.listOfAddressInfoClassToSave
                                                                      .isNullOrEmpty
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () {
                                                                        panelController
                                                                            .open();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            15.h,
                                                                        width: 1
                                                                            .sw,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Center(
                                                                              child: SvgPicture.asset(
                                                                                AppAssets.deliveryAddressSvg,
                                                                                width: 15,
                                                                                height: 15,
                                                                                color: Color(0xff8D8D8D),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 3,
                                                                            ),
                                                                            Text(
                                                                              "${LocaleKeys.show_address_list.tr()} ",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff8D8D8D), letterSpacing: 0.18, fontSize: 12, height: 1),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : InkWell(
                                                                      onTap: () => HelperFunctions.slidingNavigation(
                                                                          context,
                                                                          AddShippingAdress()),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        width: 1
                                                                            .sw,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(0xffE8FFED),
                                                                            borderRadius: BorderRadius.circular(15),
                                                                            border: Border.all(color: Color(0xffC4C2C2))),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Center(
                                                                              child: Stack(
                                                                                alignment: Alignment.center,
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    AppAssets.addShippingAddressSvg,
                                                                                  ),
                                                                                  Positioned(
                                                                                    top: 2,
                                                                                    child: SvgPicture.asset(
                                                                                      AppAssets.addShippingAddressWhiteSvg,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 3,
                                                                            ),
                                                                            Text(
                                                                              "${LocaleKeys.add_shipping_address.tr()} ",
                                                                              style: context.textTheme.bodyMedium?.mr.copyWith(color: const Color(0xff1D1D1D), letterSpacing: 0.18, fontSize: 12, height: 1.33),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                            ],
                                                          )),
                                                      SizedBox(
                                                        height: 20.h,
                                                      ),
                                                      (state.listOfAddressInfoClassToSave
                                                              .isNullOrEmpty)
                                                          ? SizedBox.shrink()
                                                          : PaymentMethod(
                                                              fromSuccessOrder:
                                                                  false,
                                                              fromPalceOrder:
                                                                  false,
                                                              paymentMethod:
                                                                  paymentMethod),
                                                      (state.listOfAddressInfoClassToSave
                                                              .isNullOrEmpty)
                                                          ? SizedBox.shrink()
                                                          : ValueListenableBuilder<
                                                                  bool>(
                                                              valueListenable:
                                                                  isExpanded,
                                                              builder: (context,
                                                                  _isExpanded,
                                                                  _) {
                                                                return SizedBox(
                                                                  height:
                                                                      !_isExpanded
                                                                          ? 10.h
                                                                          : 120
                                                                              .h,
                                                                );
                                                              }),
                                                    ])))),
                                        ValueListenableBuilder<bool>(
                                            valueListenable: showPanel,
                                            builder: (context, _showPanel, _) {
                                              return !_showPanel
                                                  ? SizedBox.shrink()
                                                  : InkWell(
                                                      onTap: () {
                                                        panelController.close();
                                                        showPanel.value = false;
                                                      },
                                                      child: Container(
                                                          width: 1.sh,
                                                          height: 600,
                                                          color: Color.fromRGBO(
                                                              0, 0, 0, 0.65)),
                                                    );
                                            }),
                                        Positioned(
                                            bottom: 0,
                                            child: (state
                                                    .listOfAddressInfoClassToSave
                                                    .isNullOrEmpty)
                                                ? SizedBox.shrink()
                                                : Container(
                                                    height: 100.h,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 1),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 10,
                                                          blurStyle:
                                                              BlurStyle.solid,
                                                          color:
                                                              Color(0xffF1F1F1),
                                                        )
                                                      ],
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                    ),
                                                    width: 1.sw,
                                                    child:
                                                        ValueListenableBuilder<
                                                                String>(
                                                            valueListenable:
                                                                paymentMethod,
                                                            builder: (context,
                                                                _paymentMethod,
                                                                _) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  if (_paymentMethod !=
                                                                      "") {
                                                                    HelperFunctions
                                                                        .slidingNavigation(
                                                                            context,
                                                                            PlaceOrder(
                                                                              customerAddressesInfo: state.listOfAddressInfoClassToSave![_indexTap],
                                                                              paymentMethod: paymentMethod,
                                                                              cartImages: widget.cartImages,
                                                                              currencySympole: widget.currencySympole,
                                                                              totalPrice: widget.totalPrice,
                                                                            ));
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 70.h,
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    color: _paymentMethod !=
                                                                            ""
                                                                        ? Color(
                                                                            0xff346BFF)
                                                                        : Color(
                                                                            0xffC4C2C2),
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        LocaleKeys
                                                                            .confirm_shipping_payment
                                                                            .tr(),
                                                                        style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                            color: const Color(
                                                                                0xffFEFEFE),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            fontSize:
                                                                                18,
                                                                            height:
                                                                                0.8),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10.h,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            '${widget.cartImages.length} ',
                                                                            style: context.textTheme.bodyMedium?.br.copyWith(
                                                                                color: const Color(0xffFEFEFE),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 14,
                                                                                height: 0.8),
                                                                          ),
                                                                          Text(
                                                                            LocaleKeys.item.tr(),
                                                                            style: context.textTheme.bodyMedium?.rr.copyWith(
                                                                                color: const Color(0xffFEFEFE),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 14,
                                                                                height: 0.8),
                                                                          ),
                                                                          Text(
                                                                            ' ${widget.totalPrice} ',
                                                                            style: context.textTheme.bodyMedium?.br.copyWith(
                                                                                color: const Color(0xffFEFEFE),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 14,
                                                                                height: 0.8),
                                                                          ),
                                                                          Text(
                                                                            "${widget.currencySympole}",
                                                                            style: context.textTheme.bodyMedium?.rr.copyWith(
                                                                                color: const Color(0xffFEFEFE),
                                                                                letterSpacing: 0.18,
                                                                                fontSize: 14,
                                                                                height: 0.8),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )),
                                                                ),
                                                              );
                                                            }),
                                                  )),
                                        Positioned(
                                          bottom: 0,
                                          child: GestureDetector(
                                            child: Container(
                                              height: 510,
                                              width: 1.sw,
                                              child: SlidingUpPanel(
                                                  controller: panelController,
                                                  borderRadius:
                                                      BorderRadius.only(
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
                                                    showPanel.value = false;
                                                  },
                                                  onPanelOpened: () {
                                                    showPanel.value = true;
                                                  },
                                                  minHeight: 0,
                                                  maxHeight: 510,
                                                  panelBuilder: (sc) =>
                                                      Container(
                                                          width: 1.sw,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                height: 25.h,
                                                                width: 145.w,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AppAssets
                                                                            .deliveryAddressSvg,
                                                                        width:
                                                                            18,
                                                                        height:
                                                                            18,
                                                                        color: Color(
                                                                            0xff1D1D1D),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Text(
                                                                      "${LocaleKeys.your_address_list.tr()} ",
                                                                      style: context.textTheme.bodyMedium?.rr.copyWith(
                                                                          color: const Color(
                                                                              0xff1D1D1D),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          fontSize:
                                                                              14,
                                                                          height:
                                                                              1.33),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Container(
                                                                height: 425.h,
                                                                width: 1.sw,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            24.w),
                                                                child: ListView
                                                                    .separated(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  itemBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          InkWell(
                                                                    onTap: () {
                                                                      indexTap.value =
                                                                          index;
                                                                    },
                                                                    child:
                                                                        AddressInfoWithContactInfoCart(
                                                                      cartChoosed:
                                                                          false,
                                                                      isDelete:
                                                                          false,
                                                                      customerAddressesInfo:
                                                                          state.listOfAddressInfoClassToSave![
                                                                              index],
                                                                      context:
                                                                          context,
                                                                      index:
                                                                          index,
                                                                      indexTap:
                                                                          _indexTap,
                                                                      onTapDelete:
                                                                          () {
                                                                        if (index ==
                                                                            _indexTap) {
                                                                          indexTap.value =
                                                                              0;
                                                                        }
                                                                        indexToDelete =
                                                                            index;
                                                                        showDeleteAddress.value =
                                                                            true;
                                                                      },
                                                                      onTapEdit:
                                                                          () {
                                                                        panelController
                                                                            .close();
                                                                        HelperFunctions.slidingNavigation(
                                                                            context,
                                                                            AddShippingAdress(
                                                                              addressInfoClassToEdid: state.listOfAddressInfoClassToSave![index],
                                                                              fromEdid: true,
                                                                            ));
                                                                      },
                                                                    ),
                                                                  ),
                                                                  separatorBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  itemCount: state
                                                                      .listOfAddressInfoClassToSave!
                                                                      .length,
                                                                  controller:
                                                                      sc,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              InkWell(
                                                                onTap: () {
                                                                  panelController
                                                                      .close();
                                                                  HelperFunctions
                                                                      .slidingNavigation(
                                                                          context,
                                                                          AddShippingAdress());
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 1.sw,
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              24.w),
                                                                  decoration: BoxDecoration(
                                                                      color: Color(
                                                                          0xffE8FFED),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                      border: Border.all(
                                                                          color:
                                                                              Color(0xffC4C2C2))),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Center(
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              AppAssets.addShippingAddressSvg,
                                                                            ),
                                                                            Positioned(
                                                                              top: 2,
                                                                              child: SvgPicture.asset(
                                                                                AppAssets.addShippingAddressWhiteSvg,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                        "${LocaleKeys.add_new_shipping_address.tr()} ",
                                                                        style: context.textTheme.bodyMedium?.mr.copyWith(
                                                                            color: const Color(
                                                                                0xff1D1D1D),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            fontSize:
                                                                                12,
                                                                            height:
                                                                                1.33),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              )
                                                            ],
                                                          ))),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                        _showDeleteAddress
                            ? Container(
                                width: 1.sw,
                                height: 1.sh,
                                color: Color.fromRGBO(0, 0, 0, 0.90),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 1.sh / 3.5,
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.deletecartSvg,
                                      color: Color(0xffFFFFFF),
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${LocaleKeys.delete_below_address.tr()} ",
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                              color: const Color(0xffFFFFFF),
                                              letterSpacing: 0.18,
                                              fontSize: 16,
                                              height: 1.33),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: AddressInfoWithContactInfoCart(
                                        cartChoosed: false,
                                        context: context,
                                        isDelete: true,
                                        indexTap: 0,
                                        index: 1,
                                        customerAddressesInfo:
                                            state.listOfAddressInfoClassToSave![
                                                indexToDelete],
                                        onTapDelete: () {},
                                        onTapEdit: () {},
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        showDeleteAddress.value = false;
                                        homeBloc.add(DeleteAdressInfoClassEvent(
                                            adressInfoClassId: state
                                                .listOfAddressInfoClassToSave?[
                                                    indexToDelete]
                                                .id));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 24.w),
                                        height: 50.h,
                                        width: 1.sw,
                                        decoration: BoxDecoration(
                                            color: Color(0xffF8F8F8),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: Color(0xffFF5F61),
                                            )),
                                        child: Center(
                                          child: Text(
                                            LocaleKeys.yes_delete.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.br
                                                .copyWith(
                                                    color: Color(0xffFF5F61),
                                                    letterSpacing: 0.18,
                                                    fontSize: 16,
                                                    height: 1.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDeleteAddress.value = false;
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 24.w),
                                        height: 50.h,
                                        width: 1.sw,
                                        child: Center(
                                          child: Text(
                                            LocaleKeys.cansel.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.rr
                                                .copyWith(
                                                    color: Color(0xffFFFFFF),
                                                    letterSpacing: 0.18,
                                                    fontSize: 16,
                                                    height: 1.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink()
                      ],
                    );
                  });
            },
          )),
    );
  }
}

Widget AddressInfoWithContactInfoCart(
    {required CustomerAddressesInfo customerAddressesInfo,
    required int index,
    required int indexTap,
    required bool isDelete,
    bool? placeOrder,
    bool? successfulOrder,
    required bool cartChoosed,
    required BuildContext context,
    required void Function()? onTapEdit,
    required void Function()? onTapDelete}) {
  return Container(
      height: (placeOrder ?? false)
          ? 130.h
          : (!isDelete && cartChoosed)
              ? 125.h
              : 90.h,
      width: 1.sw,
      padding: EdgeInsets.only(
          right: LanguageService.languageCode == "ar" ? 20 : 10,
          left: LanguageService.languageCode != "ar" ? 20 : 10),
      decoration: BoxDecoration(
          color: (placeOrder ?? false) || (successfulOrder ?? false)
              ? Color(0xffFFFFFF)
              : isDelete
                  ? Color.fromRGBO(0, 0, 0, 0)
                  : Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15),
          border: (placeOrder ?? false)
              ? Border.all(color: Color(0xffC4C2C2))
              : isDelete || (successfulOrder ?? false)
                  ? Border.all(color: Color(0xffFFFFFF))
                  : cartChoosed
                      ? Border.all(color: Color(0xff388CFF))
                      : index != indexTap
                          ? null
                          : Border.all(color: Color(0xff388CFF))),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Container(
            width: 360,
            height: 16,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.homeInactiveSvg,
                  color: isDelete
                      ? Color(0xffFFFFFF)
                      : index != indexTap
                          ? Color(0xff8D8D8D)
                          : Color(0xff1D1D1D),
                  height: 12,
                  width: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  customerAddressesInfo.address ?? "",
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: isDelete
                          ? Color(0xffFFFFFF)
                          : index != indexTap
                              ? Color(0xff8D8D8D)
                              : const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                ),
                isDelete || cartChoosed ? SizedBox.shrink() : Spacer(),
                isDelete || cartChoosed
                    ? SizedBox.shrink()
                    : InkWell(
                        onTap: onTapEdit,
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          width: 15,
                          height: 12,
                          child: SvgPicture.asset(
                            AppAssets.editSvg,
                            height: 30,
                            width: 20,
                          ),
                        ),
                      ),
                isDelete || cartChoosed
                    ? SizedBox.shrink()
                    : SizedBox(
                        width: 10,
                      ),
                isDelete || cartChoosed
                    ? SizedBox.shrink()
                    : InkWell(
                        onTap: onTapDelete,
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          width: 20,
                          height: 30,
                          child: SvgPicture.asset(
                            AppAssets.deletecartSvg,
                            height: 14,
                            width: 14,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Container(
            width: 350,
            height: 16,
            child: Row(
              children: [
                Text(
                  "${customerAddressesInfo.regionDetails?.building ?? ""}${(customerAddressesInfo.regionDetails?.building?.length ?? 0) > 0 ? " | " : ""}${customerAddressesInfo.regionDetails?.street ?? ""}${(customerAddressesInfo.regionDetails?.street?.length ?? 0) > 0 ? " | " : ""}${customerAddressesInfo.regionDetails?.town ?? ""}${(customerAddressesInfo.regionDetails?.town?.length ?? 0) > 0 ? " | " : ""}${customerAddressesInfo.regionDetails?.city ?? ""}${(customerAddressesInfo.regionDetails?.city?.length ?? 0) > 0 ? " | " : ""}${customerAddressesInfo.regionDetails?.province ?? ""} | ${customerAddressesInfo.regionDetails?.country ?? ''}",
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: isDelete
                          ? Color(0xffFFFFFF)
                          : index != indexTap
                              ? Color(0xff8D8D8D)
                              : const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                )
              ],
            ),
          ),
          Container(
            width: 350,
            height: 16,
            child: Row(
              children: [
                Text(
                  "${customerAddressesInfo.addressDetail}",
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: isDelete
                          ? Color(0xffFFFFFF)
                          : index != indexTap
                              ? Color(0xff8D8D8D)
                              : const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                )
              ],
            ),
          ),
          Container(
            width: 350,
            height: 16,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.phoneCallSvg,
                  color: isDelete
                      ? Color(0xffFFFFFF)
                      : index != indexTap
                          ? Color(0xff8D8D8D)
                          : Color(0xff1D1D1D),
                  height: 12,
                  width: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '+${customerAddressesInfo.contactInfo?.phone ?? ""}',
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: isDelete
                          ? Color(0xffFFFFFF)
                          : index != indexTap
                              ? Color(0xff8D8D8D)
                              : const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3),
                ),
                SizedBox(
                  width: 40,
                ),
                Container(
                  height: 16,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.personSvg,
                        color: isDelete
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : Color(0xff1D1D1D),
                        height: 12,
                        width: 12,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${customerAddressesInfo.contactInfo?.name ?? ""}',
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: isDelete
                                ? Color(0xffFFFFFF)
                                : index != indexTap
                                    ? Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                index != indexTap || isDelete
                    ? SizedBox.shrink()
                    : SvgPicture.asset(
                        AppAssets.shareSvg,
                        color: isDelete || cartChoosed
                            ? Color(0xffFFFFFF)
                            : Color(0xff388CFF),
                        allowDrawingOutsideViewBox: true,
                        height: 12,
                        width: 12,
                      ),
              ],
            ),
          ),
          !(!isDelete && cartChoosed)
              ? SizedBox.shrink()
              : SizedBox(
                  height: 8.h,
                ),
          !(placeOrder ?? false)
              ? SizedBox.shrink()
              : SizedBox(
                  height: 5.h,
                ),
          !(!isDelete && cartChoosed)
              ? SizedBox.shrink()
              : Container(
                  height: 30.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                      color: (placeOrder ?? false) || (successfulOrder ?? false)
                          ? Color(0xffF8F8F8)
                          : Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${LocaleKeys.expected_delivery.tr()}',
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff8D8D8D),
                            letterSpacing: 0.18,
                            fontSize: 10,
                            height: 1.3),
                      ),
                      Text(
                        ' Sunday, 03.Jun.21. ',
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 10,
                            height: 1.3),
                      ),
                      Text(
                        '${LocaleKeys.delivery_not.tr()}',
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xff388CFF),
                            color: const Color(0xff388CFF),
                            letterSpacing: 0.18,
                            fontSize: 10,
                            height: 1.3),
                      ),
                    ],
                  ))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: (!isDelete && cartChoosed)
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
      ));
}
