import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/authentication/presentation/pages/number_not_registered.dart';
import 'package:trydos/features/authentication/presentation/pages/register_completed.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
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
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(
        tester: tester,
        isForLogin: true,
        phoneNumber: '963774581230',
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
      await GlobalTestFunctions.waitFor(tester, find.byType(AddingName));
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: AddingName,
        successMessage: 'Find AddingName Page Success',
        failedMessage: 'Find AddingName Page failed',
      );
      //////////////////////////
      final Finder nameField = find.byKey(Key(WidgetsKey.nameFormFieldKey));
      final Finder confirmNameButton =
          find.byKey(Key(WidgetsKey.confirmNameButtonKey));
      await tester.enterText(nameField, 'aaaaaaaaa');
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(confirmNameButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(RegisterCompleted));
      ///////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: RegisterCompleted,
        successMessage: 'Find RegisterCompleted Page Success',
        failedMessage: 'Find RegisterCompleted Page failed',
      );
      //////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      final Finder skipForNowButton = find.byKey(Key(WidgetsKey.skipForNowKey));
      await tester.tap(skipForNowButton);
      await tester.pumpAndSettle();
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
      await SharedScenarios.testTokensAreNotNull(isJustForMarketToken: false);
      ////////////////////////////
    },
  );
}
