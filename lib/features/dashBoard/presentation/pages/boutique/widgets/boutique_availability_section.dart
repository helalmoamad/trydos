import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trydos/core/utils/media_display_url.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../boutique_form.dart';

/// Colours of the website's boutique screens (`addBoiutic.html`), shared by
/// every section of the boutique page.
abstract class BoutiqueColors {
  static const Color page = Color(0xFFFAFAFA);
  static const Color text = Color(0xFF3C3C3C);
  static const Color muted = Color(0xFF8E8E8E);
  static const Color border = Color(0xFFEDEDED);
  static const Color field = Color(0xFFF8F8F8);
  static const Color chip = Color(0xFFF2F2F2);
  static const Color primary = Color(0xFF5D5D5D);
  static const Color upload = Color(0xFF388CFF);
  static const Color secondaryButton = Color(0xFFF4F4F4);
  static const Color secondaryText = Color(0xFF505050);
  static const Color error = Color(0xFFD32F2F);
  static const Color active = Color(0xFF2E7D32);
  static const Color activeBg = Color(0xFFE8F5E9);
}

/// The white rounded card with an icon, a title and a subtitle that every
/// section of the boutique page uses.
class BoutiqueSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const BoutiqueSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: BoutiqueColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 19, color: BoutiqueColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: BoutiqueColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BoutiqueColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A boutique image: a file just picked ([localPath]) or a stored one
/// ([storedValue], a full URL or a file name). Decoded at [decodeWidth]
/// pixels — never at the photo's full size (review finding P-2).
class BoutiquePreviewImage extends StatelessWidget {
  final String? localPath;
  final String? storedValue;
  final String legacyFolder;
  final int decodeWidth;
  final IconData placeholder;

  const BoutiquePreviewImage({
    super.key,
    this.localPath,
    this.storedValue,
    required this.legacyFolder,
    required this.decodeWidth,
    this.placeholder = Icons.sell_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final int cacheWidth =
        (decodeWidth * MediaQuery.devicePixelRatioOf(context)).round();
    final Widget fallback = Center(
      child: Icon(placeholder, size: 26, color: BoutiqueColors.muted),
    );
    final String? local = localPath;
    if (local != null && local.isNotEmpty) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    final String? stored = storedValue;
    if (stored != null && stored.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: mediaDisplayUrl(stored, legacyFolder: legacyFolder),
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
        errorWidget: (_, __, ___) => fallback,
        placeholder: (_, __) => fallback,
      );
    }
    return fallback;
  }
}

/// Availability: Web, Mobile, or Web + Mobile. Labels are the app's own
/// translated words; the backend `label` is never shown.
class BoutiqueAvailabilitySection extends StatelessWidget {
  final List<int> options;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const BoutiqueAvailabilitySection({
    super.key,
    required this.options,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  static String labelOf(int value) {
    switch (value) {
      case BoutiqueAvailability.web:
        return LocaleKeys.boutique_availability_web.tr();
      case BoutiqueAvailability.mobile:
        return LocaleKeys.boutique_availability_mobile.tr();
      default:
        return LocaleKeys.boutique_availability_web_mobile.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> values = options.contains(value)
        ? options
        : <int>[...options, value];
    return BoutiqueSectionCard(
      icon: Icons.sell_outlined,
      title: LocaleKeys.boutique_availability.tr(),
      subtitle: LocaleKeys.boutique_availability_hint.tr(),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Opacity(
            opacity: enabled ? 1 : 0.7,
            child: DropdownButtonFormField<int>(
              // `initialValue` is read once; the key rebuilds the field when
              // the value changes from outside (Cancel, load).
              key: ValueKey<int>(value),
              initialValue: value,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: BoutiqueColors.field,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BoutiqueColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BoutiqueColors.border),
                ),
              ),
              items: <DropdownMenuItem<int>>[
                for (final int option in values)
                  DropdownMenuItem<int>(
                    value: option,
                    child: Text(labelOf(option)),
                  ),
              ],
              onChanged: enabled
                  ? (selected) {
                      if (selected != null) onChanged(selected);
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
