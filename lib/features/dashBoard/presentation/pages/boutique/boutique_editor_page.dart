import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/presentation/widgets/dashboard_permission_checker.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'boutique_editor_bloc.dart';
import 'boutique_form.dart';
import 'widgets/boutique_availability_section.dart';
import 'widgets/boutique_countries_section.dart';
import 'widgets/boutique_rich_text_field.dart';
import 'widgets/boutique_translations_section.dart';

/// The New Boutique page ([boutiqueId] `null`) or an existing boutique's page.
///
/// Pops with `true` when anything was created or saved, so the list reloads
/// (AC-37).
class BoutiqueEditorPage extends StatelessWidget {
  final int? boutiqueId;
  final List<String> permissions;

  const BoutiqueEditorPage({
    super.key,
    required this.boutiqueId,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BoutiqueEditorBloc>(
      create: (_) =>
          GetIt.I<BoutiqueEditorBloc>()
            ..add(BoutiqueEditorStarted(boutiqueId: boutiqueId)),
      child: _BoutiqueEditorView(
        permissions: DashboardPermissionChecker(permissions),
      ),
    );
  }
}

class _BoutiqueEditorView extends StatefulWidget {
  final DashboardPermissionChecker permissions;

  const _BoutiqueEditorView({required this.permissions});

  @override
  State<_BoutiqueEditorView> createState() => _BoutiqueEditorViewState();
}

class _BoutiqueEditorViewState extends State<_BoutiqueEditorView> {
  /// Text controllers per language. The text stays here while the user types
  /// and reaches the bloc only through [_syncText] (review finding P-3).
  final Map<String, TextEditingController> _names =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _bios =
      <String, TextEditingController>{};
  final Map<String, QuillController> _descriptions =
      <String, QuillController>{};
  int _appliedRevision = -1;

