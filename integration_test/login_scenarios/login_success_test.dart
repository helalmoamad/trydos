import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/main.dart' as app;
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Login page test',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage));

      try {
        expect(find.byType(RegistrationPage), findsOneWidget);
        debugPrint('find RegistrationPage Success');
      } catch (e) {
        print('//////// Find RegistrationPage failed Failure: //////////\n $e');
        rethrow;
      }
    },
  );
}



















// const MethodChannel _channel = MethodChannel('flutter_callkit_incoming');

  // setUpAll(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
  //       .setMockMethodCallHandler(_channel, (MethodCall methodCall) async {
  //     if (methodCall.method == 'activeCalls') {
  //       return []; // Mock the response you expect from the native code
  //     }

  //     if (methodCall.method == 'endAllCalls') {
  //       return []; // Mock the response you expect from the native code
  //     }
  //     return null;
  //   });
  // });

  // tearDownAll(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
  //       .setMockMethodCallHandler(_channel, null);
  // });
