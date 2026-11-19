import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/animated_emoji_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/pick_sheet_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/reaction_fly_v2.dart';

/// تبويبات نافذة التفاعلات الستّة.
enum ReactionTab { all, recent, popular, smileys, gestures, symbols }

/// نافذة التفاعلات الموسَّعة التي يفتحها زرّ «+» في شريط القائمة.
///
/// منقولةٌ من `web_design/components/DemoApp1/chat/ReactionSheet.tsx` على فرع
/// `development`: عنوانٌ 16 Medium، وحقلُ بحثٍ ارتفاعه 36 بنصف قطر 12 ولون
/// `rgba(118,118,128,0.12)` فيه عدسةٌ 16 على بعد 14 و✕ في دائرةٍ رمادية متى
/// كُتب شيء، وحبّاتُ التبويبات 13 Medium (المختار حبرياً والبقيّة رمادية على
/// `rgba(118,118,128,0.08)`) وتغيب أثناء البحث، وشبكةٌ من **ستّة أعمدة**
/// خاناتُها 48 ورموزُها 30، والمختار بخلفيّةٍ `rgba(0,0,0,0.09)` وحدٍّ
/// `rgba(0,0,0,0.08)`.
class ReactionSheetV2 extends StatefulWidget {
  const ReactionSheetV2({
    super.key,
    required this.onPick,
    required this.searchHint,
    required this.emptyLabel,
    required this.titleLabel,
    required this.labelOf,
    this.current,
  });

  /// الرمز، ومركزُ خانته ومقاسُه — لتطير منهما الحبّة إلى الرسالة.
  final void Function(String emoji, Offset from, double size) onPick;

  final String searchHint;
  final String emptyLabel;
  final String titleLabel;
  final String Function(ReactionTab) labelOf;

  /// الرمز الذي تحمله الرسالة الآن — يُعلَّم في الشبكة.
  final String? current;

  /// مقاس الرمز في الخانة.
  static const double emojiSize = 30;

  /// الخانة 48، والشبكة ستّة أعمدة.
  static const double cell = 48;
  static const int columns = 6;

  /// سقف ارتفاع الشبكة في الملف.
  static const double gridMaxHeight = 380;

