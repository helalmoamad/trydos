import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../../../../service/language_service.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../my_text_widget.dart';
import 'app_bar_params.dart';

class TrydosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TrydosAppBar({
    Key? key,
    required this.appBarParams,
  }) : super(key: key);

  final AppBarParams appBarParams;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              boxShadow: appBarParams.withShadow
                  ? [
                      BoxShadow(
                          color: context.colorScheme.black.withOpacity(0.1),
                          offset: Offset(0, 0),
                          blurRadius: 6)
                    ]
                  : null),
          child: AppBar(
            scrolledUnderElevation: appBarParams.scrolledUnderElevation,
            backgroundColor: appBarParams.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            leading: LanguageService.rtl ? null : leadingAppBar(context),
            actions: [
              LanguageService.rtl ? leadingAppBar(context) : SizedBox.shrink(),
              ...appBarParams.action ?? [],
            ],
            centerTitle: appBarParams.centerTitle,
            elevation: appBarParams.elevation,
            shadowColor: appBarParams.shadowColor,
            surfaceTintColor: appBarParams.surfaceTintColor,
            leadingWidth: 30.w,
            shape: appBarParams.shape,
            automaticallyImplyLeading: false,
            flexibleSpace: appBarParams.child,
            bottom: appBarParams.bottom,
          ),
        ),
        if (appBarParams.dividerBottom)
          Divider(height: 0, endIndent: 25.w, indent: 25.w)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);

  Widget title(BuildContext context) {
    return Transform.translate(
      offset: Offset(
          (appBarParams.action?.isNotEmpty ?? true)
              ? 0
              : (LanguageService.rtl ? 30 : -30),
          0),
      child: Row(
        mainAxisAlignment: appBarParams.centerTitle
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (appBarParams.child != null) ...{
            5.horizontalSpace,
            appBarParams.child!,
          },
          if (appBarParams.title != null)
            MyTextWidget(
              appBarParams.title!,
              style: appBarParams.tittleStyle ??
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: appBarParams.textColor,
                      ),
            ),
        ],
      ),
    );
  }

  Widget leadingAppBar(BuildContext context, {Widget? leading}) =>
      appBarParams.hasLeading
          ? Row(
              children: [
                InkWell(
                  key: TestVariables.kTestMode
                      ? Key(WidgetsKey.appBarGoBackArrowKey)
                      : null,
                  onTap: () {
                    appBarParams.onBack?.call();
                    Navigator.pop(context);
                    /////////////////////////////////
                    FirebaseAnalyticsService.logEventForSession(
                      eventName: AnalyticsEventsConst.buttonClicked,
                      executedEventName: AnalyticsExecutedEventNameConst
                          .trydosAppbarBackIconButton,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      AppAssets.backIconArrowSvg,
                      matchTextDirection: true,
                      width: 8.w,
                      color:
                          appBarParams.backIconColor ?? const Color(0xff388CFF),
                    ),
                  ),
                ),
                if (leading != null) ...{
                  SizedBox(
                    width: 10,
                  ),
                  leading
                }
              ],
            )
          : const SizedBox();
}
