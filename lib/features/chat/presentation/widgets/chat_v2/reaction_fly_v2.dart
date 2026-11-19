import 'package:flutter/widgets.dart';

/// الرمز الذي اختير للتوّ في الشريط، في طريقه إلى الرسالة.
///
/// منقولٌ من `web_design/components/DemoApp1/chat/reactionFly.ts` على فرع
/// `development`:
///
/// > الشريط والحبّة التي تهبط على الرسالة شيئان منفصلان: القائمة تُغلق
/// > والحبّة تظهر في الإطار نفسه. فالقائمة تترك هنا موضعَ الرمز المختار
/// > (مركزَ خانته ومقاسه على الشاشة)، والحبّة — إن كانت حبّةَ تلك الرسالة
/// > وذلك الرمز — تقرأه عند تركيبها فتطير من هناك، كما تفعل واتساب على
/// > الآيفون.
class ReactionFly {
  const ReactionFly({
    required this.messageId,
    required this.emoji,
    required this.center,
    required this.size,
    required this.at,
  });

  final String messageId;
  final String emoji;

  /// مركز الرمز المختار في الشريط، بإحداثيّات الشاشة.
  final Offset center;

  /// مقاس الرمز في الشريط.
  final double size;

  /// لحظة الإطلاق — طيرانٌ لم تستلمه حبّةٌ يُهمَل بعد [wait].
  final DateTime at;
}

/// مخزنُ الطيران المعلَّق — واحدٌ في كل لحظة، كما في الويب.
abstract class ReactionFlyStore {
  /// كم ينتظر الطيرانُ حبّتَه.
  static const Duration wait = Duration(milliseconds: 1500);

  static ReactionFly? _pending;

  /// جهةُ الشريط: هذا الرمز على وشك الهبوط على الرسالة.
  static void launch({
    required String messageId,
    required String emoji,
    required Offset center,
    required double size,
  }) {
    _pending = ReactionFly(
      messageId: messageId,
      emoji: emoji,
      center: center,
      size: size,
      at: DateTime.now(),
    );
  }

  /// جهةُ الحبّة: الطيرانُ المقصودُ بها، أو `null`.
  ///
  /// يقرأ ولا يمحو: الودجت قد تُبنى مرّتين، والثانية يجب أن تجد الطيران نفسه.
  /// والحبّة تمحوه بـ[drop] متى أخذته.
  static ReactionFly? peek(String messageId, String emoji) {
    final ReactionFly? fly = _pending;
    if (fly == null) return null;
    if (fly.messageId != messageId || fly.emoji != emoji) return null;
    if (DateTime.now().difference(fly.at) > wait) return null;
    return fly;
  }

  /// الحبّة أخذت طيرانها.
  static void drop() => _pending = null;
}

/// موضعُ رمزٍ على الشاشة، من مفتاحه.
///
/// يُستعمل في شريط القائمة ونافذة التفاعلات معاً لتسجيل نقطة الانطلاق.
Offset? centerOfKey(GlobalKey key) {
  final BuildContext? context = key.currentContext;
  if (context == null) return null;
  final RenderObject? object = context.findRenderObject();
  if (object is! RenderBox || !object.hasSize) return null;
  return object.localToGlobal(object.size.center(Offset.zero));
}