  /// الوجوه.
  static const List<String> smileys = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😛',
    '😝',
    '😜',
    '🤪',
    '🤨',
    '🧐',
    '🤓',
    '😎',
    '🥸',
    '🤩',
    '🥳',
    '😏',
    '😒',
    '😞',
    '😔',
    '😟',
    '😕',
    '🙁',
    '☹️',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥺',
    '😢',
    '😭',
    '😮',
    '😯',
    '😲',
    '😳',
    '🤯',
    '😱',
    '😨',
    '😰',
    '😥',
    '😓',
    '🤔',
    '🫡',
    '🤐',
    '😶',
    '😐',
    '😑',
    '😬',
    '🥱',
    '😴',
    '🤤',
    '😷',
    '🤒',
    '🤕',
    '🤢',
    '🤮',
    '🤧',
    '🥵',
    '🥶',
    '🥴',
    '😵',
    '🤠',
    '😈',
    '👿',
    '💀',
    '☠️',
    '👻',
    '👽',
    '👾',
    '🤖',
    '💩',
  ];

  /// الأيدي والقلوب.
  static const List<String> gestures = [
    '👍',
    '👎',
    '👏',
    '🙌',
    '🫶',
    '👐',
    '🤲',
    '🤝',
    '🙏',
    '✍️',
    '💪',
    '👈',
    '👉',
    '👆',
    '👇',
    '☝️',
    '✌️',
    '🤞',
    '🫰',
    '🤟',
    '🤘',
    '🤙',
    '🖐️',
    '✋',
    '🖖',
    '👋',
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🖤',
    '🤍',
    '🤎',
    '💔',
    '❣️',
    '💕',
    '💞',
    '💓',
    '💗',
    '💖',
    '💘',
    '💝',
    '💟',
  ];

  /// الأشياء والرموز.
  static const List<String> symbols = [
    '🔥',
    '💯',
    '✨',
    '🎉',
    '🎊',
    '🎈',
    '🎁',
    '🏆',
    '🥇',
    '⭐',
    '🌟',
    '⚡',
    '🌈',
    '💥',
    '🍕',
    '🍔',
    '🥑',
    '🍩',
    '🍦',
    '🍿',
    '☕',
    '🍾',
    '🍻',
    '⚽',
    '🏀',
    '🏈',
    '🎾',
    '🎯',
    '🚀',
    '🚗',
    '✈️',
    '🚲',
    '💡',
    '📱',
    '💻',
    '📷',
    '💎',
    '🔔',
    '🎶',
    '⚠️',
    '✅',
    '❌',
    '❓',
    '❗',
  ];

  /// كلماتٌ مفتاحية للبحث — من `EMOJI_KEYWORDS` في الملف، وأشيعُها هنا.
  static const Map<String, List<String>> keywords = {
    '👍': ['thumbs up', 'like', 'yes', 'good', 'ok', 'موافق', 'اعجاب'],
    '👎': ['thumbs down', 'dislike', 'no', 'bad', 'رفض'],
    '❤️': ['heart', 'love', 'قلب', 'حب'],
    '😂': ['laugh', 'joy', 'lol', 'haha', 'ضحك'],
    '🤣': ['rofl', 'laugh', 'lol', 'ضحك'],
    '😮': ['wow', 'surprise', 'omg', 'shock', 'دهشة'],
    '😢': ['sad', 'cry', 'tear', 'حزن', 'بكاء'],
    '🙏': ['pray', 'thanks', 'please', 'شكرا', 'دعاء'],
    '😘': ['kiss', 'love', 'قبلة'],
    '🔥': ['fire', 'hot', 'lit', 'نار'],
    '🎉': ['party', 'celebrate', 'tada', 'احتفال'],
    '👏': ['clap', 'applause', 'تصفيق'],
    '😍': ['love', 'heart eyes', 'اعجاب'],
    '🤔': ['think', 'hmm', 'تفكير'],
    '💯': ['hundred', 'perfect', 'score'],
    '🚀': ['rocket', 'launch', 'fast', 'صاروخ'],
    '✅': ['check', 'done', 'yes', 'تم'],
    '❌': ['cross', 'no', 'wrong', 'cancel', 'خطأ'],
    '⚠️': ['warning', 'caution', 'alert', 'تحذير'],
    '❓': ['question', 'what', 'help', 'سؤال'],
    '❗': ['exclamation', 'important', 'alert', 'مهم'],
    '💡': ['idea', 'lightbulb', 'فكرة'],
    '🎁': ['gift', 'present', 'هدية'],
    '🏆': ['trophy', 'winner', 'كأس'],
    '💎': ['diamond', 'gem', 'الماس'],
    '☕': ['coffee', 'tea', 'قهوة'],
    '🍕': ['pizza', 'food', 'طعام'],
    '⚽': ['football', 'soccer', 'كرة'],
    '📱': ['phone', 'mobile', 'هاتف'],
    '💻': ['laptop', 'computer', 'حاسوب'],
  };

  /// كلُّ الرموز بلا تكرار: السبعة، ثم المشهورة، ثم المجموعات الثلاث.
  static List<String> get all {
    final List<String> out = [];
    for (final List<String> group in [
      AnimatedEmojiV2.primary,
      AnimatedEmojiV2.popular,
      smileys,
      gestures,
      symbols,
    ]) {
      for (final String e in group) {
        if (!out.contains(e)) out.add(e);
      }
    }
    return out;
  }

  /// يفتحها بغشاوة النوافذ ونصف قطرها نفسه.
  static Future<void> show(
    BuildContext context, {
    required void Function(String emoji, Offset from, double size) onPick,
    required String searchHint,
    required String emptyLabel,
    required String titleLabel,
    required String Function(ReactionTab) labelOf,
    String? current,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: PickSheetV2.backdrop,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PickSheetV2.radius.r),
        ),
      ),
      builder: (_) => ReactionSheetV2(
        onPick: onPick,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
        titleLabel: titleLabel,
        labelOf: labelOf,
        current: current,
      ),
    );
  }

  @override
  State<ReactionSheetV2> createState() => _ReactionSheetV2State();
}

class _ReactionSheetV2State extends State<ReactionSheetV2> {
  final TextEditingController _query = TextEditingController();
  ReactionTab _tab = ReactionTab.all;

