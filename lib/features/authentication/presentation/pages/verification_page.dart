
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/authentication/presentation/pages/login_successfully.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';

import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../widgets/adding_name.dart';
import '../widgets/verification_methods.dart';
class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key, required this.fromLogin}) : super(key: key);
  final bool fromLogin;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final PageController pageController = PageController();
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    FocusScope.of(context).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: pageContent,
        builder: (context, index, _) {
          return Scaffold(
            backgroundColor: index <= 3
                ? context.colorScheme.background
                : const Color(0xffF4FFF4),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(top: 50.h, left: 40.w, child: logo),
                Padding(
                  padding: EdgeInsets.only(top: 100.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: ValueListenableBuilder<int>(
                            valueListenable: pageContent,
                            builder: (context, index, _) {
                              return PageView(
                                physics: NeverScrollableScrollPhysics(),
                                controller: pageController,
                                children: <Widget>[
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
