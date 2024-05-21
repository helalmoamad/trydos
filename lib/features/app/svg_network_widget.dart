import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgNetworkWidget extends StatelessWidget {
  const SvgNetworkWidget(
      {super.key, this.width, this.height, required this.svgUrl, this.color});

  final double? width;
  final double? height;
  final String svgUrl;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      svgUrl,
      height: height,
      width: width,
      color: color,
    );
  }
}