  /// مفتاحٌ لكل خانةٍ معروضة، لقياس موضعها عند الاختيار.
  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// رموز التبويب، أو نتائج البحث متى كُتب شيء.
  List<String> get _shown {
    final String q = _query.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      return ReactionSheetV2.all.where((emoji) {
        if (emoji.contains(q)) return true;
        final List<String> words = ReactionSheetV2.keywords[emoji] ?? const [];
        return words.any((w) => w.toLowerCase().contains(q));
      }).toList();
    }
    switch (_tab) {
      case ReactionTab.recent:
        return AnimatedEmojiV2.primary;
      case ReactionTab.popular:
        return AnimatedEmojiV2.popular;
      case ReactionTab.smileys:
        return ReactionSheetV2.smileys;
      case ReactionTab.gestures:
        return ReactionSheetV2.gestures;
      case ReactionTab.symbols:
        return ReactionSheetV2.symbols;
      case ReactionTab.all:
        return ReactionSheetV2.all;
    }
  }

  void _pick(String emoji) {
    final GlobalKey? key = _keys[emoji];
    final Offset center =
        (key == null ? null : centerOfKey(key)) ?? Offset.zero;
    Navigator.of(context).pop();
    widget.onPick(emoji, center, ReactionSheetV2.emojiSize);
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = _query.text.trim().isNotEmpty;
    final List<String> shown = _shown;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
              child: DesignText(
                widget.titleLabel,
                size: 16,
                family: 'Quicksand-Medium',
                center: true,
              ),
            ),
            _search(),
            if (!searching) _tabs(),
            if (shown.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: DesignText(
                  widget.emptyLabel,
                  size: 14,
                  family: 'Quicksand-Regular',
                  color: ContactDesign.grey,
                  center: true,
                ),
              )
            else
              _grid(shown),
          ],
        ),
      ),
    );
  }

  /// حقل البحث: 36 بنصف قطر 12، عدسةٌ 16 عند 14، و✕ في دائرةٍ رمادية.
  Widget _search() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 36.h,
      decoration: BoxDecoration(
        color: const Color(0x1F767680),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 14.w, end: 8.w),
            child: Icon(Icons.search, size: 16.sp, color: ContactDesign.grey),
          ),
          Expanded(
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: 'Quicksand-Regular',
                fontSize: 14.sp,
                color: ContactDesign.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.searchHint,
                hintStyle: TextStyle(
                  fontFamily: 'Quicksand-Regular',
                  fontSize: 14.sp,
                  color: ContactDesign.grey,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_query.text.trim().isNotEmpty)
            GestureDetector(
              onTap: () => setState(_query.clear),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: 6.w, end: 10.w),
                width: 20.w,
                height: 20.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4D4D4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12.sp, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// حبّات التبويبات — تغيب أثناء البحث.
  Widget _tabs() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final ReactionTab tab in ReactionTab.values)
              GestureDetector(
                onTap: () => setState(() => _tab = tab),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: EdgeInsetsDirectional.only(end: 6.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _tab == tab
                        ? ContactDesign.ink
                        : const Color(0x14767680),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: DesignText(
                    widget.labelOf(tab),
                    size: 13,
                    family: 'Quicksand-Medium',
                    color: _tab == tab ? Colors.white : ContactDesign.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// شبكة الرموز: ستّة أعمدة، خاناتٌ 48، ورموزٌ 30.
  Widget _grid(List<String> shown) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ReactionSheetV2.gridMaxHeight.h),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: shown.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ReactionSheetV2.columns,
          mainAxisSpacing: 8.h,
        ),
        itemBuilder: (context, index) {
          final String emoji = shown[index];
          final bool chosen = widget.current == emoji;
          final GlobalKey key = _keys.putIfAbsent(emoji, GlobalKey.new);

          return Center(
            child: GestureDetector(
              onTap: () => _pick(emoji),
              behavior: HitTestBehavior.opaque,
              child: Container(
                key: key,
                width: ReactionSheetV2.cell.w,
                height: ReactionSheetV2.cell.w,
                alignment: Alignment.center,
                decoration: chosen
                    ? BoxDecoration(
                        color: const Color(0x17000000),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x14000000)),
                      )
                    : null,
                child: AnimatedEmoji(
                  emoji: emoji,
                  size: ReactionSheetV2.emojiSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
