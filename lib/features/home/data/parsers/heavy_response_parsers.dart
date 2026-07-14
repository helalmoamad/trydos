import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trydos/main.dart';

import '../models/get_home_boutiqes_model.dart';
import '../models/get_product_detail_without_related_products_model.dart';
import '../models/get_product_filters_model.dart';
import '../models/get_product_listing_with_filters_model.dart';
import '../models/getRelatedProducts.dart';
import '../models/main_categories_response_model.dart';

/// Off-main-isolate parsing for the app's heaviest responses.
///
/// The bottleneck for large listing/detail responses is building the model
/// object graph (`Model.fromJson`), which runs on the UI isolate and causes
/// jank. Each `parse*` helper below hands the raw response to a top-level
/// function via [compute] so the object construction happens on a background
/// isolate; only the finished (immutable) model is copied back.
///
/// IMPORTANT — isolate purity:
/// A fresh isolate does NOT share the main isolate's globals. Every model
/// `fromJson` in this feature builds image URLs from exactly three pieces of
/// startup-constant state:
///   * the `mediaServerIsS3` global (from main.dart)
///   * `dotenv.env['Media_S3_Server']`
///   * `dotenv.env['Images_Url']`
/// So we capture those on the main isolate ([_ParseArgs.capture]) and re-seed
/// them inside the worker ([_seedGlobals]) before calling `fromJson`. If a
/// model in this parse path ever starts reading another global / `dotenv` key /
/// `GetIt` singleton, it must be seeded here too — otherwise it throws
/// (`dotenv.env` throws `NotInitializedError`) or silently produces wrong URLs.
class _ParseArgs {
  final dynamic raw;
  final bool isS3;
  final String mediaServer;
  final String imagesUrl;

  const _ParseArgs(this.raw, this.isS3, this.mediaServer, this.imagesUrl);

  /// Snapshots the (startup-constant) globals on the calling isolate so they
  /// can travel into the worker isolate.
  factory _ParseArgs.capture(dynamic raw) => _ParseArgs(
    raw,
    mediaServerIsS3,
    dotenv.env['Media_S3_Server'] ?? '',
    dotenv.env['Images_Url'] ?? '',
  );
}

/// Runs inside the worker isolate: re-creates the globals the models depend on.
void _seedGlobals(_ParseArgs a) {
  mediaServerIsS3 = a.isS3;
  // testLoad is the supported way to initialise dotenv without a file; it marks
  // dotenv initialised so `dotenv.env[...]` no longer throws in this isolate.
  dotenv.testLoad(
    mergeWith: {'Media_S3_Server': a.mediaServer, 'Images_Url': a.imagesUrl},
  );
}

// ---------------------------------------------------------------------------
// Top-level isolate entry points (must be top-level/static for `compute`).
// ---------------------------------------------------------------------------

GetProductListingWithFiltersModel _parseListing(_ParseArgs a) {
  _seedGlobals(a);
  return GetProductListingWithFiltersModel.fromJson(a.raw);
}

GetProductDetailWithoutRelatedProductsModel _parseProductDetail(_ParseArgs a) {
  _seedGlobals(a);
  return GetProductDetailWithoutRelatedProductsModel.fromJson(a.raw);
}

MainCategoriesResponseModel _parseMainCategories(_ParseArgs a) {
  _seedGlobals(a);
  return MainCategoriesResponseModel.fromJson(a.raw);
}

GetProductFiltersModel _parseProductFilters(_ParseArgs a) {
  _seedGlobals(a);
  return GetProductFiltersModel.fromJson(a.raw);
}

GetHomeBoutiquesModel _parseHomeBoutiques(_ParseArgs a) {
  _seedGlobals(a);
  return GetHomeBoutiquesModel.fromJson(a.raw);
}

RelatedProductsResponse _parseRelatedProducts(_ParseArgs a) {
  _seedGlobals(a);
  return RelatedProductsResponse.fromJson(a.raw);
}

// ---------------------------------------------------------------------------
// Public API — call these from the data source with the raw decoded response.
// ---------------------------------------------------------------------------

Future<GetProductListingWithFiltersModel> parseListingInBackground(
  dynamic raw,
) => compute(_parseListing, _ParseArgs.capture(raw));

Future<GetProductDetailWithoutRelatedProductsModel>
parseProductDetailInBackground(dynamic raw) =>
    compute(_parseProductDetail, _ParseArgs.capture(raw));

Future<MainCategoriesResponseModel> parseMainCategoriesInBackground(
  dynamic raw,
) => compute(_parseMainCategories, _ParseArgs.capture(raw));

Future<GetProductFiltersModel> parseProductFiltersInBackground(dynamic raw) =>
    compute(_parseProductFilters, _ParseArgs.capture(raw));

Future<GetHomeBoutiquesModel> parseHomeBoutiquesInBackground(dynamic raw) =>
    compute(_parseHomeBoutiques, _ParseArgs.capture(raw));

Future<RelatedProductsResponse> parseRelatedProductsInBackground(dynamic raw) =>
    compute(_parseRelatedProducts, _ParseArgs.capture(raw));

// ---------------------------------------------------------------------------
// Home-page prefetch cache (SharedPreferences) — decode/encode off the UI
// isolate. The stored blob is a DataGetProductListingWithFiltersModel JSON.
// ---------------------------------------------------------------------------

/// Isolate: encode the Data model to a JSON string for storage. `toJson` only
/// reads already-built fields, so no globals need seeding here.
///
/// NOTE: prefetch *reads* are intentionally synchronous (on the caller) so the
/// cached content renders instantly on open — the isolate round-trip added
/// visible latency. Only the (fire-and-forget) *write* is offloaded here.
String _encodePrefetchData(DataGetProductListingWithFiltersModel? data) =>
    jsonEncode(data ?? DataGetProductListingWithFiltersModel());

/// Encode a home-page prefetch model (model → String) on a background isolate.
Future<String> encodePrefetchDataInBackground(
  DataGetProductListingWithFiltersModel? data,
) => compute(_encodePrefetchData, data);

/// Isolate: encode a boutiques-per-category prefetch model to a JSON string.
String _encodeBoutiquesPrefetch(GetHomeBoutiquesModel? data) =>
    jsonEncode(data ?? GetHomeBoutiquesModel());

/// Encode a boutiques-per-category prefetch model (model → String) off-thread.
Future<String> encodeBoutiquesPrefetchInBackground(
  GetHomeBoutiquesModel? data,
) => compute(_encodeBoutiquesPrefetch, data);

/// Isolate: encode a main-categories prefetch model to a JSON string.
String _encodeMainCategoriesPrefetch(MainCategoriesResponseModel? data) =>
    jsonEncode(data ?? MainCategoriesResponseModel());

/// Encode a main-categories prefetch model (model → String) off-thread.
Future<String> encodeMainCategoriesPrefetchInBackground(
  MainCategoriesResponseModel? data,
) => compute(_encodeMainCategoriesPrefetch, data);
