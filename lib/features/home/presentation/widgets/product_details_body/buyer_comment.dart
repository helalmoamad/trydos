import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/show_message.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart'
    show
        HomeState,
        DeleteOrderCommentRatingStatus,
        UpdateOrderCommentRatingStatus,
        UpdateLikeCommentRatingStatus,
        TranslateCommentStatus;

import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../core/utils/theme_state.dart';

class BuyerComment extends StatefulWidget {
  final String productId;
  final String? ownerType;
  final PanelController panelBuyersComments;
  final String? ownerId;
  final String productSlug;
  final ValueNotifier<bool>? isVerified;
  const BuyerComment({
    super.key,
    required this.productId,
    required this.isVerified,
    required this.productSlug,
    required this.panelBuyersComments,
    required this.ownerType,
    required this.ownerId,
  });

  @override
  State<BuyerComment> createState() => _BuyerCommentState();
}

class _BuyerCommentState extends ThemeState<BuyerComment> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.6)) {
        GetIt.I<HomeBloc>().add(
          GetBuyersCommentsEvent(
            productId: widget.productId,
            getWithPagination: true,
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getBuyersCommentsPaginationModel?['all']?.paginationStatus !=
              current
                  .getBuyersCommentsPaginationModel?['all']
                  ?.paginationStatus ||
          previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
              current.getProductDetailWithoutSimilarRelatedProductsStatus ||
          previous.getFullProductDetailsStatus !=
              current.getFullProductDetailsStatus ||
          previous.deleteOrderCommentRatingStatus !=
              current.deleteOrderCommentRatingStatus ||
          previous.updateOrderCommentRatingStatus !=
              current.updateOrderCommentRatingStatus ||
          previous.updateLikeCommentRatingStatus !=
              current.updateLikeCommentRatingStatus ||
          previous.translateCommentStatus != current.translateCommentStatus,
      builder: (context, state) {
        print(
          "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD*******////${state.updateLikeCommentRatingStatus}",
        );
        if (state.getBuyersCommentsPaginationModel == null) {
          return const SizedBox.shrink();
        }
        if (state.getBuyersCommentsPaginationModel!['all']!.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (state.getBuyersCommentsPaginationModel?['all'] == null) {
                    return;
                  }
                  if (state
                      .getBuyersCommentsPaginationModel!['all']!
                      .items
                      .isEmpty) {
                    return;
                  }
                  LastPagesTracker.push("BuyersCommentsPanel Page");
                  widget.panelBuyersComments.open();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(AppAssets.buyersCommentSvg),
                ),
              ),
              InkWell(
                onTap: () {
                  if (state.getBuyersCommentsPaginationModel?['all'] == null) {
                    return;
                  }
                  if (state
                      .getBuyersCommentsPaginationModel!['all']!
                      .items
                      .isEmpty) {
                    return;
                  }
                  LastPagesTracker.push("BuyersCommentsPanel Page");
                  widget.panelBuyersComments.open();
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      MyTextWidget(
                        '${LocaleKeys.buyers_comment.tr()}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        AppAssets.registerInfoSvg,
                        height: 10,
                        width: 10,
                        // ignore: deprecated_member_use
                        color: const Color(0xffC4C2C2),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 125,
                width: 1.sw,
                child: ListView.separated(
                  controller: scrollController,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 5),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return (index ==
                            (state
                                    .getBuyersCommentsPaginationModel?['all']
                                    ?.items
                                    .length ??
                                0))
                        ? SizedBox(
                            width: 30,
                            height: 50,
                            child:
                                state
                                        .getBuyersCommentsPaginationModel?['all']
                                        ?.paginationStatus ==
                                    PaginationStatus.loading
                                ? TrydosLoader(size: 20)
                                : const SizedBox.shrink(),
                          )
                        : _commentWidget(
                            state
                                .getBuyersCommentsPaginationModel!['all']!
                                .items[index],
                            (index + 1000000),
                            widget.isVerified,
                            state,
                            widget.productSlug,
                          );
                  },
                  itemCount:
                      (state
                              .getBuyersCommentsPaginationModel?['all']
                              ?.items
                              .length ??
                          0) +
                      1,
                ),
              ),
              state
                          .cachedProductWithoutRelatedProductsModel[widget
                              .productId]
                          ?.product
                          ?.recommendationStats?[0]
                          .count ==
                      0
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.recommendSvg,
                            // ignore: deprecated_member_use
                            color: const Color(0xff068D06),
                            width: 12,
                          ),
                          MyTextWidget(
                            ' ${state.cachedProductWithoutRelatedProductsModel[widget.productId]?.product?.recommendationStats?[0].count} ',
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                          MyTextWidget(
                            '${LocaleKeys.buyer.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                          MyTextWidget(
                            ' ${LocaleKeys.recommend_it.tr()}',
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            AppAssets.recommendSvg,
                            // ignore: deprecated_member_use
                            color: const Color(0xffFF6200),
                            width: 12,
                          ),
                          MyTextWidget(
                            ' ${state.cachedProductWithoutRelatedProductsModel[widget.productId]?.product?.recommendationStats?[1].count} ',
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                          MyTextWidget(
                            '${LocaleKeys.buyer.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                          MyTextWidget(
                            ' ${LocaleKeys.dont_recommend_it.tr()}',
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
              state
                          .cachedProductWithoutRelatedProductsModel[widget
                              .productId]
                          ?.product
                          ?.recommendationStats?[0]
                          .count ==
                      0
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 10,
                            bottom: 10,
                          ),
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xffFF6200),
                          ),
                        ),
                        Container(
                          width:
                              (1.sw - 36) *
                              ((double.tryParse(
                                        state
                                                .cachedProductWithoutRelatedProductsModel[widget
                                                    .productId]
                                                ?.product
                                                ?.recommendationStats?[0]
                                                .percentage ??
                                            "0",
                                      ) ??
                                      0) /
                                  100),
                          margin: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 10,
                            bottom: 10,
                          ),
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xff068D06),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _commentWidget(
    BuyersComment buyersComment,
    int index,
    ValueNotifier<bool>? isVerified,
    HomeState state,
    String productSlug,
  ) {
    void _showEditBottomSheet(BuildContext context, String initialText) {
      final TextEditingController _controller = TextEditingController(
        text: initialText,
      );
      final ValueNotifier<bool> isNotEmptyNotifier = ValueNotifier(
        _controller.text.trim().isNotEmpty,
      );
      _controller.addListener(() {
        isNotEmptyNotifier.value = _controller.text.trim().isNotEmpty;
      });
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    LocaleKeys.edit_comment_title.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.edit_comment_hint.tr(),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),

                    minLines: 3,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: isNotEmptyNotifier,
                      builder: (context, isNotEmpty, _) {
                        if (!isNotEmpty) return const SizedBox.shrink();
                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              BlocProvider.of<HomeBloc>(context).add(
                                UpdateCommentRatingEvent(
                                  commentId: buyersComment.id,
                                  fromBuyerComments: true,
                                  ownerId: widget.ownerId,
                                  ownerType: widget.ownerType,
                                  slug: productSlug,
                                  productId: buyersComment.productId,
                                  tapCommentIndex: index,
                                  variant: buyersComment.variant,
                                  text: _controller.text,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    String extractInitialsAndAppendXXX(String text) {
      final words = text.trim().split(RegExp(r'\s+'));
      final result = words
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0]}xxx')
          .join(' ');
      return result;
    }

    String formatDateByLocale(DateTime isoDate, String locale) {
      final date = isoDate;
      // صيغة "day short_month" مثل "18 Feb" أو "20 Oct"
      final format = tran.DateFormat(
        'd MMM',
        locale,
      ); // locale مثال "en", "ar", "fr", "tr" ...
      return format.format(date);
    }

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
          SizedBox(
            height: 20,
            width: 1.sw,
            child: Row(
              children: [
                MyCachedNetworkImage(
                  imageUrl:
                      (buyersComment.customer?.image ?? "").contains(
                        "cloudinary",
                      )
                      ? buyersComment.customer?.image ?? ""
                      : '${dotenv.env['Images_Url']}${buyersComment.customer?.image}',
                  width: 20,
                  imageFit: BoxFit.cover,
                  height: 20,
                ),
                const SizedBox(width: 10),
                MyTextWidget(
                  extractInitialsAndAppendXXX(
                    buyersComment.customer?.name ?? "",
                  ),
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                MyTextWidget(
                  formatDateByLocale(
                    buyersComment.createdAt!,
                    GetIt.I<PrefsRepository>().language ?? "en",
                  ),
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MyTextWidget(
            buyersComment.variant ?? "",
            style: context.textTheme.titleLarge?.mq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 10),
          MyTextWidget(
            (buyersComment.isTran ?? false)
                ? (buyersComment.commentTran ?? "")
                : buyersComment.comment ?? "",
            maxLines: 10,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                state.updateLikeCommentRatingStatus ==
                            UpdateLikeCommentRatingStatus.loading &&
                        state.tapCommentIndex == index
                    ? TrydosLoader(size: 16)
                    : GestureDetector(
                        onTap: () {
                          if (!(GetIt.I<PrefsRepository>().isVerifiedPhone ??
                              false)) {
                            showMessage(
                              LocaleKeys.must_login_to_edit_comment.tr(),
                            );
                            Future.delayed(const Duration(seconds: 1), () {
                              widget.isVerified?.value = false;
                              if ((GetIt.I<PrefsRepository>()
                                      .isVerifiedPhonePeforeExpiredToken ??
                                  false)) {
                                GetIt.I<AuthBloc>().add(
                                  SendOtpEvent(
                                    phone: GetIt.I<PrefsRepository>()
                                        .myPhoneNumber!,
                                    isViaWhatsApp: 1,
                                  ),
                                );
                              }
                            });
                            return;
                          }
                          BlocProvider.of<HomeBloc>(context).add(
                            UpdateLikeCommentEvent(
                              commentId: buyersComment.id,
                              toAddLike: !(buyersComment.isLiked ?? false),
                              productId: buyersComment.productId,
                              tapCommentIndex: index,
                              fromBuyerComments: true,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 25,
                          height: 18,
                          child: SvgPicture.asset(
                            (buyersComment.isLiked ?? false)
                                ? AppAssets.favoriteActiveSvg
                                : AppAssets.favoriteSvg,
                            height: 16,
                          ),
                        ),
                      ),
                (buyersComment.totalLikes ?? 0) == 0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        '  ${buyersComment.totalLikes ?? 0}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 9,
                        ),
                      ),
                ((state.deleteOrderCommentRatingStatus ==
                                DeleteOrderCommentRatingStatus.loading ||
                            state.updateOrderCommentRatingStatus ==
                                UpdateOrderCommentRatingStatus.loading ||
                            state.translateCommentStatus ==
                                TranslateCommentStatus.loading) &&
                        state.tapCommentIndex == index)
                    ? TrydosLoader(size: 15)
                    : SizedBox(
                        width: 30,
                        height: 35,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black87,
                          ),
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (ctx) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 8.h),
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2FFF1),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF402CDD),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              // ignore: deprecated_member_use
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyTextWidget(
                                              LocaleKeys
                                                  .confirm_delete_comment_title
                                                  .tr(),
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            MyTextWidget(
                                              LocaleKeys
                                                  .confirm_delete_comment_message
                                                  .tr(),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF666666),
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(false),
                                                    child: Text(
                                                      LocaleKeys.cancel.tr(),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF402CDD,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      LocaleKeys.confirm_delete
                                                          .tr(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              if (confirmed == true) {
                                if (!(GetIt.I<PrefsRepository>()
                                        .isVerifiedPhone ??
                                    false)) {
                                  Future.delayed(const Duration(seconds: 1), () {
                                    isVerified?.value = false;
                                    if ((GetIt.I<PrefsRepository>()
                                            .isVerifiedPhonePeforeExpiredToken ??
                                        false)) {
                                      GetIt.I<AuthBloc>().add(
                                        SendOtpEvent(
                                          phone: GetIt.I<PrefsRepository>()
                                              .myPhoneNumber!,
                                          isViaWhatsApp: 1,
                                        ),
                                      );
                                    }
                                  });
                                  return;
                                }
                                BlocProvider.of<HomeBloc>(context).add(
                                  DeleteCommentRatingEvent(
                                    commentId: buyersComment.id,
                                    fromBuyerComments: true,
                                    productId: buyersComment.productId,
                                    tapCommentIndex: index,
                                  ),
                                );
                              }
                            } else if (value == 'edit') {
                              if (!(GetIt.I<PrefsRepository>()
                                      .isVerifiedPhone ??
                                  false)) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  isVerified?.value = false;
                                  if ((GetIt.I<PrefsRepository>()
                                          .isVerifiedPhonePeforeExpiredToken ??
                                      false)) {
                                    GetIt.I<AuthBloc>().add(
                                      SendOtpEvent(
                                        phone: GetIt.I<PrefsRepository>()
                                            .myPhoneNumber!,
                                        isViaWhatsApp: 1,
                                      ),
                                    );
                                  }
                                });
                                return;
                              }
                              _showEditBottomSheet(
                                context,
                                buyersComment.comment ?? "",
                              );
                            } else if (value == 'translate') {
                              if (!(GetIt.I<PrefsRepository>()
                                      .isVerifiedPhone ??
                                  false)) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  isVerified?.value = false;
                                  if ((GetIt.I<PrefsRepository>()
                                          .isVerifiedPhonePeforeExpiredToken ??
                                      false)) {
                                    GetIt.I<AuthBloc>().add(
                                      SendOtpEvent(
                                        phone: GetIt.I<PrefsRepository>()
                                            .myPhoneNumber!,
                                        isViaWhatsApp: 1,
                                      ),
                                    );
                                  }
                                });
                                return;
                              }
                              BlocProvider.of<HomeBloc>(context).add(
                                TranslateCommentEvent(
                                  commentId: buyersComment.id,
                                  showOriginal: (buyersComment.isTran ?? false),
                                  fromBuyerComments: true,
                                  tapCommentIndex: index,
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuEntry<String>> menu = [];
                            menu.add(
                              PopupMenuItem(
                                value: 'translate',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.languageSvg,

                                      height: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (buyersComment.isTran ?? false)
                                          ? LocaleKeys.show_original_version
                                                .tr()
                                          : LocaleKeys.translate.tr(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (buyersComment.customer?.id ==
                                GetIt.I<PrefsRepository>().myMarketId) {
                              menu.add(
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.editSvg,
                                        // ignore: deprecated_member_use
                                        color: Colors.green,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(LocaleKeys.edit.tr()),
                                    ],
                                  ),
                                ),
                              );
                              menu.add(
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.deletecartSvg,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(LocaleKeys.delete.tr()),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return menu;
                          },
                        ),
                      ),

                // إذا كان هناك عمليات جارية (لودر الحذف أو التعديل)
                const Spacer(),
                StarRatingProductWidget(
                  itemHeight: 13,
                  itemSize: 14,
                  itemWidth: 14,
                  isInteractive: false,
                  widgetHeight: 14,
                  widgetWidth: 71,
                  svgWidth: 12,
                  onRatingChanged: (p0) {},
                  starColor: const Color(0xff1D1D1D),
                  initialRating: (buyersComment.starRating ?? 0).toDouble(),
                ),
                MyTextWidget(
                  ' | ${(buyersComment.goodQualitycomment ?? false) ? LocaleKeys.good_quality.tr() : ""} ${(buyersComment.trueSize ?? false) ? "| ${LocaleKeys.true_size.tr()}" : ""} ',
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9,
                  ),
                ),
                !(buyersComment.recommendation ?? false)
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(
                        AppAssets.recommendSvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xff068D06),
                        width: 12,
                      ),
                !(buyersComment.recommendation ?? false)
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        ' ${LocaleKeys.recommend_it.tr()}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 9,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
