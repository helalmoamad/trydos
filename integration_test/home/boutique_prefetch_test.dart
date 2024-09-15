import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test prefetch boutiques data for the visible boutiques when home page is oppened',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      /////////////  Register As Guest  /////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////// Find Boutiques HomePageCard //////////////
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKey.boutiquesSuccessStatusKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiquesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Boutiques HomePageCard2 Success',
        failedMessage: 'Find Boutiques HomePageCard2 failed',
      );
      //////////// get all visible boutiques slugs ////////////////
      int index = 0;
      List<String> boutiqueSlugs = [];
      while (true) {
        Finder boutiqueCardWidget =
            find.byKey(Key('${WidgetsKey.boutiqueCardKey}$index'));

        try {
          expect(boutiqueCardWidget, findsOneWidget);
          ///////////////////
          boutiqueSlugs.add(
            tester.widget<HomePageCard2>(boutiqueCardWidget).boutniqe.slug ??
                '',
          );
          //////////////////
          print(
              '////////// boutiquesSlug $index : ${boutiqueSlugs[index]} /////////');
          //////////////////
          index++;
        } catch (e) {
          print('////////// No boutiquesSlug is visible /////////');
          break;
        }
      }
      print(
          '////////// boutiquesSlugs length : ${boutiqueSlugs.length} /////////');
      HomeBloc homeBloc = GetIt.I<HomeBloc>();
      HomeState homeState = homeBloc.state;
      ///////////////// check if visible boutiques are pre-fetched and enter each boutique  ////////////////
      for (int i = 0; i < boutiqueSlugs.length; i++) {
        bool check =
            homeState.boutiquesThatDidPrefetch[boutiqueSlugs[i]] == true;
        expect(check, isTrue);
        /////////////////////////////////////////////////
        Finder boutiqueCardWidget =
            find.byKey(Key('${WidgetsKey.boutiqueCardKey}$i'));

        Finder boutiqueProductListingLoadingWidget =
            find.byKey(Key(WidgetsKey.boutiqueProductListingLoadingKey));

        await tester.tap(boutiqueCardWidget);
        await tester.pump();

        await GlobalTestFunctions.findNoWidget(
          tester: tester,
          actual: boutiqueProductListingLoadingWidget,
          withDelayAndPumpAndSettle: false,
          successMessage:
              'Find No boutique Product Listing Loading Widget  Success',
          failedMessage:
              'Find No boutique Product Listing Loading Widget failed',
        );

        final Finder productListFilterWidget =
            find.byKey(Key(WidgetsKey.productListFilterKey));
        ///////////////////////////////
        await GlobalTestFunctions.findWidget(
          tester: tester,
          actual: productListFilterWidget,
          withDelayAndPumpAndSettle: false,
          successMessage: 'Find product List Filter Widget  Success',
          failedMessage: 'Find product List Filte Widget failed',
        );
        //////////////////////////////
        await tester.pumpAndSettle();

        ///////////  test the data variable in state for filters and products  not null  /////////
      }
      ///////////////////////////////////
    },
  );
}
