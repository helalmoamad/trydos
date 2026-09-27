import 'package:get_it/get_it.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';

/// يعيد تحميل كل ما تعرضه الصفحة الرئيسية.
///
/// تعريف واحد يستعمله السحب للتحديث، وتغيير اللغة، وتغيير البلد. قبل ذلك كان
/// كل موضع يطلب ما يتذكّره صاحبه، فتبقى بعض الأقسام على بيانات اللغة أو البلد
/// السابق حتى يسحب المستخدم الشاشة بنفسه.
///
/// تنبيه: يجب أن تكون اللغة والبلد الجديدان محفوظين **قبل** الاستدعاء، لأن
/// ترويستي `lang` و`country` تُبنيان من القيمة الحالية لحظة إنشاء كل طلب.
void refreshHomeScreenData() {
  // كل قسم يُطلب فقط إن كان الـ bloc الخاص به مسجّلاً: بعض المسارات (اختبارات
  // الوحدة مثلاً) تسجّل ما تحتاجه وحده، ولا يصحّ أن يُسقط غيابُ قسمٍ التحديثَ
  // كلّه أو يرمي خطأً في مسح الكاش.
  if (GetIt.I.isRegistered<BoutiqueBloc>()) {
    final BoutiqueBloc boutiqueBloc = GetIt.I<BoutiqueBloc>();
    for (final String boutiqueSlug in const <String>[
      "*featured*",
      "*flashDeal*",
      "*recommended*",
    ]) {
      boutiqueBloc.add(
        GetProductWithFiltersWithoutCancelingPreviousEvents(
          categorySlugs: const [],
          cashedOrginalBoutique: true,
          boutiqueSlug: boutiqueSlug,
        ),
      );
    }
  }

  if (GetIt.I.isRegistered<CategoryBloc>()) {
    final CategoryBloc categoryBloc = GetIt.I<CategoryBloc>();
    categoryBloc.add(const GetMainCategoriesEvent(getWithPrefech: false));
    categoryBloc.add(
      GetHomeBoutiqesEvent(
        getWithPrefetchToStoreInMemory: false,
        getWithOutPrefetchForEachBoutiques: true,
        categorySlug: "Empty",
        offset: "1",
        forRefresh: true,
      ),
    );
  }

  if (GetIt.I.isRegistered<StoryBloc>()) {
    GetIt.I<StoryBloc>().add(const GetStoryEvent(withPaginition: false));
  }
}
