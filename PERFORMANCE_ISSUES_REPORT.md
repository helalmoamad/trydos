# تقرير مشاكل الأداء - System UI isn't responding

## المشاكل المكتشفة:

### 1. استدعاءات API مفرطة في home_page.dart
**المشكلة:**
```dart
void listenToScroll() {
  debounce = Timer(Duration(milliseconds: 200), () { // وقت قصير جداً
    if (scrollRatio >= 0.6) {
      categoryBloc.add(GetHomeBoutiqesEvent(...)); // يتم استدعاؤها باستمرار
    }
    if (scrollRatio >= 0.4) {
      categoryBloc.prefetchBoutiques(...); // يتم استدعاؤها باستمرار
    }
  });
}
```

**الحل:**
- زيادة debounce time إلى 500ms
- إضافة متغيرات `_isLoadingMore` و `_isPrefetching`
- فحص الحالة قبل الاستدعاء
- إعادة تعيين الحالة بعد delay مناسب

### 2. استهلاك ذاكرة مفرط - cacheExtent
**المشكلة:**
```dart
cacheExtent: 1000, // قيمة عالية جداً
```

**الحل:**
```dart
cacheExtent: 250, // قيمة مناسبة
```

### 3. حجم ملف product_listing_page.dart
**المشكلة:**
- الملف بحجم 260KB و 3421 سطر
- widgets معقدة جداً
- عدة BlocBuilder متداخلة

**الحل:**
- تقسيم الملف لعدة widgets منفصلة
- استخدام const constructors
- تحسين buildWhen conditions

## الحلول المطبقة:

### 1. إصلاح scroll listener في home_page.dart:
```dart
// Variables to prevent excessive API calls
bool _isLoadingMore = false;
bool _isPrefetching = false;

void listenToScroll() {
  debounce = Timer(Duration(milliseconds: 500), () {
    // ... existing logic ...
    
    // Load more with protection
    if (scrollRatio >= 0.6 && !_isLoadingMore) {
      _isLoadingMore = true;
      // API call
      Timer(Duration(seconds: 3), () {
        if (mounted) _isLoadingMore = false;
      });
    }
    
    // Prefetch with protection
    if (scrollRatio >= 0.4 && !_isPrefetching) {
      _isPrefetching = true;
      // Prefetch call
      Timer(Duration(seconds: 5), () {
        if (mounted) _isPrefetching = false;
      });
    }
  });
}
```

### 2. تقليل cacheExtent:
```dart
// في home_page.dart و product_listing_page.dart
cacheExtent: 250, // بدلاً من 1000
```

### 3. تحسينات إضافية مقترحة:

#### A. إضافة error handling:
```dart
try {
  categoryBloc.add(GetHomeBoutiqesEvent(...));
} catch (e) {
  debugPrint('Error in scroll listener: $e');
}
```

#### B. استخدام RepaintBoundary:
```dart
RepaintBoundary(
  child: YourExpensiveWidget(),
)
```

#### C. تحسين BlocBuilder conditions:
```dart
BlocBuilder<CategoryBloc, CategoryState>(
  buildWhen: (previous, current) => 
    previous.status != current.status && 
    current.status != CategoryStatus.loading,
  builder: (context, state) => ...
)
```

## نصائح لمنع المشاكل المستقبلية:

1. **استخدام Flutter Inspector** لمراقبة الأداء
2. **تشغيل flutter analyze** بانتظام
3. **استخدام const constructors** كلما أمكن
4. **تجنب الـ widgets الكبيرة** (أكثر من 500 سطر)
5. **استخدام debouncing** للعمليات المكلفة
6. **مراقبة استهلاك الذاكرة** باستخدام DevTools

## الخطوات التالية:

1. تطبيق التعديلات المذكورة أعلاه
2. اختبار الأداء على أجهزة مختلفة
3. مراقبة logs للتأكد من عدم وجود استدعاءات مفرطة
4. تقسيم product_listing_page.dart لملفات أصغر

## ملاحظات:
- المشكلة تحدث في الهواتف ذات المواصفات المنخفضة أكثر
- التحسينات ستحسن الأداء بشكل ملحوظ
- يُنصح بالاختبار على أجهزة حقيقية وليس المحاكي فقط 