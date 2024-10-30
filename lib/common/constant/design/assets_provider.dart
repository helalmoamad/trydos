extension AssetsUtils on String {
  /// assets/svg/$this.svg
  String get svg => 'assets/svg/$this.svg';

  String get flagSvg => 'assets/flags/$this.svg';

  /// assets/images/$this.png
  String get png => 'assets/images/$this.png';

  /// assets/images/$this.jpg
  String get jpg => 'assets/images/$this.jpg';

  /// assets/animations/$this.json
  String get json => 'assets/animations/$this.json';

  /// assets/animations/$this.flr
  String get flr => 'assets/animations/$this.flr';

  /// assets/animations/$this.riv
  String get riv => 'assets/animations/$this.riv';
}

abstract class AppAssets {
  /// region SVG Section
  static String get logoSvg => 'logo'.svg;
  static String get countItemSvg => 'countitem'.svg;
  static String get sizeSvg => 'size'.svg;
  static String get adresswSvg => 'adressw'.svg;
  static String get logoIconSvg => 'logo_icon'.svg;
  static String get inactiveLogoIconSvg => 'inactive_logo_icon'.svg;
  static String get logoTextActiveSvg => 'logo_text_active'.svg;
  static String get logoTextInactiveSvg => 'logo_text_inactive'.svg;
  static String get manActiveSvg => 'man_active'.svg;
  static String get manInactiveSvg => 'man_inactive'.svg;
  static String get womenActiveSvg => 'woman_active'.svg;
  static String get womenInactiveSvg => 'woman_inactive'.svg;
  static String get homeActiveSvg => 'home_active'.svg;
  static String get homeInactiveSvg => 'home_inactive'.svg;
  static String get childrenActiveSvg => 'children_active'.svg;
  static String get childrenInactiveSvg => 'children_inactive'.svg;
  static String get electronicActiveSvg => 'electronic_active'.svg;
  static String get electronicInactiveSvg => 'electronic_inactive'.svg;
  static String get cartSvg => 'cart'.svg;
  static String get favoriteSvg => 'favorite'.svg;
  static String get sizeIconSvg => 'size_icon'.svg;
  static String get coloredSizeIconSvg => 'colored_size_icon'.svg;
  static String get recyclingSvg => 'recycling'.svg;
  static String get searchSvg => 'search'.svg;
  static String get cameraSvg => 'camera'.svg;
  static String get settingsSvg => 'settings'.svg;
  static String get arrowsSvg => 'arrows'.svg;
  static String get chatSvg => 'chat'.svg;
  static String get activeChatSvg => 'chat_active'.svg;
  static String get qualityBadgeSvg => 'quality_badge'.svg;
  static String get verifiedBadgeSvg => 'verified_badge'.svg;
  static String get colorPickerSvg => 'color_picker'.svg;
  static String get chromeIconSvg => 'chrome_icon'.svg;
  static String get indicatorSvg => 'indicator'.svg;
  static String get dressSvg => 'dress'.svg;
  static String get emptySvg => 'empty'.svg;
  static String get colorIndicatorSvg => 'color_indicator'.svg;
  static String get textSvg => 'text'.svg;
  static String get freeShippingSvg => 'free_shipping'.svg;
  static String get freeReturnSvg => 'free_return'.svg;
  static String get arrivalOfShippingSvg => 'arrival_of_shipping'.svg;

  static String get filtersSvg => 'filters'.svg;
  static String get sortingSvg => 'sorting'.svg;
  static String get starBadgeSvg => 'star_badge'.svg;
  static String get searchOutlinedReversedSvg => 'search_outlined_reversed'.svg;

