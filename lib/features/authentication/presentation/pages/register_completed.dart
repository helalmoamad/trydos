import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';

import '../../../../base_page.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';

class RegisterCompleted extends StatefulWidget {
  const RegisterCompleted({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  State<RegisterCompleted> createState() => _RegisterCompletedState();
}

class _RegisterCompletedState extends ThemeState<RegisterCompleted> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBCFFDF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50, left: 40, right: 40, child: logo),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  SizedBox(height: 10,),
                  Padding(
                    padding: HWEdgeInsets.only(left: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: HWEdgeInsets.only(left: 4.0),
                          child: Text('Hello,',
                              textAlign: TextAlign.start,
                              style: textTheme.headline3?.ba.copyWith(
                                  color: Color(0xff5D5C5D), height: 1.25)),
                        ),
                        SizedBox(height: 17,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.userName,
                                textAlign: TextAlign.start,
                                style: textTheme.headline3?.la.copyWith(
                                  color: Color(0xff5D5C5D),
                                  letterSpacing: 0.3,
                                  height: 0.67,
                                )),
                            SizedBox(height: 18,),
                            Text('Enjoy With Our Services',
                                textAlign: TextAlign.center,
                                style: textTheme.subtitle1?.la.copyWith(
                                    color: Color(0xff5D5C5D),
                                    height: 1.25)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Text(
                      'We Recommend That You Complete Your Profile To Make The\nMost Of The App’s Features, Such As Shopping, Chatting,Stories,\nTaking Advantage Of Offers, Interests, And Much More',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyText2?.la.copyWith(
                        color: Color(0xff5D5C5D),
                        letterSpacing: 0.14,
                        height: 1.43,
                      )),
                  SizedBox(height: 10,),
                  Container(
                    width: 1.sw,
                    height: 60,
                    margin: HWEdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xffF4FFF4),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Complete My Profile',
                          style: textTheme.bodyText1?.ra.copyWith(
                            color: Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  InkWell(
                    onTap: (){
                      context.go(GRouter.config.applicationRoutes.kBasePage);
                    },
                    child: Text(
                      'Skip For Now',
                      style: textTheme.bodyText2?.ra.copyWith(
                        color: Color(0xff4d84ff),
                        letterSpacing: 0.14,
                        height: 1.43,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 5,),
                ]),
          ),
        ],
      ),
    );
  }
}
