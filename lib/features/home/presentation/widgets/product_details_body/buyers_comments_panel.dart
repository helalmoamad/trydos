import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../common/constant/design/assets_provider.dart';

import '../../../../app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BuyersCommentsPanel extends StatelessWidget {
  const BuyersCommentsPanel({super.key, required this.panelController});

  final PanelController panelController;

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
    List<String> filter = [
      "Size",
      "Quality",
      "Color",
      "Shipping",
      "Complaint",
      "Recommendation"
    ];
    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 70,
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 1.sh - 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xffFEFEFE),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: (1.sw / 2) - 40, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Color(0xffC4C2C2)),
                  height: 2,
                  width: 40,
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: SvgPicture.asset(
                      AppAssets.buyersCommentSvg,
                      height: 30,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: MyTextWidget(
                      '${LocaleKeys.buyers_comment.tr()}',
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 13),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: MyTextWidget(
                      LocaleKeys
                          .all_comments_are_genuine_from_customers_who_purchased_and_actually
                          .tr(),
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 11),
                    )),
                Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        MyTextWidget(
                          '${LocaleKeys.received_the_product_through.tr()} ',
                          style: context.textTheme.titleLarge?.rr.copyWith(
                              color: const Color(0xff1D1D1D), fontSize: 11),
                        ),
                        MyTextWidget(
                          'trydos  ',
                          style: context.textTheme.titleLarge?.br.copyWith(
                              color: const Color(0xff1D1D1D), fontSize: 11),
                        ),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffD3D3D3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 0.5,
                  width: 1.sw,
                ),
                SizedBox(
                  height: 32,
                  width: 1.sw,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.only(
                          left: LanguageService.languageCode == "ar" ? 5 : 0,
                          right: LanguageService.languageCode != "ar" ? 5 : 0),
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      alignment: Alignment.center,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(8)),
                      child: MyTextWidget(
                        filter[index],
                        style: context.textTheme.titleLarge?.rr.copyWith(
                            color: const Color(0xff505050), fontSize: 11),
                      ),
                    ),
                    itemCount: 6,
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  itemBuilder: (context, index) => _commentWidget(context),
                  itemCount: 10,
                ))
              ],
            ),
          );
        });
  }

  Widget _commentWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: 388.w,
      height: 115,
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
              padding: EdgeInsets.only(left: 5, right: 5),
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
                  MyTextWidget(
                    '${LocaleKeys.true_size.tr()} | ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    color: Color(0xff068D06),
                    width: 12,
                  ),
                  MyTextWidget(
                    ' ${LocaleKeys.recommend_it.tr()} | ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
                  MyTextWidget(
                    '${LocaleKeys.good_quality.tr()} ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: Color(0xff1D1D1D), fontSize: 9),
                  ),
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
                ],
              )),
        ],
      ),
    );
  }
}
