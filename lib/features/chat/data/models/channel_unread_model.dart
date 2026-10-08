/// ردّ نقطة «تعليم كغير مقروءة» `POST /channels/{id}/unread`.
///
/// يعيد الخادم العدّاد بعد التغيير، فنصالح به العرض المتفائل بدل افتراض أنه
/// صار واحداً — المواصفة تقول «واحد **على الأقل**»، فقد يعود أكبر.
class ChannelUnreadModel {
  final String? channelId;
  final int totalUnreadMessageCount;

  const ChannelUnreadModel({
    this.channelId,
    required this.totalUnreadMessageCount,
  });

  factory ChannelUnreadModel.fromJson(Map<String, dynamic> json) =>
      ChannelUnreadModel(
        channelId: json["channel_id"]?.toString(),
        totalUnreadMessageCount:
            int.tryParse(json["total_unread_message_count"].toString()) ?? 1,
      );

  Map<String, dynamic> toJson() => {
    "channel_id": channelId,
    "total_unread_message_count": totalUnreadMessageCount,
  };
}
