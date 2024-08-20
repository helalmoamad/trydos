import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/app_widgets/app_text_field.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetShareContent extends StatelessWidget {
  const ProductDetailsSheetShareContent(
      {super.key,
      required this.indicesOfChatCardsToShare,
      required this.focusNode,
       this.scrollController});

  final FocusNode focusNode;

  final ValueNotifier<List<int>> indicesOfChatCardsToShare;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: cupertino.CupertinoScrollBehavior(),
      child: ListView(
        controller: scrollController,
        shrinkWrap: true,
        physics: cupertino.ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.shareSvg,
                color: Color(0xff505050),
                height: 20,
              ),
              SizedBox(
                width: 10,
              ),
              MyTextWidget('Share This Product With',
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: Color(0xff505050),
                  )),
            ],
          ),
          10.verticalSpace,
          Material(
            color: Colors.transparent,
            child: Padding(
              padding:
                  HWEdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 10),
              child: AppTextField(
                focusNode: focusNode,
                filledColor: Color(0xffF8F8F8),
                bordersColor: Color(0xffF8F8F8),
                hintText: 'Search',
                roundingCornersValue: 30,
                textStyle: context.textTheme.titleMedium?.lr
                    .copyWith(color: const Color(0xff8D8D8D)),
                hintTextStyle: context.textTheme.bodySmall?.lr
                    .copyWith(color: const Color(0xff8D8D8D)),
                prefixIcon: Padding(
                  padding: HWEdgeInsetsDirectional.only(top: 15, bottom: 15),
                  child: SvgPicture.asset(
                    AppAssets.searchOutlinedSvg,
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<List<int>>(
              valueListenable: indicesOfChatCardsToShare,
              builder: (context, indices, _) {
                return Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    children: List.generate(
                        10,
                        (index) => ChatCardForShare(
                              index: index,
                              onTap: () {
                                if (!indicesOfChatCardsToShare.value
                                    .contains(index)) {
                                  indicesOfChatCardsToShare.value.add(index);
                                } else {
                                  indicesOfChatCardsToShare.value.remove(index);
                                }
                                indicesOfChatCardsToShare.notifyListeners();
                              },
                              selected: indices.contains(index),
                            )),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class ChatCardForShare extends StatelessWidget {
  const ChatCardForShare(
      {super.key, required this.index, required this.selected, this.onTap});

  final int index;
  final bool selected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: HWEdgeInsets.only(
              right: (index != 4 && index != 9) ? 10 : 0,
              top: index > 4 ? 20 : 0),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: selected
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0x29000000),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                        border: selected
                            ? Border.all(
                                color: Color(0xff0859D9),
                              )
                            : null),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: selected ? 0.5 : 1,
                            child: Container(
                              width: 70.w - (selected ? 2 : 0),
                              height: 80 - (selected ? 2 : 0),
                              decoration: BoxDecoration(),
                              child: Image.asset(
                                AppAssets.profileJpg,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 70.w - (selected ? 2 : 0),
                            height: 80 - (selected ? 2 : 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                  color: Colors.white.withOpacity(0.5),
                                  inset: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  MyTextWidget(
                    'Omar',
                    style: context.textTheme.bodySmall?.rq
                        .copyWith(color: Color(0xff505050)),
                  )
                ],
              ),
              selected
                  ? Positioned(
                      right: 0,
                      child: SvgPicture.asset(
                        AppAssets.shareSvg,
                        height: 20,
                        color: Color(0xff0859D9),
                      ))
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
