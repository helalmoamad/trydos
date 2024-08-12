class AppState {
  AppState(
      {required this.currentIndex,
      required this.replyType,
      required this.replyOnMe,
      required this.thereIsReply,
      required this.tabIndex,
      required this.tabIndexInChat,
      required this.showBars,
      this.currentIndexForSearch,
      required this.hideBottomNavigationBar,
      this.messageId,
      this.pusherActivityIds = const {},
      this.pusherActivityDescription = const {},
      this.senderParentMessageId,
      this.time,
      this.message,
      this.imageUrl}) {}

  final int currentIndex;
  final int tabIndex;
  final int tabIndexInChat;
  final bool showBars;
  int? currentIndexForSearch;
  final bool hideBottomNavigationBar;
  final bool thereIsReply;
  final bool replyOnMe;
  final String replyType;
  final String? message;
  final String? messageId;
  final String? imageUrl;
  final DateTime? time;
  final int? senderParentMessageId;
  final Map<int, dynamic> pusherActivityIds;
  final Map<int, String?> pusherActivityDescription;

  AppState copyWith({
    int? currentIndex,
    int? tabIndex,
    int? currentIndexForSearch,
    final bool? thereIsReply,
    final bool? replyOnMe,
    final String? replyType,
    final int? senderParentMessageId,
    int? tabIndexInChat,
    final DateTime? time,
    final String? message,
    final Map<int, dynamic>? pusherActivityIds,
    final Map<int, String?>? pusherActivityDescription,
    final String? messageId,
    final String? imageUrl,
    final bool? showBars,
    final bool? hideBottomNavigationBar,
  }) {
    return AppState(
      currentIndex: currentIndex ?? this.currentIndex,
      tabIndex: tabIndex ?? this.tabIndex,
      currentIndexForSearch:
          currentIndexForSearch ?? this.currentIndexForSearch,
      replyType: replyType ?? this.replyType,
      thereIsReply: thereIsReply ?? this.thereIsReply,
      replyOnMe: replyOnMe ?? this.replyOnMe,
      tabIndexInChat: tabIndexInChat ?? this.tabIndexInChat,
      senderParentMessageId:
          senderParentMessageId ?? this.senderParentMessageId,
      showBars: showBars ?? this.showBars,
      hideBottomNavigationBar:
          hideBottomNavigationBar ?? this.hideBottomNavigationBar,
      message: message ?? this.message,
      pusherActivityIds: pusherActivityIds ?? this.pusherActivityIds,
      pusherActivityDescription:
          pusherActivityDescription ?? this.pusherActivityDescription,
      messageId: messageId ?? this.messageId,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
    );
  }
}
