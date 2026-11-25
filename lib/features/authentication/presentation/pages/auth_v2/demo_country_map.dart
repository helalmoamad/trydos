/// خريطةُ الدول الأربع — `countryMap.svg` نفسُه الذي يستعمله الويب.
///
/// > الويبُ يرسمها بـ`<use href="#id">`: مسارٌ لكلّ دولةٍ بلا لونٍ خاصّ، ثمّ
/// > استعمالان — أحدهما يُعطيه حشوَه وخطَّه، والآخرُ يرسم خطَّ المختارة
/// > **فوق الجميع** فلا تحجبه خطوطُ جيرانها الرمادية.
/// >
/// > و`flutter_svg` لا يُعطي مساراً يُلوَّن، ولا يُلمس مسارٌ فيه. فالملفُّ
/// > يُقرأ هنا نصّاً وتُستخرج منه المساراتُ الأربعةُ وتُرسم بأنفسنا: فيُلوَّن
/// > كلٌّ منها وحدَه، وينتشر الرماديُّ فيه من موضع الإصبع، ويُعرف أيُّ دولةٍ
/// > تحت اللمس بـ`Path.contains`.
/// >
/// > ومسارُ الملفّ فيه `M` و`L` و`Z` وحدَها — لا منحنىً واحد، فهي خريطةٌ
/// > مُقتفاة. ولكلّ مسارٍ `transform="matrix(1 0 0 1 tx ty)"`، إزاحةٌ محضة.
library;

import 'dart:ui' show Offset, Path, PathFillType, Rect;

import 'package:flutter/services.dart' show rootBundle;

import 'demo_design.dart';

/// المساراتُ في إحداثيّات الملفّ (بعد إزاحة كلٍّ منها)، تُقرأ مرّةً واحدة.
Future<Map<String, Path>>? _loading;

Future<Map<String, Path>> loadCountryMap() =>
    _loading ??= _read('assets/svg/$kDemoSvg/countryMap.svg');

Future<Map<String, Path>> _read(String asset) async =>
    parseCountryMap(await rootBundle.loadString(asset));

/// المساراتُ الأربعةُ من نصّ الملفّ — عامّةٌ ليُجرَّب قارئُها على الملفّ نفسِه.
Map<String, Path> parseCountryMap(String source) {
  final Map<String, Path> paths = <String, Path>{};
  final RegExp one = RegExp(
    r'<path id="(\w+)" d="([^"]+)" transform="matrix\('
    r'\s*1\s+0\s+0\s+1\s+([-\d.]+)\s+([-\d.]+)\s*\)"',
  );
  for (final RegExpMatch m in one.allMatches(source)) {
    paths[m.group(1)!] = _parse(
      m.group(2)!,
      double.parse(m.group(3)!),
      double.parse(m.group(4)!),
    );
  }
  return paths;
}

/// `M x y`، و`L x y`، و`Z` — والإزاحةُ تُطبَّق على كلّ نقطةٍ عند بنائها.
///
/// وتركيا ستّةُ أجزاء (جزرٌ وبرٌّ)، فالحشوُ `evenOdd` كما يحشو SVG افتراضاً.
Path _parse(String d, double tx, double ty) {
  final Path path = Path()..fillType = PathFillType.evenOdd;
  final List<String> tokens = d.split(RegExp(r'[\s,]+'));
  String command = 'M';
  int i = 0;
  while (i < tokens.length) {
    final String token = tokens[i];
    if (token.isEmpty) {
      i += 1;
      continue;
    }
    final double? number = double.tryParse(token);
    if (number == null) {
      command = token;
      i += 1;
      if (command == 'Z' || command == 'z') path.close();
      continue;
    }
    // رقمٌ بلا حرفٍ قبله يُعيد الأمرَ السابق، و`M` المتكرّرةُ تصير `L`.
    final double x = number + tx;
    final double y = double.parse(tokens[i + 1]) + ty;
    if (command == 'M') {
      path.moveTo(x, y);
      command = 'L';
    } else {
      path.lineTo(x, y);
    }
    i += 2;
  }
  return path;
}

/// أيُّ دولةٍ تحت هذه النقطة، بإحداثيّات الملفّ — والأعلى أوّلاً، فتركيا
/// مرسومةٌ فوق ما قبلها فتُسأل قبله.
String? countryAt(Map<String, Path> paths, Offset point) {
  for (final String id in PickerXd.mapOrder.reversed) {
    if (paths[id]?.contains(point) ?? false) return id;
  }
  return null;
}

/// موضعُ اللمس في صندوق الدولة، نسبةً إلى ضلعيه (0 إلى 1).
Offset shareIn(Path country, Offset point) {
  final Rect box = country.getBounds();
  if (box.width == 0 || box.height == 0) return const Offset(0.5, 0.5);
  return Offset(
    ((point.dx - box.left) / box.width).clamp(0.0, 1.0),
    ((point.dy - box.top) / box.height).clamp(0.0, 1.0),
  );
}
