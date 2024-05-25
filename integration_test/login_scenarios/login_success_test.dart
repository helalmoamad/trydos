import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/main.dart' as app;

import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

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

  testWidgets(
    'Login page test',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await GlobalTestFunctions.waitFor(tester, find.byType(RegistrationPage),
          timeout: const Duration(seconds: 30));

      expect(find.byType(RegistrationPage), findsOneWidget);
    },
  );
}
