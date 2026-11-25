/// مُضيفُ صفحة التسجيل: يختار نسختَها بحسب مفتاح التصميم.
///
/// > صفحةُ التسجيل القديمة ([RegistrationPage]) باقيةٌ كما هي بسبع صفحاتها
/// > وودجاتها؛ والجديدةُ ([RegistrationPageV2]) تُدير شاشاتَ `auth_v2` على
/// > المنطق نفسِه. والاختيارُ هنا، في موضعٍ واحد.
library;

import 'package:flutter/material.dart';

import 'package:trydos/features/authentication/presentation/pages/auth_v2/auth_design.dart';
import 'package:trydos/features/authentication/presentation/pages/auth_v2/registration_page_v2.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';

/// صفحةُ التسجيل بالتصميم المُشغَّل.
Widget registrationPage({Key? key, bool? fromLogOut = false}) =>
    kAuthDesignV2
    ? RegistrationPageV2(key: key, fromLogOut: fromLogOut)
    : RegistrationPage(key: key, fromLogOut: fromLogOut);
