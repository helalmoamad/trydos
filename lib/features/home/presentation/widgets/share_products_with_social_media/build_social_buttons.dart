import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trydos/features/home/presentation/widgets/share_products_with_social_media/social_media_type.dart';
import 'package:trydos/trydos_application.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

Widget buildSocialButtons(
    {required String text,
    required String productSlugForULr,
    required String productId}) {
  String urlProductToShare =
      "https://trydos-front-git-development-trydos-front-team.vercel.app/products/$productSlugForULr";
  return Card(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialButton(
          icon: FaIcon(
            FontAwesomeIcons.squareFacebook,
            color: Color(0xff0075fc),
            size: 40,
          ),
          onClick: () {
            share(
              socialPlatform: SocialMediaType.facebook,
              text: text,
              urlShare: urlProductToShare,
              productId: productId,
            );
            //////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.shareWithFacebookButton,
            );
          },
        ),
        buildSocialButton(
          icon: FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Color(0xff00d856),
            size: 40,
          ),
          onClick: () {
            share(
              socialPlatform: SocialMediaType.whatsapp,
              text: text,
              urlShare: urlProductToShare,
              productId: productId,
            );
            //////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.shareWithWhatsappButton,
            );
          },
        ),
        /* buildSocialButton(
              icon: FaIcon(
                FontAwesomeIcons.facebookMessenger,
                color: Color.fromARGB(255, 172, 0, 252),
                size: 40,
              ),
              onClick: () => share(SocialMediaType.messanger, text, urlShare)),*/
        buildSocialButton(
          icon: FaIcon(
            FontAwesomeIcons.telegram,
            color: Color.fromARGB(255, 121, 175, 236),
            size: 40,
          ),
          onClick: () {
            share(
              socialPlatform: SocialMediaType.telegram,
              text: text,
              urlShare: urlProductToShare,
              productId: productId,
            );
            //////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.shareWithTelegramButton,
            );
          },
        ),
        buildSocialButton(
          icon: FaIcon(
            FontAwesomeIcons.twitter,
            color: Color.fromARGB(255, 8, 229, 245),
            size: 40,
          ),
          onClick: () {
            share(
              socialPlatform: SocialMediaType.twitter,
              text: text,
              urlShare: urlProductToShare,
              productId: productId,
            );
            //////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.shareWithTelegramButton,
            );
          },
        ),
        buildSocialButton(
          icon: FaIcon(
            FontAwesomeIcons.envelope,
            color: Color.fromARGB(255, 15, 15, 15),
            size: 40,
          ),
          onClick: () {
            share(
              socialPlatform: SocialMediaType.email,
              text: text,
              urlShare: urlProductToShare,
              productId: productId,
            );
            //////////////////////////////
            FirebaseAnalyticsService.logEventForSession(
              eventName: AnalyticsEventsConst.buttonClicked,
              executedEventName:
                  AnalyticsExecutedEventNameConst.shareWithTelegramButton,
            );
          },
        ),
        /*  buildSocialButton(
              icon: FaIcon(
                FontAwesomeIcons.instagram,
                color: Color.fromARGB(255, 15, 15, 15),
                size: 40,
              ),
              onClick: () => share(SocialMediaType.instagram, text, urlShare))*/
      ],
    ),
  );
}

Widget buildSocialButton(
        {required FaIcon icon, required VoidCallback onClick}) =>
    InkWell(
      child: Container(
        width: 64.w,
        height: 64.h,
        child: Center(
          child: icon,
        ),
      ),
      onTap: onClick,
    );
