
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../common/constant/configuration/stories_url_routes.dart';

enum ServerName{
  chat , market , stories
}

Uri getBaseUriForSpecificServer(ServerName serverName){
  switch (serverName){
    case ServerName.chat : return ChatUrls.baseUri;
    case ServerName.market : return MarketUrls.baseUri;
    case ServerName.stories : return StoriesUrls.baseUri;
  }
}

String? getServerToken(ServerName serverName){
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName){
    case ServerName.chat : return  prefsRepository.chatToken;
    case ServerName.market : return  prefsRepository.marketToken;
    case ServerName.stories : return prefsRepository.storiesToken;
  }
}