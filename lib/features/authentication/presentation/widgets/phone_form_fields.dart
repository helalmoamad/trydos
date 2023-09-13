import 'dart:async';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../common/constant/countries.dart';
import '../../../../core/utils/responsive_padding.dart';

double offset = 0;

class PhoneFormField extends StatelessWidget {
   PhoneFormField({
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
    this.prefixIcon,
    this.ready=false,
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
    required this.focusNode,
  }) : super(key: key);

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final bool Function(String val)? onChange;
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
  final FocusNode focusNode;
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

  final ValueNotifier<bool> rebuildCursor = ValueNotifier(false);

  final ValueNotifier<bool> showCursor = ValueNotifier(true);

  late Timer timer ;

  @override
  Widget build(BuildContext context) {
    timer=Timer.periodic(Duration(milliseconds: 500), (timer) {
      showCursor.value=!showCursor.value;
    });
    if(controller?.text.isEmpty ?? true){
      offset=0;
    }
    return DottedBorder(
      borderPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderType: BorderType.RRect,
      strokeCap: StrokeCap.round,
      strokeWidth: 0.5,
      dashPattern: [3, 3],
      radius: Radius.circular(20.0),
      color: ready ? const Color(0xff388CFF) : const Color(0xff5D5C5D),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
            height: 60,
            width: 390.w,
            child: TextFormField(
              controller: controller,
              onTap: onTap,
              onChanged: (String? text) {
                if(text != null) {
                   onChange?.call(text) ?? false;
                  offset = (controller!.text.length * 9).w;
                    rebuildCursor.value = !rebuildCursor.value;
                }
              },
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              onSaved: onSaved,
              validator: validator,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textInputAction: textInputAction,
              textDirection: TextDirection.ltr,
              scrollPadding: scrollPadding,
              expands: expands,
              maxLengthEnforcement: maxLengthEnforcement,
              focusNode: focusNode,
              obscureText: obscure,
              obscuringCharacter: obscuringCharacter,
              autovalidateMode: autoValidateMode,
              readOnly: readOnly,
              scrollPhysics: scrollPhysics,
              scrollController: scrollController,
              autocorrect: false,
              autofocus: autoFocus ?? false,
              cursorColor: Color(0xff5D5C5D),
              cursorHeight: 0,
              cursorWidth: 0.w,

              initialValue: initialValue,
              keyboardAppearance: keyboardAppearance,
              textAlignVertical: TextAlignVertical.center,
              textCapitalization: textCapitalization,
              toolbarOptions: toolbarOptions,
              inputFormatters: [
                PhoneNumberFormatter()
              ],
              style: context.textTheme.headline5?.ra.copyWith(
                color: const Color(0xff5D5C5D),
                height: 0.6,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                contentPadding: HWEdgeInsets.only(top: 15),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: context.colorScheme.white,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                counterText: '',
                hintText: hintText?.tr(),
                hintStyle: context.textTheme.bodyText1?.ra
                    .copyWith(color: Color(0xffC4C2C2)),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: showCursor,
            builder: (context , show ,_) {
              return show ? ValueListenableBuilder<bool>(
                  valueListenable: rebuildCursor,
                  builder: (context, rebuild, _) {
                    print(rebuild);
                    return Container(
                      margin: HWEdgeInsets.only(left: 95+offset, bottom: 20),
                      width: 10.w,
                      height: 1,
                      color: const Color(0xff5D5C5D),
                    );
                  }) : const SizedBox.shrink();
            }
          )
        ],
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  final validationRegex = RegExp(r'[ 0-9]');
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    print(newValue.text);
    if(newValue.text.isEmpty){
      return newValue;
    }
    if (!validationRegex.hasMatch(newValue.text) || (newValue.text[newValue.text.length-1]==' ' && newValue.text.length > oldValue.text.length)) {
      return oldValue;
    }
    if((newValue.text[newValue.text.length-1]==' ' || oldValue.text[max(0 , oldValue.text.length-1)]==' ') && newValue.text.length < oldValue.text.length) {
      return newValue.copyWith(
          text: newValue.text.substring(0 ,newValue.text.length-1 ),
          selection: TextSelection.collapsed(offset:newValue.selection.baseOffset -1)
      );
    }
    Country newCountry = countries.firstWhere(
            (element) => '+${newValue.text.toLowerCase()}'
            .startsWith(
            element.dialCode.toLowerCase()),
        orElse: () => Country(
            name: '',
            flag: '',
            code: '',
            dialCode: '',
            minLength: 0,
            maxLength: 0));
    Country prevCountry = countries.firstWhere(
            (element) => '+${oldValue.text.toLowerCase()}'
            .startsWith(
            element.dialCode.toLowerCase()),
        orElse: () => Country(
            name: '',
            flag: '',
            code: '',
            dialCode: '',
            minLength: 0,
            maxLength: 0));
    if(newValue.text.replaceAll(' ', '').length > newCountry.maxLength+newCountry.dialCode.length-1 && newCountry.flag!=''){
      return oldValue;
    }
    bool justCode = countries.any(
            (element) => element.dialCode == '+${newValue.text}');
    if(justCode && newValue.text.length < oldValue.text.length){
      return newValue.copyWith(
          text: newValue.text.substring(0 ,newValue.text.length-1 ),
          selection: TextSelection.collapsed(offset:newValue.selection.baseOffset -1)
      );
    }
    if(newCountry.dialCode != prevCountry.dialCode && newCountry.flag!=''){
      return newValue.copyWith(
        text: newValue.text + ' ',
        selection: TextSelection.collapsed(offset:newValue.selection.baseOffset + 1)
      );
    }
    int spaceIndex = max(0 ,newValue.text.lastIndexOf(' '));
    if((newValue.text.length-spaceIndex) == 4){
      return newValue.copyWith(
          text: newValue.text + ' ',
          selection: TextSelection.collapsed(offset:newValue.selection.baseOffset + 1)
      );
    }
    return newValue;
  }

}