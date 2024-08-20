import 'package:flutter/material.dart';

class AppBarParams {
  AppBarParams({
    this.textColor,
    this.translateTitle = true,
    this.centerTitle = true,
    this.hasLeading = true,
    this.dividerBottom = false,
    this.withShadow = true,
    this.child,
    this.leading,
    this.backButton,
    this.title,
    this.iconColor,
    this.action,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.backgroundColor,
    this.backIconColor,
    this.onBack,
    this.tittleStyle,
    this.shape,
    this.scrolledUnderElevation,
    this.bottom,
  });

  final double? scrolledUnderElevation;
  final String? title;
  final Widget? child;
  final Widget? leading;
  final Widget? backButton;
  final List<Widget>? action;
  final bool translateTitle;
  final double? elevation;
  final Color? shadowColor, textColor, iconColor;
  final Color? surfaceTintColor;
  final Color? backgroundColor;
  final Color? backIconColor;
  final bool centerTitle;
  final VoidCallback? onBack;
  final bool hasLeading;
  final TextStyle? tittleStyle;
  final bool dividerBottom;
  final bool withShadow;
  final ShapeBorder? shape;
  final PreferredSizeWidget? bottom;

  @override
  String toString() {
    return 'AppBarParams{title: $title, action: $action, translateTitle: $translateTitle}';
  }
}
