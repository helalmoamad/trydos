import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/features/dashBoard/data/models/get_seller_comments_model.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'dashboard_permission_checker.dart';
import 'display_text_sanitizer.dart';
import 'empty_state_widget.dart';

/// The seller dashboard's Customers Comments screen (tab index 10).
///
/// Two tabs over the same card layout: **FAQ**, the customer questions a seller
/// may answer, and **Reviewing**, the star-rated purchase reviews, which are
/// display-only because the API has no reply call for them.
///
/// Three performance rules are load-bearing here and each is easy to undo by
/// accident:
///
///   1. the `BlocBuilder` carries a `buildWhen` naming only the six comments
///      fields — `DashboardBloc` is a `@LazySingleton` shared by eleven tabs,
///      so without it every unrelated dashboard emission would rebuild the
///      whole accumulated list;
///   2. display copies are built in [_syncItems] when the list identity
///      changes, never inside `itemBuilder`, so sanitising does not re-run for
///      every visible card on every frame;
///   3. the permission checks are read once per build into fields and passed
///      down — each one is a list scan, and `isSuperAdmin` adds a second.
class CustomerComments extends StatefulWidget {
  final List<String> permissions;

  const CustomerComments({Key? key, required this.permissions})
    : super(key: key);

  @override
  State<CustomerComments> createState() => _CustomerCommentsState();
}

/// One card's text, prepared once.
///
/// Every backend string is sanitised **here**, on the way in, and at
/// [kSellerReplyMaxLength] — not the sanitizer's 200-character default, which
/// is meant for a short row label and would cut most comments in half
/// (AC-8, AC-11, AC-34).
class _CommentDisplayItem {
  final SellerCommentModel source;
  final String userName;
  final String text;
  final String sellerReply;
  final String sellerName;
  final String createdAt;
  final String replyCreatedAt;
  final int stars;

  const _CommentDisplayItem({
    required this.source,
    required this.userName,
    required this.text,
    required this.sellerReply,
    required this.sellerName,
    required this.createdAt,
    required this.replyCreatedAt,
    required this.stars,
  });

  factory _CommentDisplayItem.from(SellerCommentModel c) {
    return _CommentDisplayItem(
      source: c,
      userName: sanitizeForDisplay(c.userName),
      text: sanitizeForDisplay(c.text, maxLength: kSellerReplyMaxLength),
      sellerReply: sanitizeForDisplay(
        c.sellerReply,
        maxLength: kSellerReplyMaxLength,
      ),
      sellerName: sanitizeForDisplay(c.sellerName),
      // A comment with no date shows no date, never a substitute one (EC-1).
      createdAt: c.createdAt == null ? '' : sanitizeForDisplay(c.createdAt),
      replyCreatedAt: c.replyCreatedAt == null
          ? ''
          : sanitizeForDisplay(c.replyCreatedAt),
      // Five stars filled to the rounded rating, no halves — the owner's
      // decision of 2026-09-09 against OQ-5. FAQ rows have a null rating and
      // draw none (EC-3).
      stars: c.rating == null ? 0 : c.rating!.round().clamp(0, 5),
    );
  }
}

class _CustomerCommentsState extends State<CustomerComments> {
  late final DashboardPermissionChecker _permissionChecker =
      DashboardPermissionChecker(widget.permissions);

  /// Captured in `initState` and used in `dispose` — reading the bloc from the
  /// context while disposing is fragile and is not this feature's pattern.
  late final DashboardBloc _bloc;

  SellerCommentType _tab = SellerCommentType.faq;

  /// Display copies, rebuilt only when the underlying list identity changes.
  List<_CommentDisplayItem> _faqItems = const <_CommentDisplayItem>[];
  List<_CommentDisplayItem> _reviewItems = const <_CommentDisplayItem>[];
  List<SellerCommentModel> _faqSource = const <SellerCommentModel>[];
  List<SellerCommentModel> _reviewSource = const <SellerCommentModel>[];

  bool get _canRead => _permissionChecker.canReadComments();

  bool get _canReply => _permissionChecker.canReplyToComment();

