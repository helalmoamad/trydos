import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'boutique_availability_section.dart';

/// The description editor: Bold, Italic, Underline and Heading 2, stored as
/// HTML like the website (AC-25, AC-26).
///
/// HTML is converted only when a language is loaded into the page and when
/// the page collects the text before a tab change, a copy or a save — never on
/// a keystroke (review finding P-4).
///
/// Both directions go through [_sanitizeOps]: only the four allowed styles
/// survive, and links and embedded objects are dropped. A `javascript:` link
/// stored by another writer is therefore neither sent back nor tappable here
/// (review finding S-2). The backend and the website must still sanitize when
/// they render, because the API accepts any body.

/// A controller holding [html] (`''` gives an empty editor).
QuillController boutiqueQuillFromHtml(String html, {required bool readOnly}) {
  Document document;
  try {
    final List<Map<String, dynamic>> ops = html.trim().isEmpty
        ? const <Map<String, dynamic>>[]
        : _sanitizeOps(
            HtmlToDelta()
                .convert(html)
                .toJson()
                .cast<Map<String, dynamic>>(),
          );
    document = ops.isEmpty ? Document() : Document.fromJson(_ensureTrailingNewline(ops));
  } catch (_) {
    document = Document();
  }
  return QuillController(
    document: document,
    selection: const TextSelection.collapsed(offset: 0),
    readOnly: readOnly,
  );
}

/// The HTML to send, or `''` when the editor is empty (AC-30).
String boutiqueHtmlFromQuill(QuillController controller) {
  if (controller.document.isEmpty()) return '';
  final List<Map<String, dynamic>> ops = _sanitizeOps(
    controller.document.toDelta().toJson().cast<Map<String, dynamic>>(),
  );
  return QuillDeltaToHtmlConverter(ops).convert();
}

const Set<String> _inlineKeys = <String>{'bold', 'italic', 'underline'};

List<Map<String, dynamic>> _sanitizeOps(List<Map<String, dynamic>> ops) {
  final List<Map<String, dynamic>> clean = <Map<String, dynamic>>[];
  for (final Map<String, dynamic> op in ops) {
    final dynamic insert = op['insert'];
    // Embeds (images, videos, formulas) are maps: dropped.
    if (insert is! String || insert.isEmpty) continue;
    final dynamic rawAttributes = op['attributes'];
    final Map<String, dynamic> attributes = <String, dynamic>{};
    if (rawAttributes is Map) {
      rawAttributes.forEach((key, value) {
        if (_inlineKeys.contains(key) && value == true) {
          attributes[key as String] = true;
        }
        if (key == 'header' && value == 2 && insert.contains('\n')) {
          attributes['header'] = 2;
        }
      });
    }
    clean.add(<String, dynamic>{
      'insert': insert,
      if (attributes.isNotEmpty) 'attributes': attributes,
    });
  }
  return clean;
}

/// A Quill document must end with a newline.
List<Map<String, dynamic>> _ensureTrailingNewline(
  List<Map<String, dynamic>> ops,
) {
  final dynamic last = ops.isEmpty ? null : ops.last['insert'];
  if (last is String && last.endsWith('\n')) return ops;
  return <Map<String, dynamic>>[
    ...ops,
    <String, dynamic>{'insert': '\n'},
  ];
}

class BoutiqueRichTextField extends StatelessWidget {
  final QuillController controller;
  final bool enabled;
  final bool hasError;

  const BoutiqueRichTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    controller.readOnly = !enabled;
    // The editor's own strings come from its delegate, added here only, so the
    // app-wide localization setup is not changed (plan OQ-1a).
    return Localizations.override(
      context: context,
      delegates: const <LocalizationsDelegate<dynamic>>[
        FlutterQuillLocalizations.delegate,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enabled) ...[
            _Toolbar(controller: controller),
            const SizedBox(height: 8),
          ],
          Opacity(
            opacity: enabled ? 1 : 0.7,
            child: Container(
              constraints: const BoxConstraints(minHeight: 104),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: BoutiqueColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? BoutiqueColors.error : BoutiqueColors.border,
                ),
              ),
              child: QuillEditor.basic(
                controller: controller,
                config: const QuillEditorConfig(
                  scrollable: false,
                  minHeight: 80,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Four buttons, like the website: B, I, U, H2.
class _Toolbar extends StatelessWidget {
  final QuillController controller;

  const _Toolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final Map<String, Attribute> style =
            controller.getSelectionStyle().attributes;
        final bool isH2 = style[Attribute.header.key]?.value == 2;
        return Wrap(
          spacing: 6,
          children: [
            _ToolbarButton(
              label: 'B',
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              active: style.containsKey(Attribute.bold.key),
              onTap: () => _toggle(Attribute.bold, style),
            ),
            _ToolbarButton(
              label: 'I',
              textStyle: const TextStyle(fontStyle: FontStyle.italic),
              active: style.containsKey(Attribute.italic.key),
              onTap: () => _toggle(Attribute.italic, style),
            ),
            _ToolbarButton(
              label: 'U',
              textStyle: const TextStyle(decoration: TextDecoration.underline),
              active: style.containsKey(Attribute.underline.key),
              onTap: () => _toggle(Attribute.underline, style),
            ),
            _ToolbarButton(
              label: 'H2',
              active: isH2,
              onTap: () => controller.formatSelection(
                isH2 ? Attribute.clone(Attribute.header, null) : Attribute.h2,
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggle(Attribute attribute, Map<String, Attribute> style) {
    HapticFeedback.selectionClick();
    controller.formatSelection(
      style.containsKey(attribute.key)
          ? Attribute.clone(attribute, null)
          : attribute,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  final bool active;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    this.textStyle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFE0E0E0) : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: BoutiqueColors.primary,
              ).merge(textStyle),
            ),
          ),
        ),
      ),
    );
  }
}
