import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// The only screen the app shows when the device is rooted (Android) or
/// jailbroken (iOS).
///
/// There is no button and no way out of it on purpose. It is not pushed on a
/// navigator: `TrydosApplication` builds a `MaterialApp` with no router at all
/// when the device is blocked, so no back gesture and no deep link can reach
/// the rest of the app.
///
/// The colors here are fixed instead of coming from the theme, so the screen
/// looks the same whatever the system or app theme says.
class RootSecurityIssuePage extends StatelessWidget {
  const RootSecurityIssuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1528), Color(0xFF13203E), Color(0xFF0A101E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Color(0xFFFF7272),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  LocaleKeys.security_issues_found_title.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 22.sp,
                    height: 1.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.security_issues_found_message.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: const Color(0xFFB7C6E9),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  LocaleKeys.security_issues_found_details.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    height: 1.6,
                    color: const Color(0xFFB7C6E9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
