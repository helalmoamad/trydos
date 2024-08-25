import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Main categories , stories , boutique , data has been displayed successfully',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      //////////////////////////
      await SharedScenarios.registerGuest(tester: tester);
      ///////////////////////////////////////////
      final Finder mainCategoriesTabNull =
          find.byKey(Key(WidgetsKey.mainCategoriesTabNullKey));
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: mainCategoriesTabNull,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Main Categories not Null Success',
        failedMessage: 'Main Categories not Null failed',
      );
      ////////////////////////////
      final Finder mainCategoriesTab =
          find.byKey(Key(WidgetsKey.mainCategoriesTabKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: mainCategoriesTab,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find main Categories Tab Success',
        failedMessage: 'Find main Categories Tab failed',
      );
      ////////////////////////////
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder storiesFailureStatus =
          find.byKey(Key(WidgetsKey.storiesFailureStatusKey));
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: storiesFailureStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Stories not Null Success',
        failedMessage: 'Stories not Null failed',
      );
      ////////////////////////////
      final Finder storiesSuccessStatus =
          find.byKey(Key(WidgetsKey.storiesSuccessStatusKey));
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: storiesSuccessStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Stories Success',
        failedMessage: 'Find Stories failed',
      );
      ////////////////////////////
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder boutiquesFailureStatus =
          find.byKey(Key(WidgetsKey.boutiquesFailureStatusKey));
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: boutiquesFailureStatus,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Boutiques not Null Success',
        failedMessage: 'Boutiques not Null failed',
      );
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
    },
  );
}
