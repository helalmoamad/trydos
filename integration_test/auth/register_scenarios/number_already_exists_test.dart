import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/already_exist_account.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;
import '../../shared/shared_scenarios.dart';
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group(
    'Number Already exists tests',
    () {
      testWidgets(
        'Find Number Already exists page after entering existing number test',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
              tester: tester, isForLogin: false);
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
          await GlobalTestFunctions.waitFor(
              tester, find.byType(AlreadyExistAccount));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: AlreadyExistAccount,
            successMessage: 'Find AlreadyExistAccount Success',
            failedMessage: 'Find AlreadyExistAccount failed',
          );
        },
      );

      testWidgets(
        'Entering existing number and login test',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
              tester: tester, isForLogin: false);
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
          await GlobalTestFunctions.waitFor(
              tester, find.byType(AlreadyExistAccount));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: AlreadyExistAccount,
            successMessage: 'Find AlreadyExistAccount Success',
            failedMessage: 'Find AlreadyExistAccount failed',
          );
          ////////////////////////////
          final Finder loginContinueButtonKey =
              find.byKey(Key(WidgetsKey.loginContinueButtonKey));
          await Future.delayed(const Duration(seconds: 1));
          await tester.tap(loginContinueButtonKey);
          await tester.pumpAndSettle();
          //////////////////////////
          await GlobalTestFunctions.waitFor(
              tester, find.byType(LoginSuccessfully));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: LoginSuccessfully,
            successMessage: 'Find LoginSuccessfully Success',
            failedMessage: 'Find LoginSuccessfully failed',
          );
          /////////////////////////
          await SharedScenarios.countryDropDown(tester: tester);
          await GlobalTestFunctions.waitFor(tester, find.byType(HomePage));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: HomePage,
            successMessage: 'Find HomePage Success',
            failedMessage: 'Find HomePage failed',
          );
          ////////////////////////////
          await SharedScenarios.testTokensAreNotNull(
              isJustForMarketToken: false);
          ////////////////////////////
        },
      );

      testWidgets(
        'Entering existing number and continue as guest',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          TestVariables.kTestMode = true;
          //////////////////////////
          await SharedScenarios.goToVerifyOtp(
              tester: tester, isForLogin: false);
          ////////////////////////////
          await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
          //////////////////////////
          await GlobalTestFunctions.waitFor(
              tester, find.byType(AlreadyExistAccount));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: AlreadyExistAccount,
            successMessage: 'Find AlreadyExistAccount Success',
            failedMessage: 'Find AlreadyExistAccount failed',
          );
          ////////////////////////////
          final Finder takeLookButtonKey =
              find.byKey(Key(WidgetsKey.takeLookButtonKey));
          await Future.delayed(const Duration(seconds: 1));
          await tester.tap(takeLookButtonKey);
          await tester.pumpAndSettle();
          /////////////////////////
          await SharedScenarios.countryDropDown(tester: tester);
          //////////////////////////
          await GlobalTestFunctions.waitFor(tester, find.byType(HomePage));
          //////////////////////////
          await GlobalTestFunctions.findWidget(
            tester: tester,
            widgetType: HomePage,
            successMessage: 'Find HomePage Success',
            failedMessage: 'Find HomePage failed',
          );
          ////////////////////////////
          await SharedScenarios.testTokensAreNull(
              isJustForMarketToken: false, isJustForStoryChatTokens: true);
          ////////////////////////////
        },
      );
    },
  );
}