  BoutiqueEditorBloc get _bloc => context.read<BoutiqueEditorBloc>();

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _names.values) {
      c.dispose();
    }
    for (final c in _bios.values) {
      c.dispose();
    }
    for (final c in _descriptions.values) {
      c.dispose();
    }
    _names.clear();
    _bios.clear();
    _descriptions.clear();
  }

  /// Refills every controller from the form when the bloc replaced it (load,
  /// Cancel, copy, save). HTML becomes an editor document here, once per
  /// language — not on every rebuild (review finding P-4).
  void _applyForm(BoutiqueEditorState state) {
    final BoutiqueForm? form = state.form;
    if (form == null || state.formRevision == _appliedRevision) return;
    _appliedRevision = state.formRevision;
    _disposeControllers();
    for (final TranslationForm t in form.translations.values) {
      _names[t.languageCode] = TextEditingController(text: t.name);
      _bios[t.languageCode] = TextEditingController(text: t.bio);
      _descriptions[t.languageCode] = boutiqueQuillFromHtml(
        t.description,
        readOnly: !state.editing,
      );
    }
  }

  /// Sends the controllers' text to the bloc. Called before a tab change, a
  /// copy and a save, so the bloc always sees what is on screen.
  void _syncText() {
    final Map<String, BoutiqueTextValues> values =
        <String, BoutiqueTextValues>{};
    for (final String code in _names.keys) {
      final QuillController? description = _descriptions[code];
      values[code] = BoutiqueTextValues(
        name: _names[code]!.text,
        bio: _bios[code]?.text ?? '',
        description: description == null
            ? ''
            : boutiqueHtmlFromQuill(description),
      );
    }
    _bloc.add(BoutiqueEditorTextSynced(values));
  }

  void _close(BoutiqueEditorState state) {
    Navigator.of(context).pop(state.didChange);
  }

  Future<void> _pickIcon() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    final PlatformFile? file = result?.files.single;
    final String? path = file?.path;
    if (!mounted || file == null || path == null) return;
    _bloc.add(
      BoutiqueEditorIconPicked(PickedImageFile(path: path, size: file.size)),
    );
  }

  Future<void> _pickBanners() async {
    // `withData` stays off: the picker gives paths and sizes, and no file is
    // read into memory here (review finding P-8).
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (!mounted || result == null) return;
    final List<PickedImageFile> files = <PickedImageFile>[
      for (final PlatformFile f in result.files)
        if (f.path != null) PickedImageFile(path: f.path!, size: f.size),
    ];
    if (files.isNotEmpty) _bloc.add(BoutiqueEditorBannersPicked(files));
  }

  Future<void> _showBannerWarning(PendingBannerWarning warning) async {
    final bool? upload = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.boutique_banner_warning_title.tr()),
        content: Text(
          LocaleKeys.boutique_banner_warning_body.tr(
            args: <String>[
              '$kBannerRecommendedWidth',
              '$kBannerRecommendedHeight',
              '${warning.width}',
              '${warning.height}',
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.boutique_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.boutique_ignore_upload.tr()),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _bloc.add(BoutiqueEditorBannerWarningAnswered(upload: upload == true));
  }

  void _onNavigation(BoutiqueEditorState state) {
    switch (state.navigation) {
      case BoutiqueEditorNavigation.none:
        return;
      case BoutiqueEditorNavigation.backToList:
        _bloc.add(const BoutiqueEditorNavigationHandled());
        Navigator.of(context).pop(true);
        return;
      case BoutiqueEditorNavigation.shopChanged:
        _bloc.add(const BoutiqueEditorNavigationHandled());
        showMessage(LocaleKeys.boutique_shop_changed.tr(), hasError: true);
        _close(state);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BoutiqueEditorBloc, BoutiqueEditorState>(
          listenWhen: (p, c) => p.navigation != c.navigation,
          listener: (context, state) => _onNavigation(state),
        ),
        BlocListener<BoutiqueEditorBloc, BoutiqueEditorState>(
          listenWhen: (p, c) =>
              c.bannerWarning != null && p.bannerWarning != c.bannerWarning,
          listener: (context, state) => _showBannerWarning(state.bannerWarning!),
        ),
      ],
      child: BlocBuilder<BoutiqueEditorBloc, BoutiqueEditorState>(
        builder: (context, state) {
          _applyForm(state);
          return PopScope<bool>(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _close(state);
            },
            child: Scaffold(
              backgroundColor: BoutiqueColors.page,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                foregroundColor: const Color(0xFF1D1D1D),
                leading: BackButton(onPressed: () => _close(state)),
                title: Text(
                  state.isCreate
                      ? LocaleKeys.boutique_new_title.tr()
                      : LocaleKeys.boutique_title.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              body: SafeArea(child: _buildBody(state)),
              bottomNavigationBar:
                  state.loadStatus == BoutiqueEditorLoadStatus.ready &&
                      state.editing
                  ? _buildBottomBar(state)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BoutiqueEditorState state) {
    switch (state.loadStatus) {
      case BoutiqueEditorLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BoutiqueEditorLoadStatus.accessDenied:
        return _Message(text: LocaleKeys.boutique_access_denied.tr());
      case BoutiqueEditorLoadStatus.notFound:
        return _Message(text: LocaleKeys.boutique_not_found.tr());
      case BoutiqueEditorLoadStatus.failure:
        return _Message(
          text: LocaleKeys.boutique_load_failed.tr(),
          actionLabel: LocaleKeys.boutique_retry.tr(),
          onAction: () => _bloc.add(const BoutiqueEditorRetried()),
        );
      case BoutiqueEditorLoadStatus.ready:
        break;
    }

    final BoutiqueForm form = state.form!;
    final String active = state.activeLanguage;
    final TranslationForm translation =
        form.translations[active] ?? TranslationForm(languageCode: active);
    final Map<String, BoutiqueLanguage> byCode = <String, BoutiqueLanguage>{
      for (final BoutiqueLanguage l in state.languages) l.code: l,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildHeader(state, form),
        if (state.statusError != null) ...[
          const SizedBox(height: 16),
          _ErrorBox(
            title: LocaleKeys.boutique_status_failed_title.tr(),
            message: state.statusError!,
          ),
        ],
        if (state.saveError != null) ...[
          const SizedBox(height: 16),
          _ErrorBox(message: state.saveError!),
        ],
        const SizedBox(height: 20),
        BoutiqueAvailabilitySection(
          options: state.availabilities,
          value: form.availability,
          enabled: state.editing,
          onChanged: (value) =>
              _bloc.add(BoutiqueEditorAvailabilityChanged(value)),
        ),
        const SizedBox(height: 20),
        BoutiqueTranslationsSection(
          languages: state.languages,
          activeLanguage: active,
          onTabSelected: (code) {
            if (state.editing) _syncText();
            _bloc.add(BoutiqueEditorTabChanged(code));
          },
          translation: translation,
          nameController: _names[active] ?? TextEditingController(),
          bioController: _bios[active] ?? TextEditingController(),
          descriptionController:
              _descriptions[active] ??
              boutiqueQuillFromHtml('', readOnly: !state.editing),
          editing: state.editing,
          errors: state.errors[active] ?? const <BoutiqueField>{},
          copySources: <BoutiqueField, List<BoutiqueLanguage>>{
            for (final BoutiqueField field in BoutiqueField.values)
              field: <BoutiqueLanguage>[
                for (final String code in copySources(form, active, field))
                  if (byCode[code] != null) byCode[code]!,
              ],
          },
          onCopy: (field, from) {
            _syncText();
            _bloc.add(BoutiqueEditorFieldCopied(from, field));
          },
          iconUploading: state.iconUploading.contains(active),
          onPickIcon: _pickIcon,
          bannersPending: state.bannersPending,
          onAddBanners: _pickBanners,
          onMoveBanner: (index, delta) =>
              _bloc.add(BoutiqueEditorBannerMoved(index, delta)),
          onRemoveBanner: (index) =>
              _bloc.add(BoutiqueEditorBannerRemoved(index)),
        ),
        const SizedBox(height: 20),
        BoutiqueCountriesSection(
          countries: state.countries,
          selected: form.countriesIso,
          enabled: state.editing,
          onToggle: (iso) => _bloc.add(BoutiqueEditorCountryToggled(iso)),
        ),
      ],
    );
  }

  Widget _buildHeader(BoutiqueEditorState state, BoutiqueForm form) {
    final TranslationForm? header =
        form.translations['en'] ?? state.activeTranslation;
    final bool active = form.status == 1;
    final bool canUpdate = widget.permissions.canUpdateBoutique();
    final bool canStatus = widget.permissions.canChangeBoutiqueStatus();
    final String name = state.isCreate
        ? LocaleKeys.boutique_new_title.tr()
        : (header?.name.isNotEmpty == true
              ? header!.name
              : LocaleKeys.boutique_title.tr());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BoutiqueColors.border),
                ),
                child: BoutiquePreviewImage(
                  localPath: header?.iconLocalPath,
                  storedValue: header?.iconPreviewUrl ??
                      (header == null || header.icon.isEmpty
                          ? null
                          : header.icon),
                  legacyFolder: 'boutiques/boutiques/icon',
                  decodeWidth: 64,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: BoutiqueColors.text,
                          ),
                        ),
                        if (!state.isCreate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? BoutiqueColors.activeBg
                                  : BoutiqueColors.chip,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              active
                                  ? LocaleKeys.boutique_active.tr()
                                  : LocaleKeys.boutique_inactive.tr(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? BoutiqueColors.active
                                    : BoutiqueColors.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.isCreate
                          ? LocaleKeys.boutique_new_subtitle.tr()
                          : LocaleKeys.boutique_id_label.tr(
                              args: <String>['${state.boutiqueId}'],
                            ),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: _headerActions(state, form, canUpdate, canStatus),
          ),
        ],
      ),
    );
  }

  List<Widget> _headerActions(
    BoutiqueEditorState state,
    BoutiqueForm form,
    bool canUpdate,
    bool canStatus,
  ) {
    if (!state.editing) {
      // View mode: Edit, only with UPDATE_BUTIKS (AC-8). The control is hidden,
      // not disabled, without the permission.
      return <Widget>[
        if (canUpdate)
          _PrimaryButton(
            icon: Icons.edit_outlined,
            label: LocaleKeys.boutique_edit.tr(),
            onPressed: () => _bloc.add(const BoutiqueEditorEditEntered()),
          ),
      ];
    }
    return <Widget>[
      // Status button: edit mode, existing boutique, CHANGE_BOUTIQUE_STATUS
      // only (AC-9). It changes the form only; the call runs on save.
      if (!state.isCreate && canStatus)
        _SecondaryButton(
          label: form.status == 1
              ? LocaleKeys.boutique_set_inactive.tr()
              : LocaleKeys.boutique_set_active.tr(),
          onPressed: state.saving
              ? null
              : () => _bloc.add(const BoutiqueEditorStatusToggled()),
        ),
      ..._saveActions(state),
    ];
  }

  /// Cancel and Save / Create — in the header and again in the bottom bar.
  List<Widget> _saveActions(BoutiqueEditorState state) {
    final bool busy = state.saving || state.isUploading;
    return <Widget>[
      _SecondaryButton(
        label: LocaleKeys.boutique_cancel.tr(),
        onPressed: state.saving
            ? null
            : () {
                if (state.isCreate) {
                  _close(state);
                } else {
                  _bloc.add(const BoutiqueEditorCancelled());
                }
              },
      ),
      _PrimaryButton(
        icon: Icons.check,
        label: state.isCreate
            ? LocaleKeys.boutique_create.tr()
            : LocaleKeys.boutique_save_changes.tr(),
        loading: state.saving,
        onPressed: busy
            ? null
            : () {
                _syncText();
                _bloc.add(const BoutiqueEditorSaved());
              },
      ),
    ];
  }

  Widget _buildBottomBar(BoutiqueEditorState state) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
          children: _saveActions(state),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: BoutiqueColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: BoutiqueColors.secondaryButton,
        foregroundColor: BoutiqueColors.secondaryText,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String? title;
  final String message;

  const _ErrorBox({this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C2C0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BoutiqueColors.error,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: BoutiqueColors.error),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: BoutiqueColors.secondaryText,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              _PrimaryButton(
                icon: Icons.refresh,
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
