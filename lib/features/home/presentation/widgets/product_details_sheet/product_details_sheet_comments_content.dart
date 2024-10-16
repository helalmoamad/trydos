import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetCommentsContent extends StatelessWidget {
  final String productId;
  const ProductDetailsSheetCommentsContent(
      {super.key, this.scrollController, required this.productId});

  final ScrollController? scrollController;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCommentForProductStatus !=
          current.getCommentForProductStatus,
      builder: (context, state) {
        if ((state.getCommentForProductStatus ==
                    GetCommentForProductStatus.loading &&
                (state.getCommentForProductModel[productId]?.commentsForProduct
                            ?.commentsCount ??
                        0) <
                    1) ||
            state.getCommentForProductModel[productId] == null) {
          return cupertino.SizedBox.shrink();
        }
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
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: Color(0xff505050),
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ...List.generate(
                  state.getCommentForProductModel[productId]!
                          .commentsForProduct!.commentsCount ??
                      0,
                  (index) => Column(
                        children: [
                          CommentCard(
                            comment: state.getCommentForProductModel[productId]!
                                .commentsForProduct!.comments![index].comment!,
                            imageUrl: state
                                    .getCommentForProductModel[productId]!
                                    .commentsForProduct!
                                    .comments![index]
                                    .customer!
                                    .image ??
                                "",
                            names: state
                                    .getCommentForProductModel[productId]!
                                    .commentsForProduct!
                                    .comments![index]
                                    .customer!
                                    .name ??
                                "",
                            date: HelperFunctions.getDatesInFormat(state
                                .getCommentForProductModel[productId]!
                                .commentsForProduct!
                                .comments![index]
                                .createdAt!),
                          ),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      ))
            ],
          ),
        );
      },
    );
  }
}

class CommentCard extends StatelessWidget {
  final String imageUrl;
  final String date;
  final String names;
  final String comment;
  const CommentCard(
      {super.key,
      required this.imageUrl,
      required this.names,
      required this.comment,
      required this.date});

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
                      child: MyCachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 20,
                          imageFit: cupertino.BoxFit.cover,
                          height: 20)),
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
                      names,
                      style: context.textTheme.bodySmall?.rq
                          .copyWith(color: Color(0xff969696)),
                    ),
                    MyTextWidget(
                      date,
                      style: context.textTheme.titleSmall?.rq
                          .copyWith(color: Color(0xff969696)),
                    ),
                  ],
                ),
                Flexible(
                  child: MyTextWidget(
                    comment,
                    style: context.textTheme.bodySmall?.rq
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', names));
  }
}
