import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Click on boutique ,find products filters, find list of products , click on product , go to product details',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      //////////////////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////////////////////
      final Finder boutiquesSuccessStatus =
          find.byKey(Key(WidgetsKey.boutiquesSuccessStatusKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: boutiquesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Boutiques HomePageCard2 Success',
        failedMessage: 'Find Boutiques HomePageCard2 failed',
      );
      //////////////////////////
      final Finder boutiqueCardButton = find.byKey(
        Key('${WidgetsKey.boutiqueCardKey}0'),
      );
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCardButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        find.byType(ProductListingPage),
      );
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ProductListingPage,
        successMessage: 'Find ProductListingPage  Success',
        failedMessage: 'Find ProductListingPage  failed',
      );
      final Finder productListFilterWidget =
          find.byKey(Key(WidgetsKey.productListFilterKey));
      // /////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: productListFilterWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find product List Filter Widget  Success',
        failedMessage: 'Find product List Filte Widget failed',
      );
      /////////////////////////////
      final Finder productInBoutiqueButton = find.byKey(
        Key('${WidgetsKey.productInBoutiqueListKey}0'),
      );
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(productInBoutiqueButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        find.byType(ProductDetailsPage),
      );
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ProductDetailsPage,
        successMessage: 'Find ProductDetailsPage  Success',
        failedMessage: 'Find ProductDetailsPage  failed',
      );
      //////////////////////////
    },
  );
}
