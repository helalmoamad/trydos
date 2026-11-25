import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// الملفّ — لوح XD `Home Page – 16`.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/ProfileMenuScreen.tsx`:
///
/// > أربعة صفوفٍ 406 × 60 من y 120 (20 تحت الترويسة)، بينها 4، بزاوية 15
/// > ولون `#FCFCFC`؛ أيقونةٌ 30 على x 24 والنصّ، 14 Regular، على x 66.
///
/// وتفتحها بطاقةُ العميل في تبويب الملفّ.
class ProfileMenuPageV2 extends StatelessWidget {
  const ProfileMenuPageV2({
    super.key,
    required this.onClientInfo,
    required this.onPersonalInfo,
    required this.onBody,
    required this.onAddress,
  });

  final VoidCallback onClientInfo;
  final VoidCallback onPersonalInfo;
  final VoidCallback onBody;
  final VoidCallback onAddress;

  /// الصفوف الأربعة — `ROWS` في الويب.
  static const List<({String icon, String label})> _rows =
      <({String icon, String label})>[
        (icon: 'rowClient', label: LocaleKeys.client_info),
        (icon: 'rowPersonal', label: LocaleKeys.personal_info),
        (icon: 'rowBody', label: LocaleKeys.body_measurements),
        (icon: 'rowAddress', label: LocaleKeys.address),
      ];

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> taps = <VoidCallback>[
      onClientInfo,
      onPersonalInfo,
      onBody,
      onAddress,
    ];
    return XdScreenPage(
      header: XdScreenHeader(
        title: LocaleKeys.profile.tr(),
        onBack: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < _rows.length; i++)
            XdMenuRow(
              // 20 تحت الترويسة، ثمّ 4 بين صفٍّ وآخر.
              mt: i == 0 ? 20 : 4,
              icon: _rows[i].icon,
              iconSize: 30,
              label: _rows[i].label.tr(),
              textX: 66,
              onTap: taps[i],
            ),
        ],
      ),
    );
  }
}