  bool get _canEdit => _permissionChecker.canEditCommentReply();

  bool get _canDelete => _permissionChecker.canDeleteCommentReply();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DashboardBloc>();

    // Once, on open — never in `build`, which would re-fire on every rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Anything the singleton bloc is still holding from a previous visit, or
      // from another shop, goes before the first row is drawn (AC-4).
      _bloc.add(ClearSellerCommentsEvent());
      _bloc.add(GetSellerCommentsEvent(type: _tab, canRead: _canRead));
    });
  }

  @override
  void dispose() {
    // The bloc is app-wide and never disposed, so lists left on it would live
    // for the lifetime of the app. Clearing also bumps the load generation,
    // which makes every response still in flight stale (AC-3).
    _bloc.add(ClearSellerCommentsEvent());
    super.dispose();
  }

  void _syncItems(
    List<SellerCommentModel> faqSource,
    List<SellerCommentModel> reviewSource,
  ) {
    if (!identical(faqSource, _faqSource)) {
      _faqSource = faqSource;
      _faqItems = faqSource
          .map(_CommentDisplayItem.from)
          .toList(growable: false);
    }
    if (!identical(reviewSource, _reviewSource)) {
      _reviewSource = reviewSource;
      _reviewItems = reviewSource
          .map(_CommentDisplayItem.from)
          .toList(growable: false);
    }
  }

  void _selectTab(SellerCommentType type) {
    if (_tab == type) return;
    setState(() => _tab = type);
    // Each tab keeps its own list and page, so a tab that already loaded is
    // not fetched again (AC-6).
    final GetCommentsStatus status = type == SellerCommentType.faq
        ? _bloc.state.faqCommentsStatus
        : _bloc.state.reviewCommentsStatus;
    if (status == GetCommentsStatus.init) {
      _bloc.add(GetSellerCommentsEvent(type: type, canRead: _canRead));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashBoardState>(
      // Only this screen's six fields. Without it, any other dashboard tab's
      // emission would rebuild the whole accumulated comment list.
      buildWhen: (previous, current) =>
          previous.faqComments != current.faqComments ||
          previous.reviewComments != current.reviewComments ||
          previous.faqCommentsStatus != current.faqCommentsStatus ||
          previous.reviewCommentsStatus != current.reviewCommentsStatus ||
          previous.commentReplyWriteStatus != current.commentReplyWriteStatus ||
          previous.commentsMessage != current.commentsMessage,
      listenWhen: (previous, current) =>
          previous.commentsMessage != current.commentsMessage &&
          current.commentsMessage != null,
      listener: (context, state) {
        final String? message = state.commentsMessage;
        if (message == null || message.isEmpty) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        _syncItems(state.faqComments.comments, state.reviewComments.comments);

        final bool isFaq = _tab == SellerCommentType.faq;
        final GetCommentsStatus status = isFaq
            ? state.faqCommentsStatus
            : state.reviewCommentsStatus;
        final GetSellerCommentsModel model = isFaq
            ? state.faqComments
            : state.reviewComments;
        final List<_CommentDisplayItem> items = isFaq
            ? _faqItems
            : _reviewItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTabs(),
            Expanded(child: _buildBody(status, model, items)),
          ],
        );
      },
    );
  }

  /// The two pills. They stay visible in every state — including the empty one
  /// — so a member can always switch tabs (AC-16).
  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: <Widget>[
          _buildTabPill(
            label: LocaleKeys.comments_faq_tab.tr(),
            type: SellerCommentType.faq,
          ),
          SizedBox(width: 8.w),
          _buildTabPill(
            label: LocaleKeys.comments_reviewing_tab.tr(),
            type: SellerCommentType.review,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required SellerCommentType type,
  }) {
    final bool selected = _tab == type;
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () => _selectTab(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? Colors.grey.shade300 : Colors.transparent,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected ? Colors.black87 : Colors.grey.shade600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    GetCommentsStatus status,
    GetSellerCommentsModel model,
    List<_CommentDisplayItem> items,
  ) {
    // No read permission: a message, no request, and no retry control — a
    // retry could not succeed (AC-19, AC-24).
    if (status == GetCommentsStatus.permissionDenied) {
      return EmptyStateWidget(
        icon: Icons.lock_outline,
        title: LocaleKeys.comments_read_permission_denied.tr(),
        message: '',
      );
    }

    // A first load replaces the tab; a "load more" never reaches here, because
    // its status is `loadingMore` and the rows stay drawn (AC-13).
    if (status == GetCommentsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status == GetCommentsStatus.failure && items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: LocaleKeys.comments_generic_error.tr(),
        message: '',
        actionText: LocaleKeys.comments_retry.tr(),
        onActionPressed: () => _bloc.add(
          GetSellerCommentsEvent(type: _tab, canRead: _canRead),
        ),
      );
    }

    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.chat_bubble_outline,
        title: LocaleKeys.comments_empty_title.tr(),
        message: LocaleKeys.comments_empty_subtitle.tr(),
      );
    }

    final bool isFaq = _tab == SellerCommentType.faq;
    final bool showLoadMore = model.meta.hasMorePages;
    final bool loadingMore = status == GetCommentsStatus.loadingMore;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: items.length + (showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return _buildLoadMore(loadingMore);
        }
        // Everything the row needs is already prepared: no sanitising and no
        // permission scan happens here.
        return _CommentCard(
          item: items[index],
          isFaq: isFaq,
          canReply: isFaq && _canReply,
          canEdit: isFaq && _canEdit,
          canDelete: isFaq && _canDelete,
          onReply: () => _openReplyDialog(items[index]),
          onDelete: () => _confirmDeleteReply(items[index]),
        );
      },
    );
  }

  Widget _buildLoadMore(bool loading) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: () =>
                    _bloc.add(LoadMoreSellerCommentsEvent(type: _tab)),
                child: Text(LocaleKeys.comments_load_more.tr()),
              ),
      ),
    );
  }

  Future<void> _openReplyDialog(_CommentDisplayItem item) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider<DashboardBloc>.value(
        value: _bloc,
        child: _ReplyDialog(item: item, tab: _tab),
      ),
    );
  }

  Future<void> _confirmDeleteReply(_CommentDisplayItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.comments_delete_reply_title.tr()),
        content: Text(LocaleKeys.comments_delete_reply_confirm.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.comments_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.comments_delete_reply.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(
        DeleteCommentReplyEvent(commentId: item.source.commentId, type: _tab),
      );
    }
  }
}

