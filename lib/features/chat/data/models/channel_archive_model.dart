/// ردّ نقطة الأرشفة `POST /channels/{id}/archive`.
///
/// نقرأ منه [archived] لمصالحة العرض المتفائل مع ما استقرّ عليه الخادم فعلاً،
/// بدل افتراض أن الطلب فعل ما طُلب منه.
class ChannelArchiveModel {
  final String? channelId;
  final int? channelMemberId;
  final int archived;

  const ChannelArchiveModel({
    this.channelId,
    this.channelMemberId,
    required this.archived,
  });

  factory ChannelArchiveModel.fromJson(Map<String, dynamic> json) =>
      ChannelArchiveModel(
        channelId: json["channel_id"]?.toString(),
        channelMemberId: int.tryParse(json["channel_member_id"].toString()),
        archived: (json["archived"] is bool)
            ? (json["archived"] ? 1 : 0)
            : (int.tryParse(json["archived"].toString()) ?? 0),
      );

  Map<String, dynamic> toJson() => {
    "channel_id": channelId,
    "channel_member_id": channelMemberId,
    "archived": archived,
  };
}
