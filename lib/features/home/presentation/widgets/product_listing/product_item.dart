import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_3d_slider.dart';
import 'package:tuple/tuple.dart';


class ProductItem extends StatefulWidget {
  const ProductItem({super.key, required this.setThisEnabled, required this.slidingModeItem, required this.itemIndex});
  final void Function(int,int) setThisEnabled;
  final Tuple2<int,int> slidingModeItem;
  final int itemIndex;
  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final PageController pageController = PageController();
  List<Color> colors = [
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.grey,
    Colors.blue,
    Colors.brown,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.grey,
    Colors.blue,
    Colors.brown,
    // Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 350,
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff000000).withOpacity(0.1),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                    'assets/product_listing_background_blur_image.png',
                    fit: BoxFit.cover)),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                blendMode: BlendMode.overlay,
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xfffafafa)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffffffff).withOpacity(0.8)),
                ),
              ),
            ),
          ),
           ProductListing3DSlider(slidingModeItem : widget.slidingModeItem , itemIndex : widget.itemIndex , setThisEnabled: widget.setThisEnabled),
        ]);
  }
}

// class MyStackItem extends StatelessWidget {
//   const MyStackItem({super.key, required this.color, required this.x, required this.scale});
//   final Color color;
//   final double x;
//   final double scale;
//   @override
//   Widget build(BuildContext context) {
//     print('x: $x');
//     return Transform.translate(
//       offset: Offset(x, 0),
//       child: Transform.scale(
//         scale: scale,
//         child: Container(
//           width: 170,
//           height: 200,
//           color: color,
//         ),
//       ),
//     );
//   }
// }
