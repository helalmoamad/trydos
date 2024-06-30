import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/configuration/chat_url_routes.dart';
import 'package:trydos/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../common/constant/configuration/stories_url_routes.dart';

enum ServerName { chat, market, stories, location, cloudinary }

//todo make the return value dynamic to return the cloudinary as String
Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.chat:
      return ChatUrls.baseUri;
    case ServerName.market:
      return MarketUrls.baseUri;
    case ServerName.stories:
      return StoriesUrls.baseUri;
    case ServerName.location:
      return Uri.parse('http://ip-api.com');
    case ServerName.cloudinary:
      return CloudinaryUrls.baseUri;
  }
}

String? getServerToken(ServerName serverName) {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName) {
    case ServerName.chat:
      return prefsRepository.chatToken;
    case ServerName.market:
      return "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzQxMDlkNTRkYWZiNDgzNTYyNDRmOGQ4NzRmZjZkMTNjNjM0MDFjNmViNTk4NmUzNTZkMDIwYzIwOWQ2YzY0NzZiZTE0YWMyNTk3Mjg2ZGEiLCJpYXQiOjE3MTk0OTA2NjUuNzkwMjQ3LCJuYmYiOjE3MTk0OTA2NjUuNzkwMjQ5LCJleHAiOjE3NTEwMjY2NjUuNzc3MzIxLCJzdWIiOiI0OTQxIiwic2NvcGVzIjpbXX0.ka-fQ_6CbxuwyJr8v7pQSGiJzFdANIA5yu3f4t2XEoSV3Z3Z2WXKi9GzQq98OkP20nvz4b6XRFVYtjXnEUIu3BLTQdXdBalnDmjZbWmP7vChop0WtI6rGs4z06ImyeXhX9SqmwMIVhHm_l1taqK7yR4_8JtzwqOKskn6t7_xgNJZn6DLIeiZmlj2C68OvGiae8SS_1K9xTvWLcXNtTjauams5MTu1Lf2gApSfpa9BljA-7chweLgWnRgMgI_hzM6Qx0ikUHbJDXe8JwwkDmIa9dOP79bRJF6Dh6GvMhOmFgTUf0cwx40DAsaCj2u3WYLeIkMpZm9JupyOIn09MEIQWD71eWrliQzI5K9ZAAcH4qov3FRfoNNJ8htBD0Ds-T5PbMPIcNQM6POrtvLBPRUcWMH0i-t0JeJCfG7wy9aeEv7_B7vLILH2XSKGpu9mCUMJOevNW8gxfGqCiWkJgyfsNdc-u5AnoCzwztNoaVTVe68mVCreLHuS6-hwex40J-nNu1pe5hVT_hKiYgRJGYIRPP9hK2TyZkPQ5VHuwY6tIIG5T0rn2WeHaNiuHAsah3VQjBTjrehb3VPMuE3tdcqptThSXm8XejFffMmoEE7atQTglTL-1VkCcf2K1pko6PGcSqjMPaXzIvZVujZqA-PitpZxGCrk1PErhLXPxz96Gg";
    case ServerName.stories:
      return prefsRepository.storiesToken;
    case ServerName.location:
      return null;
    case ServerName.cloudinary:
      return null;
  }
}
