import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card2.dart';

void main() {
  group("integration test", () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("chat", (Tester) async {
      HomePageCard2(
        boutniqe: Boutique(
          banners: [
            "https://res.cloudinary.com/dtcmozf4d/image/upload/v1/boutiques/boutiques/2024-05-16-6646227b8d82d.png",
            "https://res.cloudinary.com/dtcmozf4d/image/upload/v1/boutiques/boutiques/2024-05-16-6646227dc28f7.jpg"
          ],
          childCategoriesForProductIds: [],
          description: "frgrfgrfegr",
          name: "fgfgfg",
          id: 14,
          mainCategoriesForProductIds: [],
          icon:
              ' https://res.cloudinary.com/dtcmozf4d/image/upload/v1/boutiques/boutiques/icon/2024-05-16-66462280625fd.png',
          position: 0,
        ),
        withSlidingImages: true,
        category_Slug: '',
      );
      await Tester.pumpAndSettle();
      final chat = find.byType(InkWell).first;
      await Tester.tap(chat);
      await Tester.pumpAndSettle();
      // final Button = find
      //     .byWidget(IconButton(
      //       onPressed: () {},
      //       icon: Icon(Icons.abc),
      //     ))
      //     .first;

      // await Tester.tap(Button);

      // expect(
      //     await Tester.getSemantics(chat), matchesSemantics(isChecked: true));
    });
  });
}
