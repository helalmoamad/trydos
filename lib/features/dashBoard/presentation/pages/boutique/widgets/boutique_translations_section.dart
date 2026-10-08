import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../boutique_form.dart';
import 'boutique_availability_section.dart';
import 'boutique_banner_grid.dart';
import 'boutique_rich_text_field.dart';

/// Translations: one pill tab per language, and the five fields of the active
/// language only — the other languages are not built (review finding P-2).
///
/// Text lives in controllers owned by the page; this widget never pushes a
/// keystroke into the bloc (review finding P-3).
class BoutiqueTranslationsSection extends StatelessWidget {
  final List<BoutiqueLanguage> languages;
  final String activeLanguage;
  final ValueChanged<String> onTabSelected;
  final TranslationForm translation;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final QuillController descriptionController;
  final bool editing;
  final Set<BoutiqueField> errors;

  /// For each field, the other languages it can be copied from (AC-21).
  final Map<BoutiqueField, List<BoutiqueLanguage>> copySources;
  final void Function(BoutiqueField field, String fromLanguage) onCopy;
  final bool iconUploading;
  final VoidCallback onPickIcon;
  final int bannersPending;
  final VoidCallback onAddBanners;
  final void Function(int index, int delta) onMoveBanner;
  final ValueChanged<int> onRemoveBanner;

  const BoutiqueTranslationsSection({
    super.key,
    required this.languages,
    required this.activeLanguage,
    required this.onTabSelected,
    required this.translation,
    required this.nameController,
    required this.bioController,
    required this.descriptionController,
    required this.editing,
    required this.errors,
    required this.copySources,
    required this.onCopy,
    required this.iconUploading,
    required this.onPickIcon,
    required this.bannersPending,
    required this.onAddBanners,
    required this.onMoveBanner,
    required this.onRemoveBanner,
  });

  @override
  Widget build(BuildContext context) {
    return BoutiqueSectionCard(
      icon: Icons.edit_note,
      title: LocaleKeys.boutique_translations.tr(),
      subtitle: LocaleKeys.boutique_translations_hint.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LanguageTabs(
            languages: languages,
            active: activeLanguage,
            onSelected: onTabSelected,
          ),
          const SizedBox(height: 20),
          _FieldBlock(
            label: LocaleKeys.boutique_name.tr(),
            field: BoutiqueField.name,
            parent: this,
            child: _TextInput(
              controller: nameController,
              enabled: editing,
              hasError: errors.contains(BoutiqueField.name),
            ),
          ),
          _FieldBlock(
            label: LocaleKeys.boutique_icon.tr(),
            field: BoutiqueField.icon,
            parent: this,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: errors.contains(BoutiqueField.icon)
                          ? BoutiqueColors.error
                          : BoutiqueColors.border,
                    ),
                  ),
                  child: BoutiquePreviewImage(
                    localPath: translation.iconLocalPath,
                    storedValue: translation.iconPreviewUrl ??
                        (translation.icon.isEmpty ? null : translation.icon),
                    legacyFolder: 'boutiques/boutiques/icon',
                    decodeWidth: 72,
                  ),
                ),
                const SizedBox(width: 16),
                if (editing)
                  OutlinedButton.icon(
                    onPressed: iconUploading ? null : onPickIcon,
                    icon: iconUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload, size: 17),
                    label: Text(LocaleKeys.boutique_upload_icon.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BoutiqueColors.upload,
                      side: const BorderSide(color: BoutiqueColors.upload),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _FieldBlock(
            label: LocaleKeys.boutique_description.tr(),
            field: BoutiqueField.description,
            parent: this,
            child: BoutiqueRichTextField(
              // A new controller per language: the key makes the editor
              // follow it on a tab change.
              key: ObjectKey(descriptionController),
              controller: descriptionController,
              enabled: editing,
              hasError: errors.contains(BoutiqueField.description),
            ),
          ),
          _FieldBlock(
            label: LocaleKeys.boutique_bio.tr(),
            field: BoutiqueField.bio,
            parent: this,
            child: _TextInput(
              controller: bioController,
              enabled: editing,
              hasError: errors.contains(BoutiqueField.bio),
              maxLines: 3,
            ),
          ),
          _FieldBlock(
            label: LocaleKeys.boutique_banners.tr(),
            field: BoutiqueField.banners,
            parent: this,
            hint: LocaleKeys.boutique_banners_hint.tr(),
            child: BoutiqueBannerGrid(
              banners: translation.banners,
              editing: editing,
              pending: bannersPending,
              onAdd: onAddBanners,
              onMove: onMoveBanner,
              onRemove: onRemoveBanner,
            ),
          ),
        ],
      ),
    );
  }

  static String errorText(BoutiqueField field) {
    switch (field) {
      case BoutiqueField.name:
        return LocaleKeys.boutique_name_required.tr();
      case BoutiqueField.icon:
        return LocaleKeys.boutique_icon_required.tr();
      case BoutiqueField.description:
        return LocaleKeys.boutique_description_required.tr();
      case BoutiqueField.bio:
        return LocaleKeys.boutique_bio_required.tr();
      case BoutiqueField.banners:
        return LocaleKeys.boutique_banner_required.tr();
    }
  }
}

class _LanguageTabs extends StatelessWidget {
  final List<BoutiqueLanguage> languages;
  final String active;
  final ValueChanged<String> onSelected;

  const _LanguageTabs({
    required this.languages,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final BoutiqueLanguage language in languages)
                GestureDetector(
                  onTap: () => onSelected(language.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: language.code == active ? Colors.white : null,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: language.code == active
                          ? const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      language.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: language.code == active
                            ? BoutiqueColors.primary
                            : BoutiqueColors.muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label row (with the field's **Copy from…** menu), an optional hint, the
/// field, and its error.
class _FieldBlock extends StatelessWidget {
  final String label;
  final BoutiqueField field;
  final BoutiqueTranslationsSection parent;
  final String? hint;
  final Widget child;

  const _FieldBlock({
    required this.label,
    required this.field,
    required this.parent,
    this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final List<BoutiqueLanguage> sources =
        parent.copySources[field] ?? const <BoutiqueLanguage>[];
    final bool hasError = parent.errors.contains(field);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$label *',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BoutiqueColors.text,
                    ),
                  ),
                ),
                if (parent.editing && sources.isNotEmpty)
                  PopupMenuButton<String>(
                    tooltip: LocaleKeys.boutique_copy_from.tr(),
                    onSelected: (code) => parent.onCopy(field, code),
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      for (final BoutiqueLanguage language in sources)
                        PopupMenuItem<String>(
                          value: language.code,
                          child: Text(language.label),
                        ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.content_copy,
                          size: 14,
                          color: BoutiqueColors.upload,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          LocaleKeys.boutique_copy_from.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: BoutiqueColors.upload,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (hint != null) ...[
            Text(
              hint!,
              style: const TextStyle(fontSize: 12, color: BoutiqueColors.muted),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 6),
          child,
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              BoutiqueTranslationsSection.errorText(field),
              style: const TextStyle(fontSize: 12, color: BoutiqueColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool hasError;
  final int maxLines;

  const _TextInput({
    required this.controller,
    required this.enabled,
    required this.hasError,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    final Color edge = hasError ? BoutiqueColors.error : BoutiqueColors.border;
    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: BoutiqueColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: BoutiqueColors.field,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: border(edge),
          enabledBorder: border(edge),
          disabledBorder: border(edge),
          focusedBorder: border(
            hasError ? BoutiqueColors.error : BoutiqueColors.primary,
          ),
        ),
      ),
    );
  }
}
