/// The boutique editor's form and the rules that decide what is sent.
///
/// Pure Dart on purpose — no Flutter, no network. Everything that can damage a
/// boutique the website also edits lives here: the per-language key of the
/// body, which ids are kept, the banner order, and the "file name only" rule.
/// Keeping it in one small file makes it reviewable now and testable later
/// without a refactor (plan Step 7).
///
/// Source of the rules: `.claude/docs/seller-dashboard-boutiques-dev-guide.md`
/// §6 (form), §7.2 (file names), §8 (mapping).
library;

import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';

/// Where the boutique is shown. The backend `label` is never displayed.
abstract class BoutiqueAvailability {
  static const int web = 1;
  static const int mobile = 2;
  static const int webAndMobile = 3;

  static const List<int> all = <int>[web, mobile, webAndMobile];

  /// Unknown or missing values show as Web + Mobile (AC-19).
  static int normalize(int? value) =>
      value != null && all.contains(value) ? value : webAndMobile;
}

/// The five per-language fields. Order is the order on screen.
enum BoutiqueField { name, icon, description, bio, banners }

/// Create and update send the per-language list under different keys. If
/// create gets `custom_data`, the backend silently drops every translation
/// (guide §8.2) — so the key is chosen from this, never written by hand.
enum BoutiqueSaveMode {
  create('boutique_custom_data'),
  update('custom_data');

  const BoutiqueSaveMode(this.translationsKey);
  final String translationsKey;
}

/// The last path segment of an image value: `…/boutiques/icon/abc.webp` →
/// `abc.webp`. The backend adds the folder itself; sending it doubles the
/// folder in the stored path (guide §7.2). Same rule as
/// `DashboardBloc._bareFileName`, copied because that one is private.
String? bareFileName(String? value) {
  if (value == null) return null;
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final String withoutQuery = trimmed.split('?').first;
  final int slash = withoutQuery.lastIndexOf('/');
  final String name = slash == -1
      ? withoutQuery
      : withoutQuery.substring(slash + 1);
  return name.isEmpty ? null : name;
}

/// One banner tile. [id] is set only for a banner loaded from `/edit`; a new
/// or copied banner has none, so the backend creates a row for it.
///
/// [fileName] is what is sent. [previewUrl] (a stored image) or [localPath]
/// (a file just picked) is only for display.
class BannerItem {
  final int? id;
  final String fileName;
  final String? previewUrl;
  final String? localPath;

  const BannerItem({
    this.id,
    required this.fileName,
    this.previewUrl,
    this.localPath,
  });

  /// A copy for another language: same image, no id (AC-22).
  BannerItem withoutId() => BannerItem(
    fileName: fileName,
    previewUrl: previewUrl,
    localPath: localPath,
  );
}

/// One language's content. [id] is the stored translation id; a language with
/// no stored translation has none and is created on save.
class TranslationForm {
  final int? id;
  final String languageCode;
  final String name;

  /// HTML from the rich-text editor; `''` when the editor is empty.
  final String description;
  final String bio;

  /// Bare file name of the icon; `''` when none.
  final String icon;
  final String? iconPreviewUrl;
  final String? iconLocalPath;
  final List<BannerItem> banners;

  const TranslationForm({
    this.id,
    required this.languageCode,
    this.name = '',
    this.description = '',
    this.bio = '',
    this.icon = '',
    this.iconPreviewUrl,
    this.iconLocalPath,
    this.banners = const <BannerItem>[],
  });

  TranslationForm copyWith({
    String? name,
    String? description,
    String? bio,
    String? icon,
    String? iconPreviewUrl,
    String? iconLocalPath,
    bool clearIconLocalPath = false,
    List<BannerItem>? banners,
  }) => TranslationForm(
    id: id,
    languageCode: languageCode,
    name: name ?? this.name,
    description: description ?? this.description,
    bio: bio ?? this.bio,
    icon: icon ?? this.icon,
    iconPreviewUrl: iconPreviewUrl ?? this.iconPreviewUrl,
    iconLocalPath: clearIconLocalPath
        ? null
        : (iconLocalPath ?? this.iconLocalPath),
    banners: banners ?? this.banners,
  );

