/// Models for the boutique editor calls
/// (`.claude/docs/seller-dashboard-boutiques-dev-guide.md` §9).
///
/// Everything is read tolerantly: the `/edit` answer carries full image URLs,
/// optional fields can be `null`, and the lookups object may sit directly under
/// `data` or under `data.lookups`. Images are reduced to their bare file name
/// in the form layer, not here — these models keep what the backend sent.
///
/// Hand-written rather than generated, like the Locations models: the parse is
/// defensive in ways `json_serializable` does not express, and there is no
/// `.g.dart` for this file.
library;

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

List<dynamic> _readList(dynamic value) => value is List ? value : const [];

/// One stored banner of one language. [banner] is a full URL on `/edit`.
class BoutiqueBannerModel {
  final int? id;
  final String? banner;
  final int sequence;

  const BoutiqueBannerModel({this.id, this.banner, this.sequence = 0});

  factory BoutiqueBannerModel.fromJson(dynamic json) {
    if (json is! Map) return const BoutiqueBannerModel();
    return BoutiqueBannerModel(
      id: _readInt(json['id']),
      banner: _readString(json['banner'] ?? json['file_path']),
      sequence: _readInt(json['sequence']) ?? 0,
    );
  }
}

/// One stored translation. [languageCode] is lower-cased here so the form can
/// match it against the language list without repeating the rule.
class BoutiqueTranslationModel {
  final int? id;
  final String languageCode;
  final String? name;
  final String? description;
  final String? bio;
  final String? icon;
  final List<BoutiqueBannerModel> banners;

  const BoutiqueTranslationModel({
    this.id,
    required this.languageCode,
    this.name,
    this.description,
    this.bio,
    this.icon,
    this.banners = const [],
  });

  factory BoutiqueTranslationModel.fromJson(Map json) =>
      BoutiqueTranslationModel(
        id: _readInt(json['id']),
        languageCode: (_readString(json['language_code']) ?? '').toLowerCase(),
        name: _readString(json['name']),
        description: _readString(json['description']),
        bio: _readString(json['bio']),
        icon: _readString(json['icon']),
        banners: _readList(
          json['banners'],
        ).map(BoutiqueBannerModel.fromJson).toList(),
      );
}

/// The boutique record from `GET /shop/boutiques/{id}/edit`.
class BoutiqueRecordModel {
  final int? id;
  final String? name;
  final String? icon;
  final int status;
  final int? availability;
  final List<String> restrictedCountriesIso;
  final List<int> relatedProductIds;
  final List<BoutiqueTranslationModel> translations;

  const BoutiqueRecordModel({
    this.id,
    this.name,
    this.icon,
    this.status = 0,
    this.availability,
    this.restrictedCountriesIso = const [],
    this.relatedProductIds = const [],
    this.translations = const [],
  });

  factory BoutiqueRecordModel.fromJson(dynamic json) {
    if (json is! Map) return const BoutiqueRecordModel();
    return BoutiqueRecordModel(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      icon: _readString(json['icon']),
      status: _readInt(json['status']) ?? 0,
      availability: _readInt(json['availability']),
      restrictedCountriesIso: _readList(json['restricted_countries_iso'])
          .map(_readString)
          .whereType<String>()
          .toList(),
      relatedProductIds: _readList(
        json['related_product_ids'],
      ).map(_readInt).whereType<int>().toList(),
      translations: _readList(
        json['translations'],
      ).whereType<Map>().map(BoutiqueTranslationModel.fromJson).toList(),
    );
  }
}

/// One country chip. [name] is shown as the backend sends it — the app does
/// not translate country names (spec OQ-7).
class BoutiqueCountryModel {
  final String iso;
  final String name;

  const BoutiqueCountryModel({required this.iso, required this.name});
}

/// The parts of the lookups the form uses: countries and availabilities.
/// Availabilities outside 1, 2 and 3 are dropped; the backend `label` is never
/// shown, so only the values are kept.
class BoutiqueLookupsModel {
  final List<BoutiqueCountryModel> countries;
  final List<int> availabilities;

  const BoutiqueLookupsModel({
    this.countries = const [],
    this.availabilities = const [],
  });

  factory BoutiqueLookupsModel.fromJson(dynamic json) {
    if (json is! Map) return const BoutiqueLookupsModel();
    final List<BoutiqueCountryModel> countries = <BoutiqueCountryModel>[];
    for (final dynamic item in _readList(json['countries'])) {
      if (item is! Map) continue;
      final String? iso = _readString(item['iso']);
      if (iso == null) continue;
      countries.add(
        BoutiqueCountryModel(
          iso: iso.toUpperCase(),
          name: _readString(item['name']) ?? iso.toUpperCase(),
        ),
      );
    }
    final List<int> availabilities = <int>[];
    for (final dynamic item in _readList(json['availabilities'])) {
      final int? value = item is Map ? _readInt(item['value']) : null;
      if (value != null &&
          value >= 1 &&
          value <= 3 &&
          !availabilities.contains(value)) {
        availabilities.add(value);
      }
    }
    return BoutiqueLookupsModel(
      countries: countries,
      availabilities: availabilities,
    );
  }
}

/// `GET /shop/boutiques/lookups` — the object sits directly under `data`; the
/// website also accepts `data.lookups`, so this does too.
class BoutiqueLookupsResponseModel {
  final BoutiqueLookupsModel lookups;

  const BoutiqueLookupsResponseModel({
    this.lookups = const BoutiqueLookupsModel(),
  });

