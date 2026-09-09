/// Models for the six Locations calls
/// (`.claude/docs/mobile-seller-dashboard-locations-api-guide.md`).
///
/// Everything is read tolerantly: `address`, `latitude`, `longitude` and
/// `country` can each be `null`, and `meta` may be missing. Coordinates arrive
/// as **strings** and must go back as **numbers** — that conversion lives here
/// and nowhere else.
///
/// Hand-written rather than generated: the parse is defensive in ways
/// `json_serializable` does not express, and there is no `.g.dart` for this
/// file.

/// One shop location.
class ShopLocationModel {
  final int? id;
  final String? name;
  final String? address;

  /// Parsed from the string the backend sends. `null` when absent or
  /// unparseable — never a silent `0`, which would be a real map point.
  final double? latitude;
  final double? longitude;

  /// `1` active, `0` inactive. Read as "not set" rather than "falsy":
  /// `status == 0` is a real value, and a falsy test drops it with no error.
  final int? status;

  final ShopLocationCountry? country;

  const ShopLocationModel({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.country,
  });

  bool get isActive => status == 1;

  /// A record may only reach a URL path when its id is a positive `int`.
  /// The widget gates both row controls on this, so an unusable id can never
  /// become a path segment.
  bool get hasUsableId => id != null && id! > 0;

  static String? _readString(dynamic raw) {
    if (raw == null) return null;
    final String text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// The contract's first trap: decimal columns come back as strings.
  static double? _readCoordinate(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString().trim());
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString().trim());
  }

  factory ShopLocationModel.fromJson(dynamic json) {
    if (json is! Map) return const ShopLocationModel();
    return ShopLocationModel(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      address: _readString(json['address']),
      latitude: _readCoordinate(json['latitude']),
      longitude: _readCoordinate(json['longitude']),
      status: _readInt(json['status']),
      country: json['country'] is Map
          ? ShopLocationCountry.fromJson(json['country'] as Map)
          : null,
    );
  }

  /// Used by the change-status write, which replaces one row in place with the
  /// value the backend returned.
  ShopLocationModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? status,
    ShopLocationCountry? country,
  }) => ShopLocationModel(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    status: status ?? this.status,
    country: country ?? this.country,
  );

  @override
  bool operator ==(Object other) =>
      other is ShopLocationModel &&
      other.id == id &&
      other.name == name &&
      other.address == address &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.status == status &&
      other.country == country;

  @override
  int get hashCode =>
      Object.hash(id, name, address, latitude, longitude, status, country);
}

/// The country object carried on each record, and on each form's country list.
class ShopLocationCountry {
  final int? id;
  final String? name;
  final String? nicename;
  final String? iso;

  const ShopLocationCountry({this.id, this.name, this.nicename, this.iso});

  /// What a row shows. `nicename` first — `name` is the upper-case code form.
  String get displayName => nicename ?? name ?? '';

  factory ShopLocationCountry.fromJson(Map json) => ShopLocationCountry(
    id: ShopLocationModel._readInt(json['id']),
    name: ShopLocationModel._readString(json['name']),
    nicename: ShopLocationModel._readString(json['nicename']),
    iso: ShopLocationModel._readString(json['iso']),
  );

  @override
  bool operator ==(Object other) =>
      other is ShopLocationCountry &&
      other.id == id &&
      other.name == name &&
      other.nicename == nicename &&
      other.iso == iso;

  @override
  int get hashCode => Object.hash(id, name, nicename, iso);
}

