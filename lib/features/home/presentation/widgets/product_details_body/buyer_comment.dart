import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../core/utils/theme_state.dart';
import '../../manager/homeBloc/home_bloc.dart';

class BuyerComment extends StatefulWidget {
  const BuyerComment({
    super.key,
  });

  @override
  State<BuyerComment> createState() => _BuyerCommentState();
}

class _BuyerCommentState extends ThemeState<BuyerComment> {
  @override
  void initState() {
    super.initState();
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

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: SvgPicture.asset(
                AppAssets.buyersCommentSvg,
              )),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  MyTextWidget(
                    '${LocaleKeys.buyers_comment.tr()}',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 11),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  SvgPicture.asset(
                    AppAssets.registerInfoSvg,
                    height: 10,
                    width: 10,
                    color: Color(0xffC4C2C2),
                  ),
                ],
              )),
          SizedBox(
              height: 125,
              width: 1.sw,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                  width: 5,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _commentWidget();
                },
                itemCount: 3,
              )),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    color: Color(0xff068D06),
                    width: 12,
                  ),
                  MyTextWidget(
                    ' 215 ',
                    style: context.textTheme.titleLarge?.br
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  MyTextWidget(
                    '${LocaleKeys.buyer.tr()}',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  MyTextWidget(
                    ' ${LocaleKeys.recommend_it.tr()}',
                    style: context.textTheme.titleLarge?.br
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  Spacer(),
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    color: Color(0xffFF6200),
                    width: 12,
                  ),
                  MyTextWidget(
                    ' 15 ',
                    style: context.textTheme.titleLarge?.br
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  MyTextWidget(
                    '${LocaleKeys.buyer.tr()}',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  MyTextWidget(
                    ' ${LocaleKeys.dont_recommend_it.tr()}',
                    style: context.textTheme.titleLarge?.br
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  )
                ],
              )),
          Stack(children: [
            Container(
              margin: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xffFF6200),
              ),
            ),
            Container(
              width: (1.sw - 36) * (215 / (215 + 15)),
              margin: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xff068D06),
              ),
            )
          ])
        ],
      ),
    );
  }

  Widget _commentWidget() {
    return Container(
      width: 388.w,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            width: 1.sw,
            child: Row(
              children: [
                MyCachedNetworkImage(
                    imageUrl:
                        "https://res.cloudinary.com/dtcmozf4d/image/upload/v1/boutiques/boutiques/2025-08-26-68ae378e796d0.png",
                    width: 20,
                    imageFit: BoxFit.cover,
                    height: 20),
                SizedBox(width: 10),
                MyTextWidget(
                  'Yxxx Oxxxx',
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                ),
                Spacer(),
                MyTextWidget(
                  '18 feb',
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: Color(0xff8D8D8D), fontSize: 9),
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          MyTextWidget(
            'Medium | Bule',
            style: context.textTheme.titleLarge?.mr
                .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
          ),
          SizedBox(height: 10),
          MyTextWidget(
            'Amazing Product I Buy It And I Saw It Is Good Quality Regarding Price Amazing Product I Buy It And I Saw It Is Good Quality Regardin',
            maxLines: 10,
            style: context.textTheme.titleLarge?.rr
                .copyWith(color: Color(0xff1D1D1D), fontSize: 11),
          ),
          Spacer(),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.favoriteActiveSvg,
                    width: 12,
                  ),
                  MyTextWidget(
                    '  110k',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  Spacer(),
                  StarRatingProductWidget(
                    itemHeight: 13,
                    itemSize: 14,
                    itemWidth: 14,
                    widgetHeight: 14,
                    widgetWidth: 71,
                    svgWidth: 12,
                    onRatingChanged: (p0) {},
                    starColor: Color(0xff1D1D1D),
                    initialRating: 3,
                  ),
                  MyTextWidget(
                    ' ${LocaleKeys.good_quality.tr()}  ${LocaleKeys.true_size.tr()}  ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    color: Color(0xff068D06),
                    width: 12,
                  ),
                  MyTextWidget(
                    '${LocaleKeys.recommend_it.tr()}',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
