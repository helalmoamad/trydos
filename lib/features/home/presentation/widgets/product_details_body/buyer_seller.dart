import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../core/utils/theme_state.dart';

class BuyerSellerChat extends StatefulWidget {
  final String currentVariant;
  final String productId;
  final String productSlug;
  final String? ownerType;
  final String? ownerId;
  final ValueNotifier<bool>? isVerified;
  final PanelController panelBuyersSeller;
  const BuyerSellerChat({
    super.key,
    required this.productId,
    required this.isVerified,
    required this.ownerType,
    required this.productSlug,
    required this.ownerId,
    required this.panelBuyersSeller,
    required this.currentVariant,
  });

  @override
  State<BuyerSellerChat> createState() => _BuyerSellerChatState();
}

class _BuyerSellerChatState extends ThemeState<BuyerSellerChat> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.6)) {
        GetIt.I<HomeBloc>().add(
          GetFqaCommentsEvent(
            productId: widget.productId,
            getWithPagination: true,
          ),
        );
      }
    });
    super.initState();
  }

  void _sendMessage(String message) {
    // إرسال الرسالة للبائع
    if (message.length > 0) {
      GetIt.I<HomeBloc>().add(
        CreateCommentRatingEvent(
          productId: widget.productId,
          variant: widget.currentVariant,
          ownerId: widget.ownerId,
          ownerType: widget.ownerType,
          text: message,
          slug: widget.productSlug,
          images: const [],
        ),
      );
    }
    _messageController.clear();
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getFqaCommentsPaginationModel?['all']?.paginationStatus !=
              current.getFqaCommentsPaginationModel?['all']?.paginationStatus ||
          previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
              current.getProductDetailWithoutSimilarRelatedProductsStatus ||
          previous.createCommentRatingStatus !=
              current.createCommentRatingStatus ||
          previous.deleteOrderCommentRatingStatus !=
              current.deleteOrderCommentRatingStatus ||
          previous.updateOrderCommentRatingStatus !=
              current.updateOrderCommentRatingStatus ||
          previous.getFullProductDetailsStatus !=
              current.getFullProductDetailsStatus ||
          previous.updateLikeCommentRatingStatus !=
              current.updateLikeCommentRatingStatus ||
          previous.translateCommentStatus != current.translateCommentStatus,
      builder: (context, state) {
        if (state.getFqaCommentsPaginationModel == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (state.getFqaCommentsPaginationModel == null) {
                    return;
                  }
                  if (state
                      .getFqaCommentsPaginationModel!['all']!
                      .items
                      .isEmpty) {
                    return;
                  }
                  LastPagesTracker.push("BuyerSellerChat Page");
                  widget.panelBuyersSeller.open();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: SvgPicture.asset(
                        AppAssets.faqSvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xff1D1D1D),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        bottom: 10.h,
                      ),
                      child: Row(
                        children: [
                          MyTextWidget(
                            '${LocaleKeys.faq_buyer_seller.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          SvgPicture.asset(
                            AppAssets.registerInfoSvg,
                            height: 10.h,
                            width: 10.w,
                            // ignore: deprecated_member_use
                            color: const Color(0xffC4C2C2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              state.getFqaCommentsPaginationModel!['all']!.items.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 250.h,
                      width: 1.sw,
                      child: ListView.separated(
                        controller: scrollController,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 5.w),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return (index ==
                                  (state
                                          .getFqaCommentsPaginationModel?['all']
                                          ?.items
                                          .length ??
                                      0))
                              ? SizedBox(
                                  width: 30.w,
                                  height: 50.h,
                                  child:
                                      state
                                              .getFqaCommentsPaginationModel?['all']
                                              ?.paginationStatus ==
                                          PaginationStatus.loading
                                      ? TrydosLoader(size: 20)
                                      : const SizedBox.shrink(),
                                )
                              : _commentWidget(
                                  state
                                      .getFqaCommentsPaginationModel!['all']!
                                      .items[index],
                                  index,
                                  state,
                                );
                        },
                        itemCount:
                            (state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items
                                    .length ??
                                0) +
                            1,
                      ),
                    ),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    previous.verifyOtpFromGuestStatus !=
                    current.verifyOtpFromGuestStatus,

                builder: (context, authState) {
                  return !(GetIt.I<PrefsRepository>().isVerifiedPhone ?? false)
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              if (!(GetIt.I<PrefsRepository>()
                                      .isVerifiedPhone ??
                                  false)) {
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
                              }
                            },
                            child: SizedBox(
                              width: 1.sw,
                              height: 30.h,
                              child: Center(
                                child: MyTextWidget(
                                  LocaleKeys.please_login_to_add_comment.tr(),
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 40.h,
                          width: 1.sw,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: const Color(0xff513AAF)),
                          ),
                          child: TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText:
                                  '${LocaleKeys.ask_seller_about_product.tr()}',
                              hintStyle: context.textTheme.titleLarge?.rq
                                  .copyWith(
                                    color: const Color(0xffC4C2C2),
                                    fontSize: 11.sp,
                                  ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15.w,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: SvgPicture.asset(
                                  AppAssets.faqSvg,
                                  width: 16.w,
                                  height: 16.h,
                                ),
                              ),
                              suffixIcon:
                                  state.createCommentRatingStatus ==
                                      CreateCommentRatingStatus.loading
                                  ? TrydosLoader(size: 16.w)
                                  : _messageController.text.length > 0
                                  ? GestureDetector(
                                      onTap: () {
                                        if (_messageController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _sendMessage(
                                            _messageController.text.trim(),
                                          );
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(8.w),
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff513AAF),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 16.w,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              fontSize: 11.sp,
                            ),
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.send,
                            onChanged: (value) {
                              setState(() {}); // لإعادة بناء الـ suffix icon
                            },
                            onFieldSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                // إرسال الرسالة
                                _sendMessage(value.trim());
                              }
                            },
                          ),
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _commentWidget(FqaComment fqaComment, int index, HomeState state) {
    return Container(
      width: 388.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._SingelComments(
            answard: false,
            fqaComment: fqaComment,
            index: index,
            state: state,
            isVerified: widget.isVerified,
          ),
          Container(
            height: 0.5.h,
            margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
            color: const Color(0xffD3D3D3),
          ),
          ..._SingelComments(
            answard: true,
            fqaComment: fqaComment,
            isVerified: widget.isVerified,
            index: index,
            state: state,
          ),
        ],
      ),
    );
  }

  List<Widget> _SingelComments({
    required bool answard,
    required FqaComment fqaComment,
    required int index,
    required ValueNotifier<bool>? isVerified,
    required HomeState state,
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
                                  ownerId: widget.ownerId,
                                  ownerType: widget.ownerType,
                                  productId: fqaComment.productId,
                                  slug: widget.productSlug,
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
      final format = tran.DateFormat(
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
      SizedBox(height: 10.h),
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
            : ((fqaComment.isTran ?? false)
                  ? (fqaComment.commentTran ?? "")
                  : fqaComment.comment ?? ""),
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
                          widget.isVerified?.value = false;
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
                    '${answard ? (fqaComment.replyTotalLikes ?? 0) : (fqaComment.totalLikes ?? 0)}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 9.sp,
                    ),
                  ),

            answard
                ? const SizedBox.shrink()
                : SizedBox(
                    width: 60.w,
                    height: 32.h,
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
                            width: 60.w,
                            height: 32.h,
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
                                  BlocProvider.of<HomeBloc>(context).add(
                                    TranslateCommentEvent(
                                      commentId: fqaComment.id,
                                      showOriginal:
                                          (fqaComment.isTran ?? false),
                                      tapCommentIndex: index,
                                      fromSellerComments:
                                          fqaComment.hasReply ?? false,
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
