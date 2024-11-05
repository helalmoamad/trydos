import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
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
      {super.key, this.scrollController, required this.productId});

  final ScrollController? scrollController;

  final String productId;

  @override
  State<ProductDetailsSheetMoreOptionsContent> createState() =>
      _ProductDetailsSheetMoreOptionsContentState();
}

class _ProductDetailsSheetMoreOptionsContentState
    extends ThemeState<ProductDetailsSheetMoreOptionsContent> {
  final ValueNotifier<bool> addCommentButtonToggleNotifier =
      ValueNotifier(false);
  final TextEditingController addCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.getCommentForProductModel[widget.productId] !=
              c.getCommentForProductModel[widget.productId] ||
          p.addCommentStatus != c.addCommentStatus,
      builder: (context, state) {
        if (state.getCommentForProductModel[widget.productId] == null) {
          return SizedBox.shrink();
        }
        if (state.addCommentStatus == AddCommentStatus.loading) {
          return TrydosLoader();
        }
        return ScrollConfiguration(
          behavior: cupertino.CupertinoScrollBehavior(),
          child: ListView(
            physics: cupertino.ClampingScrollPhysics(),
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              10.verticalSpace,
              MyTextWidget('More Options',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: Color(0xff505050),
                  )),
              10.verticalSpace,
              Material(
                color: Colors.transparent,
                child: ValueListenableBuilder<bool>(
                    valueListenable: addCommentButtonToggleNotifier,
                    builder: (context, toggleValue, _) {
                      return toggleValue
                          ? Padding(
                              padding: HWEdgeInsets.symmetric(horizontal: 15),
                              child: AppTextField(
                                hintText: LocaleKeys.add_comment.tr(),
                                controller: addCommentController,
                                suffixIcon: Padding(
                                  padding: HWEdgeInsets.only(
                                      right: 20.0, top: 15, bottom: 15),
                                  child: InkWell(
                                    onTap: () {
                                      if (addCommentController.text.isEmpty) {
                                        showMessage(LocaleKeys
                                            .error_empty_comment
                                            .tr());
                                        return;
                                      }
                                      BlocProvider.of<HomeBloc>(context).add(
                                          AddCommentEvent(
                                              productId: widget.productId,
                                              comment:
                                                  addCommentController.text));
                                      addCommentController.clear();
                                      addCommentButtonToggleNotifier.value =
                                          false;
                                      //////////////////////////////////////////////////////////
                                      FirebaseAnalyticsService
                                          .logEventForSession(
                                        eventName:
                                            AnalyticsEventsConst.buttonClicked,
                                        executedEventName:
                                            AnalyticsExecutedEventNameConst
                                                .confirmCommentButton,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      AppAssets.submitArrowSvg,
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                if (GetIt.I<PrefsRepository>().myMarketId ==
                                    null) {
                                  showMessage('You must Login First!');
                                  return;
                                }
                                addCommentButtonToggleNotifier.value = true;
                                //////////////////////////////
                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.buttonClicked,
                                  executedEventName:
                                      AnalyticsExecutedEventNameConst
                                          .addCommentButton,
                                );
                              },
                              child: Row(
                                children: [
                                  10.horizontalSpace,
                                  SvgPicture.asset(
                                    AppAssets.chatMarkSvg,
                                    height: 25,
                                  ),
                                  10.horizontalSpace,
                                  MyTextWidget(
                                    LocaleKeys.add_comment.tr(),
                                    style: textTheme.bodyMedium?.rq.copyWith(
                                      color: Color(0xff505050),
                                      height: 0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                    }),
              )
            ],
          ),
        );
      },
    );
  }
}
