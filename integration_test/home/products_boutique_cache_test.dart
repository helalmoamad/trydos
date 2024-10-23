import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> noLoadingTest({
    required WidgetTester tester,
    required HomeState homeState,
  }) async {
    // ///////////  no loading  /////////
    Finder boutiqueProductListingLoadingWidget =
        find.byKey(Key(WidgetsKey.boutiqueProductListingLoadingKey));
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
  }

  testWidgets(
    'Test product list cache in boutique',
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
      ////////////////////////////
      final Finder boutiqueCard1 = find.byKey(
        Key('${WidgetsKey.boutiqueCardKey}0'),
      );
      ////////////////////////////
      final boutiqueId1 =
          tester.widget<HomePageCard2>(boutiqueCard1).boutique.id!;
      ////////////////////////////
      print('//////// boutiqueCard1  : $boutiqueId1 //////////');
      ///////////// Tap on first  boutique  ///////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      ///////////// no Loading for products because of prefetch and cache  /////////////
      HomeBloc homeBloc = GetIt.I<HomeBloc>();
      HomeState homeState = homeBloc.state;
      //////////////////////////////////////////////////////////
      await noLoadingTest(tester: tester, homeState: homeState);
      await tester.pumpAndSettle();

      ///////////  Test if products belong to the  Boutique  ///////////////
      int productIndex1 = 0;
      List<String> oldCacheDate = [];

      Finder productListingScroll =
          find.byKey(Key(WidgetsKey.productListingScrollKey));

      bool reachedEnd = false;
      //////////////////// Scroll and test ////////////////////////////////////
      /////////////////////////////////
      while (!reachedEnd) {
        try {
          Finder productWidget = find.byKey(
              Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1'));
          //////////////////////////////////
          String productBoutId = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .boutiqueId!
              .toString();

          String productBoutDateNow = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .dateNow!
              .toString();

          oldCacheDate.add(productBoutDateNow);

          print('productBoutDateNow old : $productBoutDateNow');

          print('boutiqueId1 : $boutiqueId1');

          print('productBoutId : $productBoutId');

          expect(productBoutId, equals(boutiqueId1.toString()));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex1++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex1');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex1');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex1');
        }
      }

      print('old cache Date : $oldCacheDate');
      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      /////////////  Go Back  ////////////
      final Finder appBarGoBackArrow = find.byKey(
        Key(WidgetsKey.appBarGoBackArrowKey),
      );
      await tester.tap(appBarGoBackArrow);
      await tester.pumpAndSettle();
      /////////////// Tap on the second  boutique //////////
      final Finder boutiqueCard2 = find.byKey(
        Key('${WidgetsKey.boutiqueCardKey}1'),
      );
      ////////////////////////////
      final boutiqueId2 =
          tester.widget<HomePageCard2>(boutiqueCard2).boutique.id!;
      ////////////////////////////
      print('//////// boutiqueId2  : $boutiqueId2 //////////');
      ////////////////////////////
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard2);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      //////////////////////////
      await noLoadingTest(tester: tester, homeState: homeState);
      await tester.pumpAndSettle();
      ////////////////////////////////
      //////////// Test products in the second Boutique belong to it  //////////////
      int productIndex2 = 0;
      productListingScroll =
          find.byKey(Key(WidgetsKey.productListingScrollKey));
      reachedEnd = false;

      while (!reachedEnd) {
        try {
          Finder productWidget = find.byKey(
              Key('${WidgetsKey.productInBoutiqueListKey}$productIndex2'));
          //////////////////////////////////
          String productBoutId = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .boutiqueId!
              .toString();

          String productId = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .id!
              .toString();

          print(
              '/// productId : $productId  ///// productBoutId : $productBoutId | boutiqueId2 : $boutiqueId2  //// $productIndex2 /////////');

          expect(productBoutId, equals(boutiqueId2.toString()));
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex2++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKey.productInBoutiqueListKey}$productIndex2'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex2');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex2');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex2');
        }
      }

      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      //////////////  Go Back ///////////
      final Finder appBarGoBackArrow2 = find.byKey(
        Key(WidgetsKey.appBarGoBackArrowKey),
      );
      await tester.tap(appBarGoBackArrow2);
      await tester.pumpAndSettle();
      //////////////  Go Again to the first boutique ///////////
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(boutiqueCard1);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      //////////////////////////
      ///////////////  test the products come from cache and old date is before new date////////////////
      await noLoadingTest(tester: tester, homeState: homeState);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////
      ///////////// test the products belong to the first boutique  /////////////
      productIndex1 = 0;

      productListingScroll =
          find.byKey(Key(WidgetsKey.productListingScrollKey));

      reachedEnd = false;

      while (!reachedEnd) {
        try {
          Finder productWidget = find.byKey(
              Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1'));
          //////////////////////////////////
          String productBoutId = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .boutiqueId!
              .toString();

          String productBoutDateNow = tester
              .widget<ProductItem>(productWidget)
              .productItem
              .dateNow!
              .toString();

          print('productBoutDateNow : $productBoutDateNow ,,, ');

          DateTime dateNew = DateTime.parse(productBoutDateNow);
          DateTime dateOld = DateTime.parse(oldCacheDate[productIndex1]);

          print('dateOld : $dateOld ,,, dateNew : $dateNew');

          expect(productBoutId, equals(boutiqueId1.toString()));
          expect(dateOld.isBefore(dateNew), true);
        } catch (e) {
          reachedEnd = true;
          fail(e.toString());
        }
        productIndex1++;
        // Try to scroll until the next product card becomes visible
        Finder finderWidget = find
            .byKey(Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1'));
        if (finderWidget.evaluate().isEmpty) {
          try {
            await tester.drag(productListingScroll, const Offset(0, -400));
            await tester.pumpAndSettle();
            print('scroll for $productIndex1');
            expect(finderWidget, findsOneWidget);
            print('find index after scroll : $productIndex1');
          } catch (e) {
            // If the scroll fails, we have reached the end of the list
            print('scroll fails, we have reached the end of the list');
            reachedEnd = true;
          }
        } else {
          print('find index without scroll : $productIndex1');
        }
      }

      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      /////////////////////////
    },
  );
}