  /// Whether [field] has a value in this language — used by validation and by
  /// the "Copy from…" menus (AC-21).
  bool has(BoutiqueField field) {
    switch (field) {
      case BoutiqueField.name:
        return name.trim().isNotEmpty;
      case BoutiqueField.icon:
        return icon.isNotEmpty;
      case BoutiqueField.description:
        return !isEmptyHtml(description);
      case BoutiqueField.bio:
        return bio.trim().isNotEmpty;
      case BoutiqueField.banners:
        return banners.isNotEmpty;
    }
  }
}

/// The whole form. [translations] keeps the language-list order.
///
/// Updates replace only the language that changed; the other
/// [TranslationForm] objects are shared with the previous form, so keeping a
/// "saved" copy costs one map, not a deep copy (review finding P-3).
class BoutiqueForm {
  final Map<String, TranslationForm> translations;
  final List<String> countriesIso;
  final List<int> relatedProductIds;
  final int status;
  final int availability;

  const BoutiqueForm({
    required this.translations,
    this.countriesIso = const <String>[],
    this.relatedProductIds = const <int>[],
    this.status = 0,
    this.availability = BoutiqueAvailability.webAndMobile,
  });

  BoutiqueForm copyWith({
    Map<String, TranslationForm>? translations,
    List<String>? countriesIso,
    int? status,
    int? availability,
  }) => BoutiqueForm(
    translations: translations ?? this.translations,
    countriesIso: countriesIso ?? this.countriesIso,
    relatedProductIds: relatedProductIds,
    status: status ?? this.status,
    availability: availability ?? this.availability,
  );

  /// Replaces one language, sharing every other entry.
  BoutiqueForm withTranslation(TranslationForm translation) {
    final Map<String, TranslationForm> next =
        Map<String, TranslationForm>.of(translations);
    next[translation.languageCode] = translation;
    return copyWith(translations: next);
  }
}

/// An empty editor gives `<p><br></p>` or similar, never a real description
/// (AC-30). Tags, `&nbsp;` and whitespace are ignored.
bool isEmptyHtml(String html) {
  final String text = html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();
  return text.isEmpty;
}

/// The New Boutique form: Web + Mobile, no country, one empty entry per
/// language (AC-14).
BoutiqueForm emptyForm(List<BoutiqueLanguage> languages) => BoutiqueForm(
  translations: <String, TranslationForm>{
    for (final BoutiqueLanguage language in languages)
      language.code: TranslationForm(languageCode: language.code),
  },
);

/// `/edit` → form (guide §8.1).
///
/// Translations are matched by lower-case `language_code`. A language with no
/// stored translation opens empty, with no id (AC-19). Banners are sorted by
/// `sequence`. Every image is reduced to its bare file name for sending, and
/// the stored value is kept only as the preview.
BoutiqueForm buildFormFromEdit(
  BoutiqueRecordModel boutique,
  List<BoutiqueLanguage> languages,
) {
  final Map<String, BoutiqueTranslationModel> stored =
      <String, BoutiqueTranslationModel>{
        for (final BoutiqueTranslationModel t in boutique.translations)
          t.languageCode: t,
      };

  final Map<String, TranslationForm> translations = <String, TranslationForm>{};
  for (final BoutiqueLanguage language in languages) {
    final BoutiqueTranslationModel? t = stored[language.code];
    if (t == null) {
      translations[language.code] = TranslationForm(
        languageCode: language.code,
      );
      continue;
    }
    final String? iconSource = t.icon ?? boutique.icon;
    final List<BoutiqueBannerModel> banners =
        List<BoutiqueBannerModel>.of(t.banners)
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
    translations[language.code] = TranslationForm(
      id: t.id,
      languageCode: language.code,
      name: t.name ?? '',
      description: t.description ?? '',
      bio: t.bio ?? '',
      icon: bareFileName(iconSource) ?? '',
      iconPreviewUrl: iconSource,
      banners: <BannerItem>[
        for (final BoutiqueBannerModel b in banners)
          if (bareFileName(b.banner) != null)
            BannerItem(
              id: b.id,
              fileName: bareFileName(b.banner)!,
              previewUrl: b.banner,
            ),
      ],
    );
  }

  return BoutiqueForm(
    translations: translations,
    countriesIso: List<String>.of(boutique.restrictedCountriesIso),
    relatedProductIds: List<int>.of(boutique.relatedProductIds),
    status: boutique.status,
    availability: BoutiqueAvailability.normalize(boutique.availability),
  );
}

