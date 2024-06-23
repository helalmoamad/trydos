import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/authentication/presentation/widgets/adding_name.dart';
import 'package:trydos/main.dart' as app;
import '../../shared/shared_scenarios.dart';
import '../../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Create account to new user and enter name test',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      //////////////////////////
      await SharedScenarios.goToVerifyOtp(
        tester: tester,
        isForLogin: false,
        phoneNumber: '963111111111',
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
    },
  );
}
