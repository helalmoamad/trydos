import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class NotifyWhenAvailableInCountryButton extends StatefulWidget {
  const NotifyWhenAvailableInCountryButton({
    super.key,
    required this.unAvailableType,
    required this.productId,
    required this.currentTap,
    required this.productItem,
  });

  final String unAvailableType;
  final productListingModel.Products productItem;
  final String productId;
  final int currentTap;

  @override
  State<NotifyWhenAvailableInCountryButton> createState() =>
      _NotifyWhenAvailableInCountryButtonState();
}

class _NotifyWhenAvailableInCountryButtonState
    extends State<NotifyWhenAvailableInCountryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  bool isVariantRequestNotification = false;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animationController.addStatusListener(_updateStatus);
    super.initState();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.getFirebaseSettingForNotificationStatus !=
          c.getFirebaseSettingForNotificationStatus,
      builder: (context, state) {
        state
            .firebaseSettingForNotificationModel
            ?.data
            ?.firebaseSettings
            ?.subscribedTopics
            ?.forEach((element) {
              if (element.topic?.contains(
                    "product_availability_${widget.productId}",
                  ) ??
                  false) {
                isVariantRequestNotification = true;
              } else {
                isVariantRequestNotification = false;
              }
            });
        Widget GetNotifyMeButtum() {
          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final sineValue = sin(3 * 2 * pi * animationController.value);
              return Transform.translate(
                offset: Offset(sineValue * 3, 0),
                child: SizedBox(
                  width: widget.currentTap == 3 ? 1.sw - 50.w : 150.w,
                  height: 70.h,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (state.getFirebaseSettingForNotificationStatus ==
                              GetFirebaseSettingForNotificationStatus.loading) {
                            return;
                          }
                          if (isVariantRequestNotification) {
                            BlocProvider.of<HomeBloc>(context).add(
                              RequestForNotificationWhenProductBecameAvailableEvent(
                                widget.productId,
                                1,
                                "",
                                "",
                                false,
                              ),
                            );
                            return;
                          }
                          FirebaseAnalyticsService.logEventForSession(
                            executedEventName: AnalyticsButtonsEventNameConst
                                .ENABLE_PRODUCT_NOTIFICATIONS_BUTTON,
                            eventName: AnalyticsEventsConst
                                .ENABLE_PRODUCT_NOTIFICATION,
                            extraParams: {
                              'item_id': widget.productItem.productId
                                  .toString(),
                              "notification_type": '${widget.unAvailableType}',
                              'item_name': widget.productItem.name.toString(),
                              'price': widget.productItem.price.toString(),
                              'brand': widget.productItem.brand == null
                                  ? ""
                                  : widget.productItem.brand!.name.toString(),
                              'category': widget.productItem.categories!
                                  .map((e) => e.id.toString())
                                  .toList()
                                  .toString(),
                              'count_likes': widget.productItem.countOfLikes
                                  .toString(),
                              'review_count': widget.productItem.reviewsCount
                                  .toString(),
                              'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
                            },
                          );
                          HapticFeedback.lightImpact();
                          BlocProvider.of<HomeBloc>(context).add(
                            RequestForNotificationWhenProductBecameAvailableEvent(
                              widget.productId,
                              1,
                              "",
                              "",
                              true,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastLinearToSlowEaseIn,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isVariantRequestNotification
                                  ? const Color(0xff513AAF)
                                  : const Color(0xffE6F1FF),
                            ),
                            color: isVariantRequestNotification
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff513AAF),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Spacer(),
                                      state.getFirebaseSettingForNotificationStatus ==
                                              GetFirebaseSettingForNotificationStatus
                                                  .loading
                                          ? TrydosLoader(
                                              size: 20.h,
                                              color:
                                                  isVariantRequestNotification
                                                  ? const Color(0xffFCFCFC)
                                                  : const Color(0xff513AAF),
                                            )
                                          : SvgPicture.asset(
                                              isVariantRequestNotification
                                                  ? AppAssets
                                                        .notificationIconSvg
                                                  : AppAssets
                                                        .notificationOutlinedIconSvg,
                                              height: 20.h,
                                              // ignore: deprecated_member_use
                                              color:
                                                  !isVariantRequestNotification
                                                  ? const Color(0xffFCFCFC)
                                                  : const Color(0xff513AAF),
                                            ),
                                      const Spacer(),
                                    ],
                                  ),
                                  SizedBox(height: 5.h),
                                  if (!isVariantRequestNotification) ...{
                                    MyTextWidget(
                                      '${widget.unAvailableType} ${LocaleKeys.notify_me_when_available.tr()}',
                                      style: textTheme.titleMedium?.rq.copyWith(
                                        height: 15 / 12,
                                        fontSize: 15.sp,
                                        color: const Color(0xffFCFCFC),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  } else ...{
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyTextWidget(
                                          '${LocaleKeys.we_will_inform_you_when_a.tr()} ${LocaleKeys.product_is_available.tr()}',
                                          style: textTheme.titleMedium?.rq
                                              .copyWith(
                                                fontSize: 15.sp,
                                                height: 15 / 12,
                                                color: const Color(0xff513AAF),
                                              ),
                                        ),
                                      ],
                                    ),
                                  },
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -35.h,
                        right: -35.w,
                        child: Container(
                          width: 55.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isVariantRequestNotification
                                  ? const Color(0xff513AAF)
                                  : const Color(0xffFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        isVariantRequestNotification
                            ? AppAssets.notificationOutlinedIconSvg
                            : AppAssets.notificationIconSvg,
                        height: 15.h,
                        // ignore: deprecated_member_use
                        color: !isVariantRequestNotification
                            ? const Color(0xff513AAF)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return GetNotifyMeButtum();
      },
    );
  }
}
