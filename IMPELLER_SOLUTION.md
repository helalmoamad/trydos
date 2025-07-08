# حل مشكلة إغلاق التطبيق بسبب Impeller في Flutter

## 🔍 **المشكلة:**
بعد تحديث Flutter إلى الإصدار الجديد، أصبح محرك الرسوم **Impeller** يسبب إغلاق التطبيق على بعض الهواتف، خاصة:
- أجهزة PowerVR (Samsung Galaxy Tab وغيرها)
- أجهزة Android القديمة
- أجهزة معينة مع مشاكل GPU drivers

## ✅ **الحل الكامل:**

### 1️⃣ **إيقاف Impeller على Android:**

أضف هذا السطر في ملف `android/app/src/main/AndroidManifest.xml` داخل تاغ `<application>`:

```xml
<application
    android:label="trydos"
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon">
    
    <!-- إيقاف Impeller لتجنب مشاكل الإغلاق -->
    <meta-data
        android:name="io.flutter.embedding.android.EnableImpeller"
        android:value="false" />
        
    <!-- باقي الإعدادات... -->
</application>
```

### 2️⃣ **إيقاف Impeller على iOS:**

أضف هذا السطر في ملف `ios/Runner/Info.plist` داخل تاغ `<dict>`:

```xml
<dict>
    <!-- إيقاف Impeller لتجنب مشاكل الإغلاق -->
    <key>FLTEnableImpeller</key>
    <false />
    
    <!-- باقي الإعدادات... -->
</dict>
```

### 3️⃣ **إيقاف Impeller على macOS:**

أضف هذا السطر في ملف `macos/Runner/Info.plist` داخل تاغ `<dict>`:

```xml
<dict>
    <!-- إيقاف Impeller لتجنب مشاكل الإغلاق -->
    <key>FLTEnableImpeller</key>
    <false />
    
    <!-- باقي الإعدادات... -->
</dict>
```

### 4️⃣ **إيقاف Impeller أثناء التطوير:**

```bash
# تشغيل التطبيق بدون Impeller
flutter run --no-enable-impeller

# بناء التطبيق بدون Impeller
flutter build apk --no-enable-impeller
flutter build ios --no-enable-impeller
```

## 🎯 **هل هذا آمن ومضمون؟**

### ✅ **نعم، آمن تماماً:**
1. **Skia محرك مستقر:** ستعود للمحرك السابق المستقر والمختبر
2. **يعمل على جميع الأجهزة:** لا مشاكل توافق
3. **أداء موثوق:** لا مشاكل إغلاق أو تجميد
4. **مدعوم رسمياً:** Flutter يدعم هذا الخيار

### ⚠️ **ملاحظات مهمة:**
1. **ستفقد بعض التحسينات:** Impeller يقدم أداء أفضل نظرياً
2. **قد تواجه shader compilation jank:** في بعض الحالات النادرة
3. **مؤقت:** يمكنك تفعيل Impeller لاحقاً عندما يصبح أكثر استقراراً

## 🔄 **متى تعيد تفعيل Impeller؟**

1. **بعد تحديثات Flutter:** كل إصدار جديد يحسن Impeller
2. **اختبار دوري:** جرب تفعيله كل فترة واختبر التطبيق
3. **عندما تصبح مشاكلك محلولة:** راقب GitHub issues

## 🧪 **كيفية الاختبار:**

```bash
# اختبر مع Impeller
flutter run --enable-impeller

# اختبر بدون Impeller  
flutter run --no-enable-impeller

# قارن الأداء والاستقرار
```

## 📊 **التوصية:**

**للتطبيقات الإنتاجية:** أوقف Impeller حالياً لضمان الاستقرار
**للتطبيقات التجريبية:** يمكنك تجربة Impeller مع مراقبة دقيقة

## 🔗 **مصادر إضافية:**

- [Flutter Impeller Documentation](https://docs.flutter.dev/perf/impeller)
- [Impeller GitHub Issues](https://github.com/flutter/flutter/labels/a%3A%20impeller)
- [Can I use Impeller?](https://docs.flutter.dev/perf/impeller#availability)

---

**الخلاصة:** إيقاف Impeller حل آمن ومضمون لمشكلة إغلاق التطبيق، ويمكنك إعادة تفعيله لاحقاً عندما يصبح أكثر استقراراً. 