import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/categories_filter_list.dart';
import 'package:trydos/features/search/presentation/pages/search_page.dart';
import 'package:trydos/main.dart' as app;
import '../shared/shared_scenarios.dart';
import '../utils/global_test_functions.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'From home search , select boutique , then press search button , move to the filtering page ,testing that the filtering data (category, etc.) belongs to this boutique',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      TestVariables.kTestMode = true;
      /////////////  Register As Guest  /////////////
      await SharedScenarios.registerGuest(tester: tester);
      ////////////// Find Home Search Icon //////////////
      final Finder homeSearchIconWidget =
          find.byKey(Key(WidgetsKey.homeSearchIconKey));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: homeSearchIconWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find Home Search Icon Widget Success',
        failedMessage: 'Find Home Search Icon Widget failed',
      );

      await tester.tap(homeSearchIconWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        widgetType: SearchPage,
        successMessage: 'Find Search Page Success',
        failedMessage: 'Find Search Page failed',
      );
      //////////////////  Scroll until find best saller /////////////////////////////////////
      final Finder searchPageBoutiqueListWidget =
          find.byKey(Key(WidgetsKey.searchPageBoutiqueListKey));

      await GlobalTestFunctions.findWidget(
        tester: tester,
        actual: searchPageBoutiqueListWidget,
        withDelayAndPumpAndSettle: false,
        successMessage: 'Find searchPageBoutiqueListWidget Success',
        failedMessage: 'Find searchPageBoutiqueListWidget failed',
      );

      print(
          '/////////// laingqqq  ${HelperFunctions.getInitLocale()} ///////////////');

      bool isFound = false;
      int index = 0;
      while (!isFound) {
        // Try to find the boutique name widget by key with index
        Finder searchPageBoutiqueNameWidget =
            find.byKey(Key('${WidgetsKey.searchPageBoutiqueNameKey}$index'));
        try {
          expect(searchPageBoutiqueNameWidget, findsOneWidget);

          print('find index : $index');

          // Get the widget's text
          String name = tester
              .widget<MyTextWidget>(searchPageBoutiqueNameWidget)
              .text
              .toString();

          // Check if the boutique name is 'best saller'
          if (name == 'best saller test') {
            print('find best saller : $index');
            isFound = true;
            break; // Exit the loop if the desired item is found
          } else {
            print('Not best saller : $index');
            index++;
          }
        } catch (e) {
          // If the item isn't found, try scrolling to the right
          try {
            double leftOrRight =
                HelperFunctions.getInitLocale().toString().contains('en')
                    ? -200
                    : 200;

            await tester.drag(searchPageBoutiqueListWidget,
                Offset(leftOrRight, 0)); // Scroll right by 200 pixels
            await tester.pumpAndSettle();

            print('scroll for $index');
            expect(searchPageBoutiqueNameWidget, findsOneWidget);
            print('find index after scroll : $index');
          } catch (scrollError) {
            // If the scroll fails, we have reached the end of the list
            fail('Reached the end of the list without finding the item');
          }
        }
      }

      await tester.pumpAndSettle();

      expect(isFound, isTrue);

      ////////////// Get Boutique Id  /////////////////////////
      HomeBloc homeBloc = GetIt.I<HomeBloc>();
      HomeState homeState = homeBloc.state;

      String key1 = 'search';
      Filter filters =
          homeState.getProductFiltersModel[key1]?.filters ?? Filter();

      String boutiqueId = filters.boutiques![index].id.toString();

      String boutiqueBestSellerSlug = filters.boutiques![index].slug.toString();

      print('////////////// Boutique ID : $boutiqueId //////////////');
      print(
          '///////// boutique Slug : $boutiqueBestSellerSlug  ////////////////');

      //////////////////////////////////////////////////

      await Future.delayed(const Duration(seconds: 2));

      final Finder searchBoutiqueNameWidget =
          find.byKey(Key('${WidgetsKey.searchPageBoutiqueNameKey}$index'));

      await tester.tap(searchBoutiqueNameWidget);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      ///////////////////// Search ////////////////////////////////
      ///
      final Finder searchButtonInSearchPageKey =
          find.byKey(Key(WidgetsKey.searchButtonInSearchPageKey));
      final Finder scrollableFinder = find.byType(SearchPage);

      await tester.drag(scrollableFinder, const Offset(0, 2000));
      await tester.pumpAndSettle();

      expect(searchButtonInSearchPageKey, findsOneWidget);

      await tester.tap(searchButtonInSearchPageKey);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      /////////////////////////////////////////////////////
      /////////////////////  product listing filter icon button ////////////////////////
      final Finder filterIconButton = find.byKey(
        Key(WidgetsKey.filterIconKey),
      );

      expect(filterIconButton, findsOneWidget);

      await tester.tap(filterIconButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      /////////////////////  get filter data  ////////////////////////

      final Finder categoriesFilterListFinder =
          find.byType(CategoriesFilterList);

      expect(categoriesFilterListFinder, findsOneWidget);

      String boutiqueSlug = tester
          .widget<CategoriesFilterList>(categoriesFilterListFinder)
          .boutiqueSlug;

      String category = tester
              .widget<CategoriesFilterList>(categoriesFilterListFinder)
              .category ??
          '';

      String key2 = boutiqueSlug + (category);

      print('key2 : $key2');

      homeState = homeBloc.state;

      Filter? filters2 = homeState.getProductFiltersModel[key2]?.filters != null
          ? homeState.getProductFiltersModel[key2]?.filters ?? Filter()
          : Filter();

      print(
          'categories length : ${filters2.categories == null ? null : filters2.categories!.length}');

      // //////////////////// ////////////////////////////////////

      List<String> boutiquesIds = [];

      print(
          'boutiques length : ${filters2.boutiques == null ? null : filters2.boutiques!.length}');

      boutiquesIds.addAll(filters2.boutiques!.map((e) => e.id.toString()));

      print('boutiques Ids : $boutiquesIds');

      await Future.delayed(const Duration(seconds: 2));

      ///////////// check if belong to boutique ////////////////

      bool check = boutiquesIds.contains(boutiqueId);

      print('is belong to boutique : $check');

      expect(check, isTrue);

      String boutiqueSlugInFilterData = filters2.boutiques?[0].slug ?? '';

      print(
          '////// boutiques length : ${filters2.boutiques?.length} /////////////////');

      print(
          '////// boutique Slug In Filter Data : $boutiqueSlugInFilterData /////////////////');

      expect(boutiqueSlugInFilterData, equals(boutiqueBestSellerSlug));

      await Future.delayed(const Duration(seconds: 2));
    },
  );
}