/// `meta` on the list response. `total` backs the header count (AC-5);
/// `perPage` is recorded at verify as a resource observation.
class ShopLocationsMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final bool? hasMorePages;

  const ShopLocationsMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMorePages,
  });

  factory ShopLocationsMeta.fromJson(Map json) => ShopLocationsMeta(
    currentPage: ShopLocationModel._readInt(json['current_page']),
    lastPage: ShopLocationModel._readInt(json['last_page']),
    perPage: ShopLocationModel._readInt(json['per_page']),
    total: ShopLocationModel._readInt(json['total']),
    hasMorePages: json['has_more_pages'] is bool
        ? json['has_more_pages'] as bool
        : null,
  );

  @override
  bool operator ==(Object other) =>
      other is ShopLocationsMeta &&
      other.currentPage == currentPage &&
      other.lastPage == lastPage &&
      other.perPage == perPage &&
      other.total == total &&
      other.hasMorePages == hasMorePages;

  @override
  int get hashCode =>
      Object.hash(currentPage, lastPage, perPage, total, hasMorePages);
}

/// `GET /shop/locations` — the list wrapper.
///
/// [loadedForSellerId] is the shop this list was loaded for. The backend does
/// not send it; the bloc writes it locally on success, and the widget's
/// first-frame gate compares it against the shop captured when the screen
/// opened. It lives here and nowhere else, so there is only ever one stamp.
class GetShopLocationsModel {
  final bool? success;
  final String? message;
  final List<ShopLocationModel> locations;
  final ShopLocationsMeta? meta;
  final String? loadedForSellerId;

  const GetShopLocationsModel({
    this.success,
    this.message,
    this.locations = const <ShopLocationModel>[],
    this.meta,
    this.loadedForSellerId,
  });

  /// The empty record: used to clear what is loaded on a shop switch or a
  /// dispose, because `DashBoardState.copyWith` cannot put a field back to
  /// `null`.
  const GetShopLocationsModel.empty() : this();

  bool get isEmpty => locations.isEmpty && loadedForSellerId == null;

  factory GetShopLocationsModel.fromJson(dynamic response) {
    if (response is! Map) return const GetShopLocationsModel();

    final Map root = response;
    final dynamic payload = root['data'];
    final Map record = payload is Map ? payload : root;

    final dynamic rawList = record['locations'];
    return GetShopLocationsModel(
      success: root['success'] is bool ? root['success'] as bool : null,
      message: ShopLocationModel._readString(root['message']),
      locations: rawList is List
          ? rawList
                .map((dynamic e) => ShopLocationModel.fromJson(e))
                .toList(growable: false)
          : const <ShopLocationModel>[],
      meta: record['meta'] is Map
          ? ShopLocationsMeta.fromJson(record['meta'] as Map)
          : null,
    );
  }

  /// Preserves the stamp rather than re-reading the shop id. Re-reading here
  /// would re-stamp a stale list with the *current* shop, and the widget's
  /// first-frame gate would then pass for the wrong shop — which is AC-22
  /// failing in the one place the guard exists to cover.
  GetShopLocationsModel copyWith({
    bool? success,
    String? message,
    List<ShopLocationModel>? locations,
    ShopLocationsMeta? meta,
    String? loadedForSellerId,
  }) => GetShopLocationsModel(
    success: success ?? this.success,
    message: message ?? this.message,
    locations: locations ?? this.locations,
    meta: meta ?? this.meta,
    loadedForSellerId: loadedForSellerId ?? this.loadedForSellerId,
  );

  @override
  bool operator ==(Object other) =>
      other is GetShopLocationsModel &&
      other.success == success &&
      other.message == message &&
      other.meta == meta &&
      other.loadedForSellerId == loadedForSellerId &&
      _sameLocations(other.locations, locations);

  static bool _sameLocations(
    List<ShopLocationModel> a,
    List<ShopLocationModel> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(success, message, meta, loadedForSellerId, locations.length);
}

/// `GET /shop/locations/lookups` — the create form's country list.
///
/// Create-gated, so it is fetched only when the add form opens. It is never
/// used to build the list's filter: a read-only member would get a 403.
class LocationFormLookupsModel {
  final bool? success;
  final String? message;
  final List<ShopLocationCountry> countries;

