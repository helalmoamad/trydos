import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

class LastPagesTracker {
  static final List<String> _lastPages = [];

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
    GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());
    debugPrint('error $error');

    // معالج الأخطاء يجب ألّا يرمي استثناءً بنفسه: إذا كان HomeBloc مُغلقاً
    // (أُغلق الـ singleton من BlocProvider عند dispose مثلاً) نتجاهل الحدث
    // بدل رمي StateError: "Cannot add new events after calling close".
    final homeBloc = GetIt.I<HomeBloc>();
    if (homeBloc.isClosed) {
      debugPrint('⚠️ HomeBloc مُغلق — تم تجاهل إرسال حدث تسجيل الخطأ');
      return;
    }
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