/// One comment row. Stateless and given only prepared strings.
class _CommentCard extends StatelessWidget {
  final _CommentDisplayItem item;
  final bool isFaq;
  final bool canReply;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.item,
    required this.isFaq,
    required this.canReply,
    required this.canEdit,
    required this.canDelete,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final SellerCommentModel c = item.source;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildAvatar(c.userAvatar),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Q. ${item.userName}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.createdAt.isNotEmpty)
                      Text(
                        item.createdAt,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(item.text, style: TextStyle(fontSize: 13.sp)),
                // Reviews carry stars; FAQ rows have a null rating and draw
                // none (AC-9, EC-3).
                if (!isFaq && c.rating != null) ...<Widget>[
                  SizedBox(height: 8.h),
                  _buildStars(item.stars),
                ],
                SizedBox(height: 8.h),
                _buildHearts(c.totalLikes),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: c.hasReply ? _buildReply(context) : _buildAwaitingReply(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    // An empty avatar shows the placeholder (EC-2). A non-empty one is only
    // loaded over `https`; anything else falls back, so a hostile value cannot
    // make the device contact an arbitrary host.
    final bool usable = url.isNotEmpty && url.startsWith('https://');
    return CircleAvatar(
      radius: 12.r,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: usable ? NetworkImage(url) : null,
      child: usable
          ? null
          : Icon(Icons.person, size: 14.r, color: Colors.grey.shade500),
    );
  }

  Widget _buildStars(int filled) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        5,
        (i) => Icon(
          i < filled ? Icons.star : Icons.star_border,
          size: 14.r,
          color: Colors.amber,
        ),
      ),
    );
  }

  /// Read-only: a count beside an outline heart, with no tap target. The API
  /// exposes no like or unlike call (AC-33).
  Widget _buildHearts(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.favorite_border,
          size: 14.r,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 4.w),
        Text(
          '$count',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildAwaitingReply() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            LocaleKeys.comments_waiting_seller_reply.tr(),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ),
        // Reviews never offer this, whatever the permissions say (AC-12).
        if (canReply)
          TextButton.icon(
            onPressed: onReply,
            icon: Icon(Icons.reply, size: 14.r),
            label: Text(LocaleKeys.comments_reply.tr()),
          ),
      ],
    );
  }

  Widget _buildReply(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.sellerName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (item.replyCreatedAt.isNotEmpty)
              Text(
                item.replyCreatedAt,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(item.sellerReply, style: TextStyle(fontSize: 12.sp)),
        SizedBox(height: 6.h),
        Row(
          children: <Widget>[
            _buildHearts(item.source.replyTotalLikes),
            const Spacer(),
            if (canEdit)
              TextButton(
                onPressed: onReply,
                child: Text(LocaleKeys.comments_edit_reply.tr()),
              ),
            if (canDelete)
              TextButton(
                onPressed: onDelete,
                child: Text(LocaleKeys.comments_delete_reply.tr()),
              ),
          ],
        ),
      ],
    );
  }
}

