import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:tuple/tuple.dart';

import '../../../../search/presentation/widgets/close_circle.dart';

class PriceFilter extends StatefulWidget {
  const PriceFilter({
    super.key,
  });

  @override
  State<PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  late final ValueNotifier<Tuple2<int ,int>> lowerAndUpperBound = ValueNotifier(Tuple2(100 , 1000));

  List<double> values = [100 , 1000];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0 , right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 20,
                  child: CustomPaint(
                    size: Size(1.sw - 50, ((1.sw - 50) *0.13157894736842105).toDouble()),
                    painter: RPSCustomPainter(),
                  ),
                ),
                Container(
                  //color: Colors.white,
                  height:   40,
                  child: FlutterSlider(
                    minimumDistance: 10,
                    values: [100 , 1000],
                    step: FlutterSliderStep(
                      step: 10,
                    ),
                    selectByTap: false,
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBarHeight: 1,
                      inactiveTrackBarHeight: 1,
                      activeTrackBar: BoxDecoration(
                        color: Color(0xff5D5C5D),
                      ),
                      inactiveTrackBar: BoxDecoration(
                        color: Color(0xff5D5C5D),
                      )
                    ),
                    handlerWidth: 40,
                    handlerHeight: 40,
                    centeredOrigin: false,

                    rightHandler: FlutterSliderHandler(
                      decoration: BoxDecoration(),
                      child: ValueListenableBuilder<Tuple2<int,int>>(
                          valueListenable: lowerAndUpperBound,
                          builder: (context , filterData , child) {
                            return Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: filterData.item2 < 1000 ? Color(0xffFF5F61) : Colors.white,
                                  border: Border.all(width: 0.5 ,color: Color(0xffC4C2C2)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 3,
                                        offset: Offset(0,3),
                                        color: Colors.black.withOpacity(0.05)
                                    )
                                  ]
                              ),
                            );
                          }
                      )
                    ),
                    handler: FlutterSliderHandler(
                        decoration: BoxDecoration(),
                      child: ValueListenableBuilder<Tuple2<int,int>>(
                        valueListenable: lowerAndUpperBound,
                        builder: (context , filterData , child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filterData.item1 > 100 ? Color(0xffFF5F61) : Colors.white,
                              border: Border.all(width: 0.5 ,color: Color(0xffC4C2C2)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  offset: Offset(0,3),
                                  color: Colors.black.withOpacity(0.05)
                                )
                              ]
                            ),
                          );
                        }
                      )
                    ),

                    rangeSlider: true,
                    max: 1000,
                    min: 100,
                    handlerAnimation: FlutterSliderHandlerAnimation(
                      scale: 1,
                      duration: Duration(milliseconds: 0)
                    ),
                    tooltip: FlutterSliderTooltip(
                      alwaysShowTooltip: false,
                      disabled: true,
                      disableAnimation: true
                    ),
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      print(handlerIndex);
                      print(lowerValue);
                      print(upperValue);
                      print(values);
                     lowerAndUpperBound.value = Tuple2(lowerValue.toInt() , upperValue.toInt());
                    },
                  ),
                ),
                ValueListenableBuilder<Tuple2<int , int>>(
                    valueListenable: lowerAndUpperBound,
                    builder: (context , filterData , child) {
                      return Positioned(
                          top: 40,
                          left: 0,
                          child: Row(
                        children: [
                          MyTextWidget('Min ${filterData.item1} ',
                            style: textTheme.caption?.rq.copyWith(
                                color: filterData.item1 > 100 ? Color(0xffFF5F61): Color(0xff505050)
                            ),
                          ),
                          MyTextWidget('USD',
                            style: textTheme.overline?.lq.copyWith(
                                color: filterData.item1 > 100 ? Color(0xffFF5F61): Color(0xff505050)
                            ),
                          ),
                        ],
                      ));
                    }
                ),
                ValueListenableBuilder<Tuple2<int , int>>(
                    valueListenable: lowerAndUpperBound,
                    builder: (context , filterData , child) {
                      return Positioned(
                          right: 0,
                          top: 40,
                          child: Row(
                            children: [
                              MyTextWidget('Max ${filterData.item2} ',
                                style: textTheme.caption?.rq.copyWith(
                                    color: filterData.item2 < 1000 ? Color(0xffFF5F61): Color(0xff505050)
                                ),
                              ),
                              MyTextWidget('USD',
                                style: textTheme.overline?.lq.copyWith(
                                    color: filterData.item2 < 1000 ? Color(0xffFF5F61): Color(0xff505050)
                                ),
                              ),
                            ],
                          ));
                    }
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  width: 1.sw - 50,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterSelectedMark(width: 20, height: 20),
                        SizedBox(
                          width: 10,
                        ),
                        MyTextWidget(
                          'Filter By Price',
                          style: context.textTheme.caption?.rq
                              .copyWith(color: Color(0xff505050), height: 15 / 12),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset(
                          AppAssets.registerInfoSvg,
                          color: Color(0xffD3D3D3),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        lowerAndUpperBound.value = Tuple2(100 , 1000);
                        setState(() {

                        });
                      },
                      child: CloseCircle(
                        width: 20,
                        height: 20,
                        borderColor: Color(0xff707070),
                        closeSvgColor: Color(0xffFF5F61),
                      ),
                    )
                  ],
                ),)
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {

  Path path_0 = Path();
  path_0.moveTo(size.width*0.03286579,size.height*0.7938000);
  path_0.cubicTo(size.width*0.05484474,size.height*0.7269000,size.width*0.05557368,size.height*0.7631800,size.width*0.08791842,size.height*0.7228200);
  path_0.cubicTo(size.width*0.1202632,size.height*0.6824600,size.width*0.1249447,size.height*0.6864600,size.width*0.1622447,size.height*0.6323200);
  path_0.cubicTo(size.width*0.1995447,size.height*0.5781800,size.width*0.2371237,size.height*0.5062000,size.width*0.2371237,size.height*0.5062000);
  path_0.lineTo(size.width*0.3129868,size.height*0.2484000);
  path_0.cubicTo(size.width*0.3129868,size.height*0.2484000,size.width*0.3321711,size.height*0.03188000,size.width*0.3759684,0);
  path_0.cubicTo(size.width*0.4197658,size.height*-0.03188000,size.width*0.4097237,size.height*0.02086000,size.width*0.4599158,size.height*0.09336000);
  path_0.cubicTo(size.width*0.5101079,size.height*0.1658600,size.width*0.5766947,size.height*0.2900000,size.width*0.5766947,size.height*0.2900000);
  path_0.lineTo(size.width*0.7031079,size.height*0.5062000);
  path_0.lineTo(size.width*0.7907395,size.height*0.6703600);
  path_0.cubicTo(size.width*0.7907395,size.height*0.6703600,size.width*0.8529500,size.height*0.7534200,size.width*0.9004316,size.height*0.7938000);
  path_0.cubicTo(size.width*0.9479132,size.height*0.8341800,size.width*0.9693789,size.height*0.7938000,size.width*0.9693789,size.height*0.7938000);
  path_0.lineTo(size.width,size.height*0.9904000);
  path_0.lineTo(0,size.height*0.9904000);
  path_0.arcToPoint(Offset(size.width*0.03286579,size.height*0.7938000),radius: Radius.elliptical(size.width*0.07457632, size.height*0.5667800),rotation: 0 ,largeArc: false,clockwise: true);
  path_0.close();

  Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
  paint_0_fill.color = Color(0xfff8f8f8).withOpacity(1.0);
  canvas.drawPath(path_0,paint_0_fill);

}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
return true;
}
}