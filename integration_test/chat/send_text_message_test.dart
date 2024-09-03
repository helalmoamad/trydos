import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/chat/presentation/pages/chat_page_content.dart';
import 'package:trydos/features/chat/presentation/pages/chat_pages.dart';
import 'package:trydos/features/chat/presentation/pages/contacts_page.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Go to chat section , choose new contact , send text message , replay text message , forward text message , back and delete chat',
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
      final Finder contactCardButton = find.byKey(
        Key(
          '${WidgetsKey.contactCardKey}0',
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(contactCardButton);
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
      //////////////////////////
      await SharedScenarios.sendMessageInChat(tester: tester, messageNumber: 0);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      ///////////  Replay message  ////////////
      final Finder messageCardWidget =
          find.byKey(Key('${WidgetsKey.messageCardKey}0'));
      final Finder replayTextWidget = find.byKey(Key(WidgetsKey.replayTextKey));
      // /////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: messageCardWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find message Card Widget Widget  Success',
        failedMessage: 'Find message Card Widget To Widget failed',
      );
      /////////////////////////////
      await tester.ensureVisible(messageCardWidget);
      await tester.pumpAndSettle();
      ////////////////////////////
      await tester.drag(
        messageCardWidget,
        Offset(-100, 0),
      );
      ////////////////////////////
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: replayTextWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find replay Text Widget  Success',
        failedMessage: 'Find replay Text Widget failed',
      );
      //////////////////////////////////////////////
      final Finder sendMessageTextField =
          find.byKey(Key(WidgetsKey.sendMessageTextFieldKey));
      final Finder sendMessageInChatButton =
          find.byKey(Key(WidgetsKey.sendMessageInChatButtonKey));
      await tester.enterText(
          sendMessageTextField, 'test replay to my text message');
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(sendMessageInChatButton);
      await tester.pumpAndSettle();
      // ////////////////////////////
      final Finder replayOnMeMessage =
          find.byKey(Key('${WidgetsKey.replayOnMeMessageKey}0'));
      // ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: replayOnMeMessage,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find replayOnMeMessage  Success',
        failedMessage: 'Find replayOnMeMessage failed',
      );
      // ////////////////////////////
      final Finder messageSentArrow2 =
          find.byKey(Key('${WidgetsKey.messageSentArrowKey}0'));
      ////////////////////////////
      await GlobalTestFunctions.waitFor(tester, messageSentArrow2);
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: messageSentArrow2,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find message Sent Arrow  Success',
        failedMessage: 'Find message Sent Arrow  failed',
      );

      await Future.delayed(const Duration(seconds: 4));

      ///////////  Forward message  ////////////
      await SharedScenarios.sendMessageInChat(
          tester: tester, messageNumber: 0, text: 'test ForWard text message');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: messageCardWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find message Card Widget  Success',
        failedMessage: 'Find message Card Widget  failed',
      );

      await tester.longPress(messageCardWidget);
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder forWardMessageWidget =
          find.byKey(Key('${WidgetsKey.forWardMessageKey}0'));

      await GlobalTestFunctions.waitFor(tester, forWardMessageWidget);

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: forWardMessageWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find  forWard Message Widget Success',
        failedMessage: 'Find  forWard Message Widget failed',
      );

      Future.delayed(Duration(seconds: 4));
      await tester.tap(forWardMessageWidget);
      await tester.pumpAndSettle();
      //////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(ChatPageContent));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ChatPageContent,
        successMessage: 'Find ChatPageContent Success',
        failedMessage: 'Find ChatPageContent failed',
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      ////////////////////////////
      final Finder chatConversationCard =
          find.byKey(Key('${WidgetsKey.chatConversationCardKey}0'));
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: chatConversationCard,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find chatConversationCard  Success',
        failedMessage: 'Find chatConversationCard failed',
      );
      ////////////////////////////////////////
      await tester.tap(chatConversationCard);
      await tester.pumpAndSettle();
      ////////////////////////////
      final Finder textMessage =
          find.byKey(Key('${WidgetsKey.textMessageCardKey}0'));
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: textMessage,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find text Message Card  Success',
        failedMessage: 'Find text Message Card  failed',
      );
      ////////////////////////////////////////
      final Finder forwardedArrow =
          find.byKey(Key('${WidgetsKey.forwardedArrowKey}0'));
      ////////////////////////////
      await GlobalTestFunctions.waitFor(tester, forwardedArrow);
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: forwardedArrow,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find  forwarded Arrow Success',
        failedMessage: 'Find  forwarded Arrow failed',
      );
      ////////////////////////////
      final Finder messageSentArrow =
          find.byKey(Key('${WidgetsKey.messageSentArrowKey}0'));
      ////////////////////////////
      await GlobalTestFunctions.waitFor(tester, messageSentArrow);
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: messageSentArrow,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find message Sent Arrow Success',
        failedMessage: 'Find message Sent Arrow failed',
      );
      await Future.delayed(const Duration(seconds: 2));

      ///////////  Delete message   ////////////
      // await SharedScenarios.sendMessageInChat(tester: tester, messageNumber: 0);
      // await tester.pumpAndSettle();
      // await Future.delayed(const Duration(seconds: 2));

      // final Finder messageCardWidget =
      //     find.byKey(Key('${WidgetsKey.messageCardKey}0'));
      // //////////////////////////
      // await GlobalTestFunctions.findWidget(
      //   tester: tester,
      //   actual: messageCardWidget,
      //   withDelayAndPumpAndSettle: false,
      //   successMessage: 'Find message Card Widget  Success',
      //   failedMessage: 'Find message Card Widget  failed',
      // );

      // await tester.longPress(messageCardWidget);
      // await tester.pumpAndSettle();
      // ////////////////////////////
      // final Finder deleteMessageWidget =
      //     find.byKey(Key('${WidgetsKey.deleteMessageKey}0'));
      // ////////////////////////////
      // await GlobalTestFunctions.waitFor(tester, deleteMessageWidget);
      // //////////////////////////
      // await GlobalTestFunctions.findWidget(
      //   tester: tester,
      //   actual: deleteMessageWidget,
      //   withDelayAndPumpAndSettle: false,
      //   successMessage: 'Find  delete Message Widget Success',
      //   failedMessage: 'Find  delete Message Widget failed',
      // );
      // Future.delayed(Duration(seconds: 4));
      // await tester.tap(deleteMessageWidget);
      // await tester.pumpAndSettle();
      // //////////////////////////
      // final Finder deleteOnlyMeButton =
      //     find.byKey(Key('${WidgetsKey.deleteOnlyMeButtonKey}0'));
      // await GlobalTestFunctions.findWidget(
      //   tester: tester,
      //   actual: deleteOnlyMeButton,
      //   withDelayAndPumpAndSettle: false,
      //   successMessage: 'Find deleteOnlyMeButton Success',
      //   failedMessage: 'Find deleteOnlyMeButton failed',
      // );
      // Future.delayed(Duration(seconds: 2));
      // await tester.tap(deleteOnlyMeButton);
      // await tester.pumpAndSettle();
      // await tester.pumpAndSettle();
      // await tester.pumpAndSettle();

      // await Future.delayed(const Duration(seconds: 2));

      // final Finder oldMessageCardWidget =
      //     find.byKey(Key('${WidgetsKey.messageCardKey}1'));
      // await GlobalTestFunctions.findNoWidget(
      //   tester: tester,
      //   actual: oldMessageCardWidget,
      //   withDelayAndPumpAndSettle: false,
      //   successMessage: 'Find secondMessageCardWidget  Success',
      //   failedMessage: 'Find secondMessageCardWidget failed',
      // );

      ////////////// Delete conversation  //////////////
      final Finder backFromChatButton =
          find.byKey(Key(WidgetsKey.backFromChatKey));
      await Future.delayed(const Duration(seconds: 2));
      await tester.tap(backFromChatButton);
      await tester.pumpAndSettle();
      //////////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(ChatPageContent));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: ChatPageContent,
        successMessage: 'Find ChatPageContent Success',
        failedMessage: 'Find ChatPageContent failed',
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: chatConversationCard,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find chatConversationCard  Success',
        failedMessage: 'Find chatConversationCard failed',
      );
      final Finder deleteChatConversationIcon =
          find.byKey(Key('${WidgetsKey.deleteChatConversationIconKey}0'));
      ////////////////////////////
      await tester.dragUntilVisible(
        deleteChatConversationIcon,
        chatConversationCard,
        Offset(300, 0),
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
      ////////////////////////////
      await tester.tap(deleteChatConversationIcon);
      await tester.pumpAndSettle();
      ////////////////////////////
      await GlobalTestFunctions.findNoWidget(
        tester: tester,
        actual: chatConversationCard,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find chatConversationCard  Success',
        failedMessage: 'Find chatConversationCard failed',
      );
      ////////////////////////////
      await Future.delayed(const Duration(seconds: 2));
    },
  );
}
