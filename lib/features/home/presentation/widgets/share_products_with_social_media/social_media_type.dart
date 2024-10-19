import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:html/parser.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum SocialMediaType {
  facebook,
  twitter,
  linkedin,
  whatsapp,
  instagram,
  email,
  messanger,
  telegram,
}

Future share(
    {required SocialMediaType socialPlatform,
    required String text,
    required String productId,
    required String urlShare}) async {
  text = parseFragment(text).text ?? "";
  print(text);
  final urlShares = Uri.encodeComponent(urlShare);
  final textShares = Uri.encodeComponent(text);

  final urls = {
    SocialMediaType.facebook:
        "https://www.facebook.com/sharer/sharer.php?u=$textShares$urlShare",
    SocialMediaType.messanger: 'http://m.me/?$text',
    SocialMediaType.whatsapp:
        "https://api.whatsapp.com/send/?text=$text \n $urlShares",
    SocialMediaType.telegram: "https://t.me/share/url?url=$text \n $urlShares",
    SocialMediaType.instagram: 'https://instagram.com/share?text=$text',
    SocialMediaType.email:
        "mailto:?subject=Shared Preoduct&body=$text $urlShares",
    SocialMediaType.twitter:
        "https://twitter.com/intent/tweet?text=$text \n $urlShares",
  };
  final url = urls[socialPlatform];
  if (await canLaunchUrlString(url!)) {
    await launchUrlString(url).then(
      (value) {
        GetIt.I<ChatBloc>().add(IncreaseSharedProductCountOnSocialAppEvent(
            socialMediaName: socialPlatform.name,
            productId: productId,
            sharedCount: 1));
        print(
            "___________________________________________________________________${value}");
      },
    ).catchError((value) {
      print(
          "___________________________________________________________________${value}");
    });
  }
}
