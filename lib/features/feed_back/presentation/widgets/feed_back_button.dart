//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:trydos/config/theme/typography.dart';
// import 'package:trydos/core/utils/extensions/build_context.dart';
//
// import '../../../../common/constant/design/assets_provider.dart';
// import '../../../../core/utils/theme_state.dart';
// import '../pages/feed_back_page.dart';
// class FeedBackButton extends StatefulWidget {
//   const FeedBackButton({Key? key}) : super(key: key);
//
//   @override
//   State<FeedBackButton> createState() => _FeedBackButtonState();
// }
//
// class _FeedBackButtonState extends ThemeState<FeedBackButton> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (_)=>FeedBackScreen()));
//       },
//       child: Container(
//         height: 65.h,
//         decoration: BoxDecoration(
//           color: const Color(0xffffffff),
//           border: Border.all(width: 1.0, color: context.colorScheme.tertiary),
//         ),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 30.w,
//             ),
//             SizedBox(
//               width: 28.w,
//               child: Padding(
//                 padding: const EdgeInsets.all(1.0),
//                 child:  SvgPicture.asset(AppAssets.supportSvg)
//                     ),
//               ),
//             SizedBox(
//               width: 26.w,
//             ),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   MyTextWidget(
//                     '',
//                     style:textTheme.bodySmall?.rr.copyWith(
//                       color: colorScheme.tertiary
//                     )
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
