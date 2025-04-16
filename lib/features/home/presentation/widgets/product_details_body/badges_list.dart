import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

class BadgesList extends StatelessWidget {
  final List<Label>? lable;
  const BadgesList({super.key, required this.lable});

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
    return SizedBox(
      height: 14,
      child: ListView.separated(
          padding: EdgeInsets.only(right: 20, left: 20),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.network(
                  lable![index].icon!.filePath!,
                  width: 12,
                  height: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                MyTextWidget(
                  lable![index].label!,
                  style: context.textTheme.titleMedium?.rq
                      .copyWith(height: 1.27, color: Color(0xff8D8D8D)),
                )
              ],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 9,
            );
          },
          itemCount: lable!.length),
    );
  }
}
