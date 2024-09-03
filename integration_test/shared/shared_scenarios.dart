import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/authentication/presentation/pages/register_completed.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/features/authentication/presentation/widgets/create_account_section.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/authentication/presentation/widgets/welcome_section.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import '../utils/global_test_functions.dart';

class SharedScenarios {
  static final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  static Future<void> goToVerifyOtp({
    required WidgetTester tester,
    required bool isForLogin,
    bool isAfterAddName = false,
    String phoneNumber = '963997412860',
  }) async {
    if (!isAfterAddName) {
      await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: RegistrationPage,
        successMessage: 'Find Registration Page Success',
        failedMessage: 'Find Registration Page failed',
      );
      ////////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: WelcomeSection,
        successMessage: 'Find WelcomeSection Success',
        failedMessage: 'Find WelcomeSection failed',
      );
      ////////////////////////////
      final Finder haveAccountButton =
          find.byKey(Key(WidgetsKey.haveAccountButtonKey));
      final Finder createNewAccountButton =
          find.byKey(Key(WidgetsKey.createNewAccountButtonKey));
      await Future.delayed(const Duration(seconds: 1));
      if (isForLogin) {
        await tester.tap(haveAccountButton);
      } else {
        await tester.tap(createNewAccountButton);
      }
      await tester.pumpAndSettle();
      //////////////////////////
      if (!isForLogin) {
        await GlobalTestFunctions.findWidget(
          tester: tester,
          widgetType: CreateAccountSection,
          successMessage: 'Find CreateAccountSection Success',
          failedMessage: 'Find CreateAccountSection failed',
        );
        final Finder agreeContinueButton =
            find.byKey(Key(WidgetsKey.agreeContinueButtonKey));
        await Future.delayed(const Duration(seconds: 1));
        await tester.tap(agreeContinueButton);
        await tester.pumpAndSettle();
      }
    }
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: InsertPhoneTab,
      successMessage: 'Find InsertPhoneTab Success',
      failedMessage: 'Find InsertPhoneTab failed',
    );
    //////////////////////////
    final Finder phoneField =
        find.byKey(Key(WidgetsKey.loginPhoneFormFieldKey));
    final Finder confirmPhoneButton =
        find.byKey(Key(WidgetsKey.loginConfirmPhoneButtonKey));

    await tester.enterText(phoneField, phoneNumber);
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(confirmPhoneButton);
    await tester.pumpAndSettle();
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: VerificationMethods,
      successMessage: 'Find VerificationMethods Success',
      failedMessage: 'Find VerificationMethods failed',
    );
    //////////////////////////
    final Finder chooseWhatsAppButton =
        find.byKey(Key(WidgetsKey.chooseWhatsappButtonKey));
    await tester.tap(chooseWhatsAppButton);
    await tester.pumpAndSettle();
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: VerifyOtp,
      successMessage: 'Find VerifyOtp Success',
      failedMessage: 'Find VerifyOtp failed',
    );
  }

  static Future<void> countryDropDown({required WidgetTester tester}) async {
    final Finder countryDropDownWidget =
        find.byKey(Key(WidgetsKey.countryDropDownKey));
    if (countryDropDownWidget.evaluate().isEmpty) {
      print('DropdownButton not found.');
    } else {
      await tester.tap(countryDropDownWidget);
      await tester.pumpAndSettle();
      ///////////////////
      final firstItemFinder = find
          .descendant(
            of: find.byType(DropdownMenuItem<String>),
            matching: find.byType(Text),
          )
          .first;

      await tester.tap(firstItemFinder);
      await tester.pumpAndSettle();
      final selectedText =
          (firstItemFinder.evaluate().first.widget as Text).data;
      expect(find.text(selectedText!), findsOneWidget);
      await Future.delayed(const Duration(seconds: 3));
      ///////////////////
      final Finder chooseCountryButton =
          find.byKey(Key(WidgetsKey.chooseCountryButtonKey));
      await tester.tap(chooseCountryButton);
      await tester.pumpAndSettle();
    }
  }

  /////////////////////////////////////////
  static Future<void> registerGuest({required WidgetTester tester}) async {
    await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage));

    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: RegistrationPage,
      successMessage: 'Find Registration Page Success',
      failedMessage: 'Find Registration Page failed',
    );
    ////////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: WelcomeSection,
      successMessage: 'Find WelcomeSection Success',
      failedMessage: 'Find WelcomeSection failed',
    );
    ////////////////////////////
    await testTokensAreNull(isJustForMarketToken: true);
    ////////////////////////////
    final Finder laterTakeLookButton =
        find.byKey(Key(WidgetsKey.laterTakeLookKey));
    await Future.delayed(const Duration(seconds: 1));
    await tester.tap(laterTakeLookButton);
    await tester.pumpAndSettle();
    ////////////////////////////
    await countryDropDown(tester: tester);
    ////////////////////////////
    await GlobalTestFunctions.waitFor(tester, find.byType(HomePage),
        timeout: Duration(seconds: 40));
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: HomePage,
      successMessage: 'Find HomePage Success',
      failedMessage: 'Find HomePage failed',
    );
  }

  static Future<void> testTokensAreNull({
    required bool isJustForMarketToken,
    bool isJustForStoryChatTokens = false,
  }) async {
    if (isJustForMarketToken) {
      try {
        expect(prefsRepository.marketToken, isNull);
        debugPrint('marketToken is Null before');
      } catch (e) {
        print(
            '//////// marketToken is NOT null before Failure: //////////\n $e');
        rethrow;
      }
    } else if (isJustForStoryChatTokens) {
      try {
        expect(prefsRepository.storiesToken, isNull);
        debugPrint('storiesToken is Null before');
      } catch (e) {
        print(
            '//////// storiesToken is Not Null before Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      try {
        expect(prefsRepository.chatToken, isNull);
        debugPrint('chatToken is Null before');
      } catch (e) {
        print('//////// chatToken is Not Null before Failure: //////////\n $e');
        rethrow;
      }
    } else {
      try {
        expect(prefsRepository.marketToken, isNull);
        debugPrint('marketToken is Null before');
      } catch (e) {
        print(
            '//////// marketToken is Not Null before Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      try {
        expect(prefsRepository.storiesToken, isNull);
        debugPrint('storiesToken is Null before');
      } catch (e) {
        print(
            '//////// storiesToken is Not Null before Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      try {
        expect(prefsRepository.chatToken, isNull);
        debugPrint('chatToken is Null before');
      } catch (e) {
        print('//////// chatToken is Not Null before Failure: //////////\n $e');
        rethrow;
      }
    }
  }

  static Future<void> testTokensAreNotNull(
      {required bool isJustForMarketToken}) async {
    if (isJustForMarketToken) {
      try {
        expect(prefsRepository.marketToken, isNotNull);
        debugPrint('marketToken is NOT null after');
      } catch (e) {
        print('//////// marketToken is null after Failure: //////////\n $e');
        rethrow;
      }
    } else {
      try {
        expect(prefsRepository.marketToken, isNotNull);
        debugPrint('marketToken is NOT null after ');
      } catch (e) {
        print('//////// marketToken is null after  Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      try {
        expect(prefsRepository.storiesToken, isNotNull);
        debugPrint('storiesToken is NOT null after ');
      } catch (e) {
        print('//////// storiesToken is null after  Failure: //////////\n $e');
        rethrow;
      }
      ////////////////////////////
      try {
        expect(prefsRepository.chatToken, isNotNull);
        debugPrint('chatToken is NOT null after ');
      } catch (e) {
        print('//////// chatToken is null after  Failure: //////////\n $e');
        rethrow;
      }
    }
  }

  static Future<void> addingNameAfterRegister({
    required String name,
    required WidgetTester tester,
  }) async {
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
    final Finder nameField = find.byKey(Key(WidgetsKey.nameFormFieldKey));
    final Finder confirmNameButton =
        find.byKey(Key(WidgetsKey.confirmNameButtonKey));
    await tester.enterText(nameField, name);
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
    await countryDropDown(tester: tester);
    //////////////////////////
    await GlobalTestFunctions.waitFor(tester, find.byType(HomePage));
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      widgetType: HomePage,
      successMessage: 'Find HomePage Success',
      failedMessage: 'Find HomePage failed',
    );
  }

  static Future<void> sendMessageInChat({
    required WidgetTester tester,
    required int messageNumber,
    String text = 'test text message',
  }) async {
    final Finder sendMessageTextField =
        find.byKey(Key(WidgetsKey.sendMessageTextFieldKey));
    final Finder sendMessageInChatButton =
        find.byKey(Key(WidgetsKey.sendMessageInChatButtonKey));
    await tester.enterText(sendMessageTextField, text);
    await Future.delayed(const Duration(seconds: 2));
    await tester.tap(sendMessageInChatButton);
    await tester.pumpAndSettle();
    ////////////////////////////
    final Finder textMessage =
        find.byKey(Key('${WidgetsKey.textMessageCardKey}$messageNumber'));
    ////////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      actual: textMessage,
      withDelayAndPumpAndSettle: false,
      successMessage: 'Find text Message Card  $messageNumber Success',
      failedMessage: 'Find text Message Card $messageNumber failed',
    );
    ////////////////////////////
    final Finder messageSentArrow =
        find.byKey(Key('${WidgetsKey.messageSentArrowKey}$messageNumber'));
    ////////////////////////////
    await GlobalTestFunctions.waitFor(tester, messageSentArrow);
    //////////////////////////
    await GlobalTestFunctions.findWidget(
      tester: tester,
      actual: messageSentArrow,
      withDelayAndPumpAndSettle: false,
      successMessage: 'Find message Sent Arrow $messageNumber Success',
      failedMessage: 'Find message Sent Arrow failed',
    );
  }
}
