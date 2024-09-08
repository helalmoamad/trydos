import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/search/presentation/pages/search_page.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test home search , select boutique , then press search button , move to the filtering page ,testing that the filtering data (category, etc.) belongs to this boutique',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      /////////////  Register As Guest  /////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////// Find Home Search Icon //////////////
      final Finder homeSearchIconWidget =
          find.byKey(Key(WidgetsKey.homeSearchIconKey));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: homeSearchIconWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Home Search Icon Widget Success',
        failedMessage: 'Find Home Search Icon Widget failed',
      );

      await tester.tap(homeSearchIconWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: SearchPage,
        successMessage: 'Find Search Page Success',
        failedMessage: 'Find Search Page failed',
      );
      //////////////////  Scroll until find best saller /////////////////////////////////////
      final Finder searchPageBoutiqueListWidget =
          find.byKey(Key(WidgetsKey.searchPageBoutiqueListKey));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: searchPageBoutiqueListWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find searchPageBoutiqueListWidget Success',
        failedMessage: 'Find searchPageBoutiqueListWidget failed',
      );

      bool isFound = false;
      int index = 0;
      while (!isFound) {
        // Try to find the boutique name widget by key with index
        Finder searchPageBoutiqueNameWidget =
            find.byKey(Key('${WidgetsKey.searchPageBoutiqueNameKey}$index'));
        try {
          expect(searchPageBoutiqueNameWidget, findsOneWidget);

          print('find index : $index');

          // Get the widget's text
          String name = tester
              .widget<MyTextWidget>(searchPageBoutiqueNameWidget)
              .text
              .toString();

          // Check if the boutique name is 'best saller'
          if (name == 'best saller') {
            print('find best saller : $index');
            isFound = true;
            break; // Exit the loop if the desired item is found
          } else {
            print('Not best saller : $index');
            index++;
          }
        } catch (e) {
          // If the item isn't found, try scrolling to the right
          try {
            await tester.drag(searchPageBoutiqueListWidget,
                const Offset(200, 0)); // Scroll right by 200 pixels
            await tester.pumpAndSettle();

            print('scroll for $index');
            expect(searchPageBoutiqueNameWidget, findsOneWidget);
            print('find index after scroll : $index');
          } catch (scrollError) {
            // If the scroll fails, we have reached the end of the list
            fail('Reached the end of the list without finding the item');
          }
        }
      }

      await tester.pumpAndSettle();

      expect(isFound, isTrue);

      await Future.delayed(const Duration(seconds: 2));

      final Finder searchBoutiqueNameWidget =
          find.byKey(Key('${WidgetsKey.searchPageBoutiqueNameKey}$index'));

      await tester.tap(searchBoutiqueNameWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      /////////////////////////////////////////////////////
      final Finder searchButtonInSearchPageKey =
          find.byKey(Key(WidgetsKey.searchButtonInSearchPageKey));
      // Scroll until  is visible
      await tester.scrollUntilVisible(
        searchButtonInSearchPageKey,
        500.0, // This is the scroll increment, adjust as necessary
        scrollable: find.byType(Scrollable), // Find the scrollable widget
      );

      expect(searchButtonInSearchPageKey, findsOneWidget);

      await tester.tap(searchButtonInSearchPageKey);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
    },
  );
}
