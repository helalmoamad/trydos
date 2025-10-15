import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_image/flutter_svg_image.dart';

class SvgNetworkWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String svgUrl;
  final Color? color;

  const SvgNetworkWidget({
    Key? key,
    this.width,
    this.height,
    required this.svgUrl,
    this.color,
  }) : super(key: key);

  @override
  State<SvgNetworkWidget> createState() => _SvgNetworkWidgetState();
}

class _SvgNetworkWidgetState extends State<SvgNetworkWidget>
    with AutomaticKeepAliveClientMixin {
  late String currentUrl;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.svgUrl;
  }

  @override
  void didUpdateWidget(covariant SvgNetworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgUrl != widget.svgUrl) {
      setState(() {
        currentUrl = widget.svgUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (currentUrl == 'null' || currentUrl.isEmpty) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
      );
    }

    try {
      return SizedBox(
        height: widget.height,
        child: Image(
          fit: BoxFit.cover,
          image: SvgImage.cachedNetwork(currentUrl,
              width: widget.width, height: widget.height),
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        ),
      );
    } catch (e) {
      return SizedBox(
        height: widget.height,
        child: SvgPicture.network(currentUrl,
            width: widget.width, height: widget.height),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
