import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/main.dart' as app;
import '../../utils/global_test_functions.dart';
import '../../shared/shared_scenarios.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Login success test ',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(tester: tester);
      //////////////////////////
      await GlobalTestFunctions.enterTestOtp(tester: tester, number: '9');
      await Future.delayed(const Duration(seconds: 5));
      //////////////////////////
      await GlobalTestFunctions.waitFor(tester, find.byType(LoginSuccessfully));
      //////////////////////////
      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: LoginSuccessfully,
        successMessage: 'Find LoginSuccessfully Success',
        failedMessage: 'Find LoginSuccessfully failed',
      );
    },
  );
}
