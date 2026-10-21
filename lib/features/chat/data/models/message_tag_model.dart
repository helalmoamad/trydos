/// وسم على رسالة، كما يصل داخل `tags` مع كل رسالة.
///
/// الوسم مشترك بين أعضاء القناة في **الاسم** لا في التطبيق: عدّة أشخاص قد
/// يسمون نفس الرسالة بنفس الاسم، فيحمل السطر الواحد عددهم ومعرّفاتهم. ولهذا
/// لا يكفي وجود الوسم في القائمة لنعرف أنني وسمتُها — لا بدّ من البحث عن
/// معرّفي في [userIds]، وهو ما تفعله [appliedBy].
class MessageTag {
  final String tag;

  /// عدد من وسم الرسالة بهذا الاسم. يُعرض رقماً صغيراً بجانب الاسم.
  final int count;

  /// معرّفات من وسم الرسالة. منها نعرف حالة السطر عندي: مطبَّق أم اقتراح.
  final List<int> userIds;

  const MessageTag({
    required this.tag,
    this.count = 0,
    this.userIds = const [],
  });

  /// هل وسم [userId] هذه الرسالة بهذا الوسم؟
  bool appliedBy(int? userId) => userId != null && userIds.contains(userId);

  factory MessageTag.fromJson(Map<String, dynamic> json) => MessageTag(
    tag: json["tag"]?.toString() ?? '',
    count: int.tryParse(json["count"].toString()) ?? 0,
    userIds: json["user_ids"] is List
        ? (json["user_ids"] as List)
              .map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toList()
        : const <int>[],
  );

  Map<String, dynamic> toJson() => {
    "tag": tag,
    "count": count,
    "user_ids": userIds,
  };

  /// يقرأ `tags` بأي شكل وصل.
  ///
  /// الحقل يصل قائمةً فارغة في أغلب الرسائل، ولا يصل إطلاقاً في الحمولات
  /// المحفوظة داخل `hydrated_bloc` قبل هذه الميزة. وكلا الحالتين «بلا وسوم»
  /// لا خطأ — فلا نرمي، ولا نُسقط رسائل المستخدم المخزَّنة.
  /// أقصى طول يقبله الخادم. الوسم نصّ حرّ — عربي أو إنجليزي أو رموز.
  static const int maxLength = 30;

  static List<MessageTag> listFrom(dynamic value) {
    if (value is! List) return const <MessageTag>[];
    return value
        .whereType<Map>()
        .map((e) => MessageTag.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.tag.isNotEmpty)
        .toList();
  }
}

/// ردّ الخادم على إضافة وسم أو إزالته.
///
/// يعيد **القائمة كاملة بعد التغيير** لا السطر المتغيّر وحده، فنأخذها كما هي
/// بدل أن نحسب العدّاد عندنا — الوسم مشترك، وقد يكون شخصٌ آخر وسم الرسالة
/// بينما كانت نافذتنا مفتوحة.
class MessageTagToggleResult {
  final String messageId;
  final String tag;

  /// `true` إن أُضيف الوسم، `false` إن أُزيل. من حقل `action` في الردّ.
  final bool added;

  /// وسوم الرسالة كلّها بعد التغيير.
  final List<MessageTag> tags;

  const MessageTagToggleResult({
    required this.messageId,
    required this.tag,
    required this.added,
    this.tags = const [],
  });

  factory MessageTagToggleResult.fromJson(Map<String, dynamic> json) =>
      MessageTagToggleResult(
        messageId: json["message_id"].toString(),
        tag: json["tag"]?.toString() ?? '',
        added: json["action"]?.toString() == 'added',
        tags: MessageTag.listFrom(json["tags"]),
      );
}
