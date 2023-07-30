class AppState {
  AppState(
      {required this.currentIndex,
      required this.replyType,
      required this.replyOnMe,
      required this.thereIsReply,
      required this.tabIndex,
      required this.tabIndexInChat,
      required this.showBars,
      this.messageId,
      this.typingIds=const {},
      this.senderParentMessageId,
      this.time,
      this.message,
      this.imageUrl}){
    print('create app state');
  }

  final int currentIndex;
  final int tabIndex;
  final int tabIndexInChat;
  final bool showBars;
  final bool thereIsReply;
  final bool replyOnMe;
  final String replyType;
  final String? message;
  final String? messageId;
  final String? imageUrl;
  final DateTime? time;
  final int? senderParentMessageId;
  final Map<int , dynamic> typingIds;

  AppState copyWith(
      {int? currentIndex,
      int? tabIndex,
      final bool? thereIsReply,
      final bool? replyOnMe,
      final String? replyType,
        final int? senderParentMessageId,
        int? tabIndexInChat,
        final DateTime? time,
        final String? message,
        final Map<int , dynamic>? typingIds,
        final String? messageId,
        final String? imageUrl,
      final bool? showBars}) {
    return AppState(
      currentIndex: currentIndex ?? this.currentIndex,
      tabIndex: tabIndex ?? this.tabIndex,
      replyType: replyType ?? this.replyType,
      thereIsReply: thereIsReply ?? this.thereIsReply,
      replyOnMe: replyOnMe ?? this.replyOnMe,
      tabIndexInChat: tabIndexInChat ?? this.tabIndexInChat,
      senderParentMessageId: senderParentMessageId ?? this.senderParentMessageId,
      showBars: showBars ?? this.showBars,
      message: message ?? this.message,
      typingIds: typingIds ?? this.typingIds,
      messageId: messageId ?? this.messageId,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
    );
  }
}
