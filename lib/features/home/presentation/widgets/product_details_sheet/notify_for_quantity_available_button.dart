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
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';

class NotifyWhenQuantityAvailableButton extends StatefulWidget {
  const NotifyWhenQuantityAvailableButton(
      {super.key,
      required this.unAvailableSize,
      required this.productId,
      required this.selectedColorName,
      required this.currentTap,
      required this.notificationTypeId});

  final String unAvailableSize;
  final String productId;

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
                      width: widget.currentTap != 3 ? 150 : 1.sw - 50.h,
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
                                  color: isVariantRequestNotification
                                      ? const Color(0xffFFFCE6)
                                      : const Color(0xffE6F1FF)),
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
                                          SvgPicture.asset(
                                            isVariantRequestNotification
                                                ? AppAssets.notificationIconSvg
                                                : AppAssets
                                                    .notificationOutlinedIconSvg,
                                            height: 30,
                                          ),
                                          const Spacer()
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      if (!isVariantRequestNotification) ...{
                                        MyTextWidget(
                                          '${LocaleKeys.out_of_stock.tr()}\n${LocaleKeys.notify_me_when_quantity_is_available.tr()}',
                                          style: textTheme.titleMedium?.rq
                                              .copyWith(
                                                  height: 15 / 12,
                                                  color:
                                                      const Color(0xff505050)),
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
                                                      height: 15 / 12,
                                                      color: const Color(
                                                          0xff505050)),
                                            ),
                                            /*    MyTextWidget(
                                              '${widget.unAvailableSize} ',
                                              style: textTheme.titleMedium?.bq
                                                  .copyWith(
                                                      height: 15 / 12,
                                                      color: const Color(
                                                          0xff505050)),
                                            ),*/
                                            MyTextWidget(
                                              '${LocaleKeys.quantity_is_available.tr()}',
                                              style: textTheme.titleMedium?.rq
                                                  .copyWith(
                                                      height: 15 / 12,
                                                      color: const Color(
                                                          0xff505050)),
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
                                  borderRadius: BorderRadius.circular(20),
                                  color: colorScheme.white),
                            ),
                          ),
                          SvgPicture.asset(
                            isVariantRequestNotification
                                ? AppAssets.notificationOutlinedIconSvg
                                : AppAssets.notificationIconSvg,
                            height: 15.h,
                          ),
                        ],
                      ),
                    ));
              });
        }

        return state.getFirebaseSettingForNotificationStatus ==
                GetFirebaseSettingForNotificationStatus.loading
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                enabled: true,
                child: GetNotifyMeButtum())
            : GetNotifyMeButtum();
      },
    );
  }
}
