/// The one place backend text is made safe to render on the Locations screen
/// (AC-29). Both the list widget and the add/edit form call it, which is why it
/// lives beside the other dashboard presentation helpers instead of inside
/// either one.
///
/// Two separate jobs, and they must not be confused:
///
///   * [sanitizeForDisplay] builds a **read-only display copy** — direction
///     controls removed and the length capped. Call it once when the display
///     items are built, never inside an `itemBuilder`.
///   * [stripDirectionControls] is for an **editable field's prefill** — it
///     removes the direction controls and keeps the full length, because
///     capping an editable value would write the truncation back on the next
///     save.
///
/// The text controller is **not** filtered on every keystroke. What a member
/// types stands, so a name carrying a direction-control character can be saved
/// through this screen. That is an accepted residual, recorded in
/// `plan.md > Out of scope`: validating what it stores is the backend's job,
/// and this screen is not the only writer of location names.
library;

/// The cap for read-only rendering. The copy is a fresh allocation, so capping
/// here costs nothing and never touches stored text.
const int kDisplayTextMaxLength = 200;

/// Bidi overrides, embeddings, isolates, and the two direction marks. Removing
/// these stops a hostile value reshaping the row it is drawn in, or spoofing
/// the line direction of the text around it.
///
/// `U+200E` and `U+200F` are ordinary in `ar-SY` and `ku-IQ` text, so stripping
/// them from a prefill does normalise a name that legitimately carried them.
/// That trade is recorded in the plan and observed at verify; the alternative
/// is holding two copies of every field forever.
const Set<int> _kDirectionControlCodeUnits = <int>{
  0x061C, // ARABIC LETTER MARK
  0x200E, // LEFT-TO-RIGHT MARK
  0x200F, // RIGHT-TO-LEFT MARK
  0x202A, // LEFT-TO-RIGHT EMBEDDING
  0x202B, // RIGHT-TO-LEFT EMBEDDING
  0x202C, // POP DIRECTIONAL FORMATTING
  0x202D, // LEFT-TO-RIGHT OVERRIDE
  0x202E, // RIGHT-TO-LEFT OVERRIDE
  0x2066, // LEFT-TO-RIGHT ISOLATE
  0x2067, // RIGHT-TO-LEFT ISOLATE
  0x2068, // FIRST STRONG ISOLATE
  0x2069, // POP DIRECTIONAL ISOLATE
};

/// Removes every direction-control character and keeps everything else,
/// including the full length. This is what an editable field's prefill uses.
String stripDirectionControls(String? raw) {
  if (raw == null || raw.isEmpty) return '';

  // Scan first and allocate only when there is something to remove — the common
  // case is a clean value, and this keeps it allocation-free.
  bool hasControl = false;
  for (int i = 0; i < raw.length; i++) {
    if (_kDirectionControlCodeUnits.contains(raw.codeUnitAt(i))) {
      hasControl = true;
      break;
    }
  }
  if (!hasControl) return raw;

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    final int unit = raw.codeUnitAt(i);
    if (!_kDirectionControlCodeUnits.contains(unit)) {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// The read-only display copy: direction controls removed, then the length
/// capped at [maxLength].
///
/// `maxLines` / `overflow` on a `Text` widget stay a *visual* guard only — they
/// do not bound work, because the text engine still measures and shapes the
/// whole string. This does bound it.
String sanitizeForDisplay(String? raw, {int maxLength = kDisplayTextMaxLength}) {
  final String stripped = stripDirectionControls(raw);
  if (stripped.length <= maxLength) return stripped;
  return stripped.substring(0, maxLength);
}
