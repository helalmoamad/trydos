import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../core/utils/responsive_padding.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetCommentsContent extends StatefulWidget {
  final String productId;
  final String productSlug;
  final String productSlugForTopic;
  final String currentVariant;
  final String? ownerType;
  final String? ownerId;
  final ValueNotifier<bool>? isVerified;
  final ScrollController? scrollController;
  ProductDetailsSheetCommentsContent({
    super.key,
    this.scrollController,
    required this.productSlug,
    required this.isVerified,
    required this.productSlugForTopic,
    required this.ownerType,
    required this.ownerId,
    required this.productId,
    required this.currentVariant,
  });

  @override
  State<ProductDetailsSheetCommentsContent> createState() =>
      _ProductDetailsSheetCommentsContentState();
}

class _ProductDetailsSheetCommentsContentState
    extends State<ProductDetailsSheetCommentsContent> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  final TextEditingController addCommentController = TextEditingController();
  //  final ValueNotifier<bool> addCommentButtonToggleNotifier =
  //     ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(() {
      if (widget.scrollController!.offset >=
          (widget.scrollController!.position.maxScrollExtent * 0.6)) {
        GetIt.I<HomeBloc>().add(
          GetFqaCommentsEvent(productId: widget.productId),
        );
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LastPagesTracker.push("ProductDetailsSheetCommentsContent Page");
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.createCommentRatingStatus !=
              current.createCommentRatingStatus ||
          previous.deleteOrderCommentRatingStatus !=
              current.deleteOrderCommentRatingStatus ||
          previous.updateOrderCommentRatingStatus !=
              current.updateOrderCommentRatingStatus ||
          previous.translateCommentStatus != current.translateCommentStatus ||
          previous.getFqaCommentsPaginationModel?['all']?.paginationStatus !=
              current.getFqaCommentsPaginationModel?['all']?.paginationStatus,
      builder: (context, state) {
        return ScrollConfiguration(
          behavior: const cupertino.CupertinoScrollBehavior(),
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous.verifyOtpFromGuestStatus !=
                current.verifyOtpFromGuestStatus,

            builder: (context, authState) {
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  10.verticalSpace,
                  !(prefsRepository.isVerifiedPhone ?? false)
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
                          height: 65.h,
                          decoration: BoxDecoration(
                            color: const Color(0xffF8F8F8),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          alignment: Alignment.center,
                          child: cupertino.Directionality(
                            textDirection: cupertino.TextDirection.ltr,
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: HWEdgeInsets.symmetric(
                                  horizontal: 20.w,
                                ),
                                child: AppTextField(
                                  textInputAction:
                                      cupertino.TextInputAction.done,
                                  onFieldSubmitted: (val) {
                                    if (addCommentController.text.isEmpty) {
                                      return;
                                    }
                                    BlocProvider.of<HomeBloc>(context).add(
                                      CreateCommentRatingEvent(
                                        productId: widget.productId,
                                        slug: widget.productSlug,
                                        images: const [],
                                        ownerId: widget.ownerId,
                                        ownerType: widget.ownerType,
                                        variant: widget.currentVariant,
                                        text: val,
                                      ),
                                    );

                                    //////////////////////////////////////////////////////////
                                    // FirebaseAnalyticsService.logEventForSession(
                                    //   eventName:
                                    //       AnalyticsEventsConst.buttonClicked,
                                    //   executedEventName:
                                    //       AnalyticsButtonsEventNameConst
                                    //           .confirmCommentButton,
                                    // );

                                    //   addCommentButtonToggleNotifier.value = false;

                                    addCommentController.clear();
                                    cupertino.FocusScope.of(context).unfocus();
                                  },
                                  hintText: LocaleKeys.add_comment.tr(),
                                  controller: addCommentController,
                                  suffixIcon: Padding(
                                    padding: HWEdgeInsets.only(
                                      right: 20.w,
                                      top: 15.h,
                                      bottom: 15.h,
                                    ),
                                    child: IconButton(
                                      icon:
                                          (state.createCommentRatingStatus ==
                                                  CreateCommentRatingStatus
                                                      .loading) ||
                                              (state.updateOrderCommentRatingStatus ==
                                                  UpdateOrderCommentRatingStatus
                                                      .loading)
                                          ? const Icon(
                                              Icons.hourglass_bottom_rounded,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.send,
                                              color: Colors.blue,
                                            ),
                                      onPressed: () {
                                        /*    if (addCommentController.text.isEmpty) {
                                        return;
                                      }*/
                                        BlocProvider.of<HomeBloc>(context).add(
                                          CreateCommentRatingEvent(
                                            productId: widget.productId,
                                            variant: widget.currentVariant,
                                            slug: widget.productSlug,
                                            images: const [],
                                            ownerId: widget.ownerId,
                                            ownerType: widget.ownerType,
                                            text: addCommentController.text,
                                          ),
                                        );

                                        //////////////////////////////////////////////////////////
                                        // FirebaseAnalyticsService
                                        //     .logEventForSession(
                                        //   eventName:
                                        //       AnalyticsEventsConst.buttonClicked,
                                        //   executedEventName:
                                        //       AnalyticsButtonsEventNameConst
                                        //           .confirmCommentButton,
                                        // );
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
                                            addCommentController.clear();
                                            cupertino.FocusScope.of(
                                              context,
                                            ).unfocus();
                                          },
                                        );

                                        //     addCommentButtonToggleNotifier.value =
                                        //          false;
                                      },
                                      /* child: (state.addCommentStatus ==
                                            AddCommentStatus.loading)
                                        ? cupertino.Container(
                                            width: 25,
                                            height: 25,
                                            child: TrydosLoader(
                                              size: 20,
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            AppAssets.submitArrowSvg,
                                            width: 10,
                                            height: 10,
                                          ),*/
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  10.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppAssets.chatMarkActiveSvg,
                        height: 20.w,
                      ),
                      SizedBox(width: 10.w),
                      MyTextWidget(
                        '${LocaleKeys.comment_about_this_product.tr()}',
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff505050),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 300.h,
                    child: ListView.builder(
                      controller: widget.scrollController,
                      itemBuilder: (context, index) {
                        if (index ==
                            (state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items
                                    .length ??
                                0)) {
                          return SizedBox(
                            height: 120.h,
                            width: 1.sw,
                            child:
                                state
                                        .getFqaCommentsPaginationModel?['all']
                                        ?.paginationStatus ==
                                    PaginationStatus.loading
                                ? TrydosLoader(size: 24.h)
                                : const SizedBox.shrink(),
                          );
                        }
                        return Padding(
                          padding: HWEdgeInsets.symmetric(vertical: 2),
                          child: CommentCard(
                            state: state,
                            isVerified: widget.isVerified,
                            productSlug: widget.productSlug,
                            commentTran:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .commentTran ??
                                "",
                            commentHasReply: state
                                .getFqaCommentsPaginationModel?['all']
                                ?.items[index]
                                .hasReply,
                            isTran: state
                                .getFqaCommentsPaginationModel?['all']
                                ?.items[index]
                                .isTran,
                            userId:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .customer
                                    ?.id ??
                                "",
                            tapIndex: state.tapCommentIndex,
                            imageUrl:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .customer
                                    ?.image ??
                                "",
                            index: index,
                            ownerId: widget.ownerId,
                            ownerType: widget.ownerType,
                            commentId:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .id ??
                                "",
                            currentVariant:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .variant ??
                                "",
                            productId:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .productId ??
                                "",
                            names:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .customer
                                    ?.name ??
                                "",
                            comment:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .comment ??
                                "",
                            date:
                                state
                                    .getFqaCommentsPaginationModel?['all']
                                    ?.items[index]
                                    .createdAt
                                    ?.toString() ??
                                "",
                          ),
                        );
                      },
                      itemCount:
                          (state
                                  .getFqaCommentsPaginationModel?['all']
                                  ?.items
                                  .length ??
                              0) +
                          1,
                      physics: const cupertino.ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class CommentCard extends StatelessWidget {
  final String imageUrl;
  final String date;
  final int index;
  final String? ownerType;
  final String? ownerId;
  final String names;
  final bool? commentHasReply;
  final String userId;
  final String comment;
  final String commentTran;
  final String productSlug;
  final String commentId;
  final bool? isTran;
  final ValueNotifier<bool>? isVerified;
  final String currentVariant;
  final String productId;
  final HomeState state;
  final int tapIndex;
  const CommentCard({
    super.key,
    required this.imageUrl,
    required this.commentHasReply,
    required this.tapIndex,
    required this.state,
    required this.isVerified,
    required this.isTran,
    required this.commentTran,
    required this.ownerType,
    required this.productSlug,
    required this.ownerId,
    required this.userId,
    required this.index,
    required this.productId,
    required this.commentId,
    required this.currentVariant,
    required this.names,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
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
                                  commentId: commentId,
                                  productId: productId,
                                  ownerId: ownerId,
                                  ownerType: ownerType,
                                  slug: productSlug,
                                  tapCommentIndex: index,
                                  variant: currentVariant,
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

    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      margin: HWEdgeInsets.symmetric(horizontal: 20.w),
      padding: HWEdgeInsets.only(left: 10.w, top: 20.h, right: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(20.r),
      ),
      height: 90.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
              child: Stack(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.h,
                    child: MyCachedNetworkImage(
                      imageUrl: imageUrl.contains("cloudinary")
                          ? imageUrl
                          : '${dotenv.env['Images_Url']}$imageUrl',
                      width: 20.w,
                      imageFit: cupertino.BoxFit.cover,
                      height: 20.h,
                    ),
                  ),
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                          // ignore: deprecated_member_use
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
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyTextWidget(
                      extractInitialsAndAppendXXX(names),
                      style: context.textTheme.bodySmall?.rq.copyWith(
                        color: const Color(0xff969696),
                      ),
                    ),
                    const Spacer(),
                    MyTextWidget(
                      date,
                      style: context.textTheme.titleSmall?.rq.copyWith(
                        color: const Color(0xff969696),
                      ),
                    ),

                    SizedBox(
                      width: 40.w,
                      height: 35.h,
                      child:
                          ((state.deleteOrderCommentRatingStatus ==
                                      DeleteOrderCommentRatingStatus.loading ||
                                  state.updateOrderCommentRatingStatus ==
                                      UpdateOrderCommentRatingStatus.loading ||
                                  state.translateCommentStatus ==
                                      TranslateCommentStatus.loading) &&
                              state.tapCommentIndex == index)
                          ? TrydosLoader(size: 15)
                          : SizedBox(
                              width: 40.w,
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
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF402CDD,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.1),
                                                    blurRadius: 8.r,
                                                    offset: Offset(0, 2.h),
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 10,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            LocaleKeys
                                                                .confirm_delete
                                                                .tr(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                          commentId: commentId,
                                          productId: productId,
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
                                    _showEditBottomSheet(context, comment);
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
                                      TranslateCommentEvent(
                                        commentId: commentId,
                                        showOriginal: (isTran ?? false),
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
                                            (isTran ?? false)
                                                ? LocaleKeys
                                                      .show_original_version
                                                      .tr()
                                                : LocaleKeys.translate.tr(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (!(userId !=
                                          GetIt.I<PrefsRepository>()
                                              .myMarketId ||
                                      (commentHasReply ?? false))) {
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
                  ],
                ),
                Flexible(
                  child: MyTextWidget(
                    (isTran ?? false) ? commentTran : comment,
                    style: context.textTheme.bodySmall?.rq.copyWith(
                      color: const Color(0xff5D5C5D),
                    ),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),
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
