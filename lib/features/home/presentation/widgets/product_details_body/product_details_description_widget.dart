import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:trydos/generated/locale_keys.g.dart';

class ProductDetailsDescriptionWidget extends StatefulWidget {
  final String description;
  const ProductDetailsDescriptionWidget({
    super.key,
    required this.description,
  });

  @override
  State<ProductDetailsDescriptionWidget> createState() =>
      _ProductDetailsDescriptionWidgetState();
}

class _ProductDetailsDescriptionWidgetState
    extends State<ProductDetailsDescriptionWidget> {
  final ValueNotifier<bool> isExpandedNotifier = ValueNotifier(false);
  bool needsExpansion = false;
  late String plainText;

  @override
  void initState() {
    plainText = html_parser.parse(widget.description).body?.text ?? '';
    super.initState();
  }

  bool _checkTextOverflow(double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: plainText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              height: 1.5,
              color: const Color(0xff1D1D1D),
            ),
      ),
      maxLines: 2,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          needsExpansion = _checkTextOverflow(constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Html(
                data: widget.description,
                style: {
                  "*": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(11),
                    color: const Color(0xff1D1D1D),
                    lineHeight: const LineHeight(1.5),
                    maxLines: isExpandedNotifier.value ? null : 2,
                    textOverflow:
                        isExpandedNotifier.value ? null : TextOverflow.ellipsis,
                  ),
                },
              ),
              if (needsExpansion)
                GestureDetector(
                  onTap: () {
                    isExpandedNotifier.value = !isExpandedNotifier.value;
                    setState(() {});
                  },
                  child: Text(
                    isExpandedNotifier.value
                        ? "${LocaleKeys.read_less.tr()}"
                        : "${LocaleKeys.read_more.tr()}",
                    style: const TextStyle(
                      color: Color(0xff388CFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
