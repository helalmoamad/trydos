import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/cupertino.dart' as cupertino;

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import '../../../../../common/constant/design/assets_provider.dart';

import '../../../../../core/utils/theme_state.dart';
import '../../../../../generated/locale_keys.g.dart';

import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetMoreOptionsContent extends StatefulWidget {
  const ProductDetailsSheetMoreOptionsContent({
    super.key,
    this.scrollController,
    required this.productSlug,
    required this.productSlugForTopic,
    required this.productId,
  });

  final ScrollController? scrollController;

  final String productId;
  final String productSlug;
  final String productSlugForTopic;
  @override
  State<ProductDetailsSheetMoreOptionsContent> createState() =>
      _ProductDetailsSheetMoreOptionsContentState();
}

class _ProductDetailsSheetMoreOptionsContentState
    extends ThemeState<ProductDetailsSheetMoreOptionsContent> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  int? tapIndex;

  @override
  void initState() {
    super.initState();
    // The sheet is only built once the product details request has succeeded,
    // so this is the point where we resolve whether the product is already in
    // the user's checklist (drives the green row).
    context.read<HomeBloc>().add(
      CheckChecklistExistEvent(productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getNotificationTypeProductStatus !=
          current.getNotificationTypeProductStatus,
      builder: (context, state) {
        return SingleChildScrollView(
          child: ListView(
            controller: widget.scrollController,
            physics: const cupertino.ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              10.verticalSpace,
              MyTextWidget(
                '${LocaleKeys.more_options.tr()}',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: const Color(0xff505050),
                ),
              ),
              10.verticalSpace,
              (state
                              .notificationTypeForProductModel
                              ?.data
                              ?.notificationTypes
                              ?.length ??
                          0) ==
                      0
                  ? const SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.only(top: 20.h),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      width: 1.sw,
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 1.sw,
                            height: 25.h,
                            child: Row(
                              children: [
                                SizedBox(width: 20.w),
                                SvgPicture.asset(
                                  AppAssets.notificationOutlinedIconSvg,
                                  height: 25.h,
                                ),
                                SizedBox(width: 20.w),
                                Text(
                                  LocaleKeys.notify_me_about_the_product_when
                                      .tr(),
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        fontSize: 16.sp,
                                        height: 0.8,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) =>
                                previous
                                    .getFirebaseSettingForNotificationStatus !=
                                current.getFirebaseSettingForNotificationStatus,
                            builder: (context, state) {
                              List<String> notificationISSubsecribe = [];
                              state
                                  .firebaseSettingForNotificationModel
                                  ?.data
                                  ?.firebaseSettings
                                  ?.subscribedTopics
                                  ?.forEach(
                                    (element) => notificationISSubsecribe.add(
                                      element.topic ?? "",
                                    ),
                                  );
                              return Container(
                                width: 1.sw,
                                height: 50.h,
                                margin: EdgeInsets.only(
                                  top: 15.h,
                                  left: 20.w,
                                  right: 20.w,
                                ),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => GestureDetector(
                                    onTap: () {
                                      tapIndex = index;
                                      if (notificationISSubsecribe.contains(
                                        (state
                                                    .notificationTypeForProductModel
                                                    ?.data
                                                    ?.notificationTypes?[index]
                                                    .topic ??
                                                "") +
                                            "_${widget.productId}",
                                      )) {
                                        SubsecribeOrUnSubsecribeToTopic()
                                            .unSubsecribeToOtherTopic(
                                              ("${state.notificationTypeForProductModel?.data?.notificationTypes?[index].topic ?? ""}" +
                                                  "_${widget.productId}"),
                                            );
                                      } else {
                                        SubsecribeOrUnSubsecribeToTopic()
                                            .subsecribeToOtherTopic(
                                              ("${state.notificationTypeForProductModel?.data?.notificationTypes?[index].topic ?? ""}" +
                                                  "_${widget.productId}"),
                                            );
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffEFEFEF),
                                            border: Border.all(
                                              color:
                                                  notificationISSubsecribe.contains(
                                                    (state
                                                                .notificationTypeForProductModel
                                                                ?.data
                                                                ?.notificationTypes?[index]
                                                                .topic ??
                                                            "") +
                                                        "_${widget.productId}",
                                                  )
                                                  ? Colors.red
                                                  : const Color(0xffEFEFEF),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30.r,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.h),
                                            child: Text(
                                              (state
                                                      .notificationTypeForProductModel
                                                      ?.data
                                                      ?.notificationTypes?[index]
                                                      .showedName ??
                                                  ""),
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff505050,
                                                    ),
                                                    letterSpacing: 0.18,
                                                    fontSize: 14.sp,
                                                    height: 0.8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        index == tapIndex &&
                                                state.getFirebaseSettingForNotificationStatus ==
                                                    GetFirebaseSettingForNotificationStatus
                                                        .loading
                                            ? Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xffEFEFEF,
                                                    ),
                                                    border: Border.all(
                                                      color:
                                                          notificationISSubsecribe.contains(
                                                            (state
                                                                        .notificationTypeForProductModel
                                                                        ?.data
                                                                        ?.notificationTypes?[index]
                                                                        .topic ??
                                                                    "") +
                                                                "_${widget.productId}",
                                                          )
                                                          ? Colors.red
                                                          : const Color(
                                                              0xffEFEFEF,
                                                            ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30.r,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      8.h,
                                                    ),
                                                    child: Text(
                                                      (state
                                                              .notificationTypeForProductModel
                                                              ?.data
                                                              ?.notificationTypes?[index]
                                                              .name ??
                                                          ""),
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff505050,
                                                            ),
                                                            letterSpacing: 0.18,
                                                            fontSize: 14.sp,
                                                            height: 0.8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 5),
                                  itemCount:
                                      (state
                                          .notificationTypeForProductModel
                                          ?.data
                                          ?.notificationTypes
                                          ?.length ??
                                      0),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
              10.verticalSpace,
              _ChecklistRow(productId: widget.productId),
              10.verticalSpace,
              _CompareRow(productSlug: widget.productSlug),
            ],
          ),
        );
      },
    );
  }
}

/// "Add to my checklist" row.
///
/// Turns green once the product is in the checklist, and is replaced by a
/// same-sized shimmer while any of the three checklist calls (exist / add /
/// delete) for *this* product is in flight. Tapping toggles membership.
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.productId});

  final String productId;

  static const Color _idleColor = Color(0xffF8F8F8);
  static const Color _selectedColor = Color(0xff7BE495);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.checklistItemStatus[productId] !=
              current.checklistItemStatus[productId] ||
          previous.productInChecklist[productId] !=
              current.productInChecklist[productId],
      builder: (context, state) {
        final bool isBusy =
            state.checklistItemStatus[productId] == ChecklistItemStatus.loading;
        final bool isInChecklist = state.productInChecklist[productId] ?? false;

        final Widget row = Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: 65.h,
          decoration: BoxDecoration(
            color: isInChecklist ? _selectedColor : _idleColor,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 20.w),
              SvgPicture.asset(AppAssets.checklistSvg, height: 25.h),
              SizedBox(width: 20.w),
              Text(
                LocaleKeys.add_to_my_checklist.tr(),
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff505050),
                  letterSpacing: 0.18,
                  fontSize: 16.sp,
                  height: 0.8,
                ),
              ),
            ],
          ),
        );

        if (isBusy) {
          // AbsorbPointer: Shimmer does not block hit-testing on its child, so
          // without it the row would stay tappable while the call is running.
          return AbsorbPointer(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: row,
            ),
          );
        }

        return GestureDetector(
          onTap: () => context.read<HomeBloc>().add(
            ToggleChecklistEvent(productId: productId),
          ),
          child: row,
        );
      },
    );
  }
}

