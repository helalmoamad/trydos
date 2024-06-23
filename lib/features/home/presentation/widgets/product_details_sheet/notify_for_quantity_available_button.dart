

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';

class NotifyWhenQuantityAvailableButton extends StatefulWidget {
  const NotifyWhenQuantityAvailableButton({super.key, required this.unAvailableSize});

  final String unAvailableSize ;

  @override
  State<NotifyWhenQuantityAvailableButton> createState() => _NotifyWhenQuantityAvailableButtonState();
}

class _NotifyWhenQuantityAvailableButtonState extends State<NotifyWhenQuantityAvailableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  final ValueNotifier<bool> isButtonClicked = ValueNotifier(false);
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
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
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final sineValue =
          sin(3 * 2 * pi * animationController.value);
          return Transform.translate(
              offset: Offset(sineValue * 3, 0),
              child: SizedBox(
                width: 1.sw - 40 ,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isButtonClicked,
                      builder: (context , clicked , child) {
                        return GestureDetector(
                          onTap: (){
                            HapticFeedback.lightImpact();
                            isButtonClicked.value = !isButtonClicked.value;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastLinearToSlowEaseIn,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(20),
                                color: clicked
                                    ? const Color(0xffFFFCE6)
                                    : const Color(0xffE6F1FF)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                          const Spacer(),
                                        SvgPicture.asset(
                                          clicked ? AppAssets
                                              .notificationIconSvg : AppAssets.notificationOutlinedIconSvg,
                                          height: 30,
                                        ),
                                        const Spacer()
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    if(!clicked)...{
                                      MyTextWidget(
                                        'Notify Me When Size Is Available',
                                        style: textTheme
                                            .caption?.rq
                                            .copyWith(
                                          height: 15 / 12,
                                            color: const Color(
                                                0xff505050)),
                                      )
                                    }else ...{
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          MyTextWidget(
                                            'We Will Inform You When A ',
                                            style: textTheme
                                                .caption?.rq
                                                .copyWith(
                                                height: 15 / 12 ,
                                                color: const Color(
                                                    0xff505050)),
                                          ),
                                          MyTextWidget(
                                            '${widget.unAvailableSize} ',
                                            style: textTheme
                                                .caption?.bq
                                                .copyWith(
                                                height: 15 / 12 ,
                                                color: const Color(
                                                    0xff505050)),
                                          ),
                                          MyTextWidget(
                                            'Size Is Available',
                                            style: textTheme
                                                .caption?.rq
                                                .copyWith(
                                                height: 15 / 12 ,
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
                        );
                      }
                    ),
                    Positioned(
                      top: -35,
                      right: -35,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(20),
                            color: colorScheme.white),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isButtonClicked,
                      builder: (context , clicked , child) {
                        return SvgPicture.asset(
                          clicked ? AppAssets.notificationOutlinedIconSvg :AppAssets.notificationIconSvg,
                          height: 15.h,
                        );
                      }
                    ),
                  ],
                ),
              ));
        });
  }
}