  factory BoutiqueLookupsResponseModel.fromJson(dynamic response) {
    final dynamic data = response is Map ? response['data'] : null;
    final dynamic source = data is Map && data['lookups'] is Map
        ? data['lookups']
        : data;
    return BoutiqueLookupsResponseModel(
      lookups: BoutiqueLookupsModel.fromJson(source),
    );
  }
}

/// `GET /shop/boutiques/{id}/edit` — the record and its lookups in one call.
class BoutiqueEditResponseModel {
  final BoutiqueRecordModel boutique;
  final BoutiqueLookupsModel lookups;

  const BoutiqueEditResponseModel({
    this.boutique = const BoutiqueRecordModel(),
    this.lookups = const BoutiqueLookupsModel(),
  });

  factory BoutiqueEditResponseModel.fromJson(dynamic response) {
    final dynamic data = response is Map ? response['data'] : null;
    if (data is! Map) return const BoutiqueEditResponseModel();
    return BoutiqueEditResponseModel(
      boutique: BoutiqueRecordModel.fromJson(data['boutique']),
      lookups: BoutiqueLookupsModel.fromJson(data['lookups']),
    );
  }
}

/// `POST /shop/boutiques` and `POST /shop/boutiques/{id}/update`.
///
/// [boutiqueId] is set only by create: `data.boutique_id`, then
/// `data.boutique.id`, then `data.id` (guide §9.3). Update answers `data: []`.
class BoutiqueWriteResponseModel {
  final bool? isSuccessful;
  final String? message;
  final int? boutiqueId;

  const BoutiqueWriteResponseModel({
    this.isSuccessful,
    this.message,
    this.boutiqueId,
  });

  /// An absent flag is treated as success: the request only reached here after
  /// the transport succeeded.
  bool get isSuccess => isSuccessful ?? true;

  factory BoutiqueWriteResponseModel.fromJson(dynamic response) {
    if (response is! Map) return const BoutiqueWriteResponseModel();
    final dynamic data = response['data'];
    int? id;
    if (data is Map) {
      final dynamic nested = data['boutique'];
      id =
          _readInt(data['boutique_id']) ??
          (nested is Map ? _readInt(nested['id']) : null) ??
          _readInt(data['id']);
    }
    return BoutiqueWriteResponseModel(
      isSuccessful: response['isSuccessful'] is bool
          ? response['isSuccessful'] as bool
          : null,
      message: _readString(response['message']),
      boutiqueId: id,
    );
  }
}

/// `POST /shop/boutiques/{id}/change-status`. [status] is the value the backend
/// returned, never the value the page asked for.
class BoutiqueStatusResponseModel {
  final bool? isSuccessful;
  final String? message;
  final int? status;

  const BoutiqueStatusResponseModel({
    this.isSuccessful,
    this.message,
    this.status,
  });

  bool get isSuccess => isSuccessful ?? true;

  factory BoutiqueStatusResponseModel.fromJson(dynamic response) {
    if (response is! Map) return const BoutiqueStatusResponseModel();
    final dynamic data = response['data'];
    return BoutiqueStatusResponseModel(
      isSuccessful: response['isSuccessful'] is bool
          ? response['isSuccessful'] as bool
          : null,
      message: _readString(response['message']),
      status: data is Map ? _readInt(data['status']) : null,
    );
  }
}

/// One language tab. [label] is the language's own name (`native_name`).
class BoutiqueLanguage {
  final String code;
  final String label;

  const BoutiqueLanguage({required this.code, required this.label});

  /// Used when `GET /languages` fails or returns nothing usable (AC-12).
  static const List<BoutiqueLanguage> fallback = <BoutiqueLanguage>[
    BoutiqueLanguage(code: 'en', label: 'English'),
    BoutiqueLanguage(code: 'ar', label: 'العربية'),
    BoutiqueLanguage(code: 'tr', label: 'Türkçe'),
    BoutiqueLanguage(code: 'ku', label: 'کوردی'),
  ];
}

/// `GET /languages` — the answer shape is not fixed (guide §9.8), so the list
/// is read from `data.languages`, `languages`, `data` or the root, in that
/// order. Duplicates are dropped. An empty result means "use the fallback";
/// that choice is the caller's, so it stays visible there.
class BoutiqueLanguagesResponseModel {
  final List<BoutiqueLanguage> languages;

  const BoutiqueLanguagesResponseModel({this.languages = const []});

  factory BoutiqueLanguagesResponseModel.fromJson(dynamic response) {
    List<dynamic> raw = const [];
    if (response is List) {
      raw = response;
    } else if (response is Map) {
      final dynamic data = response['data'];
      if (data is Map && data['languages'] is List) {
        raw = data['languages'];
      } else if (response['languages'] is List) {
        raw = response['languages'];
      } else if (data is List) {
        raw = data;
      }
    }

    final List<BoutiqueLanguage> languages = <BoutiqueLanguage>[];
    final Set<String> seen = <String>{};
    for (final dynamic item in raw) {
      if (item is! Map) continue;
      final String? code =
          (_readString(item['code']) ??
                  _readString(item['language_code']) ??
                  _readString(item['iso']) ??
                  _readString(item['slug']))
              ?.toLowerCase();
      if (code == null || !seen.add(code)) continue;
      final String label =
          _readString(item['native_name']) ??
          _readString(item['name']) ??
          _readString(item['title']) ??
          _readString(item['label']) ??
          code;
      languages.add(BoutiqueLanguage(code: code, label: label));
    }
    return BoutiqueLanguagesResponseModel(languages: languages);
  }
}
