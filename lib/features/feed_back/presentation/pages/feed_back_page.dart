import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/app_elvated_button.dart';
import '../../../app/my_text_widget.dart';
import '../widgets/request_and_response_card.dart';
import '../widgets/search_app_bar.dart';

class FeedBackScreen extends StatelessWidget {
  FeedBackScreen({Key? key, required this.showRequests}) : super(key: key);
  static String routeName = 'FeedBackScreen';
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late List<Map<String, dynamic>> data;
  List<Map<String, dynamic>> searchedData = [];
  ValueNotifier<bool> rebuild = ValueNotifier(false);
  final bool showRequests;
  @override
  Widget build(BuildContext context) {
    data = _prefsRepository.getRequestsData();
    searchedData.addAll(data);
    searchedData = searchedData.reversed.toList();

    if (showRequests) {
      searchedData
          .removeWhere((element) => element.containsKey('flutter_error'));
    } else {
      searchedData
          .removeWhere((element) => !element.containsKey('flutter_error'));
    }
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child: SearchRequestsAppBar(
            onSearch: (String searchText) {
              if (searchText.isEmpty) {
                searchedData.addAll(data);
                if (showRequests) {
                  searchedData.removeWhere(
                      (element) => element.containsKey('flutter_error'));
                } else {
                  searchedData.removeWhere(
                      (element) => !element.containsKey('flutter_error'));
                }
                rebuild.value = !rebuild.value;
                return;
              }
              searchedData.clear();
              for (var element in data) {
                String text = "";
                element.forEach((key, value) {
                  if (value != null) {
                    text +=
                        (key.toLowerCase() + value.toString().toLowerCase());
                  }
                });
                if (text.trim().contains(searchText.toLowerCase())) {
                  searchedData.add(element);
                }
                if (showRequests) {
                  searchedData.removeWhere(
                      (element) => element.containsKey('flutter_error'));
                } else {
                  searchedData.removeWhere(
                      (element) => !element.containsKey('flutter_error'));
                }
              }
              rebuild.value = !rebuild.value;
            },
          )),
      body: Stack(
        children: [
          Column(
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: rebuild,
                  builder: (context, rebuildValue, _) {
                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(0),
                        itemCount: searchedData.length,
                        itemBuilder: (context, index) => Stack(
                          children: [
                            RequestAndResponseCard(
                              data: searchedData[index],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: () {
                                  _prefsRepository.removeRequestFromCache(
                                      searchedData[index]);
                                  searchedData.remove(searchedData[index]);
                                  rebuild.value = !rebuild.value;
                                },
                                child: Transform.translate(
                                  offset: Offset(-10.w, 0),
                                  child: SizedBox(
                                    width: 25.w,
                                    height: 25.w,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: context.colorScheme.tertiary,
                                          shape: BoxShape.circle),
                                      child: Center(
                                        child: MyTextWidget('X',
                                            style: context
                                                .textTheme.titleLarge!.rr
                                                .copyWith(
                                                    color: context
                                                        .colorScheme.white)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        separatorBuilder: (context, index) => SizedBox(
                          height: 11.h,
                        ),
                      ),
                    );
                  }),
              85.verticalSpace,
            ],
          ),
          Transform.translate(
            offset: Offset(0, -20.h),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                child: AppElevatedButton(
                    text: 'Clear',
                    onPressed: () {
                      _prefsRepository.clearAllRequests();
                      searchedData.clear();
                      rebuild.value = !rebuild.value;
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
