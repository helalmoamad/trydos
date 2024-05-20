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
    // List<String> list;
    // String url = '';
    // list = svgUrl.split('upload');
    // url = list[0] + 'upload/c_scale';
    // if (height != null) {
    //   url += 'h_${2 * height!.toInt()}';
    // }
    // if (width != null) {
    //   url += 'w_${2 * width!.toInt()}';
    // }
    // url += list[1];
    print('svgUrl $svgUrl');
    return SvgPicture.network(
      svgUrl,
      height: height,
      width: width,
      color: color,
    );
  }
}