/// The language whose content also fills `boutique_global_data`: English, or
/// the first language when there is no English entry (guide §6.2).
TranslationForm? globalSource(
  BoutiqueForm form,
  List<BoutiqueLanguage> languages,
) {
  final TranslationForm? english = form.translations['en'];
  if (english != null) return english;
  for (final BoutiqueLanguage language in languages) {
    final TranslationForm? t = form.translations[language.code];
    if (t != null) return t;
  }
  return form.translations.isEmpty ? null : form.translations.values.first;
}

/// Form → save body (guide §8.2, AC-32, AC-34).
///
/// - The per-language list goes under [BoutiqueSaveMode.translationsKey].
/// - `id` is sent only when it exists, on translations and on banners.
/// - Every language sends its **full** banner list; `sequence` is position + 1.
///   The backend replaces banners per language, so a banner left out is
///   deleted and a banner without id is created.
/// - `product_resources` is the loaded list, unchanged; `[]` on create.
/// - `status` is never sent — only change-status can change it.
/// - [description] HTML is sent exactly as the editor produced it; the editor
///   layer is responsible for limiting it to the four allowed styles.
Map<String, dynamic> buildPayload(
  BoutiqueForm form,
  List<BoutiqueLanguage> languages,
  BoutiqueSaveMode mode,
) {
  final TranslationForm? global = globalSource(form, languages);

  final List<Map<String, dynamic>> perLanguage = <Map<String, dynamic>>[];
  for (final BoutiqueLanguage language in languages) {
    final TranslationForm? t = form.translations[language.code];
    if (t == null) continue;
    // Validation needs a name everywhere, so this only drops a language that
    // was never filled and was never stored.
    if (t.name.trim().isEmpty && t.id == null) continue;

    final Map<String, dynamic> item = <String, dynamic>{
      if (t.id != null) 'id': t.id,
      'language_code': t.languageCode,
      'name': t.name.trim(),
      'description': isEmptyHtml(t.description) ? '' : t.description,
      'bio': t.bio.trim(),
      'icon': t.icon,
      'banners': <Map<String, dynamic>>[
        for (int i = 0; i < t.banners.length; i++)
          <String, dynamic>{
            if (t.banners[i].id != null) 'id': t.banners[i].id,
            'file_path': t.banners[i].fileName,
            'sequence': i + 1,
          },
      ],
    };
    perLanguage.add(item);
  }

  return <String, dynamic>{
    'boutique_global_data': <String, dynamic>{
      'name': global?.name.trim() ?? '',
      'availability': BoutiqueAvailability.normalize(form.availability),
      'description': global == null || isEmptyHtml(global.description)
          ? ''
          : global.description,
      'bio': global?.bio.trim() ?? '',
      'icon': global?.icon ?? '',
      'countries_iso': List<String>.of(form.countriesIso),
      'product_resources': mode == BoutiqueSaveMode.create
          ? <int>[]
          : List<int>.of(form.relatedProductIds),
    },
    mode.translationsKey: perLanguage,
  };
}

/// Every missing field of every language, in language-list order (AC-30).
/// An empty map means the form may be sent.
Map<String, Set<BoutiqueField>> validateForm(
  BoutiqueForm form,
  List<BoutiqueLanguage> languages,
) {
  final Map<String, Set<BoutiqueField>> errors =
      <String, Set<BoutiqueField>>{};
  for (final BoutiqueLanguage language in languages) {
    final TranslationForm t =
        form.translations[language.code] ??
        TranslationForm(languageCode: language.code);
    final Set<BoutiqueField> missing = <BoutiqueField>{
      for (final BoutiqueField field in BoutiqueField.values)
        if (!t.has(field)) field,
    };
    if (missing.isNotEmpty) errors[language.code] = missing;
  }
  return errors;
}