/// صفّ "أضف إلى المقارنة" — أخضر إن كان المنتج ضمن المقارنة.
///
/// المقارنة تسع منتجَين اثنين دائماً: الضغط على منتج ثالث يستبدل الأقدم،
/// والضغط على منتج موجود يزيله. والرسالة تُحدَّد قبل الإرسال، فحالة ما بعده
/// لا تدلّ على ما جرى.
class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.productSlug});

  final String productSlug;

  static const Color _idleColor = Color(0xffF8F8F8);
  static const Color _selectedColor = Color(0xff7BE495);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.compareSlugs != current.compareSlugs ||
          previous.compareProductDetailsStatus !=
              current.compareProductDetailsStatus,
      builder: (context, state) {
        final bool isInCompare = state.compareSlugs.values.contains(
          productSlug,
        );
        final int? side = state.compareSlugs.entries
            .where((entry) => entry.value == productSlug)
            .map((entry) => entry.key)
            .firstOrNull;
        final bool isBusy =
            side != null &&
            state.compareProductDetailsStatus[side] ==
                GetCompareProductDetailsStatus.loading;

        final Widget row = Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: 65.h,
          decoration: BoxDecoration(
            color: isInCompare ? _selectedColor : _idleColor,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 20.w),
              SvgPicture.asset(AppAssets.compareSvg, height: 25.h),
              SizedBox(width: 20.w),
              Text(
                LocaleKeys.add_to_compare.tr(),
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff505050),
                  letterSpacing: 0.18,
                  fontSize: 16.sp,
                  height: 0.8,
                ),
              ),
            ],
          ),
        );

        if (isBusy) {
          // AbsorbPointer: Shimmer لا يحجب اللمس عن طفله، فبدونه يبقى الصفّ
          // قابلاً للضغط أثناء جلب التفاصيل.
          return AbsorbPointer(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: row,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            // الرسالة تُختار من الحالة **قبل** الإرسال: بعده تكون قد تغيّرت.
            final String message = isInCompare
                ? LocaleKeys.removed_from_compare.tr()
                : state.compareSlugs.length >= 2
                ? LocaleKeys.compare_oldest_replaced.tr()
                : LocaleKeys.added_to_compare.tr();

            context.read<HomeBloc>().add(
              ToggleCompareProductEvent(productSlug),
            );
            showMessage(message, showInRelease: true);
          },
          child: row,
        );
      },
    );
  }
}
