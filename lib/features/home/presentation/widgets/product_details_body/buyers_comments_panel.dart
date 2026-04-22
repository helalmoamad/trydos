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
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../common/constant/design/assets_provider.dart';

import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class BuyersCommentsPanel extends StatelessWidget {
  const BuyersCommentsPanel({
    super.key,
    required this.panelController,
    required this.currentFilterForCommend,
    required this.productFirstId,
    required this.isVerified,
    required this.productSlug,
  });
  final ValueNotifier<String> currentFilterForCommend;
  final PanelController panelController;
  final String productSlug;
  final ValueNotifier<bool>? isVerified;
  final String productFirstId;
  @override
  Widget build(BuildContext context) {
    String productId = productFirstId;
    ScrollController? _currentScrollController;

    void _handleAttachScrollController(ScrollController controller) {
      if (_currentScrollController != controller) {
        _currentScrollController?.removeListener(() {
          if (_currentScrollController!.offset >=
              (_currentScrollController!.position.maxScrollExtent * 0.6)) {
            GetIt.I<HomeBloc>().add(
              GetBuyersCommentsEvent(
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
              GetBuyersCommentsEvent(
                productId: productId,
                currentFilter: currentFilterForCommend.value,
                getWithPagination: true,
              ),
            );
          }
        });
      }
    }

    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    List<String> filter = [];
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 70.h,
      onPanelClosed: () {
        currentFilterForCommend.value = "all";
      },
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        _handleAttachScrollController(scrollController);
        return ValueListenableBuilder<String>(
          valueListenable: currentFilterForCommend,
          builder: (context, _currentFilterForCommend, _) {
            return BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous
                          .getBuyersCommentsPaginationModel?[_currentFilterForCommend]
                          ?.paginationStatus !=
                      current
                          .getBuyersCommentsPaginationModel?[_currentFilterForCommend]
                          ?.paginationStatus ||
                  previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                      current
                          .getProductDetailWithoutSimilarRelatedProductsStatus ||
                  previous.getFullProductDetailsStatus !=
                      current.getFullProductDetailsStatus ||
                  previous.deleteOrderCommentRatingStatus !=
                      current.deleteOrderCommentRatingStatus ||
                  previous.updateOrderCommentRatingStatus !=
                      current.updateOrderCommentRatingStatus ||
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
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10.h),
                        child: SvgPicture.asset(
                          AppAssets.buyersCommentSvg,
                          height: 30.h,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w),
                        child: MyTextWidget(
                          '${LocaleKeys.buyers_comment.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: MyTextWidget(
                          LocaleKeys
                              .all_comments_are_genuine_from_customers_who_purchased_and_actually
                              .tr(),
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w),
                        child: Row(
                          children: [
                            MyTextWidget(
                              '${LocaleKeys.received_the_product_through.tr()} ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                            MyTextWidget(
                              'trydos  ',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 10.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffD3D3D3),
                          borderRadius: BorderRadius.circular(2.r),
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
                                GetBuyersCommentsEvent(
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
                                color: const Color(0xffF8F8F8),
                                border: Border.all(
                                  color:
                                      _currentFilterForCommend == filter[index]
                                      ? Colors.blueAccent
                                      : const Color(0xffF8F8F8),
                                ),
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
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          itemBuilder: (context, index) {
                            if (state
                                    .getBuyersCommentsPaginationModel?[_currentFilterForCommend] ==
                                null) {
                              return TrydosLoader(size: 16.h);
                            }
                            if (state
                                    .getBuyersCommentsPaginationModel![_currentFilterForCommend]!
                                    .items
                                    .isEmpty &&
                                state
                                        .getBuyersCommentsPaginationModel![_currentFilterForCommend]!
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
                                            .getBuyersCommentsPaginationModel?[_currentFilterForCommend]
                                            ?.items
                                            .length ??
                                        0))
                                ? SizedBox(
                                    width: 30.w,
                                    height: 50.h,
                                    child:
                                        state
                                                .getBuyersCommentsPaginationModel?[_currentFilterForCommend]
                                                ?.paginationStatus ==
                                            PaginationStatus.loading
                                        ? TrydosLoader(size: 20.h)
                                        : const SizedBox.shrink(),
                                  )
                                : _commentWidget(
                                    context,
                                    productSlug,
                                    state
                                        .getBuyersCommentsPaginationModel![_currentFilterForCommend]!
                                        .items[index],
                                    state,
                                    (index + 1000000),
                                  );
                          },
                          itemCount:
                              (state
                                      .getBuyersCommentsPaginationModel?[_currentFilterForCommend]
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
    String productSlug,
    BuyersComment buyersComment,
    HomeState state,
    int index,
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
                                  commentId: buyersComment.id,
                                  slug: productSlug,
                                  fromBuyerComments: true,
                                  currentFilter: currentFilterForCommend.value,
                                  ownerId: state
                                      .cachedProductWithoutRelatedProductsModel[buyersComment
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.ownerId,
                                  ownerType: state
                                      .cachedProductWithoutRelatedProductsModel[buyersComment
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.ownerType,
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
      final format = DateFormat(
        'd MMM',
        locale,
      ); // locale مثال "en", "ar", "fr", "tr" ...
      return format.format(date);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),

      height: 125.h,
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
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
                  width: 20.w,
                  imageFit: BoxFit.cover,
                  height: 20.h,
                ),
                SizedBox(width: 10.w),
                MyTextWidget(
                  extractInitialsAndAppendXXX(
                    buyersComment.customer?.name ?? "",
                  ),
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
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
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          MyTextWidget(
            buyersComment.variant ?? "",
            style: context.textTheme.titleLarge?.mq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 9.sp,
            ),
          ),
          SizedBox(height: 10.h),
          MyTextWidget(
            (buyersComment.isTran ?? false)
                ? (buyersComment.commentTran ?? "")
                : buyersComment.comment ?? "",
            maxLines: 10,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11.sp,
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 5.w, right: 5.w),
            child: Row(
              children: [
                state.updateLikeCommentRatingStatus ==
                            UpdateLikeCommentRatingStatus.loading &&
                        state.tapCommentIndex == index
                    ? TrydosLoader(size: 16.h)
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
                              commentId: buyersComment.id,
                              toAddLike: !(buyersComment.isLiked ?? false),
                              productId: buyersComment.productId,
                              tapCommentIndex: index,
                              fromBuyerComments: true,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 25.w,
                          height: 18.h,
                          child: SvgPicture.asset(
                            (buyersComment.isLiked ?? false)
                                ? AppAssets.favoriteActiveSvg
                                : AppAssets.favoriteSvg,
                            height: 16.h,
                          ),
                        ),
                      ),
                (buyersComment.totalLikes ?? 0) == 0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        '  ${buyersComment.totalLikes ?? 0}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                SizedBox(
                  width: 40.w,
                  height: 30.h,
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
                          width: 40.w,
                          height: 30.h,
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
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
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
                                                        LocaleKeys.cancel.tr(),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
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
                                  BlocProvider.of<HomeBloc>(context).add(
                                    DeleteCommentRatingEvent(
                                      commentId: buyersComment.id,
                                      fromBuyerComments: true,
                                      currentFilter:
                                          currentFilterForCommend.value,
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
                                    fromBuyerComments: true,
                                    showOriginal:
                                        (buyersComment.isTran ?? false),
                                    currentFilter:
                                        currentFilterForCommend.value,
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

                                        height: 20.h,
                                      ),
                                      SizedBox(width: 6.w),
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
                MyTextWidget(
                  '${buyersComment.trueSize ?? false ? "${LocaleKeys.true_size.tr()} | " : ""}',
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
                  ),
                ),
                !(buyersComment.recommendation ?? false)
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(
                        AppAssets.recommendSvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xff068D06),
                        width: 12.w,
                      ),
                !(buyersComment.recommendation ?? false)
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        ' ${LocaleKeys.recommend_it.tr()} | ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                MyTextWidget(
                  ' ${(buyersComment.goodQualitycomment ?? false) ? LocaleKeys.good_quality.tr() : ""} ',
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
                  ),
                ),
                StarRatingProductWidget(
                  itemHeight: 13.h,
                  itemSize: 14.h,
                  itemWidth: 14.h,
                  widgetHeight: 14.h,
                  widgetWidth: 71.w,
                  svgWidth: 12.w,
                  onRatingChanged: (p0) {},
                  starColor: const Color(0xff1D1D1D),
                  initialRating: (buyersComment.starRating ?? 0).toDouble(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
