import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../common/constant/configuration/cloudinary_url_routes.dart';
import '../../../common/constant/configuration/media_server_url_routes.dart';
import '../../../service/notification_service/notification_service/handle_notification/local_notification_service.dart';
import '../../api/client_config.dart';
import '../../api/methods/detect_server.dart';
import '../../api/methods/post.dart';
import '../../domin/repositories/prefs_repository.dart';
import '../model/bulk_upload_response.dart';
import '../model/excel_upload_response.dart';
import '../model/upload_file_cloudinary_response.dart';
import '../model/upload_file_media_server_response.dart';
import '../model/upload_ticket_response.dart';
import '../../../features/chat/data/models/upload_file_response_model.dart';

@injectable
class CommonUseRemoteDataSource {
  /// ترويسات طلبات الرفع: التذكرة وحدها.
  ///
  /// لا يُمرَّر `Content-Type` عمداً — يتولّى Dio ضبط `multipart/form-data`
  /// مع الحدّ الفاصل (boundary) بنفسه، وضبطه يدوياً يفسد الطلب.
  Map<String, dynamic> _ticketHeader(String ticket) => {
    MediaServerUrls.ticketHeader: ticket,
  };

  void Function(bool)? _finishedCallback(Map<String, dynamic> params) =>
      params['usingOnUploadingFinishedFunction'] == true
      ? ((bool isUploadingSuccess) {
          LocalNotificationService().uploadingNotification(
            0,
            0,
            false,
            isUploadingSuccess,
          );
        })
      : null;

  void Function(int, int)? _progressCallback(Map<String, dynamic> params) =>
      params['usingSendProgressFunction'] == true
      ? (count, total) {
          LocalNotificationService().uploadingNotification(
            total,
            count,
            true,
            false,
          );
        }
      : null;

