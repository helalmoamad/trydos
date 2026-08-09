import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';

class TrydosShimmerLoadingStateless extends StatelessWidget {
  const TrydosShimmerLoadingStateless({
    super.key,
    required this.width,
    this.radius = 15,
    required this.logoTextWidth,
    required this.height,
    required this.logoTextHeight,
    this.circleDimensions,
  });

  final double width, logoTextWidth;
  final double height, logoTextHeight;
  final double? circleDimensions;
  final double radius;

  /// أصغر صندوق يتّسع لنصّ الشعار مع الدوائر.
  static const double _minimumSizeForLogo = 70;

  /// أصغر صندوق تُرى فيه العلامة (الدائرة) — تحته يبقى الرمادي وحده.
  static const double _minimumSizeForMark = 20;

  @override
  Widget build(BuildContext context) {
    final double shortestSide = width < height ? width : height;

    final BoxDecoration decoration = BoxDecoration(
      color: const Color(0xffE6E6E6),
      borderRadius: BorderRadius.circular(radius),
    );

    // أصغر من أن تُرى فيه أي علامة
    if (shortestSide < _minimumSizeForMark) {
      return Container(
        key: const ValueKey("shimmer_stateless"),
        width: width,
        height: height,
        decoration: decoration,
      );
    }

    // متوسّط: العلامة وحدها بلا نصّ الشعار (النصّ لا يُقرأ في هذا الحجم)
    if (width < _minimumSizeForLogo || height < _minimumSizeForLogo) {
      final double markSize = (shortestSide * 0.32).clamp(6.0, 16.0);
      return Container(
        key: const ValueKey("shimmer_stateless"),
        width: width,
        height: height,
        decoration: decoration,
        child: Center(
          child: Container(
            width: markSize,
            height: markSize,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B6B),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // القياسات تتبع الصندوق بدل أن تكون ثابتة، مع سقف يمنع تضخّمها
    final double circleSize = (circleDimensions ?? (height * 0.08)).clamp(
      6.0,
      18.0,
    );
    final double dotSize = (circleSize * 0.22).clamp(2.0, 4.0);

    return Container(
      key: const ValueKey("shimmer_stateless"),
      width: width,
      height: height,
      decoration: decoration,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 2.5),
                Transform.translate(
                  offset: const Offset(-2, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStaticDot(dotSize),
                      const SizedBox(width: 2),
                      _buildStaticDot(dotSize + 1),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 10),
            SvgPicture.asset(
              AppAssets.trydosTextSvg,
              // لا يتجاوز الشعار حدود الصندوق مهما مُرّر إليه
              width: logoTextWidth.clamp(0.0, width * 0.7),
              height: logoTextHeight.clamp(0.0, height * 0.3),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStaticDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }
}
