import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Test get main categories api ,get story api , get boutiques api , get starting settings apis , get Allowed Countries api , get User Country api , are requested for one time when home page is oppened',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;

      //////////// Register As Guest //////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////////////////////
      await tester.pumpAndSettle();
      /////////// check by flag if apis are requested for one time /////////////////
      print(
          '///// getMainCategoriesFlag count : ${TestVariables.getMainCategoriesRequestCountFlag} ////////////////////');
      print(
          '///// getStoriesFlag count : ${TestVariables.getStoriesRequestCountFlag} ////////////////////');
      print(
          '///// getBoutiquesFlag count : ${TestVariables.getBoutiquesRequestCountFlag} ////////////////////');
      print(
          '///// getStartingSettingsFlag count : ${TestVariables.getStartingSettingsRequestCountFlag} ////////////////////');
      print(
          '///// getAllowedCountriesFlag count : ${TestVariables.getAllowedCountriesRequestCountFlag} ////////////////////');
      print(
          '///// getUserCountryFlag count : ${TestVariables.getUserCountryRequestCountFlag} ////////////////////');

      expect(TestVariables.getMainCategoriesFlag, isTrue);
      expect(TestVariables.getMainCategoriesRequestCountFlag, equals(1));

      ///

      expect(TestVariables.getStoriesFlag, isTrue);
      expect(TestVariables.getStoriesRequestCountFlag, equals(1));

      ///

      expect(TestVariables.getBoutiquesFlag, isTrue);
      expect(TestVariables.getBoutiquesRequestCountFlag, equals(1));

      ///

      expect(TestVariables.getStartingSettingsFlag, isTrue);
      expect(TestVariables.getStartingSettingsRequestCountFlag, equals(1));

      ///

      expect(TestVariables.getAllowedCountriesFlag, isTrue);
      expect(TestVariables.getAllowedCountriesRequestCountFlag, equals(1));

      ///

      expect(TestVariables.getUserCountryFlag, isTrue);
      expect(TestVariables.getUserCountryRequestCountFlag, equals(1));

      ///////////////// test the state of getting apis  /////////////////////////////

      HomeBloc homeBloc = GetIt.I<HomeBloc>();
      final homeState = homeBloc.state;

      StoryBloc storyBloc = GetIt.I<StoryBloc>();
      final storyState = storyBloc.state;

      AuthBloc authBloc = GetIt.I<AuthBloc>();
      final authState = authBloc.state;

      expect(
          homeState.getMainCategoriesStatus, GetMainCategoriesStatus.success);
      /////////////////////
      expect(storyState.getStoriesStatus, GetStoriesStatus.success);
      /////////////////////
      expect(homeState.getStartingSettingsStatus,
          GetStartingSettingsStatus.success);
      /////////////////////
      expect(homeState.getAllowedCountriesModel, isNotNull);
      /////////////////////
      expect(
          authState.getCustomerCountryStatus, GetCustomerCountryStatus.success);
    },
  );
}