  /// الخطوة الأولى: `POST /gated/ticket`.
  ///
  /// تُمرَّر ترويسة `Authorization: Bearer <access_token>` و`Content-Type:
  /// application/json`. حقول الجسم كلها اختيارية: `folder` و`count` و`story`،
  /// وهي **مقيَّدة بالتذكرة** — أي أنّ ما يُرسل مع الرفع لاحقاً يُتجاهَل.
  Future<UploadTicketResponseModel> mintUploadTicket(
    Map<String, dynamic> params,
  ) {
    final String? accessToken = GetIt.I<PrefsRepository>().marketToken;

    PostClient<UploadTicketResponseModel> mintTicket =
        PostClient<UploadTicketResponseModel>(
          requestPrams: RequestConfig<UploadTicketResponseModel>(
            endpoint: MediaServerEndPoints.ticketEP,
            data: params['data'],
            extraHeaders: {
              'Authorization': 'Bearer ${accessToken ?? ''}',
              'Content-Type': 'application/json',
            },
            response: ResponseValue<UploadTicketResponseModel>(
              fromJson: (response) =>
                  UploadTicketResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.mediaServer,
        );
    return mintTicket();
  }

  /// الخطوة الثانية (أ): `POST /gated/upload` — ملف واحد.
  Future<UploadFileMediaServerResponseModel> uploadMediaServerFile(
    Map<String, dynamic> params,
  ) {
    PostClient<UploadFileMediaServerResponseModel> uploadMediaServer =
        PostClient<UploadFileMediaServerResponseModel>(
          onUploadingFinished: _finishedCallback(params),
          onSendProgress: _progressCallback(params),
          requestPrams: RequestConfig<UploadFileMediaServerResponseModel>(
            receiveTimeout: const Duration(hours: 1),
            sendTimeout: const Duration(hours: 1),
            endpoint: MediaServerEndPoints.uploadEP,
            data: params['data'],
            extraHeaders: _ticketHeader(params['ticket']),
            response: ResponseValue<UploadFileMediaServerResponseModel>(
              fromJson: (response) =>
                  UploadFileMediaServerResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.mediaServer,
        );
    return uploadMediaServer();
  }

  /// الخطوة الثانية (ب): `POST /gated/upload/bulk` — صور فقط،
  /// وعدد الأجزاء يطابق `count` المقيَّد بالتذكرة.
  Future<BulkUploadResponseModel> uploadMediaServerBulk(
    Map<String, dynamic> params,
  ) {
    PostClient<BulkUploadResponseModel> uploadBulk =
        PostClient<BulkUploadResponseModel>(
          onUploadingFinished: _finishedCallback(params),
          onSendProgress: _progressCallback(params),
          requestPrams: RequestConfig<BulkUploadResponseModel>(
            receiveTimeout: const Duration(hours: 1),
            sendTimeout: const Duration(hours: 1),
            endpoint: MediaServerEndPoints.bulkUploadEP,
            data: params['data'],
            extraHeaders: _ticketHeader(params['ticket']),
            response: ResponseValue<BulkUploadResponseModel>(
              fromJson: (response) => BulkUploadResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.mediaServer,
        );
    return uploadBulk();
  }

  /// الخطوة الثانية (ج): `POST /gated/upload/excel` — بحدّ أعلى 512 ميغابايت.
  Future<ExcelUploadResponseModel> uploadMediaServerExcel(
    Map<String, dynamic> params,
  ) {
    PostClient<ExcelUploadResponseModel> uploadExcel =
        PostClient<ExcelUploadResponseModel>(
          onUploadingFinished: _finishedCallback(params),
          onSendProgress: _progressCallback(params),
          requestPrams: RequestConfig<ExcelUploadResponseModel>(
            receiveTimeout: const Duration(hours: 1),
            sendTimeout: const Duration(hours: 1),
            endpoint: MediaServerEndPoints.excelUploadEP,
            data: params['data'],
            extraHeaders: _ticketHeader(params['ticket']),
            response: ResponseValue<ExcelUploadResponseModel>(
              fromJson: (response) =>
                  ExcelUploadResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.mediaServer,
        );
    return uploadExcel();
  }

  /// الخطوة الثانية (د): `POST /gated/chat/upload_file` — مرفق دردشة واحد
  /// بحدّ أعلى 25 ميغابايت، ويُخزَّن تحت `originals/chat/`.
  ///
  /// انتقل هذا الطلب من خادم الدردشة إلى خادم الميديا، والاستجابة تأتي
  /// بغلاف `{isSuccessful, data:{file_path,...}}` نفسه المستعمل سابقاً.
  Future<UploadFileResponseModel> uploadChatFileGated(
    Map<String, dynamic> params,
  ) {
    PostClient<UploadFileResponseModel> uploadChatFile =
        PostClient<UploadFileResponseModel>(
          onUploadingFinished: _finishedCallback(params),
          onSendProgress: _progressCallback(params),
          requestPrams: RequestConfig<UploadFileResponseModel>(
            receiveTimeout: const Duration(minutes: 5),
            sendTimeout: const Duration(minutes: 5),
            endpoint: MediaServerEndPoints.chatUploadFileEP,
            data: params['data'],
            extraHeaders: _ticketHeader(params['ticket']),
            response: ResponseValue<UploadFileResponseModel>(
              fromJson: (response) => UploadFileResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.mediaServer,
        );
    return uploadChatFile();
  }

  Future<UploadFileCloudinaryResponseModel> uploadCloudinaryFile(
    Map<String, dynamic> params,
  ) {
    PostClient<UploadFileCloudinaryResponseModel> uploadCloudinaryFile =
        PostClient<UploadFileCloudinaryResponseModel>(
          onUploadingFinished: _finishedCallback(params),
          onSendProgress: _progressCallback(params),
          requestPrams: RequestConfig<UploadFileCloudinaryResponseModel>(
            receiveTimeout: const Duration(hours: 1),
            sendTimeout: const Duration(hours: 1),
            endpoint: CloudinaryEndPoints.uploadEP,
            data: params['data'],
            response: ResponseValue<UploadFileCloudinaryResponseModel>(
              fromJson: (response) =>
                  UploadFileCloudinaryResponseModel.fromJson(response),
            ),
          ),
          serverName: ServerName.cloudinary,
        );
    return uploadCloudinaryFile();
  }
}
