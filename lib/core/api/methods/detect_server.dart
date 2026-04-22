import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:trydos/common/constant/configuration/dashBoard_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/media_server_url_routes.dart';
import 'package:trydos/common/constant/configuration/wallet_url_routes.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../common/constant/configuration/elastic_url_routes.dart';
import '../../../common/constant/configuration/stories_url_routes.dart';

enum ServerName {
  chat,
  market,
  stories,
  location,
  cloudinary,
  gemini,
  elastic,
  dashBoard,
  webApp,
  comment,
  get_comment_token,
  wallet,
  mediaServer,
}

//todo make the return value dynamic to return the cloudinary as String
Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.chat:
      return ChatUrls.baseUri;
    case ServerName.market:
      return MarketUrls.baseUri;
    case ServerName.wallet:
      return WalletUrls.baseUri;
    case ServerName.dashBoard:
      return DashBoardUrls.baseUri;
    case ServerName.stories:
      return StoriesUrls.baseUri;
    case ServerName.elastic:
      return ElasticUrls.baseUri;
    case ServerName.location:
      return Uri.parse('https://ipwho.is/');
    case ServerName.cloudinary:
      return CloudinaryUrls.baseUri;
    case ServerName.webApp:
      return WebUrls.baseUri;
    case ServerName.comment:
      return WebUrls.baseUri;
    case ServerName.gemini:
      return Uri.parse("https://api.gemini.com");
    case ServerName.get_comment_token:
      return Uri.parse(dotenv.env['COMMENT_TOKEN_URL']!);
    case ServerName.mediaServer:
      return MediaServerUrls.baseUri;
  }
}

String? getServerToken(ServerName serverName) {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName) {
    case ServerName.chat:
      return prefsRepository.chatToken;
    case ServerName.market:
      return prefsRepository.marketToken;
    case ServerName.dashBoard:
      return prefsRepository.marketToken;
    case ServerName.get_comment_token:
      return prefsRepository.tokenForComment;
    case ServerName.stories:
      return prefsRepository.storiesToken;
    case ServerName.wallet:
      return prefsRepository.walletToken;
    case ServerName.comment:
      return prefsRepository.tokenForComment;
    case ServerName.elastic:
      return null;
    case ServerName.location:
      return null;
    case ServerName.cloudinary:
      return null;
    case ServerName.webApp:
      return null;
    case ServerName.gemini:
      return null;
    case ServerName.mediaServer:
      return null;
  }
}
