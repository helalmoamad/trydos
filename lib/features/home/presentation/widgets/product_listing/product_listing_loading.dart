import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProductListingLoading extends StatelessWidget {
  const ProductListingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 200.w / 350,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: 8,
          (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: Stack(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff000000).withOpacity(0.4),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          )
                        ],
                      )),
                      Container(
                          height: 275,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff000000).withOpacity(0.6),
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              )
                            ],
                          )),
                      Positioned(
                        bottom: 70,
                        left: 60.w,
                        child: SizedBox(
                          width: 100.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: List.generate(
                                5,
                                (index) => Positioned(
                                      left: index == 0
                                          ? 0
                                          : index == 2
                                              ? 15
                                              : null,
                                      right: index == 1
                                          ? 0
                                          : index == 3
                                              ? 15
                                              : null,
                                      child: CircleAvatar(
                                        radius: index == 4
                                            ? 20
                                            : index < 2
                                                ? 12
                                                : 15,
                                      ),
                                    )),
                          ),
                        ),
                      )
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }
}
