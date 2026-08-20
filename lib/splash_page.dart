import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/string.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
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
import 'core/domin/repositories/prefs_repository.dart';
import 'features/app/blocs/app_bloc/app_event.dart';
import 'features/calls/presentation/utils/bg_terminated_call_utils.dart';
import 'features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'features/story/presentation/bloc/story_bloc.dart';

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
    LastPagesTracker.push("Splash Page");
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    categoryBloc = BlocProvider.of<CategoryBloc>(context);

    appBloc.add(ChangeTab(-1));
    boutiqueBloc.add(
      AddCurrentMainCategoryTapedEvent(currentMainCategoryTaped: "Empty"),
    );

    GetIt.I<HomeBloc>().add(GetAllowedCountriesEvent());
    BlocProvider.of<StoryBloc>(
      context,
    ).add(const GetStoryEvent(withPaginition: false));
    if ((prefsRepository.isFoundDataCashed ?? false)) {
      boutiqueBloc.add(
        GetProductsWithFiltersEvent(
          boutiqueSlug: "search",
          cashedOrginalBoutique: true,
          fromSearch: true,
          offset: 1,
        ),
      );
      boutiqueBloc.add(
        ChangeAppliedFiltersEvent(
          boutiqueSlug: 'search',
          resetAppliedFilters: true,
        ),
      );
      boutiqueBloc.add(
        ChangeSelectedFiltersEvent(
          resetChoosedFilters: true,
          fromHomePageSearch: true,
          boutiqueSlug: 'search',
        ),
      );
      /* if ((prefsRepository.chatToken?.length ?? 0) > 10 &&
          (prefsRepository.myChatName != prefsRepository.myMarketName &&
              !(prefsRepository.myMarketName.isNullOrEmpty))) {
        authBloc.add(
            UpdateChatUserNameEvent(name: prefsRepository.myMarketName ?? ""));
      }*/
      /*  if ((prefsRepository.storiesToken?.length ?? 0) > 10 &&
          (prefsRepository.myStoriesName != prefsRepository.myMarketName &&
              !(prefsRepository.myMarketName.isNullOrEmpty))) {
        authBloc.add(
            UpdateStoriesUserEvent(name: prefsRepository.myMarketName ?? ""));
      }*/
      categoryBloc.add(const GetMainCategoriesEvent());
      GetIt.I<BoutiqueBloc>().add(
        const GetProductWithFiltersWithoutCancelingPreviousEvents(
          categorySlugs: [],
          cashedOrginalBoutique: true,
          boutiqueSlug: "*featured*",
        ),
      );
      GetIt.I<BoutiqueBloc>().add(
        const GetProductWithFiltersWithoutCancelingPreviousEvents(
          categorySlugs: [],
          cashedOrginalBoutique: true,
          boutiqueSlug: "*recommended*",
        ),
      );
      GetIt.I<BoutiqueBloc>().add(
        const GetProductWithFiltersWithoutCancelingPreviousEvents(
          categorySlugs: [],
          cashedOrginalBoutique: true,
          boutiqueSlug: "*flashDeal*",
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        //  homeBloc.add(GeColorsAndSizesForSearchEvent());
        if ((prefsRepository.marketToken?.length ?? 0) > 10) {
          //.add(GetProductsListInCartEvent());
          homeBloc.add(const GetCartItemEvent());

          homeBloc.add(const GetNotificationTypeProductEvent());
          homeBloc.add(const GetFirebaseSettingForNotificationEvent());
          homeBloc.add(const GetPopularSearchItemEvent());
        }
      });
    }

    checkAndNavigationCallingPage(
      context,
      fromTerminated: true,
      whereToNavigationAfterCheck: () {
        print(
          "SSSSSSSSSSSSSSSSSSSSSSS*///*/*/S${prefsRepository.marketToken.isNullOrEmpty}",
        );
        context.go(
          prefsRepository.marketToken.isNullOrEmpty
              ? GRouter.config.applicationRoutes.kRegistrationPage
              : GRouter.config.applicationRoutes.kBasePage,
        );
      },
    );
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    /*if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: AnalyticsButtonsEventNameConst.WEl,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': AuthScreenConst.WELCOME_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      //////////
      _eventLogged = true;
    }*/

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        navigationToSinglePageChat(
          state.chatToNavigateFromTerminated!,
          state.senderInfo!,
        );
      },
      listenWhen: (p, c) =>
          p.chatToNavigateFromTerminated != c.chatToNavigateFromTerminated,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: Center(child: logo),
      ),
    );
  }
}
