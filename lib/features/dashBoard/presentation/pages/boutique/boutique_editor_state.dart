part of 'boutique_editor_bloc.dart';

/// A plain `Bloc` state — not hydrated. Nothing here is stored on the device,
/// and the bloc lives only as long as its page.

enum BoutiqueEditorLoadStatus { loading, ready, accessDenied, notFound, failure }

/// What the page must do next. The page acts, then sends
/// [BoutiqueEditorNavigationHandled].
enum BoutiqueEditorNavigation {
  none,

  /// Create succeeded without an id: go back to the list (AC-33). With an id
  /// the same page reloads as that boutique instead (AC-32), so the list still
  /// learns about later saves when the page closes.
  backToList,

  /// The dashboard shop changed under this page: close it (AC-3).
  shopChanged,
}

/// A banner that needs the user's answer before it is uploaded.
class PendingBannerWarning {
  final String path;
  final int width;
  final int height;
  const PendingBannerWarning({
    required this.path,
    required this.width,
    required this.height,
  });
}

class BoutiqueEditorState {
  final bool isCreate;
  final int? boutiqueId;
  final BoutiqueEditorLoadStatus loadStatus;
  final List<BoutiqueLanguage> languages;
  final List<BoutiqueCountryModel> countries;
  final List<int> availabilities;

  /// What the user edits, and what was last saved. Cancel copies [saved] back
  /// into [form]; the two share every unchanged translation (P-3).
  final BoutiqueForm? form;
  final BoutiqueForm? saved;

  /// Always `true` on the New Boutique page.
  final bool editing;
  final String activeLanguage;

  /// Bumped every time [form] is replaced from outside the text fields (load,
  /// cancel, copy, save). The page then refills its text controllers.
  final int formRevision;

  final Map<String, Set<BoutiqueField>> errors;

  /// Bumped on every failed validation, so the page can shake the fields again
  /// even when the same fields are wrong (AC-31).
  final int errorRevision;

  final bool saving;

  /// Language codes whose icon is uploading, and how many banner files are
  /// still queued or uploading.
  final Set<String> iconUploading;
  final int bannersPending;
  final PendingBannerWarning? bannerWarning;

  /// The backend message of a failed save (AC-36), shown inline.
  final String? saveError;

  /// The backend message of a refused status change (AC-35), shown in the red
  /// box.
  final String? statusError;

  /// `true` once anything was created or saved, so the list reloads when the
  /// page closes (AC-37).
  final bool didChange;

  final BoutiqueEditorNavigation navigation;

  const BoutiqueEditorState({
    this.isCreate = true,
    this.boutiqueId,
    this.loadStatus = BoutiqueEditorLoadStatus.loading,
    this.languages = const <BoutiqueLanguage>[],
    this.countries = const <BoutiqueCountryModel>[],
    this.availabilities = BoutiqueAvailability.all,
    this.form,
    this.saved,
    this.editing = false,
    this.activeLanguage = 'en',
    this.formRevision = 0,
    this.errors = const <String, Set<BoutiqueField>>{},
    this.errorRevision = 0,
    this.saving = false,
    this.iconUploading = const <String>{},
    this.bannersPending = 0,
    this.bannerWarning,
    this.saveError,
    this.statusError,
    this.didChange = false,
    this.navigation = BoutiqueEditorNavigation.none,
  });

  bool get isUploading => iconUploading.isNotEmpty || bannersPending > 0;

  /// The form shown in the header: in view mode the saved values.
  TranslationForm? get activeTranslation => form?.translations[activeLanguage];

  BoutiqueEditorState copyWith({
    bool? isCreate,
    int? boutiqueId,
    BoutiqueEditorLoadStatus? loadStatus,
    List<BoutiqueLanguage>? languages,
    List<BoutiqueCountryModel>? countries,
    List<int>? availabilities,
    BoutiqueForm? form,
    BoutiqueForm? saved,
    bool? editing,
    String? activeLanguage,
    int? formRevision,
    Map<String, Set<BoutiqueField>>? errors,
    int? errorRevision,
    bool? saving,
    Set<String>? iconUploading,
    int? bannersPending,
    PendingBannerWarning? bannerWarning,
    bool clearBannerWarning = false,
    String? saveError,
    bool clearSaveError = false,
    String? statusError,
    bool clearStatusError = false,
    bool? didChange,
    BoutiqueEditorNavigation? navigation,
  }) => BoutiqueEditorState(
    isCreate: isCreate ?? this.isCreate,
    boutiqueId: boutiqueId ?? this.boutiqueId,
    loadStatus: loadStatus ?? this.loadStatus,
    languages: languages ?? this.languages,
    countries: countries ?? this.countries,
    availabilities: availabilities ?? this.availabilities,
    form: form ?? this.form,
    saved: saved ?? this.saved,
    editing: editing ?? this.editing,
    activeLanguage: activeLanguage ?? this.activeLanguage,
    formRevision: formRevision ?? this.formRevision,
    errors: errors ?? this.errors,
    errorRevision: errorRevision ?? this.errorRevision,
    saving: saving ?? this.saving,
    iconUploading: iconUploading ?? this.iconUploading,
    bannersPending: bannersPending ?? this.bannersPending,
    bannerWarning: clearBannerWarning
        ? null
        : (bannerWarning ?? this.bannerWarning),
    saveError: clearSaveError ? null : (saveError ?? this.saveError),
    statusError: clearStatusError ? null : (statusError ?? this.statusError),
    didChange: didChange ?? this.didChange,
    navigation: navigation ?? this.navigation,
  );
}
