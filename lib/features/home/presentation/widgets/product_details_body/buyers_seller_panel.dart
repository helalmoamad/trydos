import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../app/my_text_widget.dart';

class BuyerSellerPanel extends StatelessWidget {
  const BuyerSellerPanel({
    super.key,
    required this.panelController,
    required this.currentFilterForCommend,
    required this.isVerified,
    required this.productFirstId,
    required this.productSlug,
  });

  final PanelController panelController;
  final ValueNotifier<bool>? isVerified;
  final ValueNotifier<String> currentFilterForCommend;
  final String productFirstId;
  final String productSlug;
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    String productId = productFirstId;
    List<String> filter = [];
    ScrollController? _currentScrollController;

    void _handleAttachScrollController(ScrollController controller) {
      if (_currentScrollController != controller) {
        _currentScrollController?.removeListener(() {
          if (_currentScrollController!.offset >=
              (_currentScrollController!.position.maxScrollExtent * 0.6)) {
            GetIt.I<HomeBloc>().add(
              GetFqaCommentsEvent(
                productId: productId,
                currentFilter: currentFilterForCommend.value,
                getWithPagination: true,
              ),
            );
          }
        });
        _currentScrollController = controller;
        _currentScrollController?.addListener(() {
          if (_currentScrollController!.offset >=
              (_currentScrollController!.position.maxScrollExtent * 0.6)) {
            GetIt.I<HomeBloc>().add(
              GetFqaCommentsEvent(
                productId: productId,
                currentFilter: currentFilterForCommend.value,
                getWithPagination: true,
              ),
            );
          }
        });
      }
    }

    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 70.h,
      backdropEnabled: true,
      onPanelClosed: () {
        currentFilterForCommend.value = "all";
      },
      panelBuilder: (scrollController) {
        _handleAttachScrollController(scrollController);
        return ValueListenableBuilder<String>(
          valueListenable: currentFilterForCommend,
          builder: (context, _currentFilterForCommend, _) {
            return BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.createCommentRatingStatus !=
                      current.createCommentRatingStatus ||
                  previous
                          .getFqaCommentsPaginationModel?[_currentFilterForCommend]
                          ?.paginationStatus !=
                      current
                          .getFqaCommentsPaginationModel?[_currentFilterForCommend]
                          ?.paginationStatus ||
                  previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                      current
                          .getProductDetailWithoutSimilarRelatedProductsStatus ||
                  previous.deleteOrderCommentRatingStatus !=
                      current.deleteOrderCommentRatingStatus ||
                  previous.updateOrderCommentRatingStatus !=
                      current.updateOrderCommentRatingStatus ||
                  previous.getFullProductDetailsStatus !=
                      current.getFullProductDetailsStatus ||
                  previous.updateLikeCommentRatingStatus !=
                      current.updateLikeCommentRatingStatus ||
                  previous.translateCommentStatus !=
                      current.translateCommentStatus,
              builder: (context, state) {
                if (state.getFullProductDetailsStatus ==
                    GetFullProductDetailsStatus.success) {
                  productId == ""
                      ? (productId = state
                            .productContentForStatusOfOpeningProductDetailsDirectly!
                            .productId
                            .toString())
                      : (productId = productId);
                }

                filter =
                    state.cachedProductWithoutRelatedProductsModel[productId] ==
                        null
                    ? []
                    : state
                              .cachedProductWithoutRelatedProductsModel[productId]
                              ?.product
                              ?.fqaQuestions
                              ?.filtersKey ??
                          [];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 1.sh - 70.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: const Color(0xffFEFEFE),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: (1.sw / 2) - 40.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: const Color(0xffC4C2C2),
                        ),
                        height: 2.h,
                        width: 40.w,
                      ),
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: SvgPicture.asset(
                          AppAssets.faqSvg,
                          // ignore: deprecated_member_use
                          color: const Color(0xff1D1D1D),
                          height: 30.h,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: MyTextWidget(
                          '${LocaleKeys.faq_buyer_seller.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          children: [
                            MyTextWidget(
                              LocaleKeys.all_questions_below_from.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                            MyTextWidget(
                              ' trydos ',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                            MyTextWidget(
                              LocaleKeys.visitors_not_necessarily_from.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: MyTextWidget(
                          LocaleKeys
                              .customers_purchased_before_pre_purchase_questions
                              .tr(),
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 10.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffD3D3D3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: 0.5.h,
                        width: 1.sw,
                      ),
                      SizedBox(
                        height: 32.h,
                        width: 1.sw,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              if (_currentFilterForCommend == filter[index]) {
                                currentFilterForCommend.value = "all";
                                return;
                              }
                              currentFilterForCommend.value = filter[index];
                              GetIt.I<HomeBloc>().add(
                                GetFqaCommentsEvent(
                                  productId: productId,
                                  currentFilter: currentFilterForCommend.value,
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: LanguageService.languageCode == "ar"
                                    ? 5.w
                                    : 0,
                                right: LanguageService.languageCode != "ar"
                                    ? 5.w
                                    : 0,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 7.w),
                              alignment: Alignment.center,
                              height: 32.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _currentFilterForCommend == filter[index]
                                      ? Colors.blueAccent
                                      : const Color(0xffF8F8F8),
                                ),
                                color: const Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: MyTextWidget(
                                filter[index],
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      fontSize: 11.sp,
                                    ),
                              ),
                            ),
                          ),
                          itemCount: filter.length,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          itemBuilder: (context, index) {
                            if (state
                                    .getFqaCommentsPaginationModel?[_currentFilterForCommend] ==
                                null) {
                              return TrydosLoader(size: 16.h);
                            }
                            if (state
                                    .getFqaCommentsPaginationModel![_currentFilterForCommend]!
                                    .items
                                    .isEmpty &&
                                state
                                        .getFqaCommentsPaginationModel![_currentFilterForCommend]!
                                        .paginationStatus ==
                                    PaginationStatus.success) {
                              return Center(
                                child: Text(
                                  LocaleKeys.no_commends_found.tr(),
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        fontSize: 11.sp,
                                      ),
                                ),
                              );
                            }
                            return (index ==
                                    (state
                                            .getFqaCommentsPaginationModel?[_currentFilterForCommend]
                                            ?.items
                                            .length ??
                                        0))
                                ? SizedBox(
                                    width: 30.w,
                                    height: 50.h,
                                    child:
                                        state
                                                .getFqaCommentsPaginationModel?[_currentFilterForCommend]
                                                ?.paginationStatus ==
                                            PaginationStatus.loading
                                        ? TrydosLoader(size: 20.h)
                                        : const SizedBox.shrink(),
                                  )
                                : _commentWidget(
                                    context,
                                    state
                                        .getFqaCommentsPaginationModel![_currentFilterForCommend]!
                                        .items[index],
                                    index,
                                    state,
                                    productSlug,
                                  );
                          },
                          itemCount:
                              (state
                                      .getFqaCommentsPaginationModel?[_currentFilterForCommend]
                                      ?.items
                                      .length ??
                                  0) +
                              1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _commentWidget(
    BuildContext context,
    FqaComment fqaComment,
    int index,
    HomeState state,
    String productSlug,
  ) {
    return Container(
      width: 388.w,
      height: 220.h,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._SingelComments(
            answard: false,
            context: context,
            fqaComment: fqaComment,
            index: index,
            state: state,
            productSlug: productSlug,
          ),
          Container(
            height: 0.5.h,
            margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
            color: const Color(0xffD3D3D3),
          ),
          ..._SingelComments(
            answard: true,
            context: context,
            fqaComment: fqaComment,
            index: index,
            state: state,
            productSlug: productSlug,
          ),
        ],
      ),
    );
  }

  List<Widget> _SingelComments({
    required bool answard,
    required BuildContext context,
    required int index,
    required HomeState state,
    required FqaComment fqaComment,
    required String productSlug,
  }) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 5.h,
                    margin: EdgeInsets.only(bottom: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    LocaleKeys.edit_comment_title.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
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
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.edit_comment_hint.tr(),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    minLines: 3,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: isNotEmptyNotifier,
                      builder: (context, isNotEmpty, _) {
                        if (!isNotEmpty) return const SizedBox.shrink();
                        return CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              BlocProvider.of<HomeBloc>(context).add(
                                UpdateCommentRatingEvent(
                                  commentId: fqaComment.id,
                                  currentFilter: currentFilterForCommend.value,
                                  productId: fqaComment.productId,
                                  slug: productSlug,
                                  ownerId: state
                                      .cachedProductWithoutRelatedProductsModel[fqaComment
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.ownerId,
                                  ownerType: state
                                      .cachedProductWithoutRelatedProductsModel[fqaComment
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.ownerType,
                                  tapCommentIndex: index,
                                  variant: fqaComment.variant,
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

    if (answard && (!(fqaComment.hasReply ?? false))) {
      return [
        SvgPicture.asset(AppAssets.sandClockSvg, height: 16),
        MyTextWidget(
          " ${LocaleKeys.waiting_for_supplier_response.tr()}...",
          maxLines: 10,
          style: context.textTheme.titleLarge?.rq.copyWith(
            color: const Color(0xff1D1D1D),
            fontSize: 11.sp,
          ),
        ),
        const Spacer(),
      ];
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
      final format = DateFormat(
        'd MMM',
        locale,
      ); // locale مثال "en", "ar", "fr", "tr" ...
      return format.format(date);
    }

    String getTimeAgo(DateTime date, String locale) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return locale == 'ar'
            ? '${difference.inDays} يوم'
            : '${difference.inDays} day${difference.inDays > 1 ? "s" : ""}';
      } else if (difference.inHours > 0) {
        return locale == 'ar'
            ? '${difference.inHours} ساعة'
            : '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""}';
      } else {
        return locale == 'ar'
            ? '${difference.inMinutes} دقيقة'
            : '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""}';
      }
    }

    return [
      SizedBox(
        height: 20.h,
        width: 1.sw,
        child: Row(
          children: [
            answard
                ? const SizedBox.shrink()
                : MyCachedNetworkImage(
                    imageUrl:
                        (fqaComment.customer?.image ?? "").contains(
                          "cloudinary",
                        )
                        ? fqaComment.customer?.image ?? ""
                        : '${dotenv.env['Images_Url']}${fqaComment.customer?.image}',
                    width: 20.w,
                    imageFit: BoxFit.cover,
                    height: 20.h,
                  ),
            SizedBox(width: 10.w),
            Row(
              children: [
                MyTextWidget(
                  answard ? "A " : "Q ",
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
                  ),
                ),
                MyTextWidget(
                  answard
                      ? "${extractInitialsAndAppendXXX(state.cachedProductWithoutRelatedProductsModel[fqaComment.productId.toString()]?.product?.seller?.fName ?? "admin")}"
                      : "${extractInitialsAndAppendXXX(fqaComment.customer?.name ?? "")}",
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
            const Spacer(),
            MyTextWidget(
              answard
                  ? formatDateByLocale(
                      fqaComment.replyCreatedAt!,
                      GetIt.I<PrefsRepository>().language ?? "en",
                    )
                  : formatDateByLocale(
                      fqaComment.createdAt!,
                      GetIt.I<PrefsRepository>().language ?? "en",
                    ),
              style: context.textTheme.titleLarge?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
      answard
          ? MyTextWidget(
              "${LocaleKeys.dear.tr()} ${extractInitialsAndAppendXXX(fqaComment.customer?.name ?? "")}",
              style: context.textTheme.titleLarge?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                fontSize: 9.sp,
              ),
            )
          : MyTextWidget(
              fqaComment.variant ?? "",
              style: context.textTheme.titleLarge?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                fontSize: 9.sp,
              ),
            ),
      SizedBox(height: 10.h),
      MyTextWidget(
        answard
            ? ((fqaComment.isTran ?? false)
                  ? (fqaComment.sellerReplyTran ?? "")
                  : fqaComment.sellerReply ?? "")
            : (fqaComment.isTran ?? false)
            ? (fqaComment.commentTran ?? "")
            : fqaComment.comment ?? "",
        maxLines: 10,
        style: context.textTheme.titleLarge?.rq.copyWith(
          color: const Color(0xff1D1D1D),
          fontSize: 11.sp,
        ),
      ),
      const Spacer(),
      Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Row(
          children: [
            answard
                ? (state.updateLikeCommentRatingStatus ==
                              UpdateLikeCommentRatingStatus.loading &&
                          state.tapCommentIndex == index &&
                          (state.likeForReplayComment ?? false))
                      ? TrydosLoader(size: 15.h)
                      : GestureDetector(
                          onTap: () {
                            if (!(GetIt.I<PrefsRepository>().isVerifiedPhone ??
                                false)) {
                              showMessage(
                                LocaleKeys.must_login_to_edit_comment.tr(),
                              );
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
                              UpdateLikeCommentEvent(
                                commentId: fqaComment.id,
                                fromReplayComments: true,
                                toAddLike: !(fqaComment.replyIsLiked ?? false),
                                productId: fqaComment.productId,
                                tapCommentIndex: index,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 30.w,
                            height: 18.h,
                            child: SvgPicture.asset(
                              (fqaComment.replyIsLiked ?? false)
                                  ? AppAssets.favoriteActiveSvg
                                  : AppAssets.favoriteSvg,
                              height: 16.h,
                              width: 12.w,
                            ),
                          ),
                        )
                : (state.updateLikeCommentRatingStatus ==
                          UpdateLikeCommentRatingStatus.loading &&
                      state.tapCommentIndex == index &&
                      (!(state.likeForReplayComment ?? false)))
                ? TrydosLoader(size: 16.h)
                : GestureDetector(
                    onTap: () {
                      if (!(GetIt.I<PrefsRepository>().isVerifiedPhone ??
                          false)) {
                        showMessage(LocaleKeys.must_login_to_edit_comment.tr());
                        Future.delayed(const Duration(seconds: 1), () {
                          isVerified?.value = false;
                          if ((GetIt.I<PrefsRepository>()
                                  .isVerifiedPhonePeforeExpiredToken ??
                              false)) {
                            GetIt.I<AuthBloc>().add(
                              SendOtpEvent(
                                phone:
                                    GetIt.I<PrefsRepository>().myPhoneNumber!,
                                isViaWhatsApp: 1,
                              ),
                            );
                          }
                        });
                        return;
                      }
                      BlocProvider.of<HomeBloc>(context).add(
                        UpdateLikeCommentEvent(
                          commentId: fqaComment.id,
                          toAddLike: !(fqaComment.isLiked ?? false),
                          productId: fqaComment.productId,
                          tapCommentIndex: index,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 30.w,
                      height: 18.h,
                      child: SvgPicture.asset(
                        (fqaComment.isLiked ?? false)
                            ? AppAssets.favoriteActiveSvg
                            : AppAssets.favoriteSvg,
                        height: 16.h,
                        width: 12.w,
                      ),
                    ),
                  ),
            (answard
                        ? (fqaComment.replyTotalLikes ?? 0)
                        : (fqaComment.totalLikes ?? 0)) ==
                    0
                ? const SizedBox.shrink()
                : MyTextWidget(
                    '  ${answard ? (fqaComment.replyTotalLikes ?? 0) : (fqaComment.totalLikes ?? 0)}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 9.sp,
                    ),
                  ),

            answard
                ? const SizedBox.shrink()
                : SizedBox(
                    width: 80.w,
                    height: 25.h,
                    child:
                        ((state.deleteOrderCommentRatingStatus ==
                                    DeleteOrderCommentRatingStatus.loading ||
                                state.updateOrderCommentRatingStatus ==
                                    UpdateOrderCommentRatingStatus.loading ||
                                state.translateCommentStatus ==
                                    TranslateCommentStatus.loading) &&
                            state.tapCommentIndex == index)
                        ? TrydosLoader(size: 15.h)
                        : SizedBox(
                            width: 32.w,
                            height: 35.h,
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(top: 8.h),
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2FFF1),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: const Color(0xFF402CDD),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      // ignore: deprecated_member_use
                                                      .withOpacity(0.1),
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
                                                    color: const Color(
                                                      0xFF1A1A1A,
                                                    ),
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
                                                    color: const Color(
                                                      0xFF666666,
                                                    ),
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
                                                          LocaleKeys.cancel
                                                              .tr(),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
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
                                                                  12.r,
                                                                ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 10.h,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          LocaleKeys
                                                              .confirm_delete
                                                              .tr(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.sp,
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
                                      Future.delayed(
                                        const Duration(seconds: 1),
                                        () {
                                          isVerified?.value = false;
                                          if ((GetIt.I<PrefsRepository>()
                                                  .isVerifiedPhonePeforeExpiredToken ??
                                              false)) {
                                            GetIt.I<AuthBloc>().add(
                                              SendOtpEvent(
                                                phone:
                                                    GetIt.I<PrefsRepository>()
                                                        .myPhoneNumber!,
                                                isViaWhatsApp: 1,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                      return;
                                    }
                                    BlocProvider.of<HomeBloc>(context).add(
                                      DeleteCommentRatingEvent(
                                        commentId: fqaComment.id,
                                        productId: fqaComment.productId,
                                        currentFilter:
                                            currentFilterForCommend.value,
                                        tapCommentIndex: index,
                                      ),
                                    );
                                  }
                                } else if (value == 'edit') {
                                  if (!(GetIt.I<PrefsRepository>()
                                          .isVerifiedPhone ??
                                      false)) {
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
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
                                      },
                                    );
                                    return;
                                  }
                                  _showEditBottomSheet(
                                    context,
                                    fqaComment.comment ?? "",
                                  );
                                } else if (value == 'translate') {
                                  if (!(GetIt.I<PrefsRepository>()
                                          .isVerifiedPhone ??
                                      false)) {
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
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
                                      },
                                    );
                                    return;
                                  }
                                  TranslateCommentEvent(
                                    commentId: fqaComment.id,
                                    showOriginal: (fqaComment.isTran ?? false),
                                    currentFilter:
                                        currentFilterForCommend.value,
                                    tapCommentIndex: index,
                                    fromSellerComments:
                                        fqaComment.hasReply ?? false,
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

                                          height: 20.h,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          (fqaComment.isTran ?? false)
                                              ? LocaleKeys.show_original_version
                                                    .tr()
                                              : LocaleKeys.translate.tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (!(fqaComment.customer?.id !=
                                        GetIt.I<PrefsRepository>().myMarketId ||
                                    (answard))) {
                                  menu.add(
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.editSvg,
                                            // ignore: deprecated_member_use
                                            color: Colors.green,
                                            height: 20.h,
                                          ),
                                          SizedBox(width: 6.w),
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
                                            height: 20.h,
                                          ),
                                          SizedBox(width: 6.w),
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
                  ),

            const Spacer(),
            !answard
                ? const SizedBox.shrink()
                : MyTextWidget(
                    '${getTimeAgo(fqaComment.replyCreatedAt!, GetIt.I<PrefsRepository>().language ?? "en")} ${LocaleKeys.answered.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff8D8D8D),
                      fontSize: 9.sp,
                    ),
                  ),
          ],
        ),
      ),
    ];
  }
}
