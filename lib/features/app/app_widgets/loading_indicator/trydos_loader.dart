import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../common/test_utils/test_var.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import 'edited_spinkit_three_bounce.dart';

class TrydosLoader extends StatelessWidget {
  TrydosLoader({
    Key? key,
    double? size,
    Color? color,
  })  : _widget = _TripperLoaderCircle(
          size: size,
          color: color,
          key: TestVariables.kTestMode
              ? Key(WidgetsKey.loadingAfterSearchKey)
              : null,
        ),
        super(key: key);

  TrydosLoader.spinKitThreeBounce({
    Key? key,
    double? size,
    Color? color,
  })  : _widget = _TripperLoaderThreeBounce(size: size, color: color, key: key),
        super(key: key);

  TrydosLoader.spinKitThreeBounceEditing({
    Key? key,
    double? size,
    Color? color,
  })  : _widget = _TripperLoaderThreeBounceEditing(
            size: size, color: color, key: key),
        super(key: key);

  final Widget _widget;

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

class _TripperLoaderCircle extends StatelessWidget {
  const _TripperLoaderCircle({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: color ?? context.theme.colorScheme.primary,
      size: size ?? 40.r,
    );
  }
}

class _TripperLoaderThreeBounce extends StatelessWidget {
  const _TripperLoaderThreeBounce({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? context.theme.colorScheme.primary,
      size: size ?? 20.r,
    );
  }
}

class _TripperLoaderThreeBounceEditing extends StatelessWidget {
  const _TripperLoaderThreeBounceEditing({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return EditedSpinKitThreeBounce(
      color: color ?? context.theme.colorScheme.inversePrimary,
      size: size ?? 24.0,
    );
  }
}
