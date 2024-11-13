import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/app_widgets/update_user_name_widget.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Show enter name dialog after going to chat after register without username',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(
        tester: tester,
        isForLogin: false,
        phoneNumber: '963884012568',
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
      final Finder nameField = find.byKey(Key(WidgetsKey.registerCancelKey));
      await tester.tap(nameField);
      await tester.pumpAndSettle();
      //////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      //////////////////////////
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
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder chatNavBarButton = find.byKey(Key(
        WidgetsKey.chatNavBarKey,
      ));
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(chatNavBarButton);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(
        tester,
        find.byType(UpdateUserNameWidget),
      );
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: UpdateUserNameWidget,
        successMessage: 'Find UpdateUserNameWidget Success',
        failedMessage: 'Find UpdateUserNameWidget failed',
      );
      //////////////////////////
      await Future.delayed(const Duration(seconds: 2));
    },
  );
}
