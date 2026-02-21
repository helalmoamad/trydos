# تحليل أداء الصفحة الرئيسية (Home Page) – أسباب البطء والـ Lag

تم تحليل الكود تحليلاً ثابتاً (بدون تشغيل DevTools) لتحديد الأسباب المحتملة للبطء والـ lag.

---

## 1. إعادة تعيين `FlutterError.onError` داخل `build()` — تأثير كبير

**الموقع:** `home_page.dart` سطر ~387 و `home_page_boutique_card.dart` سطر ~47

```dart
@override
Widget build(BuildContext context) {
  FlutterError.onError = (FlutterErrorDetails error) { ... };
  // ...
}
```

**المشكلة:** في كل مرة تُبنى فيها الشجرة (أي عند أي rebuild للصفحة أو لأي كارد) يتم استبدال معالج الأخطاء العام. هذا يزيد من عمل الـ build ويُحدث سلوكاً غير متوقع.

**الحل:** نقله إلى `initState()` أو إلى مستوى التطبيق (مثلاً في `main.dart`) مرة واحدة فقط.

---

## 2. تعريف دالة `_refreshData()` داخل `build()` — تأثير متوسط

**الموقع:** `home_page.dart` سطور ~392–423

```dart
@override
Widget build(BuildContext context) {
  Future<void> _refreshData() async { ... }
  return RefreshIndicator(
    onRefresh: _refreshData,
    ...
  );
}
```

**المشكلة:** إنشاء دالة جديدة في كل استدعاء لـ `build()` يزيد من ضغط الذاكرة والـ GC ولا داعي له.

**الحل:** نقل `_refreshData` إلى دالة في الـ State (خارج `build`) واستخدامها في `onRefresh`.

---

## 3. معالجة HTML وتواريخ داخل الـ builder — تأثير كبير

**أ) في `home_page_boutique_card.dart`:**
- استدعاء `stripHtmlTags(boutique.description ?? '')` داخل `build()` لكل كارد.
- `stripHtmlTags` تستخدم `parse(htmlString)` من مكتبة `html` — أي تحليل HTML على الـ UI thread في كل إعادة رسم للكارد.

**ب) في `home_page.dart` (سطور ~1232–1275):**
- داخل `BlocBuilder` يتم تنفيذ `products.forEach` مع:
  - `DateFormat('MM/dd/yyyy', 'en_US').parse(...)` لكل منتج
  - حسابات `Duration` وفلترة القائمة
- هذا يحدث عند كل تغيير في الـ state المرتبط، ويُشغّل عمليات ثقيلة على الـ UI thread.

**الحل:**
- تخزين النص بعد إزالة الـ HTML في الـ model أو في متغير محسوب مرة واحدة (مثلاً عند تحميل البوتيك).
- نقل فلترة وت parsing التواريخ إلى الـ Bloc/Repository أو إلى `compute()` (خلفية) وعدم تنفيذها داخل الـ builder.

---

## 4. إرسال أحداث Bloc من داخل `builder` — خطر دوائر إعادة البناء والـ lag

**الموقع:** `home_page.dart` سطور ~1296–1327

```dart
builder: (context, tapIndex, _) {
  if (tapIndex != -1) {
    appBloc.add(HideBottomNavigationBar(true));
    homeBloc.add(IsChangedVariationWhenQtyZeroEvent(...));
    homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(...));
    loadingForRquestProductDetails.value = true;
    // ...
  }
  // ...
}
```

**المشكلة:** استدعاء `add()` على عدة Blocs من داخل الـ builder يؤدي إلى:
- تغيير الـ state → إعادة بناء → تشغيل الـ builder مرة أخرى → احتمال إرسال الأحداث مرة أخرى أو تفاعلات غير متوقعة وزيادة الـ rebuilds والـ lag.

**الحل:** تنفيذ الـ `add()` من مكان تفاعل المستخدم (مثلاً `onTap` أو `onPressed`) وليس من داخل الـ builder. استخدام مثلاً `BlocListener` إذا كنت تريد تنفيذ شيء عند تغيّر الـ state بدون إطلاق أحداث جديدة من الـ builder.

---

