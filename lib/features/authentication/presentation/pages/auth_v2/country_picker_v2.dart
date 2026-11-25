/// منتقي الدولة — نقلٌ لـ`CountryPickerBody.tsx` و`CountryRow.tsx` في
/// `web_design/components/DemoApp1/screens/`؛ لوحا `Ramaaz pay signin – 16`
/// (ولا دولةَ بعد) و`– 15` (وقد اختيرت تركيا)، من الخريطة إلى أسفل.
///
/// > وهو أوّلُ خطوةٍ في الديمو. وعمودُ المعاينة السريعة يرسم ما فوقه —
/// > لافتةَ الشعار المتقلّبةَ ولافتةَ العلامة — فهذا الجزءُ يُرسم **تحت
/// > الشعار**، ويحفظ مسافاتِ الملفّ من حافّته السفلى (248):
/// >   - خريطةُ الدول الأربع 406.5×286.5 على (11.75، 287.75)؛
/// >   - الصفوفُ الأربعةُ من 594، بينها 4؛
/// >   - والفراغُ تحت آخر صفٍّ إلى طرف اللوح.
/// >
/// > ولمسةٌ على صفٍّ أو على دولةٍ في الخريطة تختارها: الرماديُّ يملأ الدولةَ
/// > من موضع اللمس (ومن وسطها إن جاءت اللمسةُ من صفّ)، ثمّ تبقى الصفحةُ على
/// > الاختيار التامّ حتّى [PickerXd.hold]، ثمّ تُسلّم.
library;

import 'dart:ui' as ui show Path;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';

import 'demo_country_map.dart';
import 'demo_design.dart';

/// دولةُ الديمو: مُعرِّفها في الخريطة، وعلمُها، ومفتاحُ اسمها.
class DemoCountry {
  const DemoCountry({required this.id, required this.flag, required this.name});

  final String id;
  final String flag;

  /// اسمُ الدولة كما يكتبه الويب مفتاحاً — يترجمه المتّصل.
  final String name;
}

/// ترتيبُ الصفوف كما في `COUNTRIES`: تركيا ثمّ سوريا ثمّ العراق ثمّ لبنان.
///
/// وملفّا XD يرسمان لسوريا علمَ تركيا سهواً؛ وسوريا تأخذ علمَها هي، مرسوماً
/// بالنمط نفسه (`flagSyRow`).
const List<DemoCountry> kDemoCountries = <DemoCountry>[
  DemoCountry(id: 'tr', flag: 'flagTr', name: 'Turkiye'),
  DemoCountry(id: 'sy', flag: 'flagSyRow', name: 'Syria'),
  DemoCountry(id: 'iq', flag: 'flagIq', name: 'Iraq'),
  DemoCountry(id: 'lb', flag: 'flagLb', name: 'Lebanon'),
];

class CountryPickerV2 extends StatefulWidget {
  const CountryPickerV2({super.key, required this.onDone});

  /// تُنادى مرّةً واحدة، بعد [PickerXd.hold] من اختيار الدولة.
  final ValueChanged<String> onDone;

  @override
  State<CountryPickerV2> createState() => _CountryPickerV2State();
}

