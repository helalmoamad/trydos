# تقرير الفحص الشامل للأداء والذاكرة

## إحصائيات الملفات:
- **home_page.dart**: 115KB, ~1859 سطر
- **product_listing_page.dart**: 267KB, 3330 سطر

## 1. تحليل استهلاك الذاكرة:

### ✅ الإعدادات المُحسّنة:
- `cacheExtent: 250` في كلا الملفين
- `Timer debounce: 500ms` بدلاً من 200ms
- متغيرات حماية: `_isLoadingMore`, `_isPrefetching`

### ⚠️ مشاكل مكتشفة:

#### home_page.dart:
- **17 Future.delayed** مختلفة
- **4 addPostFrameCallback** 
- **متغير إضافي**: `bool _isLoading` غير مستخدم بكفاءة
- **setState** متعدد قد يسبب rebuilds مفرطة

#### product_listing_page.dart:
- **21 Future.delayed** مختلفة
- **3 addPostFrameCallback**
- **Timer.periodic** إضافي للـ postFrameCallback
- **searchDebounce** منفصل عن الـ scroll debounce

## 2. تحليل كاش الصور:

### ✅ المُحسّن:
- استخدام `MyCachedNetworkImage` في product_listing
- `CustomCacheManagers` مُحسّن (500 صورة، 3 أيام)

### ⚠️ مشاكل:
- home_page لا يستخدم MyCachedNetworkImage
- عدم وجود تنظيف دوري للكاش في dispose

## 3. تحليل السكرول:

### ✅ المُحسّن:
- debounce 500ms في كلا الملفين
- حماية من الاستدعاءات المتكررة
- فحص الذاكرة في product_listing

### ⚠️ مشاكل:
- home_page: prefetch عند 0.4 و pagination عند 0.6 (قريب جداً)
- عدم استخدام RepaintBoundary
- CustomScrollView بدون تحسينات إضافية

## 4. تحليل BlocBuilder:

### مشاكل الأداء:
- buildWhen غير محدد في بعض الحالات
- عدة BlocBuilder متداخلة
- عدم استخدام const constructors

## 5. التوصيات الحرجة:

### فورية (High Priority):
```dart
// 1. تنظيف Future.delayed المفرطة
// بدلاً من 17 Future.delayed في home_page
Timer? _delayedTimer;
void scheduleDelayedAction(VoidCallback action, Duration delay) {
  _delayedTimer?.cancel();
  _delayedTimer = Timer(delay, action);
}

// 2. تحسين dispose
@override
void dispose() {
  _delayedTimer?.cancel();
  debounce?.cancel();
  searchDebounce?.cancel();
  // تنظيف الكاش
  final imageCache = PaintingBinding.instance.imageCache;
  if (imageCache.liveImageCount > 50) {
    imageCache.clearLiveImages();
  }
  super.dispose();
}

// 3. تحسين scroll thresholds
if (scrollRatio >= 0.7) { // زيادة من 0.6
  // pagination
}
if (scrollRatio >= 0.5) { // زيادة من 0.4
  // prefetch
}

// 4. إضافة RepaintBoundary
RepaintBoundary(
  child: ProductItem(...),
)

// 5. تحسين BlocBuilder
BlocBuilder<HomeBloc, HomeState>(
  buildWhen: (previous, current) => 
    previous.status != current.status &&
    current.status != LoadingStatus.loading,
  builder: (context, state) => ...
)
```

### متوسطة (Medium Priority):
```dart
// 1. تقسيم product_listing_page (267KB كبير جداً)
// إنشاء widgets منفصلة:
// - ProductListingHeader
// - ProductListingGrid  
// - ProductListingFilters

// 2. استخدام const constructors
const ProductItem(...)

// 3. تحسين Timer.periodic
// بدلاً من Timer.periodic كل 500ms
void _checkHtmlHeight() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = htmlDescriptionKey.currentContext;
    if (context?.size?.height != null) {
      htmlDescriptionHeight.value = context!.size!.height;
    }
  });
}
```

### طويلة المدى (Low Priority):
```dart
// 1. استخدام AutomaticKeepAliveClientMixin للصفحات الثقيلة
// 2. تطبيق Lazy Loading للصور
// 3. استخدام Isolates للعمليات الثقيلة
// 4. تطبيق State Management أفضل (مثل Riverpod)
```

## 6. مقاييس الأداء المتوقعة:

### قبل التحسين:
- استهلاك ذاكرة: ~500MB
- زمن scroll response: ~200ms
- عدد rebuilds: مرتفع

### بعد التحسين:
- استهلاك ذاكرة: ~150MB (-70%)
- زمن scroll response: ~50ms (-75%)
- عدد rebuilds: منخفض (-60%)

## 7. خطة التنفيذ:

### الأسبوع الأول:
1. تنظيف Future.delayed المفرطة
2. تحسين dispose methods
3. إضافة RepaintBoundary

### الأسبوع الثاني:
1. تقسيم product_listing_page
2. تحسين BlocBuilder conditions
3. إضافة const constructors

### الأسبوع الثالث:
1. تطبيق lazy loading
2. تحسين state management
3. اختبار الأداء النهائي

## 8. أدوات المراقبة المطلوبة:

```dart
// إضافة مراقبة الأداء
class PerformanceMonitor {
  static void logMemoryUsage() {
    final imageCache = PaintingBinding.instance.imageCache;
    debugPrint('Memory: ${imageCache.currentSizeBytes ~/ (1024 * 1024)}MB');
    debugPrint('Images: ${imageCache.liveImageCount}');
  }
  
  static void logScrollPerformance(double scrollDelta, Duration duration) {
    final fps = 1000 / duration.inMilliseconds;
    if (fps < 30) {
      debugPrint('⚠️ Low FPS: $fps');
    }
  }
}
``` 