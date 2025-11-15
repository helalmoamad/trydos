# حل مشكلة Analyzer و json_serializable

## المشكلة:
- SDK 3.9.0 يتطلب analyzer 9.0.0
- json_serializable 6.11.1 غير متوافق مع analyzer 9.0.0
- build_runner يحتاج build_runner_core

## الحل:

### الخطوة 1: تنظيف ملفات build القديمة
```powershell
# حذف مجلد .dart_tool
Remove-Item -Recurse -Force .dart_tool

# حذف pubspec.lock
Remove-Item -Force pubspec.lock
```

أو تشغيل السكريبت:
```powershell
.\fix_build_runner.ps1
```

### الخطوة 2: تحديث pubspec.yaml
تم تحديث:
- `json_serializable: ^6.11.1` ✅
- `build_runner: ^2.4.8` ✅
- إزالة `analyzer` من dev_dependencies ✅
- إزالة `dependency_overrides` ✅

### الخطوة 3: تحديث الحزم
```bash
flutter pub get
```

### الخطوة 4: إذا استمرت المشكلة

#### الخيار 1: تقليل SDK constraint
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

#### الخيار 2: استخدام json_serializable 6.8.0
```yaml
json_serializable: ^6.8.0
```

#### الخيار 3: تحديث build_runner_core يدوياً
```yaml
dependency_overrides:
  build_runner_core: ^2.4.0
```

## ملاحظات:
- Flutter يدير analyzer تلقائياً من خلال SDK
- لا حاجة لإضافة analyzer في dev_dependencies
- json_serializable 6.11.1 هو أحدث إصدار متوافق

