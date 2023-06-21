
 class AppState {

   AppState({required this.currentIndex ,required this.replyType,required this.replyOnMe ,required this.thereIsReply , required this.tabIndex , required this.tabIndexInChat , required this.showBars});
   final int currentIndex;
   final int tabIndex;
   final int tabIndexInChat;
   final bool showBars;
   final bool thereIsReply;
   final bool replyOnMe;
   final String replyType;
   AppState copyWith({
     int? currentIndex,
     int? tabIndex,
     final bool? thereIsReply,
     final bool? replyOnMe,
     final String? replyType,
     int? tabIndexInChat,
     final bool? showBars
   }) {
     return AppState(
       currentIndex: currentIndex ?? this.currentIndex,
       tabIndex: tabIndex ?? this.tabIndex,
       replyType: replyType ?? this.replyType,
       thereIsReply: thereIsReply ?? this.thereIsReply,
       replyOnMe: replyOnMe ?? this.replyOnMe,
       tabIndexInChat: tabIndexInChat ?? this.tabIndexInChat,
       showBars: showBars ?? this.showBars,
     );
   }

 }