/// The reply dialog — one field, two buttons, and the quoted comment above it.
class _ReplyDialog extends StatefulWidget {
  final _CommentDisplayItem item;
  final SellerCommentType tab;

  const _ReplyDialog({required this.item, required this.tab});

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // **A prefill uses `stripDirectionControls`, never `sanitizeForDisplay`.**
    // The display helper caps its copy, and a capped value typed back into an
    // editable field would write the truncation back on the next save.
    _controller = TextEditingController(
      text: widget.item.source.hasReply
          ? stripDirectionControls(widget.item.source.sellerReply)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashBoardState>(
      buildWhen: (previous, current) =>
          previous.commentReplyWriteStatus != current.commentReplyWriteStatus,
      listenWhen: (previous, current) =>
          previous.commentReplyWriteStatus != current.commentReplyWriteStatus,
      listener: (context, state) {
        // Only a success closes the dialog. A failure leaves it open with the
        // typed text still in the field (AC-30).
        if (state.commentReplyWriteStatus == CommentReplyWriteStatus.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final bool inFlight =
            state.commentReplyWriteStatus == CommentReplyWriteStatus.inFlight;

        return AlertDialog(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  LocaleKeys.comments_reply_dialog_title.tr(),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              IconButton(
                onPressed: inFlight ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.item.userName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '"${widget.item.text}"',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  LocaleKeys.comments_reply_text_label.tr(),
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: _controller,
                  enabled: !inFlight,
                  maxLines: 5,
                  minLines: 3,
                  // The cap is the server's own, enforced as the member types
                  // (AC-25). The counter shows it.
                  maxLength: kSellerReplyMaxLength,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(kSellerReplyMaxLength),
                  ],
                  decoration: InputDecoration(
                    hintText: LocaleKeys.comments_reply_hint.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // Rebuilds the actions so the submit control enables the
                  // moment the field stops being empty.
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: inFlight ? null : () => Navigator.of(context).pop(),
              child: Text(LocaleKeys.comments_cancel.tr()),
            ),
            ElevatedButton(
              // Disabled while empty, and while a submit is in flight — which
              // is what stops a double submission (AC-25, AC-29).
              onPressed: (inFlight || _controller.text.trim().isEmpty)
                  ? null
                  : _submit,
              child: inFlight
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(LocaleKeys.comments_submit_reply.tr()),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    context.read<DashboardBloc>().add(
      SubmitCommentReplyEvent(
        commentId: widget.item.source.commentId,
        replyText: _controller.text,
        // Create or edit is decided by the comment's own flag (AC-22).
        hasReply: widget.item.source.hasReply,
        type: widget.tab,
      ),
    );
  }
}
