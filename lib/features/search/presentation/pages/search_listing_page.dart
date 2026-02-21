/*import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/form_state_mixin.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/search/presentation/widgets/search_Circle_boutique.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_brand.dart';
import 'package:trydos/features/search/presentation/widgets/search_circle_category.dart';

import 'package:trydos/features/search/presentation/widgets/trendig_section.dart';
import 'dart:ui' as ui;
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/app_widgets/app_text_field.dart';
import '../../../app/app_widgets/tabs_bar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/blocs/app_bloc/app_state.dart';
import '../../../home/presentation/manager/home_bloc.dart';
import '../widgets/close_circle.dart';
import '../widgets/search_chip.dart';
import '../widgets/search_history.dart';
import '../widgets/search_result.dart';

class SearchListingPage extends StatefulWidget {
  const SearchListingPage(
      {super.key,
      required this.buildSearchResult,
      required this.hideTrendingAndHistory,
      required this.controller});
  final TextEditingController controller;

  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> hideTrendingAndHistory;

  @override
  State<SearchListingPage> createState() => _SearchListingPageState();
}

class _SearchListingPageState extends ThemeState<SearchListingPage> {
  final ScrollController scrollController = ScrollController();
  late final AppBloc appBloc;
  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (pop) {
          appBloc.add(ChangeBasePage(0));
          appBloc.add(HideBottomNavigationBar(false));
        },
        child: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(child: 10.verticalSpace),
            SliverToBoxAdapter(
              child: SearchResult(
                controller: widget.controller,
              ),
            ),
          ],
        ));
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
*/