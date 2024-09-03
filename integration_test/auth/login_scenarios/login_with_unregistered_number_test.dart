import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/number_not_registered.dart';
import 'package:trydos/main.dart' as app;
import '../../shared/shared_scenarios.dart';
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Login with Number has not registered yet , complete SignUp and Enter UserName  , without complete my profile',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(
        tester: tester,
        isForLogin: true,
        phoneNumber: '963774581289',
      );
      ////////////////////////////
      await SharedScenarios.testTokensAreNull(isJustForMarketToken: false);
      ////////////////////////////
      await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
      //////////////////////////
      await GlobalTestFunctions.waitFor(
          tester, find.byType(NumberNotRegistered));
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: NumberNotRegistered,
        successMessage: 'Find NumberNotRegistered Page Success',
        failedMessage: 'Find NumberNotRegistered Page failed',
      );
      //////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      final Finder createNewAccountContinueButton =
          find.byKey(Key(WidgetsKey.createNewAccountContinueKey));
      await tester.tap(createNewAccountContinueButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await SharedScenarios.addingNameAfterRegister(
          name: 'aaaaaaaaa', tester: tester);
      ////////////////////////////
      await SharedScenarios.testTokensAreNotNull(isJustForMarketToken: false);
      ////////////////////////////
    },
  );
}
