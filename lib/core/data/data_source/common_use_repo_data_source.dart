import 'package:injectable/injectable.dart';

import '../../../common/constant/configuration/cloudinary_url_routes.dart';
import '../../../service/local_notification_service.dart';
import '../../../service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import '../../api/client_config.dart';
import '../../api/methods/detect_server.dart';
import '../../api/methods/post.dart';
import '../model/upload_file_cloudinary_response.dart';
@injectable
class CommonUseRemoteDataSource
{


  Future<UploadFileCloudinaryResponseModel> uploadCloudinaryFile(
      Map<String, dynamic> params) {
    PostClient<UploadFileCloudinaryResponseModel> uploadCloudinaryFile =
    PostClient<UploadFileCloudinaryResponseModel>(
      whenComplete1:

      params['isWhenComplete']?
      (() {
        LocalNotificationService().uploadingNotification(0, 0, false);
      }):null,
      onSendProgress:
          params['isWhenComplete']?
          (count, total) {
            LocalNotificationService().uploadingNotification(total, count, true);
      }:null,
      requestPrams: RequestConfig<UploadFileCloudinaryResponseModel>(
        endpoint: CloudinaryEndPoints.uploadEP,
        data: params['data'],
        response: ResponseValue<UploadFileCloudinaryResponseModel>(
            fromJson: (response) =>
                UploadFileCloudinaryResponseModel.fromJson(response)),
      ),
      serverName: ServerName.cloudinary,
    );
    // uploadStory.call();
    return uploadCloudinaryFile();
  }

}