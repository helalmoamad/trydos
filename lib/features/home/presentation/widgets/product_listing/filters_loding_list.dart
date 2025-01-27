import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class FiltersLoadingListPage extends StatefulWidget {
  const FiltersLoadingListPage({super.key, required this.countOfListInPage});

  final int countOfListInPage;

  @override
  State<FiltersLoadingListPage> createState() => _FiltersLoadingListPageState();
}

class _FiltersLoadingListPageState extends State<FiltersLoadingListPage> {
  List<String> titles = [
    '${LocaleKeys.categories.tr()}',
    '${LocaleKeys.Brands.tr()}',
    '${LocaleKeys.colors.tr()}',
    '${LocaleKeys.offer.tr()}',
    '${LocaleKeys.sizes.tr()}',
    '${LocaleKeys.prices.tr()}',
  ];

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
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
                      Text('${LocaleKeys.filter_by.tr()} ${titles[index]}'),
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
