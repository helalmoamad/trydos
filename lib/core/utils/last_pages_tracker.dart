import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
//import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

class LastPagesTracker {
  static final List<String> _lastPages = [];

  /// توقيع آخر خطأ أُرسل ووقت إرساله.
  ///
  /// خطأ يقع أثناء `build` أو `layout` يتكرّر مع **كل إطار** ما دامت الويدجت
  /// معروضة. وبما أن هذا المعالج يضيف حدث Bloc يُطلق طلب شبكة ثم `emit` ثم
  /// إعادة بناء، فإن الخطأ المتكرّر يصنع حلقة مغلقة: خطأ ← حدث ← شبكة ←
  /// إعادة بناء ← نفس الخطأ. النتيجة تعليق كامل لا تقطّع.
  ///
  /// الحارس أدناه يقطع الحلقة: الخطأ نفسه يُرسل مرّة واحدة كل [_dedupeWindow]
  /// بدل ستّين مرّة في الثانية. لا معلومة تُفقد — الخطأ مسجَّل أصلاً.
  static String? _lastSignature;
  static DateTime? _lastSentAt;

  static const Duration _dedupeWindow = Duration(seconds: 30);

  static void push(String pageName) {
    if (_lastPages.isNotEmpty) {
      if (_lastPages.last != pageName) {
        _lastPages.add(pageName);
        if (_lastPages.length > 5) {
          _lastPages.removeAt(0);
        }
      }
    } else {
      _lastPages.add(pageName);
    }
  }

  static List<String> get lastPages => List.unmodifiable(_lastPages);

  static void sendErrorToBlocAndLog(FlutterErrorDetails error) {
    /* GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());
    debugPrint('error $error');
*/
    // التوقيع يعتمد على نوع الاستثناء ونصّه فقط — لا على المكدّس، لأن
    // `error.stack.toString()` عملية غير رخيصة ونريد الخروج قبلها.
    final String signature =
        '${error.exception.runtimeType}:${error.exceptionAsString()}';
    final DateTime now = DateTime.now();
    if (signature == _lastSignature &&
        _lastSentAt != null &&
        now.difference(_lastSentAt!) < _dedupeWindow) {
      return;
    }

    // معالج الأخطاء يجب ألّا يرمي استثناءً بنفسه: إذا كان HomeBloc مُغلقاً
    // (أُغلق الـ singleton من BlocProvider عند dispose مثلاً) نتجاهل الحدث
    // بدل رمي StateError: "Cannot add new events after calling close".
    final homeBloc = GetIt.I<HomeBloc>();
    if (homeBloc.isClosed) {
      debugPrint('⚠️ HomeBloc مُغلق — تم تجاهل إرسال حدث تسجيل الخطأ');
      return;
    }
    // التسجيل بعد التأكّد من الإرسال: لو كان الـ Bloc مغلقاً لا نكتم الخطأ
    // ثلاثين ثانية بلا أن يصل أحداً.
    _lastSignature = signature;
    _lastSentAt = now;

    homeBloc.add(
      SendErrorToMobileErrorLogEvent(
        errorExption:
            'Type:${error.exception.runtimeType.toString()} ${error.exceptionAsString().toString()}',
        errorPath: error.stack.toString().split('#2').first,
        urlBackend: "Front Error",
        messageFromeBackend: "Front Error",
        lastForPageHasBeenVisited: LastPagesTracker.lastPages.join(' > '),
      ),
    );
    // يمكنك هنا أيضًا إضافة أي لوج إضافي أو تخزين محلي إذا رغبت
  }
}