  static String get singleChatSvg => 'single_chat'.svg;
  static String get chatNotificationSvg => 'chat_notification'.svg;
  static String get singleChatOutlinedSvg => 'single_chat_outlined'.svg;
  static String get singleChatOutlinedActiveSvg =>
      'single_chat_outlined_active'.svg;
  static String get callsOutlinedSvg => 'calls_outlined'.svg;
  static String get callsSvg => 'calls'.svg;
  static String get callsOutlinedActiveSvg => 'calls_outlined_active'.svg;
  static String get unreadMessageSvg => 'unread_message'.svg;
  static String get sentPictureSvg => 'sent_picture'.svg;
  static String get sentVideoSvg => 'sent_video'.svg;
  static String get sentAudioSvg => 'sent_audio'.svg;
  static String get messageReadArrowSvg => 'message_read'.svg;
  static String get messageReadArrowWithOpacitySvg =>
      'message_read_with_opacity'.svg;
  static String get messageDeliveredArrowSvg => 'message_delivered'.svg;
  static String get messageSentArrowSvg => 'message_sent'.svg;
  static String get storyOutlinedSvg => 'story_outlined'.svg;
  static String get storyFilledSvg => 'story_filled'.svg;
  static String get forwardArrowRight => 'arrow_right'.svg;
  static String get singleChatFilledActiveSvg =>
      'single_chat_filled_active'.svg;
  static String get archiveSvg => 'archive'.svg;
  static String get binSvg => 'bin'.svg;
  static String get minusMarkSvg => 'minus_mark'.svg;
  static String get pinSvg => 'pin'.svg;
  static String get unreadSvg => 'unread'.svg;
  static String get muteSvg => 'mute'.svg;
  static String get unMuteSvg => 'unmute'.svg;
  static String get callMissingSvg => 'missing_call'.svg;
  static String get callIncomeSvg => 'income_call'.svg;
  static String get callOutgoingSvg => 'outgoing_call'.svg;
  static String get callingSvg => 'calling'.svg;
  static String get ringingSvg => 'ringing'.svg;
  static String get inCallSvg => 'inCall'.svg;
  static String get backFromCallSvg => 'back_from_call'.svg;
  static String get backIconArrowSvg => 'back_icon_arrow'.svg;
  static String get endCallSvg => 'end_call'.svg;
  static String get partyCozSvg => 'party_coz'.svg;
  static String get refundSvg => 'refund'.svg;
  static String get airplaneSvg => 'airplan'.svg;
  static String get locationSvg => 'location_icon'.svg;
  static String get deliveryPathSvg => 'delivery_path'.svg;
  static String get fastPackingIconSvg => 'fast_packing_icon'.svg;
  static String get fastPackingManIconSvg => 'fast_packing_man_icon'.svg;
  static String get polyesterSvg => 'polyester'.svg;
  static String get malokanSvg => 'malokan'.svg;
  static String get logoActiveSvg => 'logo_active'.svg;
  static String get bottomBarLogoActiveSvg => 'bottom_bar_logo_active'.svg;
  static String get logoTextSvg => 'logo_text'.svg;

  static String get callMutedSvg => 'call_muted'.svg;
  static String get callUnMutedSvg => 'call_unmute'.svg;
  static String get videoCallSvg => 'video_call'.svg;
  static String get cancelVideoCallSvg => 'cancel_video_call'.svg;
  static String get makeCallSvg => 'make_call'.svg;
  static String get makeVideoCallSvg => 'make_video_call'.svg;
  static String get pauseSvg => 'pause'.svg;
  static String get playSvg => 'play'.svg;
  static String get voiceReceivedSvg => 'voice_received'.svg;
  static String get voicePlayedSvg => 'voice_played'.svg;
  static String get missedCallInChatSvg => 'missed_call_in_chat'.svg;
  static String get missedVideoCallInChatSvg =>
      'missing_video_call_in_chat'.svg;
  static String get forwardedSvg => 'forwarded'.svg;
  static String get addStickersSvg => 'add_stickers'.svg;
  static String get replyOnMessageSvg => 'reply_on_message'.svg;
  static String get closeSvg => 'close'.svg;
  static String get sendMessageSvg => 'send_message'.svg;
  static String get takePictureSvg => 'take_picture'.svg;
  static String get recordVoiceSvg => 'record_voice'.svg;
  static String get recordingVoiceSvg => 'recording_voice'.svg;
  static String get replyButtonLogoSvg => 'reply_button_logo'.svg;
  static String get messageFailedSvg => 'message_failed'.svg;

