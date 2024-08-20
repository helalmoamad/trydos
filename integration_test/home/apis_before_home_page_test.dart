import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/constant/widgets_key.dart';
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
    'Test get main categories api ,get story api , get boutiques api , get starting settings apis , get Allowed Countries api , get User Country api , are requested when home page is oppened',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      WidgetsKey.kTestMode = true;

      //////////// Register As Guest //////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////////////////////
      await tester.pumpAndSettle();
      /////////// check by flag if apis are requested  /////////////////

      expect(WidgetsKey.getMainCategoriesFlag, isTrue);

      ///

      expect(WidgetsKey.getStoriesFlag, isTrue);

      ///

      expect(WidgetsKey.getBoutiquesFlag, isTrue);

      ///

      expect(WidgetsKey.getStartingSettingsFlag, isTrue);

      ///

      expect(WidgetsKey.getAllowedCountriesFlag, isTrue);

      ///

      expect(WidgetsKey.getUserCountryFlag, isTrue);

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
