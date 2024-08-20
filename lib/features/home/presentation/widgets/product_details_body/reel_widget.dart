import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';
import 'package:like_button/like_button.dart';

import '../../../../app/trydos_favorite_buton.dart';

class ReelWidget extends StatelessWidget {
  const ReelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ProductDetailsImageWidget(
              height: 595,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              width: 1.sw,
              withBackGroundShadow: false,
              withInnerShadow: false,
              imageFit: BoxFit.fill,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TrydosFavoriteButton(),
                  const SizedBox(height: 25),
                  SvgPicture.asset(
                    AppAssets.shareSvg,
                    color: const Color(0xff505050),
                  ),
                  const SizedBox(height: 25),
                  SvgPicture.asset(AppAssets.moreOptionSvg),
                ],
              ),
            )
          ],
        ),
        Container(
          width: 1.sw,
          padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
          decoration: const BoxDecoration(
            color: Color(0xfff8f8f8),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)),
          ),
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x29000000),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Stack(
                    children: [
                      SizedBox(
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
              const SizedBox(
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
                          style: context.textTheme.bodySmall?.rq
                              .copyWith(color: Color(0xff969696)),
                        ),
                        MyTextWidget(
                          '18 feb',
                          style: context.textTheme.titleSmall?.rq
                              .copyWith(color: Color(0xff8D8D8D)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Flexible(
                      child: MyTextWidget(
                        'Amazing Product I Buy It And I Saw It Is Good Quality Regarding Price',
                        style: context.textTheme.bodySmall?.rq
                            .copyWith(color: Color(0xff5D5C5D)),
                        maxLines: 5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          AppAssets.favoriteSvg,
                          height: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        MyTextWidget(
                          '110k',
                          style: context.textTheme.titleMedium?.rq
                              .copyWith(color: Color(0xff8D8D8D)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
