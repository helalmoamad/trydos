import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class BadgesList extends StatelessWidget {
  final List<Label>? lable;
  const BadgesList({super.key, required this.lable});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return lable.isNullOrEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 14,
            child: ListView.separated(
                padding: const EdgeInsets.only(right: 20, left: 20),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SvgPicture.network(
                        lable![index].icon!.filePath!,
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        lable![index].label!,
                        style: context.textTheme.titleMedium?.rq.copyWith(
                            height: 1.27, color: const Color(0xff8D8D8D)),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 9,
                  );
                },
                itemCount: lable!.length),
          );
  }
}
