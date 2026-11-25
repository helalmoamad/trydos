/// استيرادُ حسابٍ من رمز QR — المنطقُ كما كان في `qr_login_scanner_page.dart`
/// حرفاً بحرف، أُخرج إلى هنا ليُستعمل من التصميمين: صفحةُ الماسح القديمة،
/// ونافذةُ QR في التصميم الجديد.
///
/// ولم يتبدّل سطرُ منطقٍ واحد: المفاتيحُ نفسُها، والأحداثُ نفسُها، وترتيبُها
/// نفسُه.
library;

import 'dart:convert';

import 'package:get_it/get_it.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/service/notification_service/notification_service/handle_notification/notification_process.dart';

/// يقرأ ما في الرمز ويحفظ الحساب. و`false` تعني أنّ الرمزَ لا يُفهم.
Future<bool> importQrAccount(String raw) async {
  try {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('invalid payload');
    }
    await _persistAccountData(decoded);
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _persistAccountData(Map<String, dynamic> data) async {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final List<Future<dynamic>> futures = <Future<dynamic>>[];

  final String? userMarketId = _parseString(data['userMarketId']);
  if (userMarketId != null) {
    futures.add(prefsRepository.setMyMarketId(userMarketId));
  }
  final String? phone = _parseString(data['userMarketPhone']);
  if (phone != null) {
    futures.add(prefsRepository.setPhoneNumber(phone));
  }
  final String? countryIso = _parseString(data['userCountryIso']);
  if (countryIso != null) {
    futures.add(prefsRepository.setCountryIso(countryIso));
  }

  final int? userCountryIsAvailable = _parseInt(data['userCountryIsAvailable']);
  if (userCountryIsAvailable != null) {
    futures.add(
      prefsRepository.setUserCountryIsAvailable(userCountryIsAvailable),
    );
  }

  final String? choosedCountry = _parseString(
    data['userUserChoosedCountryIso'],
  );
  if (choosedCountry != null) {
    futures.add(prefsRepository.setUserChoosedCountryIso(choosedCountry));
  }
  final String? name = _parseString(data['name']);
  if (name != null) {
    futures.add(prefsRepository.setMyMarketName(name));
  }
  final String? marketToken = _parseString(data['userMarketToken']);
  if (marketToken != null) {
    futures.add(prefsRepository.setMarketToken(marketToken));
  }

  final String? idToken = _parseString(data['idToken']);
  if (idToken != null) {
    futures.add(prefsRepository.setIdToken(idToken));
  }
  final String? language = _parseString(data['language']);
  if (language != null) {
    futures.add(prefsRepository.setLanguage(language));
  }
  GetIt.I<AuthBloc>().add(GetCustomerInfoEvent());
  GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
  //GetIt.I<HomeBloc>().add(GetProductsListInCartEvent());

  GetIt.I<AuthBloc>().add(
    LoginToStoriesEvent(
      name: name,
      originalUserId: userMarketId,
      otpIdToken: idToken,
      phone: phone,
    ),
  );
  GetIt.I<AuthBloc>().add(
    GenerateTokenForCommentEvent(
      mobilePhone: phone,
      otpIdToken: idToken,
      userId: userMarketId,
    ),
  );

  NotificationProcess().fcmToken(
    phone,
    name,
    userMarketId.toString(),
    idToken.toString(),
  );
  await Future.wait(futures);
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
  return value.toString();
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}
