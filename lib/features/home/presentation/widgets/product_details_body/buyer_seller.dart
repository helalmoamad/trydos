import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
  final String? ownerType;
  final String? ownerId;
  final ValueNotifier<bool>? isVerified;
  final PanelController panelBuyersSeller;
  const BuyerSellerChat(
      {super.key,
      required this.productId,
      required this.isVerified,
      required this.ownerType,
      required this.ownerId,
      required this.panelBuyersSeller,
      required this.currentVariant});

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
        GetIt.I<HomeBloc>().add(GetFqaCommentsEvent(
            productId: widget.productId, getWithPagination: true));
      }
    });
    super.initState();
  }

  void _sendMessage(String message) {
    // إرسال الرسالة للبائع
    if (message.length > 0) {
      GetIt.I<HomeBloc>().add(CreateCommentRatingEvent(
        productId: widget.productId,
        variant: widget.currentVariant,
        ownerId: widget.ownerId,
        ownerType: widget.ownerType,
        text: message,
      ));
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
                current
                    .getFqaCommentsPaginationModel?['all']?.paginationStatus ||
            previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                current.getProductDetailWithoutSimilarRelatedProductsStatus ||
            previous.createCommentRatingStatus !=
                current.createCommentRatingStatus ||
            previous.deleteOrderCommentRatingStatus !=
                current.deleteOrderCommentRatingStatus ||
            previous.updateOrderCommentRatingStatus !=
                current.updateOrderCommentRatingStatus ||
            previous.getFullProductDetailsStatus !=
                current.getFullProductDetailsStatus,
        builder: (context, state) {
          if (state.getFqaCommentsPaginationModel == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () {
                      if (state.getFqaCommentsPaginationModel == null) {
                        return;
                      }
                      if (state.getFqaCommentsPaginationModel!['all']!.items
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
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(AppAssets.faqSvg,
                                // ignore: deprecated_member_use
                                color: const Color(0xff1D1D1D))),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              children: [
                                MyTextWidget(
                                  '${LocaleKeys.faq_buyer_seller.tr()}',
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 11),
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
                      ],
                    )),
                state.getFqaCommentsPaginationModel!['all']!.items.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 250,
                        width: 1.sw,
                        child: ListView.separated(
                          controller: scrollController,
                          separatorBuilder: (context, index) => const SizedBox(
                            width: 5,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return (index ==
                                    (state.getFqaCommentsPaginationModel?['all']
                                            ?.items.length ??
                                        0))
                                ? SizedBox(
                                    width: 30,
                                    height: 50,
                                    child: state
                                                .getFqaCommentsPaginationModel?[
                                                    'all']
                                                ?.paginationStatus ==
                                            PaginationStatus.loading
                                        ? TrydosLoader(
                                            size: 20,
                                          )
                                        : const SizedBox.shrink())
                                : _commentWidget(
                                    state.getFqaCommentsPaginationModel!['all']!
                                        .items[index],
                                    index,
                                    state);
                          },
                          itemCount: (state
                                      .getFqaCommentsPaginationModel?['all']
                                      ?.items
                                      .length ??
                                  0) +
                              1,
                        )),
                !(GetIt.I<PrefsRepository>().isVerifiedPhone ?? false)
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
                                    GetIt.I<AuthBloc>().add(SendOtpEvent(
                                        phone: GetIt.I<PrefsRepository>()
                                            .myPhoneNumber!,
                                        isViaWhatsApp: 1));
                                  }
                                });
                              }
                            },
                            child: SizedBox(
                                width: 1.sw,
                                height: 30,
                                child: Center(
                                    child: MyTextWidget(
                                        LocaleKeys.please_login_to_add_comment
                                            .tr(),
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                                color: Colors.red,
                                                fontSize: 14))))))
                    : Container(
                        height: 40,
                        width: 1.sw,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xff513AAF))),
                        child: TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText:
                                '${LocaleKeys.ask_seller_about_product.tr()}',
                            hintStyle: context.textTheme.titleLarge?.rr
                                .copyWith(
                                    color: const Color(0xffC4C2C2),
                                    fontSize: 11),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                AppAssets.faqSvg,
                                width: 16,
                                height: 16,
                              ),
                            ),
                            suffixIcon: state.createCommentRatingStatus ==
                                    CreateCommentRatingStatus.loading
                                ? TrydosLoader(
                                    size: 16,
                                  )
                                : _messageController.text.length > 0
                                    ? GestureDetector(
                                        onTap: () {
                                          if (_messageController.text
                                              .trim()
                                              .isNotEmpty) {
                                            _sendMessage(
                                                _messageController.text.trim());
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff513AAF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    : null,
                          ),
                          style: context.textTheme.titleLarge?.rr.copyWith(
                              color: const Color(0xff1D1D1D), fontSize: 11),
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
                      )
              ],
            ),
          );
        });
  }

  Widget _commentWidget(FqaComment fqaComment, int index, HomeState state) {
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
            ..._SingelComments(
                answard: false,
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
                fqaComment: fqaComment,
                index: index,
                state: state)
          ],
        ));
  }

  List<Widget> _SingelComments(
      {required bool answard,
      required FqaComment fqaComment,
      required int index,
      required HomeState state}) {
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
                                ownerId: widget.ownerId,
                                ownerType: widget.ownerType,
                                productId: fqaComment.productId,
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
      final format = tran.DateFormat(
          'd MMM', locale); // locale مثال "en", "ar", "fr", "tr" ...
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
      const SizedBox(height: 10),
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
