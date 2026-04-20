import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProductListingLoading extends StatelessWidget {
  const ProductListingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 200.w / 350.w,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 15.h,
        ),
        delegate: SliverChildBuilderDelegate(childCount: 8, (
          BuildContext context,
          int index,
        ) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color(0xff000000).withOpacity(0.4),
                          offset: Offset(0, 3.h),
                          blurRadius: 6.h,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 275.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color(0xff000000).withOpacity(0.6),
                          offset: Offset(0, 3.h),
                          blurRadius: 6.h,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 70.h,
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
                                ? 15.w
                                : null,
                            right: index == 1
                                ? 0
                                : index == 3
                                ? 15.w
                                : null,
                            child: CircleAvatar(
                              radius: index == 4
                                  ? 20.r
                                  : index < 2
                                  ? 12.r
                                  : 15.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
