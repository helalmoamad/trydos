import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';

class NotifyWhenQuantityAvailableButton extends StatefulWidget {
  const NotifyWhenQuantityAvailableButton(
      {super.key, required this.unAvailableSize, required this.productId, required this.selectedColorName, required this.notificationTypeId});

  final String unAvailableSize;
  final String productId;
  final String selectedColorName ;
  final int notificationTypeId;

  @override
  State<NotifyWhenQuantityAvailableButton> createState() =>
      _NotifyWhenQuantityAvailableButtonState();
}

class _NotifyWhenQuantityAvailableButtonState
    extends State<NotifyWhenQuantityAvailableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

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
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.isSizeRequestNotification != c.isSizeRequestNotification,
      builder: (context, state) {
        return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final sineValue = sin(3 * 2 * pi * animationController.value);
              return Transform.translate(
                  offset: Offset(sineValue * 3, 0),
                  child: SizedBox(
                    width: 1.sw - 40,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            BlocProvider.of<HomeBloc>(context).add(RequestForNotificationWhenProductBecameAvailableEvent(widget.productId, widget.notificationTypeId, widget.unAvailableSize , widget.selectedColorName));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastLinearToSlowEaseIn,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: state.isSizeRequestNotification.contains(widget.unAvailableSize)
                                    ? const Color(0xffFFFCE6)
                                    : const Color(0xffE6F1FF)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
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
                                          state.isSizeRequestNotification.contains(widget.unAvailableSize)
                                              ? AppAssets
                                                  .notificationIconSvg
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
                                    if (!state.isSizeRequestNotification.contains(widget.unAvailableSize)) ...{
                                      MyTextWidget(
                                        'Notify Me When Size Is Available',
                                        style: textTheme.titleMedium?.rq
                                            .copyWith(
                                                height: 15 / 12,
                                                color: const Color(
                                                    0xff505050)),
                                      )
                                    } else ...{
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyTextWidget(
                                            'We Will Inform You When A ',
                                            style: textTheme
                                                .titleMedium?.rq
                                                .copyWith(
                                                    height: 15 / 12,
                                                    color: const Color(
                                                        0xff505050)),
                                          ),
                                          MyTextWidget(
                                            '${widget.unAvailableSize} ',
                                            style: textTheme
                                                .titleMedium?.bq
                                                .copyWith(
                                                    height: 15 / 12,
                                                    color: const Color(
                                                        0xff505050)),
                                          ),
                                          MyTextWidget(
                                            'Size Is Available',
                                            style: textTheme
                                                .titleMedium?.rq
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
                          state.isSizeRequestNotification.contains(widget.unAvailableSize)
                              ? AppAssets.notificationOutlinedIconSvg
                              : AppAssets.notificationIconSvg,
                          height: 15.h,
                        ),
                      ],
                    ),
                  ));
            });
      },
    );
  }
}
