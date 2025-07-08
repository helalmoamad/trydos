# إصلاحات حرجة مطلوبة فوراً

## مشاكل حرجة مكتشفة:

### 1. Future.delayed مفرطة:
- **home_page**: 17 Future.delayed
- **product_listing**: 21 Future.delayed
- **المشكلة**: تسريب ذاكرة وتأخير في الاستجابة

### 2. Timer غير محكوم:
- عدة Timer.periodic بدون إلغاء صحيح
- searchDebounce منفصل عن scroll debounce

### 3. product_listing_page حجم مفرط:
- 267KB (كبير جداً)
- 3330 سطر
- يحتاج تقسيم فوري

### 4. عدم تنظيف الذاكرة في dispose:
- لا يوجد تنظيف للكاش
- Timer لا يتم إلغاؤها
- تسريب ذاكرة محتمل

## الإصلاحات المطلوبة:

### إصلاح 1: تنظيف Timer في dispose
```dart
@override
void dispose() {
  debounce?.cancel();
  searchDebounce?.cancel();
  _delayedTimer?.cancel();
  
  // تنظيف الكاش
  final imageCache = PaintingBinding.instance.imageCache;
  if (imageCache.liveImageCount > 50) {
    imageCache.clearLiveImages();
  }
  
  super.dispose();
}
```

### إصلاح 2: دمج Future.delayed
```dart
Timer? _unifiedTimer;

void scheduleAction(VoidCallback action, Duration delay) {
  _unifiedTimer?.cancel();
  _unifiedTimer = Timer(delay, action);
}
```

### إصلاح 3: تحسين scroll thresholds
```dart
// بدلاً من 0.4 و 0.6 (قريب جداً)
if (scrollRatio >= 0.5) { // prefetch
if (scrollRatio >= 0.75) { // pagination
```

### إصلاح 4: إضافة RepaintBoundary
```dart
RepaintBoundary(
  child: ProductItem(...),
)
```

### إصلاح 5: تحسين BlocBuilder
```dart
BlocBuilder<HomeBloc, HomeState>(
  buildWhen: (p, c) => p.status != c.status,
  builder: (context, state) => ...
)
```

## أولوية التنفيذ:
1. **فوري**: إصلاح dispose وTimer
2. **عاجل**: تقسيم product_listing_page  
3. **مهم**: إضافة RepaintBoundary
4. **ضروري**: تحسين scroll thresholds 