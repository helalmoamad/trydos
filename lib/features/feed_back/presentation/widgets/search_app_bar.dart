
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../service/language_service.dart';
import '../../../app/app_default_container.dart';
import 'back_button.dart';

class SearchRequestsAppBar extends StatefulWidget {
  const SearchRequestsAppBar({Key? key, required this.onSearch}) : super(key: key);

  final void Function(String text) onSearch;

  @override
  State<SearchRequestsAppBar> createState() => _SearchRequestsAppBarState();
}

class _SearchRequestsAppBarState extends ThemeState<SearchRequestsAppBar> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    searchController.addListener(() {
      widget.onSearch.call(searchController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade200,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(17.sp),
        ),
      ),
      elevation: 0,
      leadingWidth: 50.w,
      leading: Row(
        children: [
          SizedBox(
            width: 7.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0.w),
            child: const DefaultBackButton(),
          ),
        ],
      ),
      title: DefaultContainer(
        // width: isBackButtonEnabled ? 275.w : 315.w,
        height: 40.h,
        borderColor: Colors.transparent,
        childWidget: Stack(
          children: [
            DefaultContainer(
              // width: isBackButtonEnabled ? 245.w : 299.w,
              height: 37.5.h,
              radius: 25.sp,
              backColor: Colors.white.withOpacity(0.6),
              borderColor: Colors.transparent,
              childWidget: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w)
                      .copyWith(bottom: 10.h),
                  child: TextFormField(
                    cursorColor: colorScheme.tertiary,
                    controller: searchController,
                    decoration: const InputDecoration(
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: LanguageService.languageCode== 'en' ? 0.0 : null,
              left:  LanguageService.languageCode== 'en' ? 0.0 : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18.h,
                    backgroundColor: colorScheme.tertiary,
                    child: Center(
                      child:
                      SvgPicture.asset(AppAssets.searchSvg,color: colorScheme.primary,height: 14.h),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
