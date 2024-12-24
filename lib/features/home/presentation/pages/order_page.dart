import 'dart:math';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';

import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class OrderPage extends StatefulWidget {
  final bool? fromeFilters;
  final bool? fromeNotification;

  const OrderPage({Key? key, this.fromeFilters, this.fromeNotification});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late HomeBloc homeBloc;
  late AppBloc appBloc;

  bool? fromForGroundNotification;
  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);

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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: WillPopScope(
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
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 60),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: 1.sw - 20,
                      height: 70.h,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 50.h,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    // didCallOnWillPop = true;
                                    if (Navigator.canPop(context)) {
                                      if (Navigator.of(context).canPop()) {
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
                                  "Shopping Bag ",
                                  style: context.textTheme.bodyMedium?.ra
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 13,
                                          height: 1.33),
                                ),
                                Text(
                                  "${state.cartCollection?.length} item",
                                  style: context.textTheme.bodyMedium?.br
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 13,
                                          height: 1.33),
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
                        height: 1.sh - 190,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 170.h,
                                  ),
                                  Container(
                                      height: 40,
                                      child: InkWell(
                                          child: Container(
                                              width: 200,
                                              color: const Color.fromARGB(
                                                  255, 17, 16, 16),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Place Order",
                                                style: context
                                                    .textTheme.bodyMedium?.la
                                                    .copyWith(
                                                  fontSize: 18,
                                                  color: const Color.fromARGB(
                                                      255, 247, 233, 233),
                                                  letterSpacing: 0.18,
                                                ),
                                              )))),
                                ],
                              ),
                            )

                            /*  SizedBox(
                                  height: 20,
                                ),
                                state.oldcartCollection != null
                                    ? !state.oldcartCollection!.isEmpty
                                        ? Center(
                                            child: MyTextWidget(
                                            "Old Cart",
                                            style: TextStyle(
                                                color: Colors.black, fontSize: 24),
                                          ))
                                        : SizedBox.shrink()
                                    : SizedBox.shrink(),*/
                            /*     SizedBox(
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
                                                      "Hide All",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14),
                                                    ))
                                              ],
                                            ))
                                        : SizedBox.shrink()
                                    : SizedBox.shrink(),*/
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            )),
      ),
    );
  }
}
