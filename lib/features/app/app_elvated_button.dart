import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/num.dart';
import '../../../core/utils/theme_state.dart';
import 'app_text_view.dart';
import 'loading_indicator.dart';
import 'network_bloc_widget.dart';

enum AppButtonStyle {
  primary,
  secondary,
}

class AppElevatedButton extends StatefulWidget {
  const AppElevatedButton({
    Key? key,
    this.onPressed,
    this.onDisabled,
    this.child,
    this.text,
    this.textStyle,
    this.isLoading = false,
    this.sensitiveNetwork = false,
    this.appButtonStyle,
    this.style,
  }) : super(key: key);

  final Function()? onPressed;
  final Function()? onDisabled;
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;
  final bool isLoading;
  final AppButtonStyle? appButtonStyle;
  final ButtonStyle? style;
  final bool sensitiveNetwork;

  @override
  State<AppElevatedButton> createState() => _AppElevatedButtonState();
}

class _AppElevatedButtonState extends ThemeState<AppElevatedButton> {
  ElevatedButtonThemeData? _buttonTheme;

  bool get absorbing => widget.onDisabled != null ? false : widget.isLoading;

  CrossFadeState get crossFadeState =>
      widget.isLoading ? CrossFadeState.showSecond : CrossFadeState.showFirst;

  Function()? get onTap =>
      widget.isLoading ? widget.onDisabled : widget.onPressed;

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (widget.text == null && widget.child == null) {
        throw FlutterError("Can't be both text and child is null");
      }
      if (widget.style != null && widget.appButtonStyle != null) {
        throw FlutterError("Can't be pass both style and tripperButtonStyle");
      }
      return true;
    }());

    setButtonStyle();

    final child = AbsorbPointer(
      absorbing: absorbing,
      child: ElevatedButton(
        onPressed: onTap,
        style: widget.style ?? _buttonTheme?.style,
        child: widget.child ??
            AnimatedCrossFade(
              firstChild: firstChild,
              secondChild: secondChild,
              duration: 100.milliseconds,
              crossFadeState: crossFadeState,
              reverseDuration: 100.milliseconds,
            ),
      ),
    );

    if (widget.sensitiveNetwork) {
      return NetworkBlocSensitive(child: child);
    }

    return child;
  }

  Widget get secondChild => FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppTextView(
              text: ' ',
              style: null,
              adaptiveColor: false,
            ),
            if (widget.isLoading) ...{
              8.horizontalSpace,
              const LoadingIndicator(),
              4.horizontalSpace,
            },
          ],
        ),
      );

  Widget get firstChild => FittedBox(
        child: AppTextView(
          text: widget.text!.tr(),
          style: widget.textStyle,
        ),
      );

  void setButtonStyle() {
    final defaultElevatedTheme = theme.elevatedButtonTheme;

    final secondaryElevatedTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: defaultElevatedTheme.style?.shape?.resolve({}),
        surfaceTintColor: colorScheme.primary,
        elevation: 0.0,
        shadowColor: colorScheme.white.withOpacity(0.1),
      ),
    );

    final loadingElevatedTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: defaultElevatedTheme.style?.shape?.resolve({}),
      ),
    );

    _buttonTheme = widget.isLoading
        ? loadingElevatedTheme
        : widget.appButtonStyle == AppButtonStyle.secondary
            ? secondaryElevatedTheme
            : defaultElevatedTheme;
  }
}
