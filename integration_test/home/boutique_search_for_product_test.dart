import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test search for product in boutique',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      WidgetsKey.kTestMode = true;
      //////////// Register As Guest //////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////////////////////
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKey.boutiquesSuccessStatusKey));
      /////////// Test Find Boutiques HomePageCard/////////////////
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
      ////////////// Tap on first Boutique HomePageCard //////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pumpAndSettle();
      ///////////////////////////////
      final Finder productsList = find.byKey(
        Key(WidgetsKey.productsListKey),
      );
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        productsList,
      );
      ///////////// find productsList //////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList  Success',
        failedMessage: 'Find productsList  failed',
      );
      //////////// get first product name & id before search from productsList //////////////
      final productKey = Key('${WidgetsKey.productInBoutiqueListKey}0');

      String productNameBeforeSearch = tester
          .widget<ProductItem>(find.byKey(productKey))
          .productItem
          .name!
          .toString();
      String productIdBeforeSearch = tester
          .widget<ProductItem>(find.byKey(productKey))
          .productItem
          .id!
          .toString();
      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('productNameBeforeSearch : $productNameBeforeSearch');
      //////////// Tap to search /////////////
      final Finder productListingSearchIcon = find.byKey(
        Key(WidgetsKey.productListingSearchIconKey),
      );
      await tester.tap(productListingSearchIcon);
      await tester.pumpAndSettle();
      //////////////////////////
      final Finder productListingSearchInput = find.byKey(
        Key(WidgetsKey.productListingSearchInputKey),
      );
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productListingSearchInput,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productListingSearchInput Success',
        failedMessage: 'Find productListingSearchInput failed',
      );
      /////////// get the first three char from the first product Name /////////////////
      String inputTextSearch = productNameBeforeSearch.substring(0, 3);
      ////////////////////////////
      await tester.enterText(productListingSearchInput, inputTextSearch);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      ///////////// test find loaging  ///////////////
      final Finder boutiqueProductListingLoading = find.byKey(
        Key(WidgetsKey.boutiqueProductListingLoadingKey),
      );
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiqueProductListingLoading,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find boutiqueProductListingLoading Success',
        failedMessage: 'Find boutiqueProductListingLoading failed',
      );
      await tester.pumpAndSettle();
      //////////// Test search text equals search text in filter widget ////////////////
      final searchText = tester
          .widget<StackedFiltersList>(
              find.byKey(Key(WidgetsKey.productListFilterKey)))
          .searchText
          .toString();
      expect(searchText, equals(inputTextSearch));
      //////////// get products ids after serach from productsList //////////////
      int productIndex2 = 0;
      List<String> productIdsAfterSearchList = [];
      while (true) {
        final productKey =
            Key('${WidgetsKey.productInBoutiqueListKey}$productIndex2');
        if (find.byKey(productKey).evaluate().isEmpty) {
          break;
        }

        final productBoutId = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .id!
            .toString();

        productIdsAfterSearchList.add(productBoutId);

        productIndex2++;
      }
      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('productIdsAfterSearchList : $productIdsAfterSearchList');
      ////////////// Test product ID before test in product IDs list after search /////////////
      bool chackId = false;
      for (String id in productIdsAfterSearchList) {
        if (id == productIdBeforeSearch) {
          chackId = true;
          break;
        }
      }
      // Verify the result
      expect(chackId, equals(true));
    },
  );
}
