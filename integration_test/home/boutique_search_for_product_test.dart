import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
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
      // Initialize the main application
      app.main();
      await tester.pumpAndSettle();
      // Set test mode to true
      TestVariables.kTestMode = true;

      //////////// Register As Guest //////////////
      // Simulate registering as a guest user using shared scenarios
      await SharedScenarios.registerGuest(tester: tester);

      // Define the Finder for the boutiques success status
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKey.boutiquesSuccessStatusKey));

      /////////// Test Find Boutiques HomePageCard/////////////////
      // Verify the presence of the Boutique HomePageCard widget
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiquesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Boutiques HomePageCard2 Success',
        failedMessage: 'Find Boutiques HomePageCard2 failed',
      );

      ////////////////////////////
      // Find the first boutique card
      final Finder boutiqueCard1 = find.byKey(
        Key('${WidgetsKey.boutiqueCardKey}0'),
      );

      ////////////////////////////
      // Get the boutique ID from the widget and print it for debugging
      final boutiqueId1 =
          tester.widget<HomePageCard2>(boutiqueCard1).boutique.id!;
      print('//////// boutiqueCard1  : $boutiqueId1 //////////');

      ////////////// Tap on first Boutique HomePageCard //////////////
      // Tap on the first boutique card and wait for the UI to update
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pumpAndSettle();

      ///////////////////////////////
      // Find the product list widget on the boutique page
      final Finder productsList = find.byKey(
        Key(WidgetsKey.productsListKey),
      );

      //////////////////////////
      // Wait for the product list to appear
      await GlobalTestFunctions.waitFor(
        tester,
        productsList,
      );

      ///////////// find productsList //////////////
      // Verify the presence of the product list widget
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productsList,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find productsList Success',
        failedMessage: 'Find productsList failed',
      );

      //////////// Get first product name & ID before search //////////////
      // Get the name and ID of the first product in the list before searching
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
      // Print the first product name for debugging
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('productNameBeforeSearch : $productNameBeforeSearch');

      //////////// Tap to search /////////////
      // Tap on the search icon to initiate the product search
      final Finder productListingSearchIcon = find.byKey(
        Key(WidgetsKey.productListingSearchIconKey),
      );
      await tester.tap(productListingSearchIcon);
      await tester.pumpAndSettle();

      //////////////////////////
      // Verify the presence of the search input field
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

      /////////// Enter the first three characters of the product name into the search field /////////////////
      String inputTextSearch = productNameBeforeSearch.substring(0, 3);

      ////////////////////////////
      // Enter the search text and pump the widget tree
      await tester.enterText(productListingSearchInput, inputTextSearch);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));

      ///////////// Test find loading ///////////////
      // Verify that the loading indicator appears while searching
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

      //////////// Test that the search text matches the input in the filter widget ////////////////
      final searchText = tester
          .widget<StackedFiltersList>(
              find.byKey(Key(WidgetsKey.productListFilterKey)))
          .searchText
          .toString();
      expect(searchText, equals(inputTextSearch));

      //////////// Get product IDs after search from productsList //////////////
      // Iterate through the products in the list after search and collect their IDs
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
      // Print the list of product IDs after the search for debugging
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('productIdsAfterSearchList : $productIdsAfterSearchList');

      ////////////// Test if the product ID before the search is still in the product list after search /////////////
      bool checkId = false;
      for (String id in productIdsAfterSearchList) {
        if (id == productIdBeforeSearch) {
          checkId = true;
          break;
        }
      }

      // Verify that the product ID before search exists in the list of product IDs after search
      expect(checkId, equals(true));
    },
  );
}
