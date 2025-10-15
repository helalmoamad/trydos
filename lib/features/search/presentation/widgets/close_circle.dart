import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../common/constant/design/assets_provider.dart';

class CloseCircle extends StatelessWidget {
  const CloseCircle(
      {super.key,
      required this.width,
      required this.height,
      required this.borderColor,
      required this.closeSvgColor});

  final double width;
  final double height;
  final Color borderColor;
  final Color closeSvgColor;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xffF8F8F8),
          border: Border.all(width: 0.5, color: borderColor)),
      child: Center(
        child: SvgPicture.asset(
          AppAssets.closeSvg,
          // ignore: deprecated_member_use
          color: closeSvgColor,
          width: width / 2,
          height: height / 2,
        ),
      ),
    );
  }
}
