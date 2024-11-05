import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as geminis;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';

class SearchWithImageRelatedGemini {
  static void SelecteImageForSearch(
      {required BuildContext context, required bool fromSearch}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GalleryAndCameraDialogWidget(
          onChooseFileFromGalleryAction: (AssetEntity? assetEntity) async {
            if (assetEntity != null) {
              File file = (await assetEntity.originFile)!;
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');

              if (fileType[0] != 'image') {
                Fluttertoast.showToast(
                  fontSize: 18,
                  timeInSecForIosWeb: 3,
                  msg: "the video file is not supported",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  textColor: Colors.white,
                );
                /////////////////////////////
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.programmingEvent,
                  executedEventName:
                      AnalyticsExecutedEventNameConst.videoNotSupported,
                );
              } else {
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.buttonClicked,
                  executedEventName: AnalyticsExecutedEventNameConst
                      .confirmUploadSearchImageButton,
                );
              }
              final Uint8List imageBytes = file.readAsBytesSync();
              final geminis.Gemini gemini = geminis.Gemini.instance;
              GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                  fromSearch: fromSearch,
                  sendRequestToGeminiStatus: SendRequestToGeminiStatus.loading,
                  theReplyFromGemini: ""));

              await gemini
                  .textAndImage(
                      text: LanguageService.languageCode == "ar"
                          ? " حدد ماذا يوجد في هذه الصورة بكلمة واحدة فقط بصيغة المفرد الغائب الاجابة بالعربي"
                          : "Identify what's in this picture with just one word in the singular absent answer in English",
                      images: [
                        imageBytes
                      ])
                  .then((value) {

            GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
            fromSearch: fromSearch,
            sendRequestToGeminiStatus:
            SendRequestToGeminiStatus.success,
            theReplyFromGemini:
            value?.content?.parts?[0].text?.split(".").first ??
            value?.content?.parts?[0].text ??
            ""));

            FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.programmingEvent,
            executedEventName: AnalyticsExecutedEventNameConst
                .uploadSearchImageSuccess,
            );
            })
                  .onError(
                    (error, stackTrace) {
                      GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                          fromSearch: fromSearch,
                          sendRequestToGeminiStatus:
                              SendRequestToGeminiStatus.failure,
                          theReplyFromGemini: ""));

                      if (error.toString().contains("Failed host")) {
                        Fluttertoast.showToast(
                            fontSize: 18,
                            timeInSecForIosWeb: 3,
                            msg: "the internet is not available ",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            textColor: Colors.white);
                        return;
                      }
                      if (error
                          .toString()
                          .contains("The request was manually cancelled")) {
                        Fluttertoast.showToast(
                            fontSize: 18,
                            timeInSecForIosWeb: 3,
                            msg: "time out ",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            textColor: Colors.white);
                        return;
                      }
                      print("3333333333333333333333############${error}");
                      Fluttertoast.showToast(
                          msg: "this service is not available in your Country ",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          textColor: Colors.white,
                          fontSize: 18,
                          timeInSecForIosWeb: 3);

            FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.programmingEvent,
            executedEventName:
            AnalyticsExecutedEventNameConst.uploadSearchImageFailed,
            );
                    },
                  )
                  .timeout(
                      Duration(
                        seconds: 20,
                      ), onTimeout: () {
                    gemini.cancelRequest();
                     GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                        fromSearch: fromSearch,
                        sendRequestToGeminiStatus:
                            SendRequestToGeminiStatus.failure,
                        theReplyFromGemini: ""),
                  );
                  /////////////////////////////
                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.programmingEvent,
                    executedEventName:
                        AnalyticsExecutedEventNameConst.uploadSearchImageFailed,
                  );
                },
              );
            }
          },
          onChooseFileFromCameraAction: (File? file) async {
            if (file != null) {
              String mimeStr = lookupMimeType(file.absolute.path) ?? '';
              var fileType = mimeStr.split('/');
              if (fileType[0] != 'image') {
                Fluttertoast.showToast(
                  fontSize: 18,
                  timeInSecForIosWeb: 3,
                  msg: "the video file is not supported",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  textColor: Colors.white,
                );
                /////////////////////////////
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.programmingEvent,
                  executedEventName:
                      AnalyticsExecutedEventNameConst.videoNotSupported,
                );
              } else {
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.buttonClicked,
                  executedEventName: AnalyticsExecutedEventNameConst
                      .confirmUploadSearchImageButton,
                );
              }
              final Uint8List imageBytes = file.readAsBytesSync();
              final geminis.Gemini gemini = geminis.Gemini.instance;
              GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                  fromSearch: fromSearch,
                  sendRequestToGeminiStatus: SendRequestToGeminiStatus.loading,
                  theReplyFromGemini: ""));
              await gemini
                  .textAndImage(
                      text: LanguageService.languageCode == "ar"
                          ? "اعطني كلمة واحد ماذا يوجد هذه الصورة"
                          : "give me only word about what do you see in this image ",
                      images: [
                        imageBytes
                      ])
                  .then((value) { GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                      fromSearch: fromSearch,
                      sendRequestToGeminiStatus:
                          SendRequestToGeminiStatus.success,
                      theReplyFromGemini:
                          value?.content?.parts?[0].text?.split(".").first ??
                              value?.content?.parts?[0].text ??
                              ""),
                );
                /////////////////////////////
                FirebaseAnalyticsService.logEventForSession(
                  eventName: AnalyticsEventsConst.programmingEvent,
                  executedEventName:
                      AnalyticsExecutedEventNameConst.uploadSearchImageSuccess,
                );
              }).onError(
                (error, stackTrace) {
                  print(
                      "*******************************&%^&**(*&^%${error}#******************************TTTTTTTTTTTTTTTTTTTTTTtoo");

                    GetIt.I<HomeBloc>().add(ReplyFromGeminiEvent(
                        fromSearch: fromSearch,
                        sendRequestToGeminiStatus:
                            SendRequestToGeminiStatus.failure,
                        theReplyFromGemini: ""));

                  if (error.toString().contains("Failed host")) {
                    Fluttertoast.showToast(
                        fontSize: 18,
                        timeInSecForIosWeb: 3,
                        msg: "the internet is not available ",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        textColor: Colors.white);
                    return;
                  }
                  if (error
                      .toString()
                      .contains("The request was manually cancelled")) {
                    Fluttertoast.showToast(
                        fontSize: 18,
                        timeInSecForIosWeb: 3,
                        msg: "time out ",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        textColor: Colors.white);
                    return;
                  }
                  Fluttertoast.showToast(
                      fontSize: 18,
                      timeInSecForIosWeb: 1,
                      msg: "this service is not available in your Country ",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      textColor: Colors.white);
                  //////////////////////////////////////
                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.programmingEvent,
                    executedEventName:
                        AnalyticsExecutedEventNameConst.uploadSearchImageFailed,
                  );
                },
              ).timeout(
                Duration(
                  seconds: 20,
                ),
                onTimeout: () {
                  gemini.cancelRequest();
                  GetIt.I<HomeBloc>().add(
                    ReplyFromGeminiEvent(
                      fromSearch: fromSearch,
                        sendRequestToGeminiStatus:
                            SendRequestToGeminiStatus.failure,
                        theReplyFromGemini: ""),
                  );
                  //////////////////////////////////////
                  FirebaseAnalyticsService.logEventForSession(
                    eventName: AnalyticsEventsConst.programmingEvent,
                    executedEventName:
                        AnalyticsExecutedEventNameConst.uploadSearchImageFailed,
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