class _CountryPickerV2State extends State<CountryPickerV2>
    with SingleTickerProviderStateMixin {
  Map<String, ui.Path>? _map;

  String? _picked;

  /// من أين يبدأ الرماديُّ، نسبةً إلى صندوق الدولة. ووسطُها مبدأُ لمسةِ صفٍّ.
  Offset _from = const Offset(0.5, 0.5);

  late final AnimationController _spread = AnimationController(
    duration: PickerXd.fill,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    loadCountryMap().then((Map<String, ui.Path> paths) {
      if (mounted) setState(() => _map = paths);
    });
  }

  @override
  void dispose() {
    _spread.dispose();
    super.dispose();
  }

  void _pick(String id, {Offset at = const Offset(0.5, 0.5)}) {
    // أوّلُ اختيارٍ يفوز: الخطوةُ التاليةُ في طريقها.
    if (_picked != null) return;
    setState(() {
      _from = at;
      _picked = id;
    });
    _spread.forward(from: 0);
    Future<void>.delayed(PickerXd.hold, () {
      if (mounted) widget.onDone(id);
    });
  }

  void _tapMap(Offset local, double scale) {
    final Map<String, ui.Path>? paths = _map;
    if (paths == null) return;
    // إلى إحداثيّات الملفّ: القياسُ ثمّ أصلُ `viewBox`.
    final Offset inFile = Offset(
      local.dx / scale + PickerXd.mapX,
      local.dy / scale + PickerXd.mapY,
    );
    final String? id = countryAt(paths, inFile);
    if (id == null) return;
    _pick(id, at: shareIn(paths[id]!, inFile));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: (PickerXd.mapY - PickerXd.logoEnd).h),
        _mapBox(),
        SizedBox(
          height: (PickerXd.firstRow - (PickerXd.mapY + PickerXd.mapH)).h,
        ),
        for (int i = 0; i < kDemoCountries.length; i += 1) ...<Widget>[
          if (i > 0) SizedBox(height: PickerXd.rowGap.h),
          _row(kDemoCountries[i]),
        ],
        // والفراغُ تحت آخر صفٍّ إلى طرف اللوح.
        SizedBox(height: (Xd.designH - PickerXd.lastRowEnd).h),
      ],
    );
  }

  /// الخريطةُ تحفظ عرضَ الملفّ (406.5) على هاتفٍ 430، ومسافتَها إلى
  /// الحافّتين على ما هو أضيق؛ وطولُها يتبع عرضَها.
  Widget _mapBox() {
    final double width = Xd.fill(PickerXd.mapX);
    final double scale = width / PickerXd.mapW;
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails d) => _tapMap(d.localPosition, scale),
        child: SizedBox(
          width: width,
          height: PickerXd.mapH * scale,
          child: _map == null
              ? const SizedBox.shrink()
              : AnimatedBuilder(
                  animation: _spread,
                  builder: (BuildContext context, Widget? _) => CustomPaint(
                    painter: _CountryMapPainter(
                      paths: _map!,
                      picked: _picked,
                      from: _from,
                      // يمضي إلى 1.05: فمِن أيّ بدايةٍ يستوي الصندوقُ كلُّه.
                      at:
                          PickerXd.fillEase.transform(_spread.value) *
                          PickerXd.fillOvershoot,
                      stroke: PickerXd.mapStroke * scale,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// صفُّ الدولة: 406×60 بنصف قطر 15 على 12، والعلمُ 30 على 12، والاسمُ 14
  /// بعده بـ12. وغيرُ المختار `#FCFCFC`، والمختارُ `#F8F8F8` بخطٍّ 0.5
  /// `#402CDD` داخلَ حافّته.
  Widget _row(DemoCountry country) {
    final bool on = country.id == _picked;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: XdRow.x.w),
      child: XdTap(
        // `whileTap={{ scale: 0.98 }}` في الويب.
        scale: 0.98,
        onTap: () => _pick(country.id),
        child: Container(
          width: Xd.fill(XdRow.x),
          height: CountryRowXd.height.h,
          decoration: BoxDecoration(
            color: on ? XdColors.field : XdColors.card,
            borderRadius: BorderRadius.circular(XdRow.radius.r),
          ),
          foregroundDecoration: on
              ? BoxDecoration(
                  border: Border.all(color: CountryRowXd.stroke, width: 0.5),
                  borderRadius: BorderRadius.circular(XdRow.radius.r),
                )
              : null,
          child: Row(
            children: <Widget>[
              SizedBox(width: CountryRowXd.flagInset.w),
              SvgPicture.asset(
                'assets/svg/$kDemoSvg/${country.flag}.svg',
                width: CountryRowXd.flag.w,
                height: CountryRowXd.flag.w,
              ),
              SizedBox(width: CountryRowXd.nameGap.w),
              Flexible(
                child: XdText(
                  country.name.tr(),
                  size: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// الخريطة: كلُّ دولةٍ بحشوها وخطّها، ثمّ خطُّ المختارة **فوق الجميع** فلا
/// تحجبه خطوطُ جيرانها — ترتيبُ الويب نفسُه.
class _CountryMapPainter extends CustomPainter {
  const _CountryMapPainter({
    required this.paths,
    required this.picked,
    required this.from,
    required this.at,
    required this.stroke,
  });

  final Map<String, ui.Path> paths;
  final String? picked;

  /// موضعُ بدء الرماديّ في صندوق الدولة، و«كم انتشر» (0 إلى 1.05).
  final Offset from;
  final double at;

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / PickerXd.mapW);
    canvas.translate(-PickerXd.mapX, -PickerXd.mapY);

    final double line = stroke / (size.width / PickerXd.mapW);

    for (final String id in PickerXd.mapOrder) {
      final ui.Path? path = paths[id];
      if (path == null) continue;
      final bool on = id == picked;
      canvas.drawPath(path, _fill(path, on));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = line
          ..color = on ? XdColors.purple : XdColors.line,
      );
    }
    final ui.Path? top = picked == null ? null : paths[picked];
    if (top != null) {
      canvas.drawPath(
        top,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = line
          ..color = XdColors.purple,
      );
    }
    canvas.restore();
  }

  /// القرصُ الرماديُّ ينمو من موضع اللمس بحدٍّ لَيّن، في صندوق الدولة وحدَه.
  /// وحين يغطّيها يصير الحشوُ رماديَّ `– 15` الصريح.
  Paint _fill(ui.Path path, bool on) {
    if (!on) return Paint()..color = PickerXd.empty;
    if (at >= 1) return Paint()..color = XdColors.grey;
    final Rect box = path.getBounds();
    return Paint()
      ..shader = RadialGradient(
        center: Alignment(from.dx * 2 - 1, from.dy * 2 - 1),
        radius: PickerXd.fillRadius,
        colors: const <Color>[XdColors.grey, PickerXd.empty],
        stops: <double>[at, (at + PickerXd.fillEdge).clamp(0.0, 1.0)],
      ).createShader(box);
  }

  @override
  bool shouldRepaint(_CountryMapPainter old) =>
      old.picked != picked ||
      old.at != at ||
      old.from != from ||
      old.stroke != stroke ||
      old.paths != paths;
}
