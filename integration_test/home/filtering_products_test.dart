import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group(
    'Products Filter tests',
    () {
      testWidgets(
        'Filter and return one product test in product listing page ,',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          /////////////  Register As Guest  /////////////
          await SharedScenarios.registerGuest(tester: tester);
          ////////////// Find Boutiques HomePageCard //////////////
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
          final shirtFinder = find.widgetWithText(HomePageCard2, 'best saller');
          // Check if the Boutique with the text 'best saller' is found.
          expect(shirtFinder, findsOneWidget);

          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(shirtFinder);
          await tester.pumpAndSettle();
          ////////////////////////////

          ///////// Find filters ///////////////////
          ///////// Find products for  boutique ///////////////////
          //////////// filter by category and check the results//////
          /////////////// filter by brand until one product result //////
          /////////////// check there are no filters  //////
        },
      );
    },
  );
}
