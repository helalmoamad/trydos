import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
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
      print('//////// boutiqueCard1  : $boutiqueId1 //////////');
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(boutiqueCard1);
      await tester.pumpAndSettle();
      //////////////////////////
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
      String inputTextSearch = 'sof';
      ////////////////////////////
      await tester.enterText(productListingSearchInput, inputTextSearch);
      await tester.pump();
      await Future.delayed(const Duration(seconds: 1));
      ////////////////////////////
      final Finder loadingAfterSearch = find.byKey(
        Key(WidgetsKey.loadingAfterSearchKey),
      );
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: loadingAfterSearch,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find loading After Search Success',
        failedMessage: 'Find loading After Search failed',
      );
      await tester.pumpAndSettle();
      ////////////////////////////
      final searchText = tester
          .widget<StackedFiltersList>(
              find.byKey(Key(WidgetsKey.productListFilterKey)))
          .searchText
          .toString();
      expect(searchText, equals(inputTextSearch));
    },
  );
}