## 5. تداخل كثير من الـ BlocBuilder و ValueListenableBuilder — تأثير متوسط إلى كبير

**الملاحظة:** في `home_page.dart` هناك عدة طبقات متداخلة، مثل:
- `BlocBuilder<AppBloc>` → `BlocBuilder<CategoryBloc>` (قوائم البوتيكات)
- ثم `BlocBuilder<AppBloc>` و `BlocBuilder<CategoryBloc>` مرة أخرى (للـ loader)
- ثم `ValueListenableBuilder<bool>` (للظل والبانل)
- ثم `ValueListenableBuilder` مزدوج + `BlocBuilder<BoutiqueBloc>` (المنتجات المميزة/التوصية/العروض)
- ثم `ValueListenableBuilder<int>` و `ValueListenableBuilder<bool>` و `BlocBuilder<HomeBloc>`

**المشكلة:** أي تغيير في أي من هذه الـ states يسبب إعادة بناء لأجزاء كبيرة من الشجرة. مع وجود عمليات ثقيلة (parsing، أحداث Bloc، إلخ) داخل الـ builders يزيد الـ lag.

**الحل:**
- تقليل عمق التداخل بقدر الإمكان.
- استخدام `buildWhen` بدقة (موجود جزئياً لكن يمكن تشديده).
- فصل الأجزاء المستقلة إلى widgets منفصلة مع `const` حيث أمكن حتى لا تُعاد بناء أجزاء لا تتأثر بالتغيير.

---

## 6. CarouselSlider و ListView داخل كل كارد بوتيك — تأثير متوسط

**الموقع:** `home_page_boutique_card.dart`

- استخدام `CarouselSlider.builder` مع `autoPlay` لكل كارد.
- وجود `ListView.builder` إضافي داخل الكارد (سطر ~266) للفئات الفرعية.

**المشكلة:** كل كارد يعرض في viewport يبني كاروسيلاً كاملاً وربما قائمة. مع التمرير السريع يتم بناء/إلغاء بناء العديد من الكروزلات والقوائم، مما يستهلك ذاكرة ويسبب jank.

**الحل:**
- التأكد من أن الـ list الرئيسية تستخدم lazy loading (مثلاً `SliverList`/`ListView.builder`) وأن الارتفاع ثابت أو محسوب بشكل صحيح.
- تقليل عدد الكروزلات النشطة (مثلاً إيقاف الـ autoPlay للعناصر غير المرئية أو استخدام `visibility_detector`).
- وضع حدود لعدد العناصر المُبنية في الـ ListView الداخلية إن أمكن.

---

## 7. استدعاءات `add()` عند فتح البانل من الـ builder — تأثير متوسط

**الموقع:** `home_page.dart` سطور ~951–966

```dart
builder: (context, _isShowPanelForVerified, _) {
  if (_isShowPanelForVerified) {
    if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ?? false)) {
      authBloc.add(SendOtpEvent(...));
    }
    Future.delayed(const Duration(milliseconds: 500), () => panelController.open());
  }
  // ...
}
```

**المشكلة:** في كل مرة يُعاد فيها بناء هذا الـ widget بسبب تغيّر `_isShowPanelForVerified` أو أي parent، قد تُستدعى `authBloc.add` و `panelController.open()` مرة أخرى.

**الحل:** تنفيذ فتح البانل وإرسال الـ OTP من مكان واحد (مثلاً عند تغيير القيمة للمرة الأولى فقط) باستخدام علم أو `BlocListener`، وعدم الاعتماد على الـ builder لتنفيذ side effects.

---

## 8. Listener التمرير (Scroll) — تأثير منخفض إلى متوسط

**الموقع:** `listenToScroll()` مع debounce 600ms

- عند الوصول إلى 60% و 40% من نهاية القائمة يتم إطلاق أحداث (pagination، prefetch).
- المنطق يعتمد على حسابات من الـ scroll position وربطها بالـ category الحالية.

**ملاحظة:** الـ debounce جيد، لكن إذا كانت الأحداث تسبب تحميلات ثقيلة أو إعادة بناء كبيرة، يمكن أن يشعر المستخدم بتمدد أو تجمد عند الوصول لنهاية القائمة.

