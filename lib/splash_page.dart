import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'core/domin/repositories/prefs_repository.dart';
import 'features/app/blocs/app_bloc/app_event.dart';
import 'features/calls/presentation/utils/bg_terminated_call_utils.dart';
import 'features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'features/story/presentation/bloc/story_bloc.dart';
import 'service/firebase_analytics_service/analytics_const/analytics_screens.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late HomeBloc homeBloc;
  late AuthBloc authBloc;
  late AppBloc appBloc;
  late BoutiqueBloc boutiqueBloc;
  late CategoryBloc categoryBloc;

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    categoryBloc = BlocProvider.of<CategoryBloc>(context);

    appBloc.add(ChangeTab(-1));
    GetIt.I<HomeBloc>().add(GetAllowedCountriesEvent());
    BlocProvider.of<StoryBloc>(context)
        .add(GetStoryEvent(withPaginition: false));
    if ((prefsRepository.isFoundDataCashed ?? false)) {
      boutiqueBloc.add(GetProductsWithFiltersEvent(
          boutiqueSlug: "search",
          cashedOrginalBoutique: true,
          fromSearch: true,
          getWithPagination: false,
          offset: 1));
      boutiqueBloc.add(ChangeAppliedFiltersEvent(
          boutiqueSlug: 'search',
          filtersAppliedByUser: null,
          resetAppliedFilters: true));
      boutiqueBloc.add(ChangeSelectedFiltersEvent(
        resetChoosedFilters: true,
        requestToUpdateFilters: true,
        fromHomePageSearch: true,
        boutiqueSlug: 'search',
        filtersChoosedByUser: null,
      ));
      if ((prefsRepository.chatToken?.length ?? 0) > 10 &&
          (prefsRepository.myChatName != prefsRepository.myMarketName &&
              !(prefsRepository.myMarketName.isNullOrEmpty))) {
        authBloc.add(
            UpdateChatUserNameEvent(name: prefsRepository.myMarketName ?? ""));
      }
      if ((prefsRepository.storiesToken?.length ?? 0) > 10 &&
          (prefsRepository.myStoriesName != prefsRepository.myMarketName &&
              !(prefsRepository.myMarketName.isNullOrEmpty))) {
        authBloc.add(
            UpdateStoriesUserEvent(name: prefsRepository.myMarketName ?? ""));
      }
      categoryBloc
          .add(GetMainCategoriesEvent(getWithPrefech: true, context: context));
      GetIt.I<BoutiqueBloc>().add(
          GetProductWithFiltersWithoutCancelingPreviousEvents(
              categorySlugs: [],
              cashedOrginalBoutique: true,
              fromHomePageSearch: false,
              boutiqueSlug: "*featured*",
              category: null,
              searchText: null));
      GetIt.I<BoutiqueBloc>().add(
          GetProductWithFiltersWithoutCancelingPreviousEvents(
              categorySlugs: [],
              cashedOrginalBoutique: true,
              fromHomePageSearch: false,
              boutiqueSlug: "*flashDeal*",
              category: null,
              searchText: null));
      homeBloc.add(GetCurrencyForCountryEvent());
      Future.delayed(Duration(seconds: 1), () {
        //  homeBloc.add(GeColorsAndSizesForSearchEvent());
        if ((prefsRepository.marketToken?.length ?? 0) > 10) {
          homeBloc.add(GetProductsListInCartEvent());
          homeBloc.add(GetCartItemEvent());

          homeBloc.add(GetNotificationTypeProductEvent());
          homeBloc.add(GetFirebaseSettingForNotificationEvent());
          homeBloc.add(GetPopularSearchItemEvent());
        }
      });
    }

    checkAndNavigationCallingPage(context, fromTerminated: true,
        whereToNavigationAfterCheck: () {
      context.go(prefsRepository.marketToken == null
          ? GRouter.config.applicationRoutes.kRegistrationPage
          : GRouter.config.applicationRoutes.kBasePage);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    FirebaseAnalyticsService.logScreen(
        screen: AnalyticsScreensConst.splashScreen);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        navigationToSinglePageChat(state.chatToNavigateFromTerminated!);
      },
      listenWhen: (p, c) =>
          p.chatToNavigateFromTerminated != c.chatToNavigateFromTerminated,
      child: Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: Center(child: logo)),
    );
  }
}
