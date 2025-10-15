import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../core/utils/theme_state.dart';

class BuyerSellerChat extends StatefulWidget {
  const BuyerSellerChat({
    super.key,
  });

  @override
  State<BuyerSellerChat> createState() => _BuyerSellerChatState();
}

class _BuyerSellerChatState extends ThemeState<BuyerSellerChat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(AppAssets.faqSvg,
                  // ignore: deprecated_member_use
                  color: const Color(0xff1D1D1D))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  MyTextWidget(
                    '${LocaleKeys.faq_buyer_seller.tr()}',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  SvgPicture.asset(
                    AppAssets.registerInfoSvg,
                    height: 10,
                    width: 10,
                    // ignore: deprecated_member_use
                    color: const Color(0xffC4C2C2),
                  ),
                ],
              )),
          SizedBox(
              height: 250,
              width: 1.sw,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                  width: 5,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _commentWidget();
                },
                itemCount: 3,
              )),
          Container(
            height: 40,
            width: 1.sw,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xff513AAF))),
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                SvgPicture.asset(
                  AppAssets.faqSvg,
                ),
                const Spacer(),
                MyTextWidget(
                  '${LocaleKeys.ask_seller_about_product.tr()}',
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xffC4C2C2), fontSize: 11),
                ),
                const Spacer(),
                const SizedBox(
                  width: 22,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _commentWidget() {
    return Container(
        width: 388.w,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._SingelComments(appearTimeAnsward: false),
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(bottom: 10, top: 10),
              color: const Color(0xffD3D3D3),
            ),
            ..._SingelComments(appearTimeAnsward: true)
          ],
        ));
  }

  List<Widget> _SingelComments({required bool appearTimeAnsward}) {
    return [
      SizedBox(
        height: 20,
        width: 1.sw,
        child: Row(
          children: [
            const MyCachedNetworkImage(
                imageUrl:
                    "https://res.cloudinary.com/dtcmozf4d/image/upload/v1/boutiques/boutiques/2025-08-26-68ae378e796d0.png",
                width: 20,
                imageFit: BoxFit.cover,
                height: 20),
            const SizedBox(width: 10),
            MyTextWidget(
              'Yxxx Oxxxx',
              style: context.textTheme.titleLarge?.rr
                  .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
            ),
            const Spacer(),
            MyTextWidget(
              '18 feb',
              style: context.textTheme.titleLarge?.rr
                  .copyWith(color: const Color(0xff8D8D8D), fontSize: 9),
            )
          ],
        ),
      ),
      const SizedBox(height: 10),
      MyTextWidget(
        'Medium | Bule',
        style: context.textTheme.titleLarge?.mr
            .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
      ),
      const SizedBox(height: 10),
      MyTextWidget(
        'Amazing Product I Buy It And I Saw It Is Good Quality Regarding Price Amazing Product I Buy It And I Saw It Is Good Quality Regardin',
        maxLines: 10,
        style: context.textTheme.titleLarge?.rr
            .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
      ),
      const Spacer(),
      Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.favoriteActiveSvg,
                width: 12,
              ),
              MyTextWidget(
                '  110k',
                style: context.textTheme.titleLarge?.rr
                    .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
              ),
              const Spacer(),
              appearTimeAnsward
                  ? MyTextWidget(
                      '13 Minute Answered',
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff8D8D8D), fontSize: 9),
                    )
                  : const SizedBox.shrink()
            ],
          ))
    ];
  }
}
