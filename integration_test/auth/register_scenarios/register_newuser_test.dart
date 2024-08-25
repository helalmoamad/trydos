import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/main.dart' as app;
import '../../shared/shared_scenarios.dart';
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group(
    'Create account to new user',
    () {
      testWidgets(
        'Create account to new user and enter name test',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
            tester: tester,
            isForLogin: false,
            phoneNumber: '963111111130',
          );
          ////////////////////////////
          await SharedScenarios.testTokensAreNull(isJustForMarketToken: false);
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
          await SharedScenarios.addingNameAfterRegister(
            name: 'aaaaaaaa',
            tester: tester,
          );
          ////////////////////////////
          await SharedScenarios.testTokensAreNotNull(
            isJustForMarketToken: false,
          );
          ////////////////////////////
        },
      );

      testWidgets(
        'Create account to new user and press x button in add name page to retry the registeration process',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
            tester: tester,
            isForLogin: false,
            phoneNumber: '963111111126',
          );
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
          await GlobalTestFunctions.waitFor(
            tester,
            find.byType(AddingName),
          );
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: AddingName,
            successMessage: 'Find Adding Name Success',
            failedMessage: 'Find Adding Name failed',
          );
          //////////////////////////
          final Finder registerCancelButton = find.byKey(
            Key(WidgetsKey.registerCancelKey),
          );
          ////////////////////////
          expect(registerCancelButton, findsOne);
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(registerCancelButton);
          await tester.pumpAndSettle();
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
            tester: tester,
            isForLogin: false,
            isAfterAddName: true,
            phoneNumber: '963111111115',
          );
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
        },
      );
    },
  );
}
