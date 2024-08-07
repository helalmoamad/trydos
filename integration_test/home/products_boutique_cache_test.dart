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
    'Click on boutique ,',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
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
      ////////////////////////////
      final Finder boutiqueCard1 = find.byKey(
        Key('${WidgetsKey.boutiqueCardKey}0'),
      );
      ////////////////////////////
      final boutiqueId1 =
          tester.widget<HomePageCard2>(boutiqueCard1).boutniqe.id!;
      ////////////////////////////
      print('//////// categorySlug : $boutiqueId1 //////////');
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      //////////////////////////
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
      ///////////////////////////////
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
      //////////////////////////
      int productIndex1 = 0;
      final List<String> productIds1 = [];
      while (true) {
        final productKey =
            Key('${WidgetsKey.productInBoutiqueListKey}$productIndex1');
        if (find.byKey(productKey).evaluate().isEmpty) {
          break;
        }

        final productId = tester
            .widget<ProductItem>(find.byKey(productKey))
            .productItem
            .id!
            .toString();
        productIds1.add(productId);
        productIndex1++;
      }
      ///////////////////////////
      print('/////////// productIds : $productIds1 ///////////////');
      await Future.delayed(const Duration(seconds: 2));
      /////////////////////////
      final Finder appBarGoBackArrow = find.byKey(
        Key(WidgetsKey.appBarGoBackArrowKey),
      );
      await tester.tap(appBarGoBackArrow);
      await tester.pumpAndSettle();
      /////////////////////////
    },
  );
}
