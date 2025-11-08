import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
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
  const BuyerSellerPanel(
      {super.key,
      required this.panelController,
      required this.currentFilterForCommend,
      required this.productFirstId});

  final PanelController panelController;
  final ValueNotifier<String> currentFilterForCommend;
  final String productFirstId;
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    String productId = productFirstId;
    List<Map<String, String>> filter = [
      {LocaleKeys.size.tr(): "size"},
      {LocaleKeys.quality.tr(): "quality"},
      {LocaleKeys.color.tr(): "color"},
      //   {LocaleKeys.shipping.tr(): "shipping"},
      /////  {LocaleKeys.complaint.tr(): "complaint"},
      //  {LocaleKeys.recommendation.tr(): "recommend"},
    ];
    ScrollController? _currentScrollController;

    void _handleAttachScrollController(ScrollController controller) {
      if (_currentScrollController != controller) {
        _currentScrollController?.removeListener(() {
          if (_currentScrollController!.offset >=
              (_currentScrollController!.position.maxScrollExtent * 0.6)) {
            GetIt.I<HomeBloc>().add(GetFqaCommentsEvent(
                productId: productId,
                currentFilter: currentFilterForCommend.value,
                getWithPagination: true));
          }
        });
        _currentScrollController = controller;
        _currentScrollController?.addListener(
          () {
            if (_currentScrollController!.offset >=
                (_currentScrollController!.position.maxScrollExtent * 0.6)) {
              GetIt.I<HomeBloc>().add(GetFqaCommentsEvent(
                  productId: productId,
                  currentFilter: currentFilterForCommend.value,
                  getWithPagination: true));
            }
          },
        );
      }
    }

    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 70,
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
                                .getFqaCommentsPaginationModel?[
                                    _currentFilterForCommend]
                                ?.paginationStatus !=
                            current
                                .getFqaCommentsPaginationModel?[
                                    _currentFilterForCommend]
                                ?.paginationStatus ||
                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            current
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        previous.deleteOrderCommentRatingStatus !=
                            current.deleteOrderCommentRatingStatus ||
                        previous.updateOrderCommentRatingStatus !=
                            current.updateOrderCommentRatingStatus ||
                        previous.getFullProductDetailsStatus !=
                            current.getFullProductDetailsStatus,
                    builder: (context, state) {
                      productId == ""
                          ? (productId = state
                              .productContentForStatusOfOpeningProductDetailsDirectly!
                              .productId
                              .toString())
                          : productId = productId;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                  color: const Color(0xffC4C2C2)),
                              height: 2,
                              width: 40,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: SvgPicture.asset(
                                  AppAssets.faqSvg,
                                  // ignore: deprecated_member_use
                                  color: const Color(0xff1D1D1D),
                                  height: 30,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: MyTextWidget(
                                  '${LocaleKeys.faq_buyer_seller.tr()}',
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 13),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: Row(
                                  children: [
                                    MyTextWidget(
                                      LocaleKeys.all_questions_below_from.tr(),
                                      style: context.textTheme.titleLarge?.rr
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 11),
                                    ),
                                    MyTextWidget(
                                      ' trydos ',
                                      style: context.textTheme.titleLarge?.br
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 11),
                                    ),
                                    MyTextWidget(
                                      LocaleKeys.visitors_not_necessarily_from
                                          .tr(),
                                      style: context.textTheme.titleLarge?.rr
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 11),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              height: 2,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: MyTextWidget(
                                  LocaleKeys
                                      .customers_purchased_before_pre_purchase_questions
                                      .tr(),
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 11),
                                )),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xffD3D3D3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              height: 0.5,
                              width: 1.sw,
                            ),
                            SizedBox(
                              height: 32,
                              width: 1.sw,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                        onTap: () {
                                          if (_currentFilterForCommend ==
                                              filter[index].values.first) {
                                            currentFilterForCommend.value =
                                                "all";
                                            return;
                                          }
                                          currentFilterForCommend.value =
                                              filter[index].values.first;
                                          GetIt.I<HomeBloc>()
                                              .add(GetFqaCommentsEvent(
                                            productId: productId,
                                            currentFilter:
                                                currentFilterForCommend.value,
                                          ));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? 5
                                                  : 0,
                                              right: LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? 5
                                                  : 0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7),
                                          alignment: Alignment.center,
                                          height: 32,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      _currentFilterForCommend ==
                                                              filter[index]
                                                                  .values
                                                                  .first
                                                          ? Colors.blueAccent
                                                          : const Color(
                                                              0xffF8F8F8)),
                                              color: const Color(0xffF8F8F8),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: MyTextWidget(
                                            filter[index].keys.first,
                                            style: context
                                                .textTheme.titleLarge?.rr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff505050),
                                                    fontSize: 11),
                                          ),
                                        )),
                                itemCount: filter.length,
                              ),
                            ),
                            Expanded(
                                child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemBuilder: (context, index) {
                                if (state.getFqaCommentsPaginationModel?[
                                        _currentFilterForCommend] ==
                                    null) {
                                  return TrydosLoader(
                                    size: 16,
                                  );
                                }
                                if (state
                                        .getFqaCommentsPaginationModel![
                                            _currentFilterForCommend]!
                                        .items
                                        .isEmpty &&
                                    state
                                            .getFqaCommentsPaginationModel![
                                                _currentFilterForCommend]!
                                            .paginationStatus ==
                                        PaginationStatus.success) {
                                  return Center(
                                    child: Text(
                                        LocaleKeys.no_commends_found.tr(),
                                        style: context.textTheme.titleLarge?.rr
                                            .copyWith(
                                                color: const Color(0xff1D1D1D),
                                                fontSize: 11)),
                                  );
                                }
                                return (index ==
                                        (state
                                                .getFqaCommentsPaginationModel?[
                                                    _currentFilterForCommend]
                                                ?.items
                                                .length ??
                                            0))
                                    ? SizedBox(
                                        width: 30,
                                        height: 50,
                                        child: state
                                                    .getFqaCommentsPaginationModel?[
                                                        _currentFilterForCommend]
                                                    ?.paginationStatus ==
                                                PaginationStatus.loading
                                            ? TrydosLoader(
                                                size: 20,
                                              )
                                            : const SizedBox.shrink())
                                    : _commentWidget(
                                        context,
                                        state
                                            .getFqaCommentsPaginationModel![
                                                _currentFilterForCommend]!
                                            .items[index],
                                        index,
                                        state);
                              },
                              itemCount: (state
                                          .getFqaCommentsPaginationModel?[
                                              _currentFilterForCommend]
                                          ?.items
                                          .length ??
                                      0) +
                                  1,
                            ))
                          ],
                        ),
                      );
                    });
              });
        });
  }

  Widget _commentWidget(
      BuildContext context, FqaComment fqaComment, int index, HomeState state) {
    return Container(
        width: 388.w,
        height: 220,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._SingelComments(
                answard: false,
                context: context,
                fqaComment: fqaComment,
                index: index,
                state: state),
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(bottom: 10, top: 10),
              color: const Color(0xffD3D3D3),
            ),
            ..._SingelComments(
                answard: true,
                context: context,
                fqaComment: fqaComment,
                index: index,
                state: state)
          ],
        ));
  }

  List<Widget> _SingelComments(
      {required bool answard,
      required BuildContext context,
      required int index,
      required HomeState state,
      required FqaComment fqaComment}) {
    void _showEditBottomSheet(BuildContext context, String initialText) {
      final TextEditingController _controller =
          TextEditingController(text: initialText);
      final ValueNotifier<bool> isNotEmptyNotifier =
          ValueNotifier(_controller.text.trim().isNotEmpty);
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
                    decoration: InputDecoration(
                      hintText: LocaleKeys.edit_comment_hint.tr(),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                    maxLines: 6,
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
                              BlocProvider.of<HomeBloc>(context)
                                  .add(UpdateCommentRatingEvent(
                                commentId: fqaComment.id,
                                productId: fqaComment.productId,
                                ownerId: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        fqaComment.productId.toString()]
                                    ?.product
                                    ?.ownerId,
                                ownerType: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        fqaComment.productId.toString()]
                                    ?.product
                                    ?.ownerType,
                                tapCommentIndex: index,
                                variant: fqaComment.variant,
                                text: _controller.text,
                              ));
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
        SvgPicture.asset(
          AppAssets.sandClockSvg,
          height: 16,
        ),
        MyTextWidget(
          " ${LocaleKeys.waiting_for_supplier_response.tr()}...",
          maxLines: 10,
          style: context.textTheme.titleLarge?.rr
              .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
        ),
        const Spacer(),
      ];
    }
    String extractInitialsAndAppendXXX(String text) {
      final words = text.trim().split(RegExp(r'\s+'));
      final result =
          words.where((w) => w.isNotEmpty).map((w) => '${w[0]}xxx').join(' ');
      return result;
    }

    String formatDateByLocale(DateTime isoDate, String locale) {
      final date = isoDate;
      // صيغة "day short_month" مثل "18 Feb" أو "20 Oct"
      final format =
          DateFormat('d MMM', locale); // locale مثال "en", "ar", "fr", "tr" ...
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
        height: 20,
        width: 1.sw,
        child: Row(
          children: [
            answard
                ? const SizedBox.shrink()
                : MyCachedNetworkImage(
                    imageUrl: (fqaComment.customer?.image ?? "")
                            .contains("cloudinary")
                        ? fqaComment.customer?.image ?? ""
                        : '${dotenv.env['Images_Url']}${fqaComment.customer?.image}',
                    width: 20,
                    imageFit: BoxFit.cover,
                    height: 20),
            const SizedBox(width: 10),
            Row(
              children: [
                MyTextWidget(
                  answard ? "A " : "Q ",
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                ),
                MyTextWidget(
                  answard
                      ? "${extractInitialsAndAppendXXX(state.cachedProductWithoutRelatedProductsModel[fqaComment.productId.toString()]?.product?.seller?.fName ?? "admin")}"
                      : "${extractInitialsAndAppendXXX(fqaComment.customer?.name ?? "")}",
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                ),
              ],
            ),
            const Spacer(),
            MyTextWidget(
              answard
                  ? formatDateByLocale(fqaComment.replyCreatedAt!,
                      GetIt.I<PrefsRepository>().language ?? "en")
                  : formatDateByLocale(fqaComment.createdAt!,
                      GetIt.I<PrefsRepository>().language ?? "en"),
              style: context.textTheme.titleLarge?.rr
                  .copyWith(color: const Color(0xff8D8D8D), fontSize: 9),
            )
          ],
        ),
      ),
      answard
          ? MyTextWidget(
              "${LocaleKeys.dear.tr()} ${extractInitialsAndAppendXXX(fqaComment.customer?.name ?? "")}",
              style: context.textTheme.titleLarge?.mr
                  .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
            )
          : MyTextWidget(
              fqaComment.variant ?? "",
              style: context.textTheme.titleLarge?.mr
                  .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
            ),
      const SizedBox(height: 10),
      MyTextWidget(
        answard ? (fqaComment.sellerReply ?? "") : (fqaComment.comment ?? ""),
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
              fqaComment.customer?.id !=
                          GetIt.I<PrefsRepository>().myMarketId ||
                      (answard)
                  ? const SizedBox.shrink()
                  : Flexible(
                      child: SizedBox(
                          width: 80,
                          height: 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              state.deleteOrderCommentRatingStatus ==
                                          DeleteOrderCommentRatingStatus
                                              .loading &&
                                      state.tapCommentIndex == index
                                  ? TrydosLoader(
                                      size: 15,
                                    )
                                  : SizedBox(
                                      width: 20,
                                      child: GestureDetector(
                                          onTap: () async {
                                            final confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              builder: (ctx) => Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: Container(
                                                      width: double.infinity,
                                                      margin: EdgeInsets.only(
                                                          top: 8.h),
                                                      padding:
                                                          EdgeInsets.all(16.w),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFE2FFF1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.r),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFF402CDD)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyTextWidget(
                                                            LocaleKeys
                                                                .confirm_delete_comment_title
                                                                .tr(),
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                  0xFF1A1A1A),
                                                            ),
                                                          ),
                                                          SizedBox(height: 8.h),
                                                          MyTextWidget(
                                                            LocaleKeys
                                                                .confirm_delete_comment_message
                                                                .tr(),
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFF666666),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: 12.h),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop(
                                                                              false),
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .cancel
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors.grey[
                                                                            600],
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop(
                                                                              true),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                            0xFF402CDD),
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                    ),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10),
                                                                  ),
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .confirm_delete
                                                                        .tr(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                            if (confirmed == true) {
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(DeleteCommentRatingEvent(
                                                commentId: fqaComment.id,
                                                productId: fqaComment.productId,
                                                tapCommentIndex: index,
                                              ));
                                            }
                                          },
                                          child: SvgPicture.asset(
                                            AppAssets.deletecartSvg,
                                            height: 20,
                                          ))),
                              const SizedBox(
                                width: 15,
                              ),
                              (fqaComment.hasReply ?? false)
                                  ? const SizedBox.shrink()
                                  : state.updateOrderCommentRatingStatus ==
                                              UpdateOrderCommentRatingStatus
                                                  .loading &&
                                          state.tapCommentIndex == index
                                      ? TrydosLoader(
                                          size: 15,
                                        )
                                      : SizedBox(
                                          width: 20,
                                          child: GestureDetector(
                                              onTap: () {
                                                _showEditBottomSheet(context,
                                                    fqaComment.comment ?? "");
                                              },
                                              child: SvgPicture.asset(
                                                AppAssets.editSvg,
                                                // ignore: deprecated_member_use
                                                color: Colors.green,
                                                height: 20,
                                              )),
                                        )
                            ],
                          ))),
              const Spacer(),
              !answard
                  ? const SizedBox.shrink()
                  : MyTextWidget(
                      '${getTimeAgo(fqaComment.replyCreatedAt!, GetIt.I<PrefsRepository>().language ?? "en")} ${LocaleKeys.answered.tr()}',
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff8D8D8D), fontSize: 9),
                    )
            ],
          ))
    ];
  }
}
