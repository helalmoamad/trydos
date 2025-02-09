import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/handling_market_notifications.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/responsive_padding.dart';
import '../../../../../core/utils/theme_state.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/my_text_widget.dart';

class ProductDetailsSheetMoreOptionsContent extends StatefulWidget {
  const ProductDetailsSheetMoreOptionsContent(
      {super.key,
      this.scrollController,
      required this.productSlug,
      required this.productSlugForTopic,
      required this.productId});

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
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getNotificationTypeProductStatus !=
          current.getNotificationTypeProductStatus,
      builder: (context, state) {
        String countryISo =
            ((GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
                        ? GetIt.I<PrefsRepository>().userChoosedCountryIso
                        : GetIt.I<PrefsRepository>().countryIso) ??
                    "")
                .toLowerCase();

        List<String> notifucationThatSubsecribe = [];
        notifucationThatSubsecribe =
            prefsRepository.topicThatAlreadySubsecribed();
        return SingleChildScrollView(
          child: ListView(
            controller: widget.scrollController,
            physics: cupertino.ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              10.verticalSpace,
              MyTextWidget('${LocaleKeys.more_options.tr()}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: Color(0xff505050),
                  )),
              10.verticalSpace,
              (state.notificationTypeForProductModel?.notificationTypes
                              ?.length ??
                          0) ==
                      0
                  ? SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.only(top: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 106,
                      width: 1.sw,
                      decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 1.sw,
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                SvgPicture.asset(
                                  AppAssets.notificationOutlinedIconSvg,
                                  height: 25,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                    child: Text(
                                  LocaleKeys.notify_me_about_the_product_when
                                      .tr(),
                                  style: context.textTheme.bodyMedium?.rr
                                      .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 0.8),
                                ))
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
                              state.firebaseSettingForNotificationModel?.data
                                  ?.firebaseSettings?.subscribedTopics
                                  ?.forEach(
                                (element) => notificationISSubsecribe
                                    .add(element.topic ?? ""),
                              );
                              return Container(
                                width: 1.sw,
                                height: 50.h,
                                margin: EdgeInsets.only(
                                    top: 15, left: 20, right: 20),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                          onTap: () {
                                            tapIndex = index;
                                            if (notificationISSubsecribe
                                                .contains((state
                                                            .notificationTypeForProductModel
                                                            ?.notificationTypes?[
                                                                index]
                                                            .topic ??
                                                        "") +
                                                    "_${widget.productId}")) {
                                              SubsecribeOrUnSubsecribeToTopic()
                                                  .UnSubsecribeToOtherTopic(
                                                      ("${state.notificationTypeForProductModel?.notificationTypes?[index].topic ?? ""}" +
                                                          "_${widget.productId}"));
                                            } else {
                                              SubsecribeOrUnSubsecribeToTopic()
                                                  .SubsecribeToOtherTopic(
                                                      ("${state.notificationTypeForProductModel?.notificationTypes?[index].topic ?? ""}" +
                                                          "_${widget.productId}"));
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffEFEFEF),
                                                      border: Border.all(
                                                          color: notificationISSubsecribe.contains((state
                                                                          .notificationTypeForProductModel
                                                                          ?.notificationTypes?[
                                                                              index]
                                                                          .topic ??
                                                                      "") +
                                                                  "_${widget.productId}")
                                                              ? Colors.red
                                                              : Color(
                                                                  0xffEFEFEF)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (state
                                                              .notificationTypeForProductModel
                                                              ?.notificationTypes?[
                                                                  index]
                                                              .name ??
                                                          ""),
                                                      style: context.textTheme
                                                          .bodyMedium?.rr
                                                          .copyWith(
                                                              color: const Color(
                                                                  0xff505050),
                                                              letterSpacing:
                                                                  0.18,
                                                              fontSize: 14,
                                                              height: 0.8),
                                                    ),
                                                  )),
                                              index == tapIndex &&
                                                      state.getFirebaseSettingForNotificationStatus ==
                                                          GetFirebaseSettingForNotificationStatus
                                                              .loading
                                                  ? Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          Colors.grey.shade100,
                                                      enabled: true,
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xffEFEFEF),
                                                              border: Border.all(
                                                                  color: notificationISSubsecribe.contains(
                                                                          (state.notificationTypeForProductModel?.notificationTypes?[index].topic ?? "") +
                                                                              "_${widget.productId}")
                                                                      ? Colors
                                                                          .red
                                                                      : Color(
                                                                          0xffEFEFEF)),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      30)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              (state
                                                                      .notificationTypeForProductModel
                                                                      ?.notificationTypes?[
                                                                          index]
                                                                      .name ??
                                                                  ""),
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rr
                                                                  .copyWith(
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          0.8),
                                                            ),
                                                          )))
                                                  : SizedBox.shrink()
                                            ],
                                          ),
                                        ),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          width: 5,
                                        ),
                                    itemCount: (state
                                            .notificationTypeForProductModel
                                            ?.notificationTypes
                                            ?.length ??
                                        0)),
                              );
                            },
                          )
                        ],
                      ),
                    ),
              10.verticalSpace,
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 65,
                  decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      SvgPicture.asset(
                        AppAssets.checklistSvg,
                        height: 25,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        LocaleKeys.add_to_my_checklist.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xff505050),
                            letterSpacing: 0.18,
                            fontSize: 16,
                            height: 0.8),
                      ),
                    ],
                  )),
              10.verticalSpace,
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 65,
                decoration: BoxDecoration(
                    color: Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  SvgPicture.asset(
                    AppAssets.compareSvg,
                    height: 25,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    LocaleKeys.add_to_compare.tr(),
                    style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xff505050),
                        letterSpacing: 0.18,
                        fontSize: 16,
                        height: 0.8),
                  )
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
