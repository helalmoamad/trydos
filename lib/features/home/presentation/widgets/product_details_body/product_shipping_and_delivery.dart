import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../authentication/presentation/manager/auth_bloc.dart';

class ProductShippingAndDelivery extends StatelessWidget {
  ProductShippingAndDelivery({super.key});

  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, _) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    AnimatedContainer(
                      height: expanded ? 275 : 155,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastLinearToSlowEaseIn,
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Color(0xffE2FFE6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(AppAssets.refundSvg),
                              SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'You Will Get A ',
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                          color: const Color(0xff8d8d8d),
                                          height: 14 / 11,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '25% Refund',
                                        style: context.textTheme.titleMedium?.mq
                                            .copyWith(
                                          color: const Color(0xff8d8d8d),
                                          height: 14 / 11,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' Of The Product Price If Shipping Is Delayed',
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                          color: const Color(0xff8d8d8d),
                                          height: 14 / 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(AppAssets.deliveryPathSvg),
                              SizedBox(
                                width: 10,
                              ),
                              MyTextWidget(
                                'Product Shipping & Delivery',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                        height: 16 / 13,
                                        color: Color(0xff8D8D8D)),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            isExpanded.value = !isExpanded.value;
                            //////////////////////////////
                            FirebaseAnalyticsService.logEventForSession(
                              eventName: AnalyticsEventsConst.buttonClicked,
                              executedEventName: AnalyticsExecutedEventNameConst
                                  .atYourAddressButton,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xffEFEFEF),
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            child: Center(
                              child: BlocBuilder<AuthBloc, AuthState>(
                                buildWhen: (p, c) =>
                                    p.getCustomerCountryStatus !=
                                    c.getCustomerCountryStatus,
                                builder: (context, state) {
                                  if (state.getCustomerCountryStatus ==
                                      GetCustomerCountryStatus.loading) {
                                    return TrydosLoader(
                                      size: 25,
                                    );
                                  }
                                  if (state.getCustomerCountryStatus ==
                                      GetCustomerCountryStatus.failure) {
                                    return MyTextWidget(
                                      'Failed to get location',
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                              height: 16 / 13,
                                              color: Color(0xff8D8D8D)),
                                    );
                                  }
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'At Your Address In ',
                                          style: context
                                              .textTheme.titleMedium?.lq
                                              .copyWith(
                                            color: const Color(0xff8d8d8d),
                                            height: 14 / 11,
                                          ),
                                        ),
                                        TextSpan(
                                          text: state.countryName,
                                          style: context
                                              .textTheme.titleMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff8d8d8d),
                                            height: 14 / 11,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' Expected Within ',
                                          style: context
                                              .textTheme.titleMedium?.rq
                                              .copyWith(
                                            color: const Color(0xff8d8d8d),
                                            height: 14 / 11,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '4 Days',
                                          style: context
                                              .textTheme.titleMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff8d8d8d),
                                            height: 14 / 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textHeightBehavior: TextHeightBehavior(
                                        applyHeightToFirstAscent: false),
                                    textAlign: TextAlign.start,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (expanded) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 13,
                              ),
                              SvgPicture.asset(AppAssets.fastPackingIconSvg),
                              SizedBox(
                                width: 22,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                          AppAssets.fastPackingManIconSvg),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      MyTextWidget(
                                        'Fast Packing & Start Shipping',
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                                height: 14 / 11,
                                                color: Color(0xff388CFF)),
                                      )
                                    ],
                                  ),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Same Day Packing & Ship If Buy Before ',
                                            style: context
                                                .textTheme.titleMedium?.lq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '13:00 ',
                                            style: context
                                                .textTheme.titleMedium?.lq
                                                .copyWith(
                                              color: const Color(0xff388CFF),
                                              height: 14 / 11,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Today',
                                            style: context
                                                .textTheme.titleMedium?.lq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 13,
                              ),
                              SvgPicture.asset(AppAssets.airplaneSvg),
                              SizedBox(
                                width: 22,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<AuthBloc, AuthState>(
                                    buildWhen: (p, c) =>
                                        p.getCustomerCountryStatus !=
                                        c.getCustomerCountryStatus,
                                    builder: (context, state) {
                                      if (state.getCustomerCountryStatus ==
                                          GetCustomerCountryStatus.loading) {
                                        return TrydosLoader(
                                          size: 25,
                                        );
                                      }
                                      if (state.getCustomerCountryStatus ==
                                          GetCustomerCountryStatus.failure) {
                                        return MyTextWidget(
                                          'Failed to get location',
                                          style: context
                                              .textTheme.titleLarge?.rq
                                              .copyWith(
                                                  height: 16 / 13,
                                                  color: Color(0xff8D8D8D)),
                                        );
                                      }
                                      return MyTextWidget(
                                        '12. Jun. In ${state.countryName}',
                                        style: context.textTheme.titleMedium?.rq
                                            .copyWith(
                                                height: 14 / 11,
                                                color: Color(0xff388CFF)),
                                      );
                                    },
                                  ),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Time Is Expected, It May Take More Or Less Than 2 Days',
                                            style: context
                                                .textTheme.titleMedium?.lq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 13,
                              ),
                              SvgPicture.asset(AppAssets.locationSvg),
                              SizedBox(
                                width: 22,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '14. Jun. ',
                                            style: context
                                                .textTheme.titleMedium?.mq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'In Your Adress',
                                            style: context
                                                .textTheme.titleMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Specify Your Address To Calculate The Delivery Time',
                                            style: context
                                                .textTheme.titleMedium?.lq
                                                .copyWith(
                                              color: const Color(0xff8d8d8d),
                                              height: 14 / 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textHeightBehavior: TextHeightBehavior(
                                          applyHeightToFirstAscent: false),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        }
                      ]),
                    )
                  ],
                );
              }),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xffF8F8F8)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset(AppAssets.freeShippingSvg),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextWidget(
                        'Free Shipping',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 16 / 13, color: Color(0xff8d8d8d)),
                      ),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Shipping Is Completely Free Without Any Extras',
                                style:
                                    context.textTheme.titleMedium?.lq.copyWith(
                                  color: const Color(0xff8d8d8d),
                                  height: 14 / 11,
                                ),
                              ),
                            ],
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffFFF3E8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Within ',
                                style:
                                    context.textTheme.titleMedium?.rq.copyWith(
                                  color: const Color(0xff8d8d8d),
                                  height: 14 / 11,
                                ),
                              ),
                              TextSpan(
                                text: '3 Days',
                                style:
                                    context.textTheme.titleMedium?.mq.copyWith(
                                  color: const Color(0xff8d8d8d),
                                  height: 14 / 11,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' After Receiving The Product, You Can Return It Without Conditions Or Reasons With Complete Ease And Get The Amount Back',
                                style:
                                    context.textTheme.titleMedium?.rq.copyWith(
                                  color: const Color(0xff8d8d8d),
                                  height: 14 / 11,
                                ),
                              ),
                            ],
                          ),
                          textHeightBehavior: TextHeightBehavior(
                              applyHeightToFirstAscent: false),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffF8F8F8)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      SvgPicture.asset(AppAssets.freeReturnSvg),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextWidget(
                            'Free Return',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                                height: 16 / 13, color: Color(0xff8d8d8d)),
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Return Is Completely Free Without Any Extras',
                                    style: context.textTheme.titleMedium?.lq
                                        .copyWith(
                                      color: const Color(0xff8d8d8d),
                                      height: 14 / 11,
                                    ),
                                  ),
                                ],
                              ),
                              textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
