import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/voice_message_v2.dart';

/// يملك مشغّل الصوت ويغذّي [VoiceMessageV2] بحالته.
///
/// [VoiceMessageV2] شكلٌ خالص لا يعرف مشغّلاً. وهذا المضيف يفصل الاثنين:
/// التشغيل هنا، والرسم هناك — فيبقى التصميم قابلاً للمطابقة بلا أن يجرّ
/// معه حزمة صوت.
///
/// ومشغّلٌ واحد يعمل في كل لحظة: بدء رسالةٍ يوقف ما قبلها، كما في الويب.
class VoiceMessageHost extends StatefulWidget {
  const VoiceMessageHost({
    super.key,
    required this.isMine,
    required this.time,
    required this.label,
    this.file,
    this.fileUrl,
    this.status,
    this.totalSeconds = 0,
  });

  final bool isMine;
  final String time;
  final String label;

  /// الملف المحلّي — موجودٌ لما أرسلتُه قبل أن يؤكّده الخادم.
  final File? file;
  final String? fileUrl;

  final BubbleStatus? status;

  /// مدّة الرسالة كما يرسلها الخادم. تُستبدل بما يقوله المشغّل حين يعرفها.
  final int totalSeconds;

  @override
  State<VoiceMessageHost> createState() => _VoiceMessageHostState();
}

/// المشغّل العامل الآن — بدء غيره يوقفه.
AudioPlayer? _playingNow;

class _VoiceMessageHostState extends State<VoiceMessageHost> {
  final AudioPlayer _player = AudioPlayer();

  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  /// المصدر كما جُهِّز — يحتاجه أوّلُ تشغيل، انظر [_toggle].
  Source? _source;

  /// شُغِّل هذا المصدر مرّةً على الأقلّ، فـ`resume` تصلح له.
  ///
  /// علمٌ خاصٌّ بنا لا [PlayerState] الذي يقوله المشغّل: بعد `setSource` تختلف
  /// الحالة بين المنصّات — فيقول أحدها `stopped` والآخر `paused` — و`resume`
  /// على مشغّلٍ لم يبدأ تُبدّل حالتَه ولا تُخرج صوتاً ولا تبعث تقدّماً:
  /// العلامة تنقلب إلى «إيقاف» والخطّ واقف. وهو ما كان يحدث هنا.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.totalSeconds);
    _prepare();
  }

  Future<void> _prepare() async {
    final Source? source = widget.file != null
        ? DeviceFileSource(widget.file!.path)
        : (widget.fileUrl != null ? UrlSource(widget.fileUrl!) : null);
    if (source == null) return;
    _source = source;

    try {
      await _player.setSource(source);
      final Duration? d = await _player.getDuration();
      if (d != null && mounted) setState(() => _total = d);
    } catch (e) {
      // مصدرٌ لا يُقرأ هنا: تبقى المدّة من الخادم ويبقى الشكل سليماً،
      // و[_toggle] يُعيد المحاولة بـ`play` الذي يضبط المصدر بنفسه.
      devLog('voice: تعذّر تجهيز المصدر — $e');
    }

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      // انتهت: الضغطة التالية تبدأ من أوّلها، فـ`play` لا `resume`.
      _started = false;
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
      if (_playingNow == _player) _playingNow = null;
    });
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    if (_playingNow == _player) _playingNow = null;
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      _playing = false;
      await _player.pause();
      return;
    }

    final Source? source = _source;
    if (source == null) return;

    // رسالةٌ أخرى تعمل: تُوقَف أوّلاً.
    if (_playingNow != null && _playingNow != _player) {
      await _playingNow!.pause();
    }
    _playingNow = _player;

    try {
      // `resume` للمتوقّف مؤقّتاً وحده؛ وأوّل تشغيلٍ يحتاج `play` — وهو
      // يضبط المصدر بنفسه، فيعمل حتى لو أخفق `setSource` في [_prepare].
      if (_started) {
        await _player.resume();
      } else {
        await _player.play(source);
        _started = true;
      }
      // المدّة قد لا تُعرف قبل أوّل تشغيل، وبها يتحرّك الخطّ.
      final Duration? d = await _player.getDuration();
      if (d != null && d > Duration.zero && mounted) {
        setState(() => _total = d);
      }
    } catch (e) {
      _started = false;
      devLog('voice: تعذّر التشغيل — $e');
    }
  }

  Future<void> _seek(double ratio) async {
    if (_total == Duration.zero) return;
    final Duration target = Duration(
      milliseconds: (_total.inMilliseconds * ratio).round(),
    );
    await _player.seek(target);
    if (mounted) setState(() => _position = target);
  }

  /// `00:00` من مدّة.
  String _clock(Duration d) {
    final int m = d.inMinutes;
    final int s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _total.inMilliseconds == 0
        ? 0
        : _position.inMilliseconds / _total.inMilliseconds;

    return VoiceMessageV2(
      isMine: widget.isMine,
      time: widget.time,
      label: widget.label,
      // الكلّية عند السكون، والمنقضية أثناء التشغيل — كما في الويب.
      durationText: _position == Duration.zero
          ? _clock(_total)
          : _clock(_position),
      isPlaying: _playing,
      onTogglePlay: _toggle,
      onSeek: _seek,
      progress: progress.clamp(0.0, 1.0),
      status: widget.status,
    );
  }
}
