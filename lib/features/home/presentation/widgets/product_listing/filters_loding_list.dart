import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/constant.dart';

class FiltersLoadingListPage extends StatefulWidget {
  const FiltersLoadingListPage({super.key, required this.countOfListInPage});

  final int countOfListInPage;

  @override
  State<FiltersLoadingListPage> createState() => _FiltersLoadingListPageState();
}

class _FiltersLoadingListPageState extends State<FiltersLoadingListPage> {
  List<String> titles = [
    'Categories',
    'Brands',
    'Colors',
    'Offers',
    'Sizes',
    'Prices',
  ];

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: ListView.builder(
            itemCount: widget.countOfListInPage,
            padding: EdgeInsetsDirectional.only(start: 15),
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Center(child: SvgPicture.asset(AppAssets.filtersSvg)),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Filter By ${titles[index]}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 70,
                    child: index == 5
                        ? FlutterSlider(
                            values: [1, 1000],
                            max: 1000,
                            min: 1,
                            disabled: true,
                            handlerWidth: 40,
                            handlerHeight: 40,
                            handler: FlutterSliderHandler(),
                            rightHandler: FlutterSliderHandler(),
                            rangeSlider: true,
                          )
                        : ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (ctx, index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                            itemBuilder: (ctx, index) {
                              return CircleAvatar(
                                radius: 35,
                              );
                            },
                            itemCount: 6,
                          ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              );
            }));
  }
}
