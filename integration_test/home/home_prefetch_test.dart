import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> chooseCategoryAndCheckIfBoutiquesPreFetched({
    required WidgetTester tester,
    required int categoryIndex,
    required Future<void> Function() operations,
  }) async {
    Finder categoryItemWidget =
        find.byKey(Key('${WidgetsKeys.mainCategoriesItemKey}$categoryIndex'));
    await tester.tap(categoryItemWidget);
    await tester.pump();
    await Future.delayed(const Duration(microseconds: 100));
    //////////////////////////////////////////////////////////////
    Finder boutiquesFailureStatus =
        find.byKey(const Key(WidgetsKeys.boutiquesFailureStatusKey));
    await GlobalTestFunctions.findNoWidget(
      tester: tester,
      actual: boutiquesFailureStatus,
      withDelayAndPumpAndSettle: false,
      successMessage: 'Boutiques not Null Success',
      failedMessage: 'Boutiques not Null failed',
    );
    ///////////  Find boutiques List  /////////
    final Finder boutiquesSuccessStatus =
        find.byKey(const Key(WidgetsKeys.boutiquesSuccessStatusKey));
    //////////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      actual: boutiquesSuccessStatus,
      withDelayAndPumpAndSettle: false,
      successMessage: 'Find Boutiques HomePageCard2 Success',
      failedMessage: 'Find Boutiques HomePageCard2 failed',
    );
    //////////////////////////////
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    //////////////////////////////
    await operations.call();
  }

  Future<void> enterBoutiqueAndCheckIfProductsPreFetched({
    required WidgetTester tester,
    required int boutiqueIndex,
    required BoutiqueState boutiqueBloc,
  }) async {
    Finder boutiqueCardWidget =
        find.byKey(Key('${WidgetsKeys.boutiqueCardKey}$boutiqueIndex'));

    Offset topLeft = tester.getTopLeft(boutiqueCardWidget);

    await tester.tapAt(topLeft);

    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));
    Finder boutiqueProductListingLoadingWidget =
        find.byKey(const Key(WidgetsKeys.boutiqueProductListingLoadingKey));
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
    expect(
        boutiqueBloc.getProductListingWithFiltersPaginationModels, isNotNull);

    expect(boutiqueBloc.getProductListingWithFiltersPaginationModels,
        isNot(equals({})));

    expect(boutiqueBloc.getProductFiltersModel, isNotNull);

    expect(boutiqueBloc.getProductFiltersModel, isNot(equals({})));
    // ///////////  Find product List and filters  /////////
    Finder productListFilterWidget =
        find.byKey(const Key(WidgetsKeys.productListFilterKey));
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
      const Key(WidgetsKeys.productsListKey),
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
    Finder appBarGoBackArrow =
        find.byKey(const Key(WidgetsKeys.appBarGoBackArrowKey));
    await tester.tap(appBarGoBackArrow);
    await tester.pumpAndSettle();
  }

  /* Future<void> checkFirstFiveFiltersArePreFetched({
    required WidgetTester tester,
  }) async {
    // int preFetchedCount = 0;
    // int catIndex = 0;
    // int brandIndex = 0;
    // int sizeIndex = 0;
    // int colorIndex = 0;
    // int priceIndex = 0;
    // while (preFetchedCount <= 5) {
    //   final isCatVisible = find
    //       .byKey(Key(
    //           '${WidgetsKeys.categoryCircleWithOutSubProductListingFilterKey}$catIndex'))
    //       .evaluate()
    //       .isNotEmpty;
    //   if (isCatVisible) {
    //     print('category with index $catIndex is visible.');
    //     catIndex++;
    //     preFetchedCount++;
    //   } else {
    //     print('category with index $catIndex is not visible.');
    //     final isBrandVisible = find
    //         .byKey(Key(
    //             '${WidgetsKeys.brandCircleProductListingFilterKey}$brandIndex'))
    //         .evaluate()
    //         .isNotEmpty;
    //     if (isBrandVisible) {
    //       print('brand with index $brandIndex is visible.');
    //       brandIndex++;
    //       preFetchedCount++;
    //     } else {
    //       print('brand with index $brandIndex is not visible.');
    //       final isSizeVisible = find
    //           .byKey(Key(
    //               '${WidgetsKeys.sizeCircleProductListingFilterKey}$sizeIndex'))
    //           .evaluate()
    //           .isNotEmpty;
    //       if (isSizeVisible) {
    //         print('size with index $sizeIndex is visible.');
    //         sizeIndex++;
    //         preFetchedCount++;
    //       } else {
    //         print('size with index $sizeIndex is not visible.');
    //         final isColorVisible = find
    //             .byKey(Key(
    //                 '${WidgetsKeys.colorCircleProductListingFilterKey}$colorIndex'))
    //             .evaluate()
    //             .isNotEmpty;
    //         if (isColorVisible) {
    //           print('color with index $colorIndex is visible.');
    //           colorIndex++;
    //           preFetchedCount++;
    //         } else {
    //           print('color with index $colorIndex is not visible.');
    //           final isPriceVisible = find
    //               .byKey(Key(
    //                   '${WidgetsKeys.priceCircleProductListingFilterKey}$priceIndex'))
    //               .evaluate()
    //               .isNotEmpty;
    //           if (isPriceVisible) {
    //             print('price with index $priceIndex is visible.');
    //             priceIndex++;
    //             preFetchedCount++;
    //           } else {
    //             print('price with index $priceIndex is not visible.');
    //             try {
    //               double leftOrRight =
    //                   HelperFunctions.getInitLocale().toString().contains('en')
    //                       ? -200
    //                       : 200;

    //               await tester.drag(
    //                   find.byKey(Key(WidgetsKeys.productListFilterKey)),
    //                   Offset(leftOrRight, 0)); // Scroll by 200 pixels
    //               await tester.pumpAndSettle();
    //               continue;
    //             } catch (e) {
    //               print('Reached the end of the list ///');
    //               break;
    //             }
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
    // print('/////  preFetchedCount :  $preFetchedCount ////////////////////');
  }*/

  group(
    'Test Home prefetch',
    () {
      testWidgets(
        'Test prefetch visible Main Categories when home page is oppened and for each one test prefetch visible boutiques data',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          /////////////  Register As Guest  /////////////
          await SharedScenarios.registerGuest(tester: tester);
          //////////// Find Main Categories Tab //////////////
          final Finder mainCategoriesTabNull =
              find.byKey(const Key(WidgetsKeys.mainCategoriesTabNullKey));
          await GlobalTestFunctions.findNoWidget(
            tester: tester,
            actual: mainCategoriesTabNull,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Main Categories not Null Success',
            failedMessage: 'Main Categories not Null failed',
          );
          ////////////////////////////
          final Finder mainCategoriesTab =
              find.byKey(const Key(WidgetsKeys.mainCategoriesTabKey));
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: mainCategoriesTab,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find main Categories Tab Success',
            failedMessage: 'Find main Categories Tab failed',
          );
          //////////// get all visible main Categories slugs ////////////////
          int index1 = 0;
          // add empty slug //
          List<String> categoriesSlugs = [];

          BoutiqueBloc homeBloc = GetIt.I<BoutiqueBloc>();
          BoutiqueState boutiqueBloc = homeBloc.state;

          CategoryBloc categoryBloc = GetIt.I<CategoryBloc>();
          CategoryState categoryState = categoryBloc.state;
          while (true) {
            Finder mainCategoriesItemWidget =
                find.byKey(Key('${WidgetsKeys.mainCategoriesItemKey}$index1'));

            try {
              expect(mainCategoriesItemWidget, findsOneWidget);

              MainCategory mainCategory = categoryState
                  .mainCategoriesResponseModel!.data!.mainCategories![index1];
              ///////////////////
              categoriesSlugs.add(mainCategory.slug ?? '');
              //////////////////
              print(
                  '////////// categoriesSlug $index1 : ${categoriesSlugs[index1]} /////////');
              //////////////////
              index1++;
            } catch (e) {
              print('////////// No categoriesSlug is visible /////////');
              break;
            }
          }
          print(
              '////////// categoriesSlugs length : ${categoriesSlugs.length} /////////');
          await Future.delayed(const Duration(seconds: 2));
          boutiqueBloc = homeBloc.state;
          print(
              '/// ${categoryState.boutiquesForEveryMainCategoryThatDidPrefetch}');
          ///////////////// check if visible categories are pre-fetched and enter each category  ////////////////
          for (int i = 0; i < categoriesSlugs.length; i++) {
            print('categoriesSlugs :  ${categoriesSlugs[i]}');
            bool check =
                categoryState.boutiquesForEveryMainCategoryThatDidPrefetch[
                        categoriesSlugs[i]] ==
                    true;
            print('categoriesSlugs isTrue :  $check');
            expect(check, isTrue);
            /////////////////////////////////////////////////
            await chooseCategoryAndCheckIfBoutiquesPreFetched(
              tester: tester,
              categoryIndex: i,
              operations: () async {
                //////////// get all visible boutiques slugs ////////////////
                int index = 0;
                List<String> boutiqueSlugs = [];
                while (true) {
                  Finder boutiqueCardWidget =
                      find.byKey(Key('${WidgetsKeys.boutiqueCardKey}$index'));
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
                await Future.delayed(const Duration(microseconds: 500));
                homeBloc = GetIt.I<BoutiqueBloc>();
                boutiqueBloc = homeBloc.state;
                ///////////////// check if visible boutiques are pre-fetched and enter each boutique  ////////////////
                for (int i = 0; i < boutiqueSlugs.length; i++) {
                  print('boutiqueSlugs :  ${boutiqueSlugs[i]}');
                  bool check =
                      boutiqueBloc.boutiquesThatDidPrefetch[boutiqueSlugs[i]] ==
                          true;
                  print('boutiqueSlugs isTrue :  $check');
                  expect(check, isTrue);
                  /////////////////////////////////////////////////
                  await enterBoutiqueAndCheckIfProductsPreFetched(
                    tester: tester,
                    boutiqueIndex: i,
                    boutiqueBloc: boutiqueBloc,
                  );
                }
              },
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
              find.byKey(const Key(WidgetsKeys.boutiquesSuccessStatusKey));
          await GlobalTestFunctions.findWidget(
            tester: tester,
            actual: boutiquesSuccessStatus,
            withDelayAndPumpAndSettle: false,
            successMessage: 'Find Boutiques HomePageCard2 Success',
            failedMessage: 'Find Boutiques HomePageCard2 failed',
          );

          int index = 0;
          String slug = '';
          Finder homeScroll =
              find.byKey(const Key(WidgetsKeys.homepageScrollKey));

          BoutiqueBloc homeBloc = GetIt.I<BoutiqueBloc>();
          BoutiqueState boutiqueBloc = homeBloc.state;
          //////////////////// get all  preFetched Slugs //////////////////////////
          List<String> preFetchedSlugs = boutiqueBloc
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
                find.byKey(Key('${WidgetsKeys.boutiqueCardKey}$index'));

            try {
              expect(boutiqueCardWidget, findsOneWidget);

              print('find index : $index');

              slug = tester
                      .widget<HomePageCard2>(boutiqueCardWidget)
                      .boutique
                      .slug ??
                  '';
              //////////////// check if  prefetched ///////////////////////////
              boutiqueBloc = homeBloc.state;

              bool check = boutiqueBloc.boutiquesThatDidPrefetch[slug] == true;

              expect(check, isTrue);

              await Future.delayed(const Duration(seconds: 1));
              ////////////////////////////
              await enterBoutiqueAndCheckIfProductsPreFetched(
                tester: tester,
                boutiqueIndex: index,
                boutiqueBloc: boutiqueBloc,
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
              find.byKey(const Key('${WidgetsKeys.boutiqueCardKey}0'));

          homeScroll = find.byKey(const Key(WidgetsKeys.homepageScrollKey));

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
