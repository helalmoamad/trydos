import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/domin/usecases/upload_file_media_server_usecase.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/change_boutique_status_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/create_boutique_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_boutique_for_edit_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_boutique_lookups_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_languages_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/update_boutique_usecase.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'boutique_form.dart';

part 'boutique_editor_event.dart';
part 'boutique_editor_state.dart';

/// Media-server folders (guide §7.1). The backend adds the folder to the
/// stored value itself, so only the bare file name is ever sent back.
const String _kIconFolder = 'boutiques/boutiques/icon';
const String _kBannerFolder = 'boutiques/boutiques';

/// The state of one boutique page — New Boutique or an existing boutique.
///
/// Feature-local on purpose (plan OQ-9): registered as a DI **factory**,
/// created by the page and closed with it, so the large form never sits on the
/// app-wide `DashboardBloc` and a shop switch cannot leave it behind.
///
/// The shop id is captured once, when the page opens. Every write carries that
/// id; every read answer and every save or upload first checks that the
/// dashboard is still on that shop (AC-3, review finding S-4).
///
/// | event         | transformer   | why                                    |
/// |---------------|---------------|----------------------------------------|
/// | load / retry  | restartable() | only the newest load matters           |
/// | save          | droppable()   | a second tap sends nothing (AC-38)     |
/// | banner queue  | sequential()  | one banner file at a time (AC-23)      |
/// | everything else | default     | in-memory form edits                   |
@injectable
class BoutiqueEditorBloc
    extends Bloc<BoutiqueEditorEvent, BoutiqueEditorState> {
  BoutiqueEditorBloc(
    this._getLanguages,
    this._getLookups,
    this._getForEdit,
    this._create,
    this._update,
    this._changeStatus,
    this._upload,
  ) : super(const BoutiqueEditorState()) {
    on<BoutiqueEditorStarted>(_onStarted, transformer: restartable());
    on<BoutiqueEditorRetried>(_onRetried, transformer: restartable());
    on<BoutiqueEditorEditEntered>(_onEditEntered);
    on<BoutiqueEditorCancelled>(_onCancelled);
    on<BoutiqueEditorTabChanged>(_onTabChanged);
    on<BoutiqueEditorTextSynced>(_onTextSynced);
    on<BoutiqueEditorAvailabilityChanged>(_onAvailabilityChanged);
    on<BoutiqueEditorCountryToggled>(_onCountryToggled);
    on<BoutiqueEditorStatusToggled>(_onStatusToggled);
    on<BoutiqueEditorFieldCopied>(_onFieldCopied);
    on<BoutiqueEditorIconPicked>(_onIconPicked);
    on<BoutiqueEditorBannersPicked>(_onBannersPicked);
    on<BoutiqueEditorBannerWarningAnswered>(_onBannerWarningAnswered);
    on<_BoutiqueBannerQueueAdvanced>(
      _onBannerQueueAdvanced,
      transformer: sequential(),
    );
    on<BoutiqueEditorBannerMoved>(_onBannerMoved);
    on<BoutiqueEditorBannerRemoved>(_onBannerRemoved);
    on<BoutiqueEditorSaved>(_onSaved, transformer: droppable());
    on<BoutiqueEditorNavigationHandled>(
      (event, emit) =>
          emit(state.copyWith(navigation: BoutiqueEditorNavigation.none)),
    );
  }

  final GetLanguagesUseCase _getLanguages;
  final GetBoutiqueLookupsUseCase _getLookups;
  final GetBoutiqueForEditUseCase _getForEdit;
  final CreateBoutiqueUseCase _create;
  final UpdateBoutiqueUseCase _update;
  final ChangeBoutiqueStatusUseCase _changeStatus;
  final UploadFileMediaServerUseCase _upload;

  /// The language list rarely changes, so one good answer serves the whole app
  /// session (review finding P-7). The fallback is never cached.
  static List<BoutiqueLanguage>? _languagesCache;

  /// The shop this page was opened for.
  String? _sellerId;

  final List<_QueuedBanner> _bannerQueue = <_QueuedBanner>[];

  String? get _prefsSellerId => GetIt.I<PrefsRepository>().getXSellerId;

  bool get _shopUnchanged => _prefsSellerId == _sellerId;

  @override
  Future<void> close() {
    // Uploads already sent finish on their own; nothing queued is started
    // after the page closes (review finding P-6).
    _bannerQueue.clear();
    return super.close();
  }

  // --- Load ----------------------------------------------------------------

  Future<void> _onStarted(
    BoutiqueEditorStarted event,
    Emitter<BoutiqueEditorState> emit,
  ) async {
    _sellerId = _prefsSellerId;
    emit(
      BoutiqueEditorState(
        isCreate: event.boutiqueId == null,
        boutiqueId: event.boutiqueId,
        editing: event.boutiqueId == null,
      ),
    );
    await _load(emit);
  }

  Future<void> _onRetried(
    BoutiqueEditorRetried event,
    Emitter<BoutiqueEditorState> emit,
  ) async {
    emit(state.copyWith(loadStatus: BoutiqueEditorLoadStatus.loading));
    await _load(emit);
  }

  /// Languages and the record are fetched in parallel (P-7).
  Future<void> _load(Emitter<BoutiqueEditorState> emit) async {
    final int? id = state.boutiqueId;
    final Future<List<BoutiqueLanguage>> languagesFuture = _loadLanguages();

    if (id == null) {
      final lookupsFuture = _getLookups(NoParams());
      final List<BoutiqueLanguage> languages = await languagesFuture;
      final result = await lookupsFuture;
      if (isClosed) return;
      if (!_shopUnchanged) return _closeForShopChange(emit);

      result.fold(
        (failure) => _emitLoadFailure(emit, failure),
        (response) {
          _log('load-create', 'success');
          final BoutiqueForm form = emptyForm(languages);
          emit(
            state.copyWith(
              loadStatus: BoutiqueEditorLoadStatus.ready,
              languages: languages,
              countries: response.lookups.countries,
              availabilities: response.lookups.availabilities.isEmpty
                  ? BoutiqueAvailability.all
                  : response.lookups.availabilities,
              form: form,
              saved: form,
              editing: true,
              activeLanguage: languages.first.code,
              formRevision: state.formRevision + 1,
            ),
          );
        },
      );
      return;
    }

    final editFuture = _getForEdit(id);
    final List<BoutiqueLanguage> languages = await languagesFuture;
    final result = await editFuture;
    if (isClosed) return;
    if (!_shopUnchanged) return _closeForShopChange(emit);

    result.fold((failure) => _emitLoadFailure(emit, failure), (response) {
      _log('load-edit', 'success');
      final BoutiqueForm form = buildFormFromEdit(response.boutique, languages);
      emit(
        state.copyWith(
          loadStatus: BoutiqueEditorLoadStatus.ready,
          languages: languages,
          countries: response.lookups.countries,
          availabilities: response.lookups.availabilities.isEmpty
              ? BoutiqueAvailability.all
              : response.lookups.availabilities,
          form: form,
          saved: form,
          editing: false,
          activeLanguage: languages.first.code,
          formRevision: state.formRevision + 1,
        ),
      );
    });
  }

  Future<List<BoutiqueLanguage>> _loadLanguages() async {
    final List<BoutiqueLanguage>? cached = _languagesCache;
    if (cached != null && cached.isNotEmpty) return cached;
    final result = await _getLanguages(NoParams());
    return result.fold(
      (failure) {
        _log('languages', 'fallback', code: failure.statusCode);
        return BoutiqueLanguage.fallback;
      },
      (response) {
        if (response.languages.isEmpty) {
          _log('languages', 'fallback-empty');
          return BoutiqueLanguage.fallback;
        }
        _languagesCache = response.languages;
        return response.languages;
      },
    );
  }

  void _emitLoadFailure(Emitter<BoutiqueEditorState> emit, Failure failure) {
    _log('load', 'failure', code: failure.statusCode);
    final BoutiqueEditorLoadStatus status = failure.statusCode == 403
        ? BoutiqueEditorLoadStatus.accessDenied
        : failure.statusCode == 404
        ? BoutiqueEditorLoadStatus.notFound
        : BoutiqueEditorLoadStatus.failure;
    emit(state.copyWith(loadStatus: status));
  }

  void _closeForShopChange(Emitter<BoutiqueEditorState> emit) {
    _log('shop-changed', 'closed');
    _bannerQueue.clear();
    emit(state.copyWith(navigation: BoutiqueEditorNavigation.shopChanged));
  }

  // --- View / edit ---------------------------------------------------------

  void _onEditEntered(
    BoutiqueEditorEditEntered event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    if (state.form == null) return;
    emit(state.copyWith(editing: true, clearSaveError: true));
  }

  void _onCancelled(
    BoutiqueEditorCancelled event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? saved = state.saved;
    if (saved == null || state.isCreate) return;
    _bannerQueue.clear();
    emit(
      state.copyWith(
        form: saved,
        editing: false,
        errors: const <String, Set<BoutiqueField>>{},
        formRevision: state.formRevision + 1,
        bannersPending: 0,
        clearBannerWarning: true,
        clearSaveError: true,
      ),
    );
  }

  void _onTabChanged(
    BoutiqueEditorTabChanged event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    if (state.form?.translations.containsKey(event.languageCode) != true) {
      return;
    }
    emit(state.copyWith(activeLanguage: event.languageCode));
  }

  /// Replaces only the languages whose text changed, so every other
  /// translation object stays shared with [BoutiqueEditorState.saved].
  void _onTextSynced(
    BoutiqueEditorTextSynced event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    BoutiqueForm? form = state.form;
    if (form == null || !state.editing) return;
    bool changed = false;
    event.values.forEach((code, values) {
      final TranslationForm? t = form!.translations[code];
      if (t == null) return;
      if (t.name == values.name &&
          t.description == values.description &&
          t.bio == values.bio) {
        return;
      }
      form = form!.withTranslation(
        t.copyWith(
          name: values.name,
          description: values.description,
          bio: values.bio,
        ),
      );
      changed = true;
    });
    if (changed) emit(state.copyWith(form: form));
  }

  void _onAvailabilityChanged(
    BoutiqueEditorAvailabilityChanged event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    if (form == null || !state.editing) return;
    emit(
      state.copyWith(
        form: form.copyWith(
          availability: BoutiqueAvailability.normalize(event.availability),
        ),
      ),
    );
  }

  void _onCountryToggled(
    BoutiqueEditorCountryToggled event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    if (form == null || !state.editing) return;
    final List<String> next = List<String>.of(form.countriesIso);
    if (!next.remove(event.iso)) next.add(event.iso);
    emit(state.copyWith(form: form.copyWith(countriesIso: next)));
  }

  void _onStatusToggled(
    BoutiqueEditorStatusToggled event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    if (form == null || !state.editing || state.isCreate) return;
    emit(
      state.copyWith(
        form: form.copyWith(status: form.status == 1 ? 0 : 1),
        clearStatusError: true,
      ),
    );
  }

  void _onFieldCopied(
    BoutiqueEditorFieldCopied event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    if (form == null || !state.editing) return;
    emit(
      state.copyWith(
        form: copyField(
          form,
          from: event.fromLanguage,
          to: state.activeLanguage,
          field: event.field,
        ),
        formRevision: state.formRevision + 1,
      ),
    );
  }

  // --- Images --------------------------------------------------------------

  Future<void> _onIconPicked(
    BoutiqueEditorIconPicked event,
    Emitter<BoutiqueEditorState> emit,
  ) async {
    if (!state.editing) return;
    if (!_shopUnchanged) return _closeForShopChange(emit);
    final String language = state.activeLanguage;

    final _InspectedImage image = await _inspect(event.file, isBanner: false);
    switch (image.result) {
      case ImageCheckResult.tooLarge:
        showMessage(LocaleKeys.boutique_icon_too_large.tr(), hasError: true);
        return;
      case ImageCheckResult.notImage:
        showMessage(LocaleKeys.boutique_choose_image.tr(), hasError: true);
        return;
      case ImageCheckResult.ok:
      case ImageCheckResult.warnSize:
        break;
    }

    emit(state.copyWith(iconUploading: {...state.iconUploading, language}));
    final String? fileName = await _uploadFile(event.file.path, _kIconFolder);
    if (isClosed) return;
    final Set<String> uploading = {...state.iconUploading}..remove(language);
    final BoutiqueForm? form = state.form;
    final TranslationForm? t = form?.translations[language];
    if (fileName == null || form == null || t == null || !state.editing) {
      emit(state.copyWith(iconUploading: uploading));
      return;
    }
    emit(
      state.copyWith(
        iconUploading: uploading,
        form: form.withTranslation(
          t.copyWith(icon: fileName, iconLocalPath: event.file.path),
        ),
      ),
    );
  }

  void _onBannersPicked(
    BoutiqueEditorBannersPicked event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    if (!state.editing || event.files.isEmpty) return;
    final bool idle = _bannerQueue.isEmpty;
    for (final PickedImageFile file in event.files) {
      _bannerQueue.add(_QueuedBanner(file, state.activeLanguage));
    }
    emit(state.copyWith(bannersPending: _bannerQueue.length));
    if (idle) add(const _BoutiqueBannerQueueAdvanced());
  }

  void _onBannerWarningAnswered(
    BoutiqueEditorBannerWarningAnswered event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    if (state.bannerWarning == null || _bannerQueue.isEmpty) {
      emit(state.copyWith(clearBannerWarning: true));
      return;
    }
    if (event.upload) {
      _bannerQueue.first.approved = true;
    } else {
      _bannerQueue.removeAt(0);
    }
    emit(
      state.copyWith(
        clearBannerWarning: true,
        bannersPending: _bannerQueue.length,
      ),
    );
    add(const _BoutiqueBannerQueueAdvanced());
  }

  /// One file per call. A file that needs a warning stops the queue until the
  /// user answers (AC-23, AC-24).
  Future<void> _onBannerQueueAdvanced(
    _BoutiqueBannerQueueAdvanced event,
    Emitter<BoutiqueEditorState> emit,
  ) async {
    if (isClosed || state.bannerWarning != null) return;
    if (_bannerQueue.isEmpty) {
      emit(state.copyWith(bannersPending: 0));
      return;
    }
    if (!_shopUnchanged) return _closeForShopChange(emit);

    final _QueuedBanner item = _bannerQueue.first;
    if (!item.approved) {
      final _InspectedImage image = await _inspect(item.file, isBanner: true);
      if (isClosed || _bannerQueue.isEmpty || _bannerQueue.first != item) {
        return;
      }
      switch (image.result) {
        case ImageCheckResult.tooLarge:
          _bannerQueue.removeAt(0);
          showMessage(
            LocaleKeys.boutique_banner_too_large.tr(),
            hasError: true,
          );
          return _continueQueue(emit);
        case ImageCheckResult.notImage:
          _bannerQueue.removeAt(0);
          showMessage(LocaleKeys.boutique_choose_image.tr(), hasError: true);
          return _continueQueue(emit);
        case ImageCheckResult.warnSize:
          emit(
            state.copyWith(
              bannerWarning: PendingBannerWarning(
                path: item.file.path,
                width: image.width ?? 0,
                height: image.height ?? 0,
              ),
            ),
          );
          return;
        case ImageCheckResult.ok:
          break;
      }
    }

    final String? fileName = await _uploadFile(item.file.path, _kBannerFolder);
    if (isClosed) return;
    _bannerQueue.remove(item);

    final BoutiqueForm? form = state.form;
    final TranslationForm? t = form?.translations[item.language];
    if (fileName != null && form != null && t != null && state.editing) {
      emit(
        state.copyWith(
          form: form.withTranslation(
            t.copyWith(
              banners: <BannerItem>[
                ...t.banners,
                BannerItem(fileName: fileName, localPath: item.file.path),
              ],
            ),
          ),
        ),
      );
    }
    _continueQueue(emit);
  }

  void _continueQueue(Emitter<BoutiqueEditorState> emit) {
    emit(state.copyWith(bannersPending: _bannerQueue.length));
    if (_bannerQueue.isNotEmpty) add(const _BoutiqueBannerQueueAdvanced());
  }

  void _onBannerMoved(
    BoutiqueEditorBannerMoved event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    final TranslationForm? t = state.activeTranslation;
    if (form == null || t == null || !state.editing) return;
    emit(
      state.copyWith(
        form: form.withTranslation(
          t.copyWith(banners: moveBanner(t.banners, event.index, event.delta)),
        ),
      ),
    );
  }

  /// Removes the tile only; the backend deletes the banner on save, because
  /// the banner list is replaced per language.
  void _onBannerRemoved(
    BoutiqueEditorBannerRemoved event,
    Emitter<BoutiqueEditorState> emit,
  ) {
    final BoutiqueForm? form = state.form;
    final TranslationForm? t = state.activeTranslation;
    if (form == null ||
        t == null ||
        !state.editing ||
        event.index < 0 ||
        event.index >= t.banners.length) {
      return;
    }
    emit(
      state.copyWith(
        form: form.withTranslation(
          t.copyWith(banners: List<BannerItem>.of(t.banners)..removeAt(event.index)),
        ),
      ),
    );
  }

  /// Size first — nothing is read for a file over the limit. Then the first
  /// bytes for the type, and the image header for width and height, without
  /// decoding a single pixel (review findings P-1, S-5, S-6).
  Future<_InspectedImage> _inspect(
    PickedImageFile file, {
    required bool isBanner,
  }) async {
    if (file.size > kBoutiqueImageMaxBytes) {
      return const _InspectedImage(ImageCheckResult.tooLarge);
    }
    List<int> head = const <int>[];
    RandomAccessFile? handle;
    try {
      handle = await File(file.path).open();
      head = await handle.read(16);
    } catch (_) {
      head = const <int>[];
    } finally {
      await handle?.close();
    }

    int? width;
    int? height;
    if (isBanner && looksLikeImage(head)) {
      ui.ImmutableBuffer? buffer;
      ui.ImageDescriptor? descriptor;
      try {
        buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        width = descriptor.width;
        height = descriptor.height;
      } catch (_) {
        // The size could not be read: the file is accepted (AC-24).
      } finally {
        descriptor?.dispose();
        buffer?.dispose();
      }
    }

    return _InspectedImage(
      checkImageFile(
        sizeBytes: file.size,
        head: head,
        width: width,
        height: height,
        isBanner: isBanner,
      ),
      width: width,
      height: height,
    );
  }

  /// Uploads one file and returns the bare file name to send, or `null`.
  Future<String?> _uploadFile(String path, String folder) async {
    final result = await _upload(
      UploadFileMediaServerParams(
        file: File(path),
        folder: folder,
        usingOnUploadingFinishedFunction: false,
        usingSendProgressFunction: false,
      ),
    );
    return result.fold(
      (failure) {
        _log('upload', 'failure', code: failure.statusCode);
        showMessage(LocaleKeys.boutique_upload_failed.tr(), hasError: true);
        return null;
      },
      (response) {
        final String? name = bareFileName(response.subPath ?? response.url);
        if (name == null) {
          _log('upload', 'failure-empty-path');
          showMessage(LocaleKeys.boutique_upload_failed.tr(), hasError: true);
        }
        return name;
      },
    );
  }

  // --- Save ----------------------------------------------------------------

  Future<void> _onSaved(
    BoutiqueEditorSaved event,
    Emitter<BoutiqueEditorState> emit,
  ) async {
    final BoutiqueForm? form = state.form;
    if (form == null || !state.editing || state.saving || state.isUploading) {
      return;
    }
    final String? sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      _log('save', 'blocked-no-shop');
      emit(state.copyWith(saveError: LocaleKeys.boutique_missing_shop.tr()));
      return;
    }
    if (!_shopUnchanged) return _closeForShopChange(emit);

    final Map<String, Set<BoutiqueField>> errors = validateForm(
      form,
      state.languages,
    );
    if (errors.isNotEmpty) {
      showMessage(LocaleKeys.boutique_fix_fields.tr(), hasError: true);
      emit(
        state.copyWith(
          errors: errors,
          errorRevision: state.errorRevision + 1,
          activeLanguage: errors.keys.first,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        saving: true,
        errors: const <String, Set<BoutiqueField>>{},
        clearSaveError: true,
        clearStatusError: true,
      ),
    );

    if (state.isCreate) {
      await _saveCreate(emit, form, sellerId);
    } else {
      await _saveUpdate(emit, form, sellerId);
    }
  }

  Future<void> _saveCreate(
    Emitter<BoutiqueEditorState> emit,
    BoutiqueForm form,
    String sellerId,
  ) async {
    final result = await _create(
      CreateBoutiqueParams(
        body: buildPayload(form, state.languages, BoutiqueSaveMode.create),
        sellerId: sellerId,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        _log('create', 'failure', code: failure.statusCode);
        emit(
          state.copyWith(
            saving: false,
            saveError: _messageOf(
              failure,
              LocaleKeys.boutique_create_failed.tr(),
            ),
          ),
        );
      },
      (response) {
        _log('create', 'success', boutiqueId: response.boutiqueId);
      },
    );
    final int? id = result.fold((_) => null, (r) => r.boutiqueId);
    if (result.isLeft()) return;
    if (id == null) {
      emit(
        state.copyWith(
          saving: false,
          didChange: true,
          navigation: BoutiqueEditorNavigation.backToList,
        ),
      );
      return;
    }
    // The New Boutique page becomes the new boutique's page, in view mode
    // (AC-32). A new boutique starts inactive; the load shows what was stored.
    emit(
      state.copyWith(
        saving: false,
        didChange: true,
        isCreate: false,
        boutiqueId: id,
        editing: false,
        loadStatus: BoutiqueEditorLoadStatus.loading,
      ),
    );
    await _load(emit);
  }

  /// Update first; change-status only after it succeeded, and only when the
  /// status moved. A refused status keeps the saved edits and puts the old
  /// status back (AC-34, AC-35).
  Future<void> _saveUpdate(
    Emitter<BoutiqueEditorState> emit,
    BoutiqueForm form,
    String sellerId,
  ) async {
    final int id = state.boutiqueId!;
    final result = await _update(
      UpdateBoutiqueParams(
        boutiqueId: id,
        body: buildPayload(form, state.languages, BoutiqueSaveMode.update),
        sellerId: sellerId,
      ),
    );
    if (isClosed) return;

    final Failure? updateFailure = result.fold((l) => l, (_) => null);
    if (updateFailure != null) {
      _log('update', 'failure', boutiqueId: id, code: updateFailure.statusCode);
      emit(
        state.copyWith(
          saving: false,
          saveError: _messageOf(
            updateFailure,
            LocaleKeys.boutique_update_failed.tr(),
          ),
        ),
      );
      return;
    }
    _log('update', 'success', boutiqueId: id);

    BoutiqueForm savedForm = form;
    String? statusError;
    final int savedStatus = state.saved?.status ?? form.status;
    if (form.status != savedStatus) {
      final statusResult = await _changeStatus(
        ChangeBoutiqueStatusParams(
          boutiqueId: id,
          status: form.status,
          sellerId: sellerId,
        ),
      );
      if (isClosed) return;
      statusResult.fold(
        (failure) {
          // AC-35 is partly met: only the top-level `message` reaches here
          // (plan > Recorded deviation).
          _log(
            'change-status',
            'refused',
            boutiqueId: id,
            code: failure.statusCode,
            message: failure.message,
          );
          statusError = _messageOf(
            failure,
            LocaleKeys.boutique_update_failed.tr(),
          );
          savedForm = form.copyWith(status: savedStatus);
        },
        (response) {
          _log('change-status', 'success', boutiqueId: id);
          savedForm = form.copyWith(status: response.status ?? form.status);
        },
      );
    }

    emit(
      state.copyWith(
        saving: false,
        form: savedForm,
        saved: savedForm,
        editing: false,
        didChange: true,
        statusError: statusError,
        formRevision: state.formRevision + 1,
      ),
    );
    if (statusError != null) {
      showMessage(LocaleKeys.boutique_status_failed_toast.tr(), hasError: true);
    } else {
      showMessage(
        LocaleKeys.boutique_updated_success.tr(),
        showInRelease: true,
      );
    }
  }

  /// The backend `message`, or [fallback] when the failure carries only the
  /// failure class's default text. A missing shop id has its own text.
  String _messageOf(Failure failure, String fallback) {
    if (identical(failure, missingBoutiqueShopFailure)) {
      return LocaleKeys.boutique_missing_shop.tr();
    }
    const Set<String> defaults = <String>{
      '',
      'ServerFailure',
      'DioFailure',
      'OperationFailedFailure',
      'Validation error',
    };
    final String message = failure.message.trim();
    return defaults.contains(message) ? fallback : message;
  }

  /// One diagnostic line: action, outcome, shop, boutique, HTTP code. The
  /// backend message is added only for a refused status change. No form
  /// content, file names, tokens or upload tickets (AC-40).
  void _log(
    String action,
    String outcome, {
    int? boutiqueId,
    int? code,
    String? message,
  }) {
    devLog(
      'boutique-editor | $action | $outcome | seller=$_sellerId'
      ' | boutique=${boutiqueId ?? state.boutiqueId ?? '-'}'
      '${code == null ? '' : ' | code=$code'}'
      '${message == null ? '' : ' | message=$message'}',
    );
  }
}

class _QueuedBanner {
  final PickedImageFile file;
  final String language;
  bool approved = false;
  _QueuedBanner(this.file, this.language);
}

class _InspectedImage {
  final ImageCheckResult result;
  final int? width;
  final int? height;
  const _InspectedImage(this.result, {this.width, this.height});
}
