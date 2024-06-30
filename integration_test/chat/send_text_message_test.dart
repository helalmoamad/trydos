import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/pages/contacts_page.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Go to chat section , choose contact and send text message',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(tester: tester, isForLogin: true);
      ////////////////////////////
      await SharedScenarios.testTokensAreNull(isJustForMarketToken: false);
      ////////////////////////////
      await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
      //////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(LoginSuccessfully));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: LoginSuccessfully,
        successMessage: 'Find LoginSuccessfully Success',
        failedMessage: 'Find LoginSuccessfully failed',
      );
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
      final Finder chatNavBarButton = find.byKey(Key(
        WidgetsKey.chatNavBarKey,
      ));
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(chatNavBarButton);
      await tester.pumpAndSettle();
      //////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(ChatPages));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ChatPages,
        successMessage: 'Find ChatPages Success',
        failedMessage: 'Find ChatPages failed',
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 5));
      ////////////////////////////
      final Finder myContactsFloatingActionButton = find.byKey(Key(
        WidgetsKey.myContactsFloatingActionKey,
      ));
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(myContactsFloatingActionButton);
      await tester.pumpAndSettle();
      //////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(MyContactsPage));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: MyContactsPage,
        successMessage: 'Find MyContactsPage Success',
        failedMessage: 'Find MyContactsPage failed',
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 3));
      ////////////////////////////
    },
  );
}
