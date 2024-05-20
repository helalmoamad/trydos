import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetCommentsContent extends StatelessWidget {
  const ProductDetailsSheetCommentsContent({super.key, this.scrollController });

  final ScrollController? scrollController ;
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const cupertino.CupertinoScrollBehavior(),
      child: ListView(
        controller: scrollController,
        physics: const cupertino.ClampingScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.chatMarkActiveSvg,
                height: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              MyTextWidget('Comment About This Product',
                  style: context.textTheme.subtitle1?.mq.copyWith(
                    color: Color(0xff505050),
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ...List.generate(5, (index) => const Column(
            children: [
              CommentCard(),
              SizedBox(
                height: 5,
              )
            ],
          ))
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  const CommentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: HWEdgeInsets.symmetric(horizontal: 20),
      padding: HWEdgeInsets.only(left: 10, top: 20, right: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(20.0),
      ),
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      AppAssets.profileJpg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
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
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyTextWidget(
                      'Yxxx Oxxx',
                      style: context.textTheme.subtitle2?.rq
                          .copyWith(color: Color(0xff969696)),
                    ),
                    MyTextWidget(
                      '18 feb',
                      style: context.textTheme.overline?.rq
                          .copyWith(color: Color(0xff969696)),
                    ),
                  ],
                ),
                Flexible(
                  child: MyTextWidget(
                    'Amazing Product I Buy It And I Saw It Is Good Quality Regarding Price',
                    style: context.textTheme.subtitle2?.rq
                        .copyWith(color: Color(0xff5D5C5D)),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
