import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/features/authentication/presentation/widgets/phone_form_fields.dart';

import '../../../../common/constant/countries.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';

class InsertPhoneTab extends StatefulWidget {
  const InsertPhoneTab(
      {this.fromLogin = false, required this.moveToNextStep, required this.focusNode, Key? key})
      : super(key: key);
  final bool fromLogin;
  final void Function(String phoneNumber) moveToNextStep;
  final FocusNode focusNode;
  @override
  State<InsertPhoneTab> createState() => _InsertPhoneTabState();
}

class _InsertPhoneTabState extends State<InsertPhoneTab> with FormStateMinxin {
  final ValueNotifier<Country> countryChanged = ValueNotifier(Country(
      name: '', flag: '', code: '', dialCode: '', minLength: 0, maxLength: 0));
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  final ValueNotifier<bool> changeTextInputFieldContent = ValueNotifier(false);
  int maxLength = 25;

  @override
  void initState() {
    widget.focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('here:  ${form.controllers[0].text}');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 40.0),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                      widget.fromLogin
                          ? AppAssets.enterSvg
                          : AppAssets.phoneCallOutlinedSvg,
                      width: 15,
                      height: 15),
                  10.horizontalSpace,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Your Phone Number ' +
                            (widget.fromLogin
                                ? 'To Login'
                                : 'Registered With Us'),
                        style: context.textTheme.caption?.ra
                            .copyWith(color: Color(0xff5D5C5D), height: 1.42),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: HWEdgeInsets.only(top: 3.0),
                            child: SvgPicture.asset(AppAssets.registerInfoSvg,
                                width: 10, height: 10),
                          ),
                          5.horizontalSpace,
                          Text(
                            'Enter Your Phone Number Registered With Us',
                            textAlign: TextAlign.start,
                            style: context.textTheme.caption?.ra.copyWith(
                                color: Color(0xffC4C2C2), height: 1.25),
                          )
                        ],
                      ),
                      if (widget.fromLogin) ...{
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppAssets.phoneOtpSvg,
                                width: 10, height: 10),
                            5.horizontalSpace,
                            Text(
                              'We Will Send A Verification Code To The Number',
                              style: context.textTheme.caption?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25),
                            )
                          ],
                        ),
                      } else ...{
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: HWEdgeInsets.only(top: 3.0),
                              child: SvgPicture.asset(AppAssets.privacySvg,
                                  width: 10, height: 10),
                            ),
                            5.horizontalSpace,
                            Text(
                              'Your Privacy Is Completely Safe, We Not Share Your\nInformation With Anyone',
                              textAlign: TextAlign.start,
                              style: context.textTheme.caption?.ra.copyWith(
                                  color: Color(0xffC4C2C2), height: 1.25),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        )
                      }
                    ],
                  )
                ],
              ),
            ]),
          ),
          SizedBox(height: 29,),
          Padding(
              padding: HWEdgeInsets.symmetric(horizontal: 20.0),
              child: ValueListenableBuilder<bool>(
                  valueListenable: displaySubmit,
                  builder: (context, display, _) {
                    return PhoneFormField(
                      focusNode:widget.focusNode,
                      onChange: (String? text) {
                        Country newCountry = countries.firstWhere(
                            (element) => '+${text?.toLowerCase()}'
                                .startsWith(
                                    element.dialCode.toLowerCase()),
                            orElse: () => Country(
                                name: '',
                                flag: '',
                                code: '',
                                dialCode: '',
                                minLength: 0,
                                maxLength: 0));
                        if (text?.isNotEmpty ?? false) {
                          displaySubmit.value = text!.replaceAll(' ', '').length >=
                                  (newCountry.minLength +
                                      newCountry.dialCode.length - 1) &&
                              text.replaceAll(' ', '').length <=
                                  (newCountry.maxLength +
                                      newCountry.dialCode.length - 1);
                        }
                        countryChanged.value = newCountry;
                        return form.controllers[0].text.isNotEmpty ? form.controllers[0].text[form.controllers[0].text.length-1]==' ' : false;
                      },
                      maxLength: maxLength,
                      prefixIcon: Padding(
                        padding: HWEdgeInsets.only(left: 20.0, top: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(AppAssets.phoneCallSvg),
                            10.horizontalSpace,
                            ValueListenableBuilder<Country>(
                                valueListenable: countryChanged,
                                builder: (context, country, _) {
                                  if (country.code == '')
                                    return const SizedBox(
                                      width: 22,
                                      height: 15,
                                    );
                                  else
                                    return CountryFlag.fromCountryCode(
                                    country.code,
                                    height: 15,
                                    width: 22,
                                      borderRadius: 4,
                                    );
                                }),
                            10.horizontalSpace,
                            Text(
                              '+',
                              style: context.textTheme.subtitle1?.rr
                                  .copyWith(color: Color(0xff8E8E8E)),
                            ),
                            4.horizontalSpace
                          ],
                        ),
                      ),
                      ready: display,
                      suffixIcon: Padding(
                        padding: HWEdgeInsets.only(right: 20.0, top: 22),
                        child: !display
                            ? SizedBox(
                                width: 22,
                                height: 15,
                              )
                            : InkWell(
                                onTap: () {
                                  widget.moveToNextStep.call(
                                      '+${form.controllers[0].text}');
                                },
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.submitArrowSvg,
                                        width: 10,
                                        height: 20,
                                      ),
                                    ]),
                              ),
                      ),
                      hintText: 'Phone Number',
                      controller: form.controllers[0],
                    );
                  })),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}
