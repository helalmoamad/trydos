import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../common/helper/show_message.dart';
import '../../../../core/api/handling_exception.dart';

part 'sensitive_connectivity_event.dart';
part 'sensitive_connectivity_state.dart';

/// نصّ رسالة انقطاع الاتصال. مكانٌ واحد يستعمله مصدرا العرض: مراقب الشبكة
/// أدناه، وفشل إرسال رسالة في الدردشة — فتظهر للمستخدم متطابقة في الحالتين.
///
/// دالة لا ثابت: الترجمة تُقرأ **لحظة العرض** لا لحظة تحميل الملف، وإلّا بقيت
/// باللغة التي كانت مختارة عند الإقلاع بعد تغيير المستخدم للغته.
String get noInternetMessage => LocaleKeys.no_internet_connected.tr();

/// يعرض رسالة انقطاع الاتصال **إن كانت الشبكة مقطوعة فعلاً**.
///
/// يُستدعى عند فشل طلب لا نعرف سببه: الفشل الشبكي يصل من طبقة الـ API على هيئة
/// `DioFailure(statusCode: 400)` تماماً كخطأ خادم حقيقي — لأن الاستجابة معدومة
/// فلا رمز لها — فلا يمكن تمييزه من كائن `Failure` وحده. لذا نسأل حالة الشبكة
/// نفسها بدل التخمين، فلا تظهر الرسالة على خطأ خادم والشبكة سليمة.
Future<void> showNoInternetMessageIfOffline() async {
  final List<ConnectivityResult> results = await Connectivity()
      .checkConnectivity();
  final bool offline =
      results.isEmpty || results.contains(ConnectivityResult.none);
  if (!offline) return;
  showMessage(noInternetMessage, hasError: true, showInRelease: true);
}

@injectable
class SensitiveConnectivityBloc
    extends Bloc<SensitiveConnectivityEvent, SensitiveConnectivityState>
    with HandlingExceptionRequest {
  SensitiveConnectivityBloc() : super(ConnectivityOfflineState()) {
    on<ChangeConnectivityEvent>(_onCheckConnectivity);
  }

  void _onCheckConnectivity(
    ChangeConnectivityEvent event,
    Emitter<SensitiveConnectivityState> emit,
  ) async {
    prettyPrinterI(
        "***|| 🌐 ${event.connectivityResult.name.toUpperCase()} 🌐 ||***");

    if (event.connectivityResult == ConnectivityResult.mobile) {
      showMessage(LocaleKeys.internet_connected.tr(), showInRelease: true);
      emit(ConnectivityCellularState());
    } else if (event.connectivityResult == ConnectivityResult.wifi) {
      showMessage(LocaleKeys.internet_connected.tr(), showInRelease: true);
      emit(ConnectivityWifiState());
    } else if (event.connectivityResult == ConnectivityResult.none) {
      showMessage(noInternetMessage, hasError: true, showInRelease: true);
      emit(ConnectivityOfflineState());
    }
  }
}
