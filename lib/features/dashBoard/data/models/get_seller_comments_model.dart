/// The Customers Comments screen's read model.
///
/// Hand-written, like every other model in this feature — there is no
/// `json_serializable` here. The parse is deliberately tolerant, because the
/// contract marks several fields nullable and one optional:
///
///   * `rating` is `null` for every FAQ comment and a number only for reviews;
///   * `created_at` and `reply_created_at` may be `null`;
///   * `meta` may be absent entirely on an empty page.
///
/// A strict parse would throw on a perfectly legal payload and the tab would
/// look empty rather than broken, so every reader below tests for the shape it
/// wants instead of trusting the type.
library;

import 'package:equatable/equatable.dart';

/// The server's hard maximum for `page_size`. The screen asks for
/// [kSellerCommentsPageSize]; this is the ceiling the data source clamps to, so
/// no caller can widen a read past what the contract allows (AC-17).
const int kSellerCommentsMaxPageSize = 50;

/// What the screen actually asks for per page.
const int kSellerCommentsPageSize = 10;

/// The server's cap on a reply, and the cap the field enforces.
///
/// **Not to be confused with `kDisplayTextMaxLength` (200)** in
/// `display_text_sanitizer.dart`. That one is a *display* cap for a short row
/// label; using it on a comment or a reply would silently cut most of the text
/// (AC-8, AC-11). Anything rendering a comment body passes this value instead.
const int kSellerReplyMaxLength = 1000;

/// Which list is being read. The value is what the API's `type` parameter takes.
enum SellerCommentType {
  /// Customer questions. These are the only comments a seller may reply to.
  faq('faq'),

  /// Star-rated purchase reviews. Display-only — the API has no reply call.
  review('review');

  final String value;
  const SellerCommentType(this.value);
}

/// One comment, with the seller's reply folded into the same row — that is how
/// the API returns it, and keeping the shape means a reply can be patched in
/// place without touching the list around it.
class SellerCommentModel extends Equatable {
  final String commentId;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;

  /// Stars. `null` for FAQ, and only ever drawn on the Reviewing tab.
  final double? rating;
  final String variant;
  final String? createdAt;

  /// Decides create-versus-edit for the whole screen. Never inferred from
  /// whether `sellerReply` is empty — a reply may legitimately be blank text
  /// while the record still exists.
  final bool hasReply;
  final String sellerReply;
  final String sellerName;
  final String? replyCreatedAt;
  final int totalLikes;
  final int replyTotalLikes;

  const SellerCommentModel({
    required this.commentId,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.rating,
    required this.variant,
    required this.createdAt,
    required this.hasReply,
    required this.sellerReply,
    required this.sellerName,
    required this.replyCreatedAt,
    required this.totalLikes,
    required this.replyTotalLikes,
  });

  /// Ids arrive as strings in the contract, but a backend that sends a number
  /// must not break the screen — so read the shape, not the type.
  static String _readString(dynamic value) {
    if (value == null) return '';
    return value is String ? value : value.toString();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// `null` stays `null` — it is the difference between a FAQ row and a review
  /// row, so a `0` fallback here would draw an empty star row on every
  /// question.
  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// An empty string is treated as absent, so a blank date does not render as
  /// a blank gap where a date belongs (EC-1).
  static String? _readNullableString(dynamic value) {
    if (value == null) return null;
    final String text = value is String ? value : value.toString();
    return text.trim().isEmpty ? null : text;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String lowered = value.toLowerCase();
      return lowered == 'true' || lowered == '1';
    }
    return false;
  }

  factory SellerCommentModel.fromJson(Map<String, dynamic> json) {
    return SellerCommentModel(
      commentId: _readString(json['comment_id']),
      productId: _readString(json['product_id']),
      userId: _readString(json['user_id']),
      userName: _readString(json['user_name']),
      userAvatar: _readString(json['user_avatar']),
      text: _readString(json['text']),
      rating: _readNullableDouble(json['rating']),
      variant: _readString(json['variant']),
      createdAt: _readNullableString(json['created_at']),
      hasReply: _readBool(json['has_reply']),
      sellerReply: _readString(json['seller_reply']),
      sellerName: _readString(json['seller_name']),
      replyCreatedAt: _readNullableString(json['reply_created_at']),
      totalLikes: _readInt(json['total_likes']),
      replyTotalLikes: _readInt(json['reply_total_likes']),
    );
  }