**الحل:** التأكد من أن الـ pagination لا تُطلَق بشكل متكرر (مثلاً عدم الإطلاق مرة أخرى حتى انتهاء التحميل السابق)، واستخدام `buildWhen` حتى لا تُعاد بناء كل القائمة عند تغيّر الـ pagination state.

---

## 9. `setState(() {})` من داخل الـ panel — تأثير منخفض

**الموقع:** سطر ~1062 عند `moveToNextStep`:

```dart
setState(() {});
```

**المشكلة:** استدعاء `setState` على الـ Home page بالكامل عند الانتقال لخطوة التالي في البانل يسبب إعادة بناء الصفحة كاملة.

**الحل:** إن أمكن، عزل حالة البانل في state منفصل أو في widget فرعي حتى لا تحتاج إلى `setState` على الـ Home بالكامل.

---

## 10. نقاط إضافية سريعة

- **RepaintBoundary:** الـ `sliverListSeparated` يمرّر `addRepaintBoundaries: true` (القيمة الافتراضية)، وهذا جيد. يمكن إضافة `RepaintBoundary` حول أقسام ثقيلة (مثلاً الـ bottom sheet أو الأقسام الثابتة) لتقليل إعادة الرسم.
- **مفاتيح الـ list:** استخدام `reRenderingListViewKey[currentSlug]` للتحكم بإعادة البناء جيد؛ التأكد من استقرار المفتاح عند الـ pagination لتفادي إعادة إنشاء عناصر لا داعي لها.
- **Shimmer:** وجود 10 عناصر shimmer في حالة التحميل الأولي مع `List.generate(5, ...)` لكل عنصر قد يكون ثقيلاً؛ يمكن تقليل العدد أو الارتفاع في الشيمر.

---

## ملخص أولويات المعالجة

| الأولوية | المشكلة | الإجراء المقترح |
|----------|---------|------------------|
| عالية    | `FlutterError.onError` و `_refreshData` داخل `build` | نقلهما خارج `build` (initState / دوال في State) |
| عالية    | تحليل HTML (`stripHtmlTags`) في كل build للكارد | حساب النص مرة واحدة (model أو cache) |
| عالية    | parsing التواريخ وفلترة القوائم داخل الـ BlocBuilder | نقلها إلى Bloc/Repository أو `compute()` |
| عالية    | إرسال أحداث Bloc من داخل الـ builder عند `tapIndex != -1` | نقل المنطق إلى `onTap` أو `BlocListener` |
| متوسطة   | side effects (فتح البانل، إرسال OTP) من داخل الـ builder | استخدام علم أو `BlocListener` لمرة واحدة |
| متوسطة   | تداخل الـ BlocBuilder و ValueListenableBuilder | تقليل التداخل وفصل widgets و `buildWhen` أدق |
| متوسطة   | Carousel + ListView داخل كل كارد | تحسين الـ lazy loading وإيقاف الـ autoPlay خارج الشاشة |
| منخفضة   | `setState` على الصفحة كاملة من البانل | عزل حالة البانل في state أصغر |

---

## تشغيل DevTools يدوياً لقياس التأثير

لرصد البطء والـ lag فعلياً على جهازك:

1. تشغيل التطبيق في وضع profile:
   ```bash
   flutter run -d chrome --profile
   ```
   أو لجهاز Android:
   ```bash
   flutter run -d <device_id> --profile
   ```

2. فتح الرابط الذي يظهر في الـ console لـ **Flutter DevTools**.

3. في DevTools:
   - **Performance:** تسجيل جلسة أثناء التمرير وفتح الصفحة الرئيسية، ثم مراجعة frames التي تجاوزت 16ms (أو 8ms لـ 120fps).
   - **CPU Profiler:** لمعرفة أي الدوال تستهلك وقتاً (مثلاً `parse`، `DateFormat.parse`، `build`).
   - **Widget rebuilds:** التحقق من عدد مرات إعادة بناء الـ widgets عند التمرير أو عند فتح البانل.

بعد تطبيق التعديات أعلاه، إعادة القياس في DevTools لمقارنة التحسن.