/// Copies one field from [from] into [to] (AC-21). Banners are copied without
/// their ids, so the receiving language gets new rows and the source language
/// keeps its own (AC-22). Returns [form] unchanged when either language is
/// missing.
BoutiqueForm copyField(
  BoutiqueForm form, {
  required String from,
  required String to,
  required BoutiqueField field,
}) {
  final TranslationForm? source = form.translations[from];
  final TranslationForm? target = form.translations[to];
  if (source == null || target == null || from == to) return form;

  switch (field) {
    case BoutiqueField.name:
      return form.withTranslation(target.copyWith(name: source.name));
    case BoutiqueField.description:
      return form.withTranslation(
        target.copyWith(description: source.description),
      );
    case BoutiqueField.bio:
      return form.withTranslation(target.copyWith(bio: source.bio));
    case BoutiqueField.icon:
      return form.withTranslation(
        TranslationForm(
          id: target.id,
          languageCode: target.languageCode,
          name: target.name,
          description: target.description,
          bio: target.bio,
          icon: source.icon,
          iconPreviewUrl: source.iconPreviewUrl,
          iconLocalPath: source.iconLocalPath,
          banners: target.banners,
        ),
      );
    case BoutiqueField.banners:
      return form.withTranslation(
        target.copyWith(
          banners: <BannerItem>[
            for (final BannerItem banner in source.banners) banner.withoutId(),
          ],
        ),
      );
  }
}

/// Languages other than [active] where [field] is filled — the entries of the
/// "Copy from…" menu (AC-21).
List<String> copySources(
  BoutiqueForm form,
  String active,
  BoutiqueField field,
) => <String>[
  for (final TranslationForm t in form.translations.values)
    if (t.languageCode != active && t.has(field)) t.languageCode,
];

/// Moves a banner one place left (`-1`) or right (`+1`) (AC-28).
List<BannerItem> moveBanner(List<BannerItem> banners, int index, int delta) {
  final int target = index + delta;
  if (index < 0 ||
      index >= banners.length ||
      target < 0 ||
      target >= banners.length) {
    return banners;
  }
  final List<BannerItem> next = List<BannerItem>.of(banners);
  final BannerItem item = next.removeAt(index);
  next.insert(target, item);
  return next;
}

// --- Image file checks (AC-24) ---------------------------------------------

/// Limits from guide §6.4.
const int kBoutiqueImageMaxBytes = 10 * 1024 * 1024;
const int kBannerMinWidth = 600;
const double kBannerMinRatio = 1.5;
const double kBannerMaxRatio = 1.8;
const int kBannerRecommendedWidth = 1280;
const int kBannerRecommendedHeight = 750;

enum ImageCheckResult { ok, notImage, tooLarge, warnSize }

/// Image type from the file's first bytes, not its name or reported type
/// (review finding S-6): JPEG, PNG, GIF, WebP, HEIC / HEIF.
bool looksLikeImage(List<int> head) {
  bool startsWith(List<int> sig, [int offset = 0]) {
    if (head.length < offset + sig.length) return false;
    for (int i = 0; i < sig.length; i++) {
      if (head[offset + i] != sig[i]) return false;
    }
    return true;
  }

  if (startsWith(const <int>[0xFF, 0xD8, 0xFF])) return true; // JPEG
  if (startsWith(const <int>[0x89, 0x50, 0x4E, 0x47])) return true; // PNG
  if (startsWith(const <int>[0x47, 0x49, 0x46, 0x38])) return true; // GIF8
  if (startsWith(const <int>[0x52, 0x49, 0x46, 0x46]) && // RIFF....WEBP
      startsWith(const <int>[0x57, 0x45, 0x42, 0x50], 8)) {
    return true;
  }
  if (startsWith(const <int>[0x66, 0x74, 0x79, 0x70], 4) && head.length >= 12) {
    final String brand = String.fromCharCodes(head.sublist(8, 12));
    return const <String>{
      'heic',
      'heix',
      'hevc',
      'hevx',
      'mif1',
      'msf1',
      'avif',
    }.contains(brand);
  }
  return false;
}

/// One picked file against the rules. [sizeBytes] is checked before anything
/// is read (review finding P-1). [width] / [height] are `null` when the size
/// could not be read; such a file is accepted (AC-24). Icons skip the
/// width / ratio warning.
ImageCheckResult checkImageFile({
  required int sizeBytes,
  required List<int> head,
  int? width,
  int? height,
  bool isBanner = true,
}) {
  if (sizeBytes > kBoutiqueImageMaxBytes) return ImageCheckResult.tooLarge;
  if (!looksLikeImage(head)) return ImageCheckResult.notImage;
  if (!isBanner || width == null || height == null || height == 0) {
    return ImageCheckResult.ok;
  }
  final double ratio = width / height;
  if (width < kBannerMinWidth ||
      ratio < kBannerMinRatio ||
      ratio > kBannerMaxRatio) {
    return ImageCheckResult.warnSize;
  }
  return ImageCheckResult.ok;
}
