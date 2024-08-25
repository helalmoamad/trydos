import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Go to chat page , load more messages test',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
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
      final Finder testUser = find.text('test user');
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: testUser,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find testUser  Success',
        failedMessage: 'Find testUser  failed',
      );
      /////////////////////////////////////////////////////////
      await tester.tap(testUser);
      await tester.pumpAndSettle();
      //////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(SinglePageChat));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: SinglePageChat,
        successMessage: 'Find SinglePageChat Success',
        failedMessage: 'Find SinglePageChat failed',
      );
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder messagesList = find.byKey(Key(
        WidgetsKey.messagesListKey,
      ));
      ////////////////////////////
      int initialItemCount = 0;
      while (tester.any(find
          .byKey(Key('${WidgetsKey.messagesListCardKey}$initialItemCount')))) {
        initialItemCount++;
      }
      ///////////////////////////
      debugPrint(
          '///initial messagesList length //// $initialItemCount ////////////');
      await Future.delayed(const Duration(seconds: 2));
      ///////////////////////////
      await tester.drag(
          messagesList, Offset(0, 600)); // Adjust the offset if needed
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      ///////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      ///////////////////////////
      int finalItemCount = initialItemCount;
      while (tester.any(find
          .byKey(Key('${WidgetsKey.messagesListCardKey}$finalItemCount')))) {
        finalItemCount++;
      }
      ///////////////////////////
      debugPrint(
          '///final messagesList length //// $finalItemCount ////////////');

      // Verify if more items are loaded
      expect(finalItemCount, greaterThan(initialItemCount));
    },
  );
}
