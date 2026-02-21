import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../service/language_service.dart';
import '../app_text_view.dart';
import '../app_widgets/trydos_app_bar/app_bar_params.dart';

class FeedBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FeedBackAppBar({
    Key? key,
    required this.appBarParams,
  }) : super(key: key);

  final AppBarParams appBarParams;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: title(context),
          backgroundColor: appBarParams.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          leading: leadingAppBar(context),
          actions: appBarParams.action,
          centerTitle: appBarParams.centerTitle,
          elevation: appBarParams.elevation,
          shadowColor: appBarParams.shadowColor,
          surfaceTintColor: appBarParams.surfaceTintColor,
          shape: appBarParams.shape,
        ),
        if (appBarParams.dividerBottom)
          Divider(height: 0, endIndent: 25.w, indent: 25.w)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
            AppTextView(
              text: appBarParams.title!,
              style: appBarParams.tittleStyle ??
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: appBarParams.textColor,
                      ),
            ),
        ],
      ),
    );
  }

  Widget leadingAppBar(BuildContext context) => appBarParams.hasLeading
      ? IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: appBarParams.iconColor,
            size: 18,
          ),
          onPressed: appBarParams.onBack ?? () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        )
      : const SizedBox();
}