  const LocationFormLookupsModel({
    this.success,
    this.message,
    this.countries = const <ShopLocationCountry>[],
  });

  factory LocationFormLookupsModel.fromJson(dynamic response) {
    if (response is! Map) return const LocationFormLookupsModel();

    final Map root = response;
    final dynamic payload = root['data'];
    final Map record = payload is Map ? payload : root;

    final dynamic rawList = record['countries'];
    return LocationFormLookupsModel(
      success: root['success'] is bool ? root['success'] as bool : null,
      message: ShopLocationModel._readString(root['message']),
      countries: rawList is List
          ? rawList
                .whereType<Map>()
                .map(ShopLocationCountry.fromJson)
                .toList(growable: false)
          : const <ShopLocationCountry>[],
    );
  }
}

/// `GET /shop/locations/{id}/edit` — the record **and** its country list in one
/// call, so a member who may only update never has to call the create-gated
/// lookups endpoint.
class ShopLocationEditModel {
  final bool? success;
  final String? message;
  final ShopLocationModel? location;
  final List<ShopLocationCountry> countries;

  const ShopLocationEditModel({
    this.success,
    this.message,
    this.location,
    this.countries = const <ShopLocationCountry>[],
  });

  factory ShopLocationEditModel.fromJson(dynamic response) {
    if (response is! Map) return const ShopLocationEditModel();

    final Map root = response;
    final dynamic payload = root['data'];
    final Map record = payload is Map ? payload : root;

    final dynamic lookups = record['lookups'];
    final dynamic rawCountries = lookups is Map ? lookups['countries'] : null;

    return ShopLocationEditModel(
      success: root['success'] is bool ? root['success'] as bool : null,
      message: ShopLocationModel._readString(root['message']),
      location: record['location'] is Map
          ? ShopLocationModel.fromJson(record['location'])
          : null,
      countries: rawCountries is List
          ? rawCountries
                .whereType<Map>()
                .map(ShopLocationCountry.fromJson)
                .toList(growable: false)
          : const <ShopLocationCountry>[],
    );
  }
}

/// The write response for create and update.
///
/// Its own small model rather than the shared `ReadOnlyMessageFromApiModel`:
/// that one is shared with home, orders, users and stories and carries no
/// `success`, and without the flag an `HTTP 200` with `success: false` cannot
/// be told apart from a real save (AC-15).
class ShopLocationWriteResponseModel {
  final bool? success;
  final String? message;

  const ShopLocationWriteResponseModel({this.success, this.message});

  /// Success is decided by the flag, not by the status code. An absent flag is
  /// treated as success, because the request only reached here after the
  /// transport succeeded.
  bool get isSuccess => success ?? true;

  factory ShopLocationWriteResponseModel.fromJson(dynamic response) {
    if (response is! Map) return const ShopLocationWriteResponseModel();
    return ShopLocationWriteResponseModel(
      success: response['success'] is bool ? response['success'] as bool : null,
      message: ShopLocationModel._readString(response['message']),
    );
  }
}

/// `POST /shop/locations/{id}/change-status`.
///
/// The row's new marker is [status] — the value the backend returned, never the
/// value the screen asked for (AC-30). There is no reload after a toggle.
class ChangeLocationStatusResponseModel {
  final bool? success;
  final String? message;
  final int? status;

  const ChangeLocationStatusResponseModel({
    this.success,
    this.message,
    this.status,
  });

  bool get isSuccess => success ?? true;

  factory ChangeLocationStatusResponseModel.fromJson(dynamic response) {
    if (response is! Map) return const ChangeLocationStatusResponseModel();

    final Map root = response;
    final dynamic payload = root['data'];
    final Map record = payload is Map ? payload : root;

    return ChangeLocationStatusResponseModel(
      success: root['success'] is bool ? root['success'] as bool : null,
      message: ShopLocationModel._readString(root['message']),
      status: ShopLocationModel._readInt(record['status']),
    );
  }
}
