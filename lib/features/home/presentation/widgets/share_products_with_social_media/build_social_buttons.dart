import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trydos/features/home/presentation/widgets/share_products_with_social_media/social_media_type.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

Widget buildSocialButtons(
    {required String text,
    required String productSlugForULr,
    required String productId,
    required String currentColor,
    required String currentSize}) {
  String urlProductToShare =
      "${dotenv.env['WEB_CALLS_URL']!}/tr-${LanguageService.languageCode == "ar" ? "ar" : LanguageService.languageCode == "tr" ? "tr" : "en"}/products/$productSlugForULr" +
          (currentColor.length > 1 || currentSize.length > 1 ? "?" : "") +
          (currentColor.length > 1 ? "color=$currentColor" : "") +
          (currentSize.length > 1 ? "&size=$currentSize" : "");
  return Card(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialButton(
          icon: const FaIcon(
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
            // FirebaseAnalyticsService.logEventForSession(
            //   eventName: AnalyticsEventsConst.buttonClicked,
            //   executedEventName:
            //       AnalyticsButtonsEventNameConst.shareWithFacebookButton,
            // );
          },
        ),
        buildSocialButton(
          icon: const FaIcon(
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
            // FirebaseAnalyticsService.logEventForSession(
            //   eventName: AnalyticsEventsConst.buttonClicked,
            //   executedEventName:
            //       AnalyticsButtonsEventNameConst.shareWithWhatsappButton,
            // );
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
          icon: const FaIcon(
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
            // FirebaseAnalyticsService.logEventForSession(
            //   eventName: AnalyticsEventsConst.buttonClicked,
            //   executedEventName:
            //       AnalyticsButtonsEventNameConst.shareWithTelegramButton,
            // );
          },
        ),
        buildSocialButton(
          icon: const FaIcon(
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
            // FirebaseAnalyticsService.logEventForSession(
            //   eventName: AnalyticsEventsConst.buttonClicked,
            //   executedEventName:
            //       AnalyticsButtonsEventNameConst.shareWithTelegramButton,
            // );
          },
        ),
        buildSocialButton(
          icon: const FaIcon(
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
            // FirebaseAnalyticsService.logEventForSession(
            //   eventName: AnalyticsEventsConst.buttonClicked,
            //   executedEventName:
            //       AnalyticsButtonsEventNameConst.shareWithTelegramButton,
            // );
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
