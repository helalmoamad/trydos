import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../common/constant/configuration/elastic_url_routes.dart';
import '../../../common/constant/configuration/stories_url_routes.dart';

enum ServerName { chat, market, stories, location, cloudinary, gemini, elastic }

//todo make the return value dynamic to return the cloudinary as String
Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.chat:
      return ChatUrls.baseUri;
    case ServerName.market:
      return MarketUrls.baseUri;
    case ServerName.stories:
      return StoriesUrls.baseUri;
    case ServerName.elastic:
      return ElasticUrls.baseUri;
    case ServerName.location:
      return Uri.parse('http://ip-api.com');
    case ServerName.cloudinary:
      return CloudinaryUrls.baseUri;
    case ServerName.gemini:
      return Uri.parse("https://api.gemini.com");
  }
}

String? getServerToken(ServerName serverName) {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName) {
    case ServerName.chat:
      return prefsRepository.chatToken;
    case ServerName.market:
      return prefsRepository.marketToken;
    case ServerName.stories:
      return prefsRepository.storiesToken;
    case ServerName.elastic:
      return null;
    case ServerName.location:
      return null;
    case ServerName.cloudinary:
      return null;
    case ServerName.gemini:
      return null;
  }
}
