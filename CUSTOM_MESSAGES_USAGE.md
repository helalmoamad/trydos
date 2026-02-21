# دليل استخدام الرسائل التوضيحية المخصصة

تم إنشاء نظام جديد للرسائل التوضيحية مع تصميم موحد وجميل يتضمن الأيقونات والألوان والأزرار.

## الدوال المتاحة

### 1. الدوال المبسطة

```dart
// رسالة معلوماتية
showInfoMessage(context, 'Your message here');

// رسالة نجاح  
showSuccessMessage(context, 'Operation completed successfully');

// رسالة تحذير
showWarningMessage(context, 'Please check your input');
```

### 2. الدالة الرئيسية مع جميع الخيارات

```dart
showCustomMessage(
  context,
  'Title',
  'Message content',
  isSuccess: false,      // للنجاح (أخضر)
  isWarning: false,      // للتحذير (برتقالي)  
  isInfo: true,          // للمعلومات (أزرق) - افتراضي
  actionText: 'OK',      // نص الزر
  onActionPressed: () {  // إجراء عند الضغط
    // your action here
  },
  durationSeconds: 4,    // مدة العرض بالثواني
);
```

## أمثلة عملية

### رسالة معلوماتية بسيطة
```dart
showInfoMessage(
  context,
  'Entering Your Information Correctly Allows Us To Provide You With Better Service And Benefit From All Services.',
);
```

### رسالة خطأ مع إعادة المحاولة
```dart
showCustomMessage(
  context,
  'Connection Error',
  'Failed to connect to server. Please check your internet connection.',
  isWarning: true,
  actionText: 'Retry',
  onActionPressed: () {
    // إعادة المحاولة
    retryConnection();
  },
  durationSeconds: 6,
);
```

### رسالة نجاح مع انتقال
```dart
showCustomMessage(
  context,
  'Order Placed Successfully', 
  'Your order has been placed and will be processed shortly.',
  isSuccess: true,
  actionText: 'View Order',
  onActionPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => OrderDetailsPage(),
    ));
  },
);
```

### رسالة مع أزرار متعددة
```dart
showCustomMessage(
  context,
  'Update Available',
  'A new version of the app is available. Update now to get the latest features.',
  isInfo: true,
  actionButton: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Later'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => updateApp(),
        child: Text('Update'),
      ),
    ],
  ),
);
```

## التحويل من النظام القديم

### قبل (النظام القديم):
```dart
showMessage('Error occurred', hasError: true);
showMessage('Success!', hasError: false);
```

### بعد (النظام الجديد):
```dart
showWarningMessage(context, 'Error occurred');
showSuccessMessage(context, 'Success!');
```

## أنواع الرسائل والألوان

| النوع | اللون | الأيقونة | الاستخدام |
|-------|--------|----------|-----------|
| Info | أزرق | info | المعلومات العامة |
| Success | أخضر | check_circle | العمليات الناجحة |
| Warning | برتقالي | warning | التحذيرات والأخطاء |

## ملاحظات مهمة

1. **الدالة القديمة `showMessage` محفوظة** للتوافق مع الكود الموجود
2. **استخدم الدوال الجديدة** للرسائل الجديدة للحصول على التصميم الموحد
3. **جميع الرسائل تظهر في الأعلى** مع إمكانية الإغلاق اليدوي
4. **يمكن إضافة أزرار مخصصة** باستخدام `actionButton`
5. **مدة العرض قابلة للتخصيص** عبر `durationSeconds`

## استبدال تدريجي

يمكنك البدء باستبدال `showMessage` تدريجياً في الملفات التالية:
- `verify_otp.dart` - خط 115
- `cart_page_new.dart` - خط 174, 1510, 1697  
- `home_bloc.dart` - عدة مواضع
- `order_bloc.dart` - عدة مواضع

مثال للاستبدال:
```dart
// استبدل هذا:
showMessage(state.sendOtpError.toString());

// بهذا:
showWarningMessage(context, state.sendOtpError.toString());
``` 