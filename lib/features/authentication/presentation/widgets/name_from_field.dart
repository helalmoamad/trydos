import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../core/utils/responsive_padding.dart';

class NameFormField extends StatefulWidget {
  NameFormField({
    Key? key,
    this.controller,
    this.onTap,
    this.onEditingComplete,
    this.onChange,
    this.onFieldSubmitted,
    this.onSaved,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.textInputType,
    this.textInputAction,
    this.textDirection,
    this.validator,
    this.maxLengthEnforcement,
    this.focusNode,
    this.autoValidateMode,
    this.scrollPhysics,
    this.scrollController,
    this.initialValue,
    this.keyboardAppearance,
    this.textAlignVertical,
    this.toolbarOptions,
    this.obscuringCharacter = "•",
    this.expands = false,
    this.readOnly = false,
    this.autocorrect = true,
    this.showLength = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.titleField,
    this.obscure = false,
    this.ready = false,
    this.prefixIcon,
    this.icon,
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon,
    this.suffix,
    this.hintText,
    this.labelText,
    this.inputFormatters,
    this.autoFocus,
    this.contentPadding,
    this.filledColor,
    this.bordersColor,
  }) : super(key: key);

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final void Function(String val)? onChange;
  final void Function(String val)? onFieldSubmitted;
  final void Function(String? val)? onSaved;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? enabled;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final FormFieldValidator<String?>? validator;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final FocusNode? focusNode;
  final AutovalidateMode? autoValidateMode;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String? initialValue;
  final Brightness? keyboardAppearance;
  final TextAlignVertical? textAlignVertical;
  final ToolbarOptions? toolbarOptions;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsets scrollPadding;
  final bool expands;
  final bool readOnly;
  final bool autocorrect;
  final String obscuringCharacter;
  final String? titleField;
  final bool showLength;
  final bool obscure;
  final bool? autoFocus;
  final Widget? prefixIcon;
  final Widget? icon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final String? labelText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? filledColor;
  final Color? bordersColor;
  bool ready=false;

  @override
  State<NameFormField> createState() => _NameFormFieldState();
}

class _NameFormFieldState extends State<NameFormField> {

  final ValueNotifier<bool> showHint = ValueNotifier(true);

  @override
  void initState() {
    widget.controller!.addListener(() {
      showHint.value=widget.controller!.text.isEmpty;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DottedBorder(
          borderPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          borderType: BorderType.RRect,
          strokeCap: StrokeCap.round,
          strokeWidth: 0.5,
          dashPattern: [3, 3],
          radius: Radius.circular(20.0),
          color: widget.ready ? const Color(0xff388CFF) : const Color(0xff5D5C5D),
          child: SizedBox(
            height: 60,
            width: 1.sw,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TextFormField(
                controller: widget.controller,
                onTap: widget.onTap,
                onChanged: widget.onChange,
                onFieldSubmitted: widget.onFieldSubmitted,
                onEditingComplete: widget.onEditingComplete,
                onSaved: widget.onSaved,
                validator: widget.validator,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                keyboardType: TextInputType.name,
                textInputAction: widget.textInputAction,
                textDirection: TextDirection.ltr,
                scrollPadding: widget.scrollPadding,
                expands: widget.expands,
                maxLengthEnforcement: widget.maxLengthEnforcement,
                focusNode: FocusNode()..requestFocus(),
                obscureText: widget.obscure,
                obscuringCharacter: widget.obscuringCharacter,
                autovalidateMode: widget.autoValidateMode,
                readOnly: widget.readOnly,
                scrollPhysics: widget.scrollPhysics,
                scrollController: widget.scrollController,
                autocorrect: false,
                autofocus: widget.autoFocus ?? false,
                cursorColor: Color(0xff5D5C5D),
                initialValue: widget.initialValue,
                keyboardAppearance: widget.keyboardAppearance,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: widget.textCapitalization,
                textAlign: TextAlign.start,
                cursorHeight: 0,
                toolbarOptions: widget.toolbarOptions,
                style: context.textTheme.bodyText1?.ra.copyWith(
                  color: const Color(0xff5D5C5D),
                  letterSpacing: 0.16 ,
                  height: 1.25,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: context.colorScheme.white,
                  filled: true,
                  contentPadding: HWEdgeInsets.only(top: 25 , left: 20,bottom: 25),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: Padding(
                    padding: HWEdgeInsets.only(bottom: 20),
                    child: widget.suffixIcon,
                  ),
                  counterText: '',
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: showHint,
          builder: (context , show , _) {
            return show ? Text('Enter Your Name',style:  context.textTheme.bodyText1?.ra
                .copyWith(color: Color(0xffC4C2C2)),) : const SizedBox.shrink();
          }
        )
      ],
    );
  }
}
