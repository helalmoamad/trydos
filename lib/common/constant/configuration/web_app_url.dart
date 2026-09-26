import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  //  String noScope() => '$_version/$_cloudinaryName/$this';
}

abstract class WebAppEndPoints {
  static const imageSearchEP = "api/image-search";
  static const addLikeCommentEP = "public_comment/likes/like";
  static const addLikeOFProductEP = "products/like";
  static const getCategoriesEP = "api/v1/shop/excel/categories";
  static const removeLikeOFProductEP = "products/unlike";
  static const removeLikeCommentEP = "public_comment/likes/unlike";
  static String translateCommentsToAppLanEP(String commentId) =>
      "public_comment/comments/${commentId}/translate";
  static const mainCategoriesEP = "api/home/mainCategories";
  static const getPopularSearchTermsEP = "api/products/popular-search";
  static const editSocialProductEP = "api/editSocialProduct";
  static const homeBoutiquesEP = "api/home/boutiques";
  static const searchProductEP = "api/products/searchInCatalog";
  static const productFeaturedEP = "api/products/featured";
  static const createOrderRatingEP = "public_comment/comments/create";
  static String updateOrderRatingEP(String commentId) =>
      "public_comment/comments/$commentId/update";
  static String deleteOrderRatingEP(String commentId) =>
      "public_comment/comments/$commentId/delete";
  // ---------------------------------------------------------------------------
  // Seller comments — the dashboard's Customers Comments screen.
  //
  // Two paths serve four calls: the collection is read with `GET`, and the one
  // reply path answers `POST` (create), `PUT` (edit) and `DELETE` (remove).
  // They live here, with the other `{WEB_API}` routes, because that is the
  // server they belong to — `DashBoardEndPoints` is the market server.
  //
  // The shop travels as a `seller_id` query parameter or body field, never as
  // the `X-Seller-ID` header the market server uses.
  // ---------------------------------------------------------------------------

  /// `GET` — one page of comments for one `type` (`faq` or `review`).
  static const sellerCommentsEP = "api/seller/comments";

  /// `POST` creates a reply, `PUT` edits it, `DELETE` removes it. Which verb is
  /// correct is decided by the comment's own `has_reply` flag, never by the
  /// member.
  static const sellerCommentReplyEP = "api/seller/comments/reply";

  static const getFqaCommentsEP = "api/products/comments/fqa_comments";
  static const getBuyersCommentsEP = "api/products/comments/buyers_comments";
  static const generateTokenForCommentEP = "public_comment/auth/exchange_token";
  static const getOrderRatingEP = "api/products/comments/order_rating";
  static const getCommentsFromAnalyticsEP = "api/products/comments/comments";
  static const productRecommendedEP = "api/products/recomended";
  static String productDetailsEP(String slug) =>
      "api/mobile/product/details/${slug}";
  static String getAuthProductDetailsEP(String slug) =>
      "api/mobile/product/qty/${slug}";
  //  static final imageSearchEP = "api/image-search";
  static String getRelatedProducts(int Product_ID) =>
      "api/related-products/${Product_ID}";

  static String getDeliveredOrdersResponse(int Product_ID) =>
      "api/v1/web/product/delivery_times/${Product_ID}";

  static String downloadExcel(int categoryId) =>
      "api/v1/shop/excel/downloadExcel/${categoryId}";

  static String getUploadedExcelFiles({int page = 1}) =>
      'api/v1/shop/excel/getUploadedExcelFiles?page=$page';
}

abstract class WebUrls {
  static final String _baseUri = dotenv.env['WEB_APP']!;
  static final String _loadPreset = dotenv.env['WEB_APP']!;

  static Uri get baseUri => Uri.parse(_baseUri);

  static String get LoadPreset => _loadPreset;
}
