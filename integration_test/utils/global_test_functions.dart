import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GlobalTestFunctions {
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);

    do {
      if (DateTime.now().isAfter(end)) {
        throw Exception('Timed out waiting for $finder');
      }

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 100));
    } while (finder.evaluate().isEmpty);
  }

  //////////////////////////////////////////////////////////////
  static Future<void> findWidget({
    required WidgetTester tester,
    Type? widgetType,
    dynamic actual,
    bool withDelayAndPumpAndSettle = true,
    int delayInSeconds = 2,
    required String successMessage,
    required String failedMessage,
  }) async {
    try {
      expect(widgetType == null ? actual : find.byType(widgetType),
          findsOneWidget);
      debugPrint(successMessage);
    } catch (e) {
      fail('//////// $failedMessage Failure: //////////\n $e');
    }
    if (withDelayAndPumpAndSettle) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: delayInSeconds));
    }
  }

  //////////////////////////////////////////////////////////////
  static Future<void> findNoWidget({
    required WidgetTester tester,
    dynamic actual,
    Type? widgetType,
    bool withDelayAndPumpAndSettle = true,
    int delayInSeconds = 2,
    required String successMessage,
    required String failedMessage,
  }) async {
    try {
      expect(
          widgetType == null ? actual : find.byType(widgetType), findsNothing);
      debugPrint(successMessage);
    } catch (e) {
      fail('//////// $failedMessage Failure: //////////\n $e');
    }
    if (withDelayAndPumpAndSettle) {
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: delayInSeconds));
    }
  }

  //////////////////////////////////////////////////////////////
  static Future<void> enterTestOtp({
    required WidgetTester tester,
    required String number,
  }) async {
    await Future.delayed(const Duration(seconds: 5));

    final Finder otpItem1 = find.byKey(const Key('otp_item_1'));
    final Finder otpItem2 = find.byKey(const Key('otp_item_2'));
    final Finder otpItem3 = find.byKey(const Key('otp_item_3'));
    final Finder otpItem4 = find.byKey(const Key('otp_item_4'));
    final Finder otpItem5 = find.byKey(const Key('otp_item_5'));
    final Finder otpItem6 = find.byKey(const Key('otp_item_6'));

    await tester.enterText(otpItem1, number);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.enterText(otpItem2, number);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.enterText(otpItem3, number);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.enterText(otpItem4, number);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.enterText(otpItem5, number);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.enterText(otpItem6, number);
    await tester.pumpAndSettle();
  }
}