  /// Used to patch one row after a reply write, so the list keeps its position
  /// and its already-loaded pages (AC-21).
  SellerCommentModel copyWith({
    bool? hasReply,
    String? sellerReply,
    String? sellerName,
    String? replyCreatedAt,
    bool clearReplyCreatedAt = false,
    int? replyTotalLikes,
  }) {
    return SellerCommentModel(
      commentId: commentId,
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      rating: rating,
      variant: variant,
      createdAt: createdAt,
      hasReply: hasReply ?? this.hasReply,
      sellerReply: sellerReply ?? this.sellerReply,
      sellerName: sellerName ?? this.sellerName,
      replyCreatedAt: clearReplyCreatedAt
          ? null
          : (replyCreatedAt ?? this.replyCreatedAt),
      totalLikes: totalLikes,
      replyTotalLikes: replyTotalLikes ?? this.replyTotalLikes,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    commentId,
    productId,
    userId,
    userName,
    userAvatar,
    text,
    rating,
    variant,
    createdAt,
    hasReply,
    sellerReply,
    sellerName,
    replyCreatedAt,
    totalLikes,
    replyTotalLikes,
  ];
}

/// The page marker. `hasMorePages` is the only thing that decides whether the
/// "load more" control is drawn (AC-14), and `currentPage` is where the next
/// page number comes from — the screen keeps no page counter of its own.
class SellerCommentsMeta extends Equatable {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMorePages;

  const SellerCommentsMeta({
    this.currentPage = 1,
    this.perPage = 0,
    this.total = 0,
    this.lastPage = 1,
    this.hasMorePages = false,
  });

  factory SellerCommentsMeta.fromJson(Map<String, dynamic> json) {
    return SellerCommentsMeta(
      currentPage: SellerCommentModel._readInt(json['current_page']),
      perPage: SellerCommentModel._readInt(json['per_page']),
      total: SellerCommentModel._readInt(json['total']),
      lastPage: SellerCommentModel._readInt(json['last_page']),
      hasMorePages: SellerCommentModel._readBool(json['has_more_pages']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentPage,
    perPage,
    total,
    lastPage,
    hasMorePages,
  ];
}

/// One tab's accumulated list plus its page marker.
///
/// **This is a value type on purpose.** The state it sits on is a large
/// `Equatable`, and a plain class here would make every comments emission
/// unequal by identity, re-running the whole `props` compare for every listener
/// on the dashboard. `Equatable` on the model and a `buildWhen` on the screen
/// are the two halves of keeping that cost off the other ten tabs.
class GetSellerCommentsModel extends Equatable {
  final List<SellerCommentModel> comments;
  final SellerCommentsMeta meta;

  const GetSellerCommentsModel({
    this.comments = const <SellerCommentModel>[],
    this.meta = const SellerCommentsMeta(),
  });

  const GetSellerCommentsModel.empty()
    : comments = const <SellerCommentModel>[],
      meta = const SellerCommentsMeta();

  /// The envelope is `{success, data: {comments: [...], meta}}`. Both `data`
  /// and `meta` are read defensively: an empty shop may send neither.
  factory GetSellerCommentsModel.fromJson(dynamic response) {
    final Map<String, dynamic> root = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};

    final dynamic rawData = root['data'];
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};

    final dynamic rawComments = data['comments'];
    final List<SellerCommentModel> comments = rawComments is List
        ? rawComments
              .whereType<Map<String, dynamic>>()
              .map(SellerCommentModel.fromJson)
              .toList(growable: false)
        : const <SellerCommentModel>[];

    final dynamic rawMeta = data['meta'];
    final SellerCommentsMeta meta = rawMeta is Map<String, dynamic>
        ? SellerCommentsMeta.fromJson(rawMeta)
        : const SellerCommentsMeta();

    return GetSellerCommentsModel(comments: comments, meta: meta);
  }

  /// Appending, never replacing — this is what `AC-13` means by "load more".
  /// A comment already held is not added twice, because a page boundary can
  /// shift under a concurrent write on the backend.
  GetSellerCommentsModel appendPage(GetSellerCommentsModel next) {
    final Set<String> seen = comments
        .map((SellerCommentModel c) => c.commentId)
        .toSet();
    final List<SellerCommentModel> merged = <SellerCommentModel>[
      ...comments,
      ...next.comments.where(
        (SellerCommentModel c) => !seen.contains(c.commentId),
      ),
    ];
    return GetSellerCommentsModel(comments: merged, meta: next.meta);
  }

  /// Replace one row, keeping every other row and the page marker untouched.
  GetSellerCommentsModel replaceComment(SellerCommentModel updated) {
    return GetSellerCommentsModel(
      comments: comments
          .map(
            (SellerCommentModel c) =>
                c.commentId == updated.commentId ? updated : c,
          )
          .toList(growable: false),
      meta: meta,
    );
  }

  /// Drop one row — used when the server says a comment no longer exists
  /// (`AC-26`, EC-5).
  GetSellerCommentsModel removeComment(String commentId) {
    return GetSellerCommentsModel(
      comments: comments
          .where((SellerCommentModel c) => c.commentId != commentId)
          .toList(growable: false),
      meta: meta,
    );
  }

  bool get isEmpty => comments.isEmpty;

  @override
  List<Object?> get props => <Object?>[comments, meta];
}
