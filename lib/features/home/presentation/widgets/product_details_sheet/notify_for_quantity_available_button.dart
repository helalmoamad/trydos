import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class NotifyWhenQuantityAvailableButton extends StatefulWidget {
  const NotifyWhenQuantityAvailableButton(
      {super.key,
      required this.unAvailableSize,
      required this.productId,
      required this.selectedColorName,
      required this.productItem,
      required this.currentTap,
      required this.notificationTypeId});

  final String unAvailableSize;
  final String productId;
  final productListingModel.Products productItem;
  final String selectedColorName;
  final int notificationTypeId;
  final int currentTap;
  @override
  State<NotifyWhenQuantityAvailableButton> createState() =>
      _NotifyWhenQuantityAvailableButtonState();
}

class _NotifyWhenQuantityAvailableButtonState
    extends State<NotifyWhenQuantityAvailableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  bool isVariantRequestNotification = false;
  String variant = "";
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
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
        if (widget.unAvailableSize != "") {
          variant = widget.selectedColorName == ''
              ? widget.unAvailableSize
              : "${widget.selectedColorName}-${widget.unAvailableSize}";
        } else {
          variant =
              widget.selectedColorName == '' ? "" : widget.selectedColorName;
        }

        state.firebaseSettingForNotificationModel?.data?.firebaseSettings
            ?.subscribedTopics
            ?.forEach((element) {
          if (element.topic
                  ?.contains("product_availability_${widget.productId}") ??
              false) {
            if (variant == "") {
              isVariantRequestNotification = true;
            } else if (element.variants!.contains(variant)) {
              isVariantRequestNotification = true;
            }
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
                      width: 1.sw - 40,
                      height: 70,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (state
                                      .getFirebaseSettingForNotificationStatus ==
                                  GetFirebaseSettingForNotificationStatus
                                      .loading) {
                                return;
                              }
                              if (isVariantRequestNotification) {
                                BlocProvider.of<HomeBloc>(context).add(
                                    RequestForNotificationWhenProductBecameAvailableEvent(
                                        widget.productId,
                                        widget.notificationTypeId,
                                        widget.unAvailableSize,
                                        widget.selectedColorName,
                                        false));
                                return;
                              }
                              HapticFeedback.lightImpact();

                              FirebaseAnalyticsService.logEventForSession(
                                executedEventName:
                                    AnalyticsButtonsEventNameConst
                                        .ENABLE_PRODUCT_NOTIFICATIONS_BUTTON,
                                eventName: AnalyticsEventsConst.viewTimeProduct,
                                extraParams: {
                                  'item_id':
                                      widget.productItem.productId.toString(),
                                  "notification_type":
                                      '${widget.unAvailableSize} - ${widget.selectedColorName}',
                                  'item_name':
                                      widget.productItem.name.toString(),
                                  'price': widget.productItem.price.toString(),
                                  'brand': widget.productItem.brand == null
                                      ? ""
                                      : widget.productItem.brand!.name
                                          .toString(),
                                  'category': widget.productItem.categories!
                                      .map(
                                        (e) => e.id.toString(),
                                      )
                                      .toList()
                                      .toString(),
                                  'count_likes': widget.productItem.countOfLikes
                                      .toString(),
                                  'review_count': widget
                                      .productItem.reviewsCount
                                      .toString(),
                                  'screen_name':
                                      GlobalScreenConst.PRODUCT_SCREEN,
                                },
                              );
                              BlocProvider.of<HomeBloc>(context).add(
                                  RequestForNotificationWhenProductBecameAvailableEvent(
                                      widget.productId,
                                      widget.notificationTypeId,
                                      widget.unAvailableSize,
                                      widget.selectedColorName,
                                      true));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastLinearToSlowEaseIn,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isVariantRequestNotification
                                          ? const Color(0xff513AAF)
                                          : const Color(0xffE6F1FF)),
                                  color: isVariantRequestNotification
                                      ? const Color(0xffFFFFFF)
                                      : const Color(0xff513AAF)),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Spacer(),
                                          state.getFirebaseSettingForNotificationStatus ==
                                                  GetFirebaseSettingForNotificationStatus
                                                      .loading
                                              ? TrydosLoader(
                                                  size: 20.h,
                                                  color:
                                                      !isVariantRequestNotification
                                                          ? const Color(
                                                              0xffFCFCFC)
                                                          : const Color(
                                                              0xff513AAF),
                                                )
                                              : SvgPicture.asset(
                                                  isVariantRequestNotification
                                                      ? AppAssets
                                                          .notificationIconSvg
                                                      : AppAssets
                                                          .notificationOutlinedIconSvg,
                                                  height: 20,
                                                  color:
                                                      !isVariantRequestNotification
                                                          ? const Color(
                                                              0xffFCFCFC)
                                                          : const Color(
                                                              0xff513AAF),
                                                ),
                                          const Spacer()
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      if (!isVariantRequestNotification) ...{
                                        MyTextWidget(
                                          '${LocaleKeys.notify_me_when_quantity_is_available.tr()}',
                                          style: textTheme.titleMedium?.rq
                                              .copyWith(
                                                  height: 15 / 12,
                                                  fontSize: 15,
                                                  color:
                                                      const Color(0xffFCFCFC)),
                                          textAlign: TextAlign.center,
                                        )
                                      } else ...{
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyTextWidget(
                                              '${LocaleKeys.we_will_inform_you_when_a.tr()} ',
                                              style: textTheme.titleMedium?.rq
                                                  .copyWith(
                                                      fontSize: 15,
                                                      height: 15 / 12,
                                                      color: const Color(
                                                          0xff513AAF)),
                                            ),
                                            MyTextWidget(
                                              '${LocaleKeys.quantity_is_available.tr()}',
                                              style: textTheme.titleMedium?.rq
                                                  .copyWith(
                                                      fontSize: 15,
                                                      height: 15 / 12,
                                                      color: const Color(
                                                          0xff513AAF)),
                                            ),
                                          ],
                                        )
                                      }
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -35,
                            right: -35,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: isVariantRequestNotification
                                        ? const Color(0xff513AAF)
                                        : const Color(0xffFFFFFF)),
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            isVariantRequestNotification
                                ? AppAssets.notificationOutlinedIconSvg
                                : AppAssets.notificationIconSvg,
                            height: 15,
                            color: !isVariantRequestNotification
                                ? const Color(0xff513AAF)
                                : null,
                          ),
                        ],
                      ),
                    ));
              });
        }

        return GetNotifyMeButtum();
      },
    );
  }
}
