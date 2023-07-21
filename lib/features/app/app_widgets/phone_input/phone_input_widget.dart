import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'dart:ui' as UI;
import '../../../../common/constant/countries.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../service/language_service.dart';

class DefaultContainer extends StatelessWidget {
  const DefaultContainer(
      {Key? key,
      this.width,
      this.height,
      this.backColor,
      this.borderColor,
      this.childWidget,
      this.borderWidth,
      // this.backGroundImageUrl,
      this.radius,
      this.withoutRadius})
      : super(key: key);

  final double? width;
  final double? borderWidth;
  final double? height;
  final Color? backColor;
  final Color? borderColor;
  final Widget? childWidget;

  // final String? backGroundImageUrl;
  final bool? withoutRadius;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(
            withoutRadius != null ? 0.0 : radius ?? 2.0.sp),
        border: Border.all(
            width: borderWidth ?? 1.0, color: borderColor ?? Colors.black),
      ),
      child: childWidget,
    );
  }
}
class PhoneInputField extends StatelessWidget {
  PhoneInputField({
    Key? key,
    this.onInputChanged,
    this.enable = true,
    this.phoneController,
  }) : super(key: key);

  final void Function(PhoneNumber number)? onInputChanged;
  final TextEditingController? phoneController;
  final bool enable;
  String dialCode = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: UI.TextDirection.ltr,
          child: DefaultContainer(
            borderColor: context.colorScheme.borderTextField,
            radius: 8.0.sp,
            backColor: context.colorScheme.white,
            childWidget: Padding(
              padding: HWEdgeInsets.symmetric(horizontal: 10),
              child: InternationalPhoneNumberInput(
                  textFieldController: phoneController,
                  isEnabled: enable,
                  onFieldSubmitted: (String? val) {
                    // accountCubit.updatePhoneNum(val!);
                  },
                  keyboardType: TextInputType.number,
                  inputDecoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  formatInput: true,
                  validator: (String? val) {
                    if (val == null) {
                    } else if (double.tryParse(
                            val.replaceAll(RegExp(r'[^0-9]'), '')) ==
                        null) {
                      return 'Enter a valid number';
                    }
                    print(dialCode);
                    Country country = countries
                        .firstWhere((element) => element.dialCode == dialCode);
                    if ((country.minLength - 1) >
                        (val!.replaceAll(RegExp(r'[^0-9]'), '')).length) {
                      return 'Enter a valid number';
                    } else if (country.maxLength <
                        (val.replaceAll(RegExp(r'[^0-9]'), '')).length) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,

                    showFlags: true,

                    leadingPadding: 0.0,

                    trailingSpace: false,

                    // useEmoji : false,
                    setSelectorButtonAsPrefixIcon: false,
                  ),
                  onInputChanged: (phone) {
                    onInputChanged!.call(phone);
                    dialCode = phone.dialCode!;
                  }),
            ),
          ),
        ),
        SizedBox(
          height: 15.h,
        ),

//         IntlPhoneField(
//       // isArabic: true,
// dropdownIconPosition: IconPosition.leading,
//      pickerDialogStyle: PickerDialogStyle(
//
//      ),
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.all(10.h),
//             // icon: Icon(Icons.send),
//             // hintText: 'Hint Text',
//             // helperText: 'Helper Text',
//             // counterText: '0 characters',
//
//             focusedBorder: OutlineInputBorder(
//                 borderSide:
//                     const BorderSide(color: Color(0xffa4c4f4), width: 2.0),
//                 borderRadius: BorderRadius.all(Radius.circular(11.0.sp))),
//
//             enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     const BorderSide(color: Color(0xffa4c4f4), width: 1.0),
//                 borderRadius: BorderRadius.all(Radius.circular(11.0.sp))),
//           ),
//           initialCountryCode: 'AE',
//           onChanged: (phone) {
//             logg(phone.completeNumber);
//           },
//         )
      ],
    );
  }
}
