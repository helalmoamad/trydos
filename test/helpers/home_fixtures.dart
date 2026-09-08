/// Test ledger · wave 02 Account and session — the home-server response bodies.
///
/// Same idea as `auth_fixtures.dart`: the envelope is written once so each test
/// can show only the field it is about.
library;

import 'auth_fixtures.dart';

/// What `customer/update-profile` answers: the saved user, under `data`.
Map<String, dynamic> updateProfileEnvelope({
  Map<String, dynamic>? user,
  String message = 'profile updated',
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'message': message,
    'data': user ?? userJson(),
  };
}

/// What the currency endpoint answers. The symbol and the number of decimals are
/// what every price on every screen is formatted with.
Map<String, dynamic> currencyEnvelope({
  int id = 1,
  String symbol = 'ل.س',
  String code = 'SYP',
  int decimalDigits = 0,
  double exchangeRate = 13000,
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'currency': <String, dynamic>{
        'id': id,
        'name': 'Syrian Pound',
        'symbol': symbol,
        'code': code,
        'decimal_digits': decimalDigits,
        'exchange_rate': exchangeRate,
      },
    },
  };
}

/// What the allowed-countries endpoint answers.
///
/// `phonecode` is an **int** here on purpose: `Country.fromJson` casts it
/// straight into an `int?` with no tolerance, so a server that sent it as a
/// string would take the whole country list down with a cast error and leave the
/// picker empty.
Map<String, dynamic> allowedCountriesEnvelope({
  List<Map<String, dynamic>>? countries,
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'countries': countries ??
          <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'phonecode': 963,
              'iso': 'SY',
              'name': 'Syria',
              'longitude': '38.0',
              'latitude': '35.0',
            },
            <String, dynamic>{
              'id': 2,
              'phonecode': 964,
              'iso': 'IQ',
              'name': 'Iraq',
              'longitude': '43.0',
              'latitude': '33.0',
            },
          ],
    },
  };
}

/// What the elastic country-boundary endpoint answers.
Map<String, dynamic> countryBoundaryEnvelope({
  String iso = 'SY',
  List<List<double>> points = const <List<double>>[
    <double>[35.0, 38.0],
    <double>[36.0, 39.0],
  ],
}) {
  return <String, dynamic>{
    'status': 'ok',
    'country': <String, dynamic>{
      'country_iso': iso,
      'country_name_en': 'Syria',
      'country_name_ar': 'سوريا',
      'boundary': <String, dynamic>{
        'type': 'Polygon',
        'coordinates': points
            .map((List<double> p) => <String, dynamic>{
                  'lat': p[0],
                  'lon': p[1],
                })
            .toList(),
      },
    },
  };
}

/// What every notification-settings endpoint answers — they all return the whole
/// settings object, so one fixture covers reading them and every switch.
Map<String, dynamic> firebaseSettingsEnvelope({
  required int email,
  required int firebase,
  required int whatsapp,
  String notificationFrequency = 'daily',
  List<String> subscribed = const <String>['fixture-topic'],
  List<String> unsubscribed = const <String>['news'],
}) {
  List<Map<String, dynamic>> topics(List<String> names) => names
      .map((String n) => <String, dynamic>{'name': n, 'showed_name': n})
      .toList();

  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'firebase_settings': <String, dynamic>{
        'email': email,
        'firebase': firebase,
        'whatsapp': whatsapp,
        'notification_frequency': notificationFrequency,
        'subscribed_topics': topics(subscribed),
        'unsubscribed_topics': topics(unsubscribed),
      },
    },
  };
}

/// What the notification inbox answers — a paginated list.
Map<String, dynamic> userNotificationsEnvelope({
  List<Map<String, dynamic>>? notifications,
  int currentPage = 1,
  int lastPage = 1,
}) {
  return <String, dynamic>{
    'isSuccessful': true,
    'hasContent': true,
    'code': 200,
    'data': <String, dynamic>{
      'current_page': currentPage,
      'last_page': lastPage,
      'first_page_url': '',
      'last_page_url': '',
      'from': 1,
      'data': notifications ?? <Map<String, dynamic>>[],
    },
  };
}

/// One row of the notification inbox.
Map<String, dynamic> notificationItem({
  int id = 0,
  String title = 'Your order shipped',
  String body = 'It is on its way',
  String createdAt = '2026-09-05T10:00:00Z',
}) {
  return <String, dynamic>{
    'id': id,
    'user_id': 501,
    'title': title,
    'notification_type_id': 1,
    'body': body,
    'created_at': createdAt,
  };
}