  static String get copyIconSvg => 'copy_icon'.svg;
  static String get removeIconSvg => 'remove_icon'.svg;
  static String get editIconSvg => 'edit_icon'.svg;
  static String get notificationIconSvg => 'notification_icon'.svg;
  static String get notificationOutlinedIconSvg =>
      'notification_outlined_icon'.svg;
  static String get goBackIconSvg => 'go_back_icon'.svg;
  static String get addToGroupSvg => 'add_to_group'.svg;
  static String get backButtonSvg => 'back_button'.svg;
  static String get supportSvg => 'support'.svg;
  static String get sandClockSvg => 'sand_clock'.svg;
  static String get documentSvg => 'document'.svg;
  static String get gallerySvg => 'gallery'.svg;
  static String get imageGallerySvg => 'image_gallery'.svg;
  static String get videoGallerySvg => 'video_gallery'.svg;
  static String get fileGallerySvg => 'file_gallery'.svg;
  static String get saveToGallerySvg => 'save_to_gallery'.svg;
  static String get lastMessageImageSvg => 'last_message_image_icon'.svg;
  static String get lastMessageVideoSvg => 'last_message_video_icon'.svg;
  static String get lastMessageAudioSvg => 'last_message_audio_icon'.svg;
  static String get replaySwappedSvg => 'replay_icon_on_swap'.svg;
  static String get cancelSvg => 'cancel'.svg;
  static String get editPenSvg => 'edit_pen'.svg;
  static String get enterSvg => 'enter'.svg;
  static String get phoneCallSvg => 'phone_call'.svg;
  static String get phoneCallOutlinedSvg => 'phone_call_outlined'.svg;
  static String get phoneOtpSvg => 'phone_otp'.svg;
  static String get privacySvg => 'privacy'.svg;
  static String get registerInfoSvg => 'register_info'.svg;
  static String get smsSvg => 'sms'.svg;
  static String get submitArrowSvg => 'submit_arrow'.svg;
  static String get whatsappSvg => 'whatsapp'.svg;
  static String get verifiedNumberSvg => 'verified_number'.svg;
  static String get termsSvg => 'terms'.svg;
  static String get storyFilmSvg => 'story_film'.svg;
  static String get bagsSvg => 'bags'.svg;
  static String get searchOutlinedSvg => 'search_outlined'.svg;
  static String get realCameraSvg => 'real_camera'.svg;
  static String get microphoneSvg => 'microphone'.svg;
  static String get trendingSvg => 'trending'.svg;
  static String get searchHistorySvg => 'search_history'.svg;
  static String get favoriteActiveSvg => 'favourite-active'.svg;
  static String get storeIconInactiveSvg => 'store_icon_inactive'.svg;
  static String get mangoSvg => 'mango'.svg;
  static String get eyeSvg => 'eye'.svg;
  static String get quickOfferSvg => 'quick_offer'.svg;
  static String get trydosTextSvg => 'trydos_text'.svg;
  static String get backArrowArabic => 'back_arrow_arabic'.svg;
  static String get bagSvg => 'bag'.svg;
  static String get plusMarkSvg => 'plus_mark'.svg;
  static String get chatMarkSvg => 'chat_mark'.svg;
  static String get chatMarkActiveSvg => 'chat_mark_active'.svg;
  static String get shareSvg => 'share'.svg;
  static String get moreOptionSvg => 'more_option'.svg;
  static String getFlagPath(String name) => name.flagSvg;

  ///endregion

//...
//...

  ///! JPG  Section
  ///! PNG  Section
  static String get image1Png => 'image1'.png;
  static String get image2Png => 'image2'.png;
  static String get color1Png => 'color1'.png;
  static String get address2Png => 'address2'.png;
  static String get color2Png => 'color2'.png;
  static String get color3Png => 'color3'.png;
  static String get trydosWelcomePng => 'trydos_welcome'.png;

  static String get profileJpg => 'profile'.jpg;
  static String get backgroundJpg => 'background'.jpg;
  static String get halloweenJpg => 'Halloween'.jpg;

  /// region JSON Section

  ///endregion
  ///! FLR  Section
}

