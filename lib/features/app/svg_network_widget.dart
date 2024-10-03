import 'package:flutter/material.dart';
import 'package:flutter_svg_image/flutter_svg_image.dart';

import 'my_cached_network_image.dart';
class SvgNetworkWidget extends StatefulWidget {
  const SvgNetworkWidget(
      {super.key, this.width, this.height, required this.svgUrl, this.color});

  final double? width;
  final double? height;
  final String svgUrl;
  final Color? color;

  @override
  State<SvgNetworkWidget> createState() => _SvgNetworkWidgetState();
}

class _SvgNetworkWidgetState extends State<SvgNetworkWidget> {


  @override
  Widget build(BuildContext context) {
    if(widget.svgUrl == 'null'){
      return SizedBox(
        height: widget.height,
        width: widget.width,
      );
    }
    return Image(
      fit: BoxFit.cover,
      height: widget.height,
      errorBuilder: (context , _ , st){
        return SizedBox.shrink();
      },
      //width: widget.width,
      image: SvgImage.cachedNetwork(
        widget.svgUrl,
        cacheManager: CustomCacheManager(),
      ),
    );
  }
}
