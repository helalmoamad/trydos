import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';

class OrderDetails2 extends StatelessWidget {
  OrderDetails2({super.key, required this.order});

  final OrderListModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffFFFFFF),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          resizeToAvoidBottomInset: true,
          appBar: TrydosAppBar(
            appBarParams: AppBarParams(
              backgroundColor: const Color(0xffFFFFFF),
              scrolledUnderElevation: 0,
              backIconColor: Colors.black,
              withShadow: false,
              action: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    SvgPicture.asset(
                      AppAssets.bagsSvg,
                      width: 23,
                    ),
                    ///////////////////////////
                    SizedBox(
                      width: 4,
                    ),
                    ///////////////////////////
                    Text(
                      LocaleKeys.order_details.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    ///////////////////////////
                    SizedBox(
                      width: 15,
                    ),
                    ///////////////////////////
                  ],
                ),
                Spacer(),
                ////////////
                SvgPicture.asset(
                  AppAssets.orderMenuSvg,
                  width: 20,
                ),
                ///////////////////////////
                SizedBox(
                  width: 12,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 11.h,
              ),
              ///////////////////
              buildFirstSection(context, order.details!.length.toString()),
              ///////////////////
              SizedBox(
                height: 10.h,
              ),
              ///////////////////
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 10,
                            width: 60,
                            color: Colors.black,
                          ),
                          ///////////////////
                          const SizedBox(
                            height: 5,
                          ),
                          ///////////////////
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: '${LocaleKeys.buying.tr()} '),
                                /////////////////////////
                                TextSpan(
                                  text: '${order.details?.length ?? 0}',
                                  style:
                                      context.textTheme.bodyMedium?.bq.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                                /////////////////////////
                                TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
                                /////////////////////////
                                TextSpan(
                                  text: '${order.orderAmount}',
                                  style:
                                      context.textTheme.bodyMedium?.bq.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                                /////////////////////////
                                TextSpan(text: ' currency'),
                                /////////////////////////
                              ],
                            ),
                          ),
                          ///////////////////
                          SizedBox(
                            height: 5.h,
                          ),
                          ///////////////////
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.orderAddressSvg,
                                      width: 20,
                                    ),
                                    ///////////////////
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ///////////////////
                                    Text(
                                      LocaleKeys.expected_delivery_date.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                    ),
                                    ///////////////////
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ///////////////////
                                    Text(
                                      'Monday 2.Jun | 3 Work Days',
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /////////////
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.orderBag2Svg,
                                            width: 20,
                                          ),
                                          ////////////////////
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          ///////////////////
                                          SvgPicture.asset(
                                            AppAssets.orderBag3Svg,
                                            width: 15,
                                          ),
                                          ////////////////////
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          ///////////////////
                                          SvgPicture.asset(
                                            AppAssets.orderBag3Svg,
                                            width: 15,
                                          ),
                                          ///////////////////////
                                        ],
                                      ),
                                      ///////////////////
                                      SizedBox(
                                        height: 5,
                                      ),
                                      ///////////////////
                                      Text(
                                        LocaleKeys.order_status.tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                          color: const Color(0xff8D8D8D),
                                          letterSpacing: 0.18,
                                          fontSize: 10,
                                          height: 1.3,
                                        ),
                                      ),
                                      ///////////////////
                                      SizedBox(
                                        height: 5,
                                      ),
                                      ///////////////////
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            order.orderStatus?.label ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                          ///////////////////
                                          SizedBox(
                                            width: 10,
                                          ),
                                          ///////////////////
                                          SvgPicture.asset(
                                            AppAssets.orderPreparingSvg,
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          ///////////////////
                          SizedBox(
                            height: 12,
                          ),
                          ///////////////////
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: const Color(0xffC4C2C2),
                          ),
                          ///////////////////
                          SizedBox(
                            height: 12,
                          ),
                          ///////////////////
                          ListView.separated(
                            itemCount: order.details?.length ?? 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                height: 170,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        color: Colors.white,
                                        child: MyCachedNetworkImage(
                                          imageUrl: order.details?[index]
                                                  .productDetails?.images?[0] ??
                                              '',
                                          imageFit: BoxFit.contain,
                                          width: 100,
                                          height: 150,
                                        ),
                                      ),
                                    ),
                                    ///////////////////
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    ///////////////////
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 8,
                                                  width: 50,
                                                  color: Colors.black,
                                                ),
                                                ///////////////////
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                ///////////////////
                                                Text(
                                                  order
                                                          .details?[index]
                                                          .productDetails
                                                          ?.name ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: context
                                                      .textTheme.bodyMedium?.rq
                                                      .copyWith(
                                                    color:
                                                        const Color(0xff505050),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                ///////////////////
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                ///////////////////
                                                Row(
                                                  children: [
                                                    RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                        style: context.textTheme
                                                            .bodyMedium?.rq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xff8D8D8D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 10,
                                                          height: 1.3,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${LocaleKeys.color.tr()} : ',
                                                          ),
                                                          ////////////////////////////
                                                          TextSpan(
                                                            text: order
                                                                        .details?[
                                                                            index]
                                                                        .variation ==
                                                                    null
                                                                ? ''
                                                                : order
                                                                        .details?[
                                                                            index]
                                                                        .variation
                                                                        ?.color ??
                                                                    '',
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.mq
                                                                .copyWith(
                                                              color: const Color(
                                                                  0xff505050),
                                                              letterSpacing:
                                                                  0.18,
                                                              fontSize: 10,
                                                              height: 1.3,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ///////////////////
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    ///////////////////
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rq
                                                              .copyWith(
                                                            color: const Color(
                                                                0xff8D8D8D),
                                                            letterSpacing: 0.18,
                                                            fontSize: 10,
                                                            height: 1.3,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${LocaleKeys.size.tr()} : ',
                                                            ),
                                                            ////////////////////////////
                                                            TextSpan(
                                                              text: order
                                                                          .details?[
                                                                              index]
                                                                          .variation ==
                                                                      null
                                                                  ? ''
                                                                  : order
                                                                          .details?[
                                                                              index]
                                                                          .variation
                                                                          ?.size ??
                                                                      '',
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.mq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff505050),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 10,
                                                                height: 1.3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ///////////////////
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                ///////////////////
                                                Row(
                                                  children: [
                                                    RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                        style: context.textTheme
                                                            .bodyMedium?.rq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xff8D8D8D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 10,
                                                          height: 1.3,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${LocaleKeys.composed_of.tr()}:',
                                                          ),
                                                          ////////////////////////////
                                                          TextSpan(
                                                            text: ' 1 Piece',
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.mq
                                                                .copyWith(
                                                              color: const Color(
                                                                  0xff505050),
                                                              letterSpacing:
                                                                  0.18,
                                                              fontSize: 10,
                                                              height: 1.3,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ///////////////////
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    ///////////////////
                                                    Flexible(
                                                      child: RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rq
                                                              .copyWith(
                                                            color: const Color(
                                                                0xff8D8D8D),
                                                            letterSpacing: 0.18,
                                                            fontSize: 10,
                                                            height: 1.3,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${LocaleKeys.item.tr()}: ',
                                                            ),
                                                            ////////////////////////////
                                                            TextSpan(
                                                              text: order
                                                                  .details
                                                                  ?.length
                                                                  .toString(),
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.mq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff505050),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 10,
                                                                height: 1.3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ///////////////////
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                ///////////////////
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rq
                                                              .copyWith(
                                                            color: const Color(
                                                                0xff8D8D8D),
                                                            letterSpacing: 0.18,
                                                            fontSize: 10,
                                                            height: 1.3,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${LocaleKeys.item_status.tr()}: ',
                                                            ),
                                                            ////////////////////////////
                                                            TextSpan(
                                                              text: order
                                                                      .orderStatus
                                                                      ?.label ??
                                                                  '',
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.mq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff505050),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 10,
                                                                height: 1.3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    ///////////////////
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    ///////////////////
                                                    SvgPicture.asset(
                                                      AppAssets
                                                          .orderPreparingSvg,
                                                      width: 15,
                                                    ),
                                                  ],
                                                ),
                                                ////////////////////
                                                const Spacer(),
                                                ////////////////////
                                                RichText(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  text: TextSpan(
                                                    style: context.textTheme
                                                        .bodyMedium?.rq
                                                        .copyWith(
                                                      color: const Color(
                                                          0xffC4C2C2),
                                                      letterSpacing: 0.18,
                                                      fontSize: 12,
                                                      height: 1.3,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${order.details?[index].price}',
                                                        style: context.textTheme
                                                            .bodyMedium?.rq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xffC4C2C2),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.3,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                      ////////////////////////////
                                                      TextSpan(
                                                        text:
                                                            ' ${order.details?[index].priceAfterDiscount}',
                                                        style: context.textTheme
                                                            .bodyMedium?.bq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xff1D1D1D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.3,
                                                        ),
                                                      ),
                                                      /////////////
                                                      TextSpan(
                                                        text: ' currency',
                                                        style: context.textTheme
                                                            .bodyMedium?.lq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xff1D1D1D),
                                                          letterSpacing: 0.18,
                                                          fontSize: 12,
                                                          height: 1.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ///////////////////
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 227, 227, 227),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$index',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme.bodyMedium?.mq
                                                      .copyWith(
                                                    color:
                                                        const Color(0xff8D8D8D),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                height: 1,
                                color: const Color(0xffC4C2C2),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFirstSection(BuildContext context, String itemsCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xffC4C2C2),
            )),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppAssets.bagsSvg,
              width: 20,
            ),
            ///////////////////
            SizedBox(
              height: 3,
            ),
            ///////////////////
            Text(
              LocaleKeys.order_details.tr(),
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 3,
            ),
            ///////////////////
            RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: itemsCount,
                    style: context.textTheme.bodyMedium?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  TextSpan(text: ' ${LocaleKeys.item.tr()}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
