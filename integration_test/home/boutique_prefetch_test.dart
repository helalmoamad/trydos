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

  Future<void> enterBoutiqueAndCheckIfPreFetched({
    required WidgetTester tester,
    required int boutiqueIndex,
    required HomeState homeState,
  }) async {
    Finder boutiqueCardWidget =
        find.byKey(Key('${WidgetsKey.boutiqueCardKey}$boutiqueIndex'));

    Offset topLeft = tester.getTopLeft(boutiqueCardWidget);

    await tester.tapAt(topLeft);

    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));
    Finder boutiqueProductListingLoadingWidget =
        find.byKey(Key(WidgetsKey.boutiqueProductListingLoadingKey));
    // ///////////  no loading  /////////
    await GlobalTestFunctions.findNoWidget(
      tester: tester,
      actual: boutiqueProductListingLoadingWidget,
      withDelayAndPumpAndSettle: false,
      successMessage:
          'Find No boutique Product Listing Loading Widget  Success',
      failedMessage: 'Find No boutique Product Listing Loading Widget failed',
    );
    // ///////////  test the data in state for filters and products  /////////
    expect(homeState.getProductListingWithFiltersPaginationModels, isNotNull);

    expect(homeState.getProductListingWithFiltersPaginationModels,
        isNot(equals({})));

    expect(homeState.getProductFiltersModel, isNotNull);

    expect(homeState.getProductFiltersModel, isNot(equals({})));
    // ///////////  Find product List and filters  /////////
    Finder productListFilterWidget =
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
    final Finder productsList = find.byKey(
      Key(WidgetsKey.productsListKey),
    );
    await GlobalTestFunctions.findWidget(
      tester: tester,
      actual: productsList,
      withDelayAndPumpAndSettle: false,
      successMessage: 'Find productsList  Success',
      failedMessage: 'Find productsList  failed',
    );
    //////////////////////////////
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    ////////////// Go Back ////////////////
    Finder appBarGoBackArrow = find.byKey(Key(WidgetsKey.appBarGoBackArrowKey));
    await tester.tap(appBarGoBackArrow);
    await tester.pumpAndSettle();
  }

  group(
    'Test prefetch boutiques',
    () {
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
                tester
                        .widget<HomePageCard2>(boutiqueCardWidget)
                        .boutique
                        .slug ??
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
          await Future.delayed(const Duration(seconds: 2));
          HomeBloc homeBloc = GetIt.I<HomeBloc>();
          HomeState homeState = homeBloc.state;

          ///////////////// check if visible boutiques are pre-fetched and enter each boutique  ////////////////
          for (int i = 0; i < boutiqueSlugs.length; i++) {
            bool check =
                homeState.boutiquesThatDidPrefetch[boutiqueSlugs[i]] == true;
            expect(check, isTrue);
            /////////////////////////////////////////////////
            await enterBoutiqueAndCheckIfPreFetched(
              tester: tester,
              boutiqueIndex: i,
              homeState: homeState,
            );
          }
          await Future.delayed(const Duration(seconds: 2));
        },
      );
      //////////////////////////////////////////
      testWidgets(
        'Test prefetch for all boutiques data when make scroll to home screen , check no data will be fetched again for preFetched boutiques',
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

          int index = 0;
          String slug = '';
          Finder homeScroll = find.byKey(Key(WidgetsKey.homepageScrollKey));

          HomeBloc homeBloc = GetIt.I<HomeBloc>();
          HomeState homeState = homeBloc.state;
          //////////////////// get all  preFetched Slugs //////////////////////////
          List<String> preFetchedSlugs = homeState
              .boutiquesThatDidPrefetch.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();
          ;

          print(
              '////// preFetchedSlugs /////// $preFetchedSlugs ///////////////');

          ////////// scroll to the slug after preFetchedSlugs to check if preFetched after scrolling //////////////////

          while (true) {
            Finder boutiqueCardWidget =
                find.byKey(Key('${WidgetsKey.boutiqueCardKey}$index'));

            try {
              expect(boutiqueCardWidget, findsOneWidget);

              print('find index : $index');

              slug = tester
                      .widget<HomePageCard2>(boutiqueCardWidget)
                      .boutique
                      .slug ??
                  '';
              //////////////// check if  prefetched ///////////////////////////
              homeState = homeBloc.state;

              bool check = homeState.boutiquesThatDidPrefetch[slug] == true;

              expect(check, isTrue);

              await Future.delayed(const Duration(seconds: 1));
              ////////////////////////////
              await enterBoutiqueAndCheckIfPreFetched(
                tester: tester,
                boutiqueIndex: index,
                homeState: homeState,
              );
              await Future.delayed(const Duration(seconds: 2));

              index++;
            } catch (e) {
              // If the item isn't found, try scrolling to the right
              try {
                await tester.drag(homeScroll,
                    const Offset(0, -400)); // Scroll buttom by 400 pixels
                await tester.pumpAndSettle();

                print('scroll for $index');
                expect(boutiqueCardWidget, findsOneWidget);
                print('find index after scroll : $index');
              } catch (scrollError) {
                // If the scroll fails, we have reached the end of the list
                print('scroll fails, we have reached the end of the list');
                break;
              }
            }
          }
          await tester.pumpAndSettle();

          await Future.delayed(const Duration(seconds: 2));
          ////////// Test if scrolling up no data will be fetched for preFetched boutiques //////////////////
          //////////////////////////////////////////////////////
          print(
              '/////////  Product Filters For Boutique Flage ${TestVariables.getProductFiltersForBoutiqueFlag} //////////////');

          TestVariables.getProductFiltersForBoutiqueFlag
              .updateAll((key, value) => false);
          //////////////// Scroll to start ////////////////////////

          Finder boutiqueCardWidget =
              find.byKey(Key('${WidgetsKey.boutiqueCardKey}0'));

          homeScroll = find.byKey(Key(WidgetsKey.homepageScrollKey));

          expect(homeScroll, findsOneWidget);

          while (true) {
            try {
              expect(boutiqueCardWidget, findsOneWidget);
              print('//// Find start boutiqueCardKey  /////');
              break;
            } catch (e) {
              await tester.drag(homeScroll, const Offset(0, 300));
              print('//// scroll up  /////');
              await tester.pumpAndSettle();
              continue;
            }
          }

          //////////////// check no data will be fetched for preFetched boutiques ////////////////////////

          print(
              '/////////  Product Filters For Boutique Flage after scrolling up ${TestVariables.getProductFiltersForBoutiqueFlag} //////////////');

          bool allFalse = TestVariables.getProductFiltersForBoutiqueFlag.values
              .every((value) => value == false);

          expect(allFalse, isTrue);
          await Future.delayed(const Duration(seconds: 2));
        },
      );
    },
  );
}