/*
import 'dart:ui' as ui;

//Add this CustomPaint widget to the Widget Tree
CustomPaint(
    size: Size(WIDTH, (WIDTH*0.2410958904109589).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
    painter: RPSCustomPainter(),
)

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {

Path path_0 = Path();
    path_0.moveTo(size.width*0.9452048,size.height*1.000002);
    path_0.lineTo(size.width*0.05479147,size.height*1.000002);
    path_0.cubicTo(size.width*0.04739446,size.height*1.000002,size.width*0.04021849,size.height*0.9939933,size.width*0.03346295,size.height*0.9821421);
    path_0.cubicTo(size.width*0.02693817,size.height*0.9706953,size.width*0.02107839,size.height*0.9543084,size.width*0.01604626,size.height*0.9334370);
    path_0.cubicTo(size.width*0.01101438,size.height*0.9125662,size.width*0.007063447,size.height*0.8882609,size.width*0.004303422,size.height*0.8611963);
    path_0.cubicTo(size.width*0.001446261,size.height*0.8331777,size.width*-0.000002430856,size.height*0.8034138,size.width*-0.000002430856,size.height*0.7727320);
    path_0.lineTo(size.width*-0.000002430856,size.height*0.7272821);
    path_0.lineTo(size.width*0.02348138,size.height*0.7272821);
    path_0.cubicTo(size.width*0.03184477,size.height*0.7272821,size.width*0.03970741,size.height*0.7143606,size.width*0.04562110,size.height*0.6908972);
    path_0.cubicTo(size.width*0.05153480,size.height*0.6674334,size.width*0.05479159,size.height*0.6362356,size.width*0.05479159,size.height*0.6030512);
    path_0.lineTo(size.width*0.05479159,size.height*0.3969613);
    path_0.cubicTo(size.width*0.05479159,size.height*0.3637764,size.width*0.05153480,size.height*0.3325791,size.width*0.04562110,size.height*0.3091158);
    path_0.cubicTo(size.width*0.03970741,size.height*0.2856524,size.width*0.03184477,size.height*0.2727309,size.width*0.02348138,size.height*0.2727309);
    path_0.lineTo(size.width*-0.000002430856,size.height*0.2727309);
    path_0.lineTo(size.width*-0.000002430856,size.height*0.2272805);
    path_0.cubicTo(size.width*-0.000002430856,size.height*0.1965987,size.width*0.001446261,size.height*0.1668348,size.width*0.004303422,size.height*0.1388162);
    path_0.cubicTo(size.width*0.007063447,size.height*0.1117516,size.width*0.01101438,size.height*0.08744633,size.width*0.01604626,size.height*0.06657546);
    path_0.cubicTo(size.width*0.02107839,size.height*0.04570407,size.width*0.02693817,size.height*0.02931719,size.width*0.03346295,size.height*0.01787040);
    path_0.cubicTo(size.width*0.04021849,size.height*0.006019155,size.width*0.04739446,size.height*0.00001037446,size.width*0.05479147,size.height*0.00001037446);
    path_0.lineTo(size.width*0.9452048,size.height*0.00001037446);
    path_0.cubicTo(size.width*0.9526012,size.height*0.00001037446,size.width*0.9597767,size.height*0.006019155,size.width*0.9665322,size.height*0.01787040);
    path_0.cubicTo(size.width*0.9730568,size.height*0.02931719,size.width*0.9789168,size.height*0.04570407,size.width*0.9839491,size.height*0.06657546);
    path_0.cubicTo(size.width*0.9889816,size.height*0.08744839,size.width*0.9929325,size.height*0.1117537,size.width*0.9956923,size.height*0.1388162);
    path_0.cubicTo(size.width*0.9985498,size.height*0.1668363,size.width*0.9999987,size.height*0.1966002,size.width*0.9999987,size.height*0.2272805);
    path_0.lineTo(size.width*0.9999987,size.height*0.7727320);
    path_0.cubicTo(size.width*0.9999987,size.height*0.8034123,size.width*0.9985498,size.height*0.8331762,size.width*0.9956923,size.height*0.8611963);
    path_0.cubicTo(size.width*0.9929325,size.height*0.8882588,size.width*0.9889816,size.height*0.9125641,size.width*0.9839491,size.height*0.9334370);
    path_0.cubicTo(size.width*0.9789168,size.height*0.9543084,size.width*0.9730568,size.height*0.9706953,size.width*0.9665322,size.height*0.9821421);
    path_0.cubicTo(size.width*0.9597767,size.height*0.9939933,size.width*0.9526012,size.height*1.000002,size.width*0.9452048,size.height*1.000002);
    path_0.close();

Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
paint_0_fill.color = Color(0xfffff9b4).withOpacity(1.0);
canvas.drawPath(path_0,paint_0_fill);

}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
}
}
 */