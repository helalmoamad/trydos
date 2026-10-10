part of 'boutique_editor_bloc.dart';

abstract class BoutiqueEditorEvent {
  const BoutiqueEditorEvent();
}

/// Opens the page. [boutiqueId] is `null` on the New Boutique page.
class BoutiqueEditorStarted extends BoutiqueEditorEvent {
  final int? boutiqueId;
  const BoutiqueEditorStarted({this.boutiqueId});
}

/// The error box's **Retry** (AC-20).
class BoutiqueEditorRetried extends BoutiqueEditorEvent {
  const BoutiqueEditorRetried();
}

class BoutiqueEditorEditEntered extends BoutiqueEditorEvent {
  const BoutiqueEditorEditEntered();
}

/// Restores the last saved form and status; sends nothing (AC-18).
class BoutiqueEditorCancelled extends BoutiqueEditorEvent {
  const BoutiqueEditorCancelled();
}

class BoutiqueEditorTabChanged extends BoutiqueEditorEvent {
  final String languageCode;
  const BoutiqueEditorTabChanged(this.languageCode);
}

/// The text the page holds in its controllers, per language. Text does not
/// go through the bloc on every keystroke (review finding P-3); the page sends
/// it before a tab change, a copy, or a save.
class BoutiqueEditorTextSynced extends BoutiqueEditorEvent {
  final Map<String, BoutiqueTextValues> values;
  const BoutiqueEditorTextSynced(this.values);
}

class BoutiqueTextValues {
  final String name;
  final String description;
  final String bio;
  const BoutiqueTextValues({
    required this.name,
    required this.description,
    required this.bio,
  });
}

class BoutiqueEditorAvailabilityChanged extends BoutiqueEditorEvent {
  final int availability;
  const BoutiqueEditorAvailabilityChanged(this.availability);
}

class BoutiqueEditorCountryToggled extends BoutiqueEditorEvent {
  final String iso;
  const BoutiqueEditorCountryToggled(this.iso);
}

/// Flips the status in the form only; the call runs on save (AC-9, AC-35).
class BoutiqueEditorStatusToggled extends BoutiqueEditorEvent {
  const BoutiqueEditorStatusToggled();
}

/// Copies [field] from [fromLanguage] into the active tab (AC-21).
class BoutiqueEditorFieldCopied extends BoutiqueEditorEvent {
  final String fromLanguage;
  final BoutiqueField field;
  const BoutiqueEditorFieldCopied(this.fromLanguage, this.field);
}

/// A file chosen in the picker. [size] comes from the picker, so the 10 MB
/// limit is checked before a single byte is read (review finding P-1).
class PickedImageFile {
  final String path;
  final int size;
  const PickedImageFile({required this.path, required this.size});
}

class BoutiqueEditorIconPicked extends BoutiqueEditorEvent {
  final PickedImageFile file;
  const BoutiqueEditorIconPicked(this.file);
}

class BoutiqueEditorBannersPicked extends BoutiqueEditorEvent {
  final List<PickedImageFile> files;
  const BoutiqueEditorBannersPicked(this.files);
}

/// The answer to "This banner may not display well" (AC-24).
class BoutiqueEditorBannerWarningAnswered extends BoutiqueEditorEvent {
  final bool upload;
  const BoutiqueEditorBannerWarningAnswered({required this.upload});
}

class BoutiqueEditorBannerMoved extends BoutiqueEditorEvent {
  final int index;
  final int delta;
  const BoutiqueEditorBannerMoved(this.index, this.delta);
}

class BoutiqueEditorBannerRemoved extends BoutiqueEditorEvent {
  final int index;
  const BoutiqueEditorBannerRemoved(this.index);
}

class BoutiqueEditorSaved extends BoutiqueEditorEvent {
  const BoutiqueEditorSaved();
}

/// The page has acted on [BoutiqueEditorState.navigation].
class BoutiqueEditorNavigationHandled extends BoutiqueEditorEvent {
  const BoutiqueEditorNavigationHandled();
}

/// Internal: process the next file of the banner queue, one at a time
/// (AC-23).
class _BoutiqueBannerQueueAdvanced extends BoutiqueEditorEvent {
  const _BoutiqueBannerQueueAdvanced();
}
