import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/search/presentation/widgets/close_circle.dart';

class SearchHistoryChip extends StatelessWidget {
  const SearchHistoryChip(
      {super.key, required this.text, required this.onClickClose});

  final String text;
  final void Function() onClickClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => BlocProvider.of<HomeBloc>(context)
                    .add(GetSearchREsultEvent(searchTitle: text)),
                child: Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      text,
                      style: context.textTheme.bodyText2?.rq
                          .copyWith(height: 18 / 14, color: Color(0xff8D8D8D)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              )
            ],
          ),
          GestureDetector(
            onTap: onClickClose,
            child: Container(
              width: 40,
              height: 40,
              color: Colors.transparent, // don't remove it
              child: Align(
                alignment: Alignment.centerRight,
                child: CloseCircle(
                    width: 12,
                    height: 12,
                    borderColor: Color(0xffC4C2C2),
                    closeSvgColor: Color(0xffFF5F61)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
