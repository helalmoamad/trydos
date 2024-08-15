import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test product list cache in boutique',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
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
          tester.widget<HomePageCard2>(boutiqueCard1).boutniqe.id!;
      ////////////////////////////
      print('//////// boutiqueCard1  : $boutiqueId1 //////////');
      ///////////// Tap on first  boutique  ///////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      /////////////  Loading for products  /////////////
      final Finder boutiqueProductListingLoading = find.byKey(
        Key(WidgetsKey.boutiqueProductListingLoadingKey),
      );
      ///////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiqueProductListingLoading,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find boutiqueProductListingLoading  Success',
        failedMessage: 'Find boutiqueProductListingLoading  failed',
      );
      await tester.pumpAndSettle();
      //////////////  Find product list  /////////////////
      final Finder productsList = find.byKey(
        Key(WidgetsKey.productsListKey),
      );
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        productsList,
      );
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList  Success',
        failedMessage: 'Find productsList  failed',
      );

      ///////////  Test if products belong to the  Boutique  ///////////////
      int productIndex1 = 0;
      List<String> oldCacheDate = [];
      while (true) {
        Key productKey =
            Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1');

        print('productKey  found 1 : $productKey');

        if (find.byKey(productKey).evaluate().isEmpty) {
          print('productKey not found 1 : $productKey');
          break;
        }

        String productBoutId = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .boutiqueId!
            .toString();

        String productBoutDateNow = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .dateNow!
            .toString();

        oldCacheDate.add(productBoutDateNow);

        print('productBoutDateNow old : $productBoutDateNow');

        print('boutiqueId1 : $boutiqueId1');

        print('productBoutId : $productBoutId');

        expect(productBoutId, equals(boutiqueId1.toString()));

        productIndex1++;
      }

      print('old cache : $oldCacheDate');
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
          tester.widget<HomePageCard2>(boutiqueCard2).boutniqe.id!;
      ////////////////////////////
      print('//////// boutiqueId2  : $boutiqueId2 //////////');
      ////////////////////////////
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard2);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiqueProductListingLoading,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find boutiqueProductListingLoading  Success',
        failedMessage: 'Find boutiqueProductListingLoading  failed',
      );
      await tester.pumpAndSettle();
      ///////////////////////////////
      final Finder productsList2 = find.byKey(
        Key(WidgetsKey.productsListKey),
      );
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        productsList2,
      );
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList2,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList2  Success',
        failedMessage: 'Find productsList2  failed',
      );
      //////////// Test products in the second Boutique belong to it  //////////////
      int productIndex2 = 0;
      while (true) {
        Key productKey =
            Key('${WidgetsKey.productInBoutiqueListKey}$productIndex2');
        if (find.byKey(productKey).evaluate().isEmpty) {
          break;
        }

        String productBoutId = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .boutiqueId!
            .toString();

        expect(productBoutId, equals(boutiqueId2.toString()));

        productIndex2++;
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
      ///////////////  test the products come from cache (no loading) ////////////////
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: boutiqueProductListingLoading,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find boutiqueProductListingLoading  Success',
        failedMessage: 'Find boutiqueProductListingLoading  failed',
      );
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        productsList,
      );
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList  Success',
        failedMessage: 'Find productsList  failed',
      );
      ////////////
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      ///////////// test the products belong to the first boutique  /////////////
      productIndex1 = 0;
      while (true) {
        Key productKey =
            Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1');
        if (find.byKey(productKey).evaluate().isEmpty) {
          print('productKey not found : $productKey');
          break;
        }

        String productBoutId = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .boutiqueId!
            .toString();

        String productBoutDateNow = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .dateNow!
            .toString();

        print('productBoutDateNow : $productBoutDateNow ,,, ');

        DateTime dateNew = DateTime.parse(productBoutDateNow);
        DateTime dateOld = DateTime.parse(oldCacheDate[productIndex1]);

        print('dateOld : $dateOld ,,, dateNew : $dateNew');

        expect(productBoutId, equals(boutiqueId1.toString()));
        expect(dateOld.isBefore(dateNew), true);

        productIndex1++;
      }
      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      /////////////////////////
    },
  );
}
