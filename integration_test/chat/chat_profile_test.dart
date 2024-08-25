import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;

import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Go to profile page for chat, test media and files information',
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

      /////////// show profile for the user ///////////
      final Finder goToProfileButton = find.byKey(
        Key(
          WidgetsKey.goToProfileButtonKey,
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(goToProfileButton);
      await tester.pumpAndSettle();
      //////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(ProfilePage));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ProfilePage,
        successMessage: 'Find ProfilePage Success',
        failedMessage: 'Find ProfilePage failed',
      );
      //////////////////////////
      ////////////////////////////
      final Finder imageCountInEachChat = find.byKey(Key(
        WidgetsKey.imageCountInEachChatKey,
      ));
      ////////////////////////////
      final Finder videoCountInEachChat = find.byKey(Key(
        WidgetsKey.videoCountInEachChatKey,
      ));
      ////////////////////////////
      final Finder fileCountInEachChat = find.byKey(Key(
        WidgetsKey.fileCountInEachChatKey,
      ));
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: imageCountInEachChat,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find imageCountInEachChat  Success',
        failedMessage: 'Find imageCountInEachChat  failed',
      );
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: videoCountInEachChat,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find videoCountInEachChat  Success',
        failedMessage: 'Find videoCountInEachChat  failed',
      );
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: fileCountInEachChat,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find fileCountInEachChat  Success',
        failedMessage: 'Find fileCountInEachChat  failed',
      );
      ///////////////////////////
      final imageTextWidget = tester.widget<Text>(imageCountInEachChat);
      expect(imageTextWidget.data, '2');
      ///////////////////////////
      final videoTextWidget = tester.widget<Text>(videoCountInEachChat);
      expect(videoTextWidget.data, '0');
      ///////////////////////////
      final fileTextWidget = tester.widget<Text>(fileCountInEachChat);
      expect(fileTextWidget.data, '1');
      //////////////////////////
      await Future.delayed(const Duration(seconds: 5));
      final Finder backFromProfile = find.byKey(
        Key(
          WidgetsKey.backFromProfileKey,
        ),
      );
      await tester.tap(backFromProfile);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: SinglePageChat,
        successMessage: 'Find SinglePageChat Success',
        failedMessage: 'Find SinglePageChat failed',
      );
    },
  );
}
