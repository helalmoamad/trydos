import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

class AgoraInAppWebView extends StatefulWidget {
  String type;
  String channelId;
  String uId;
  String auth_token;
  String action;
  String message_id;

  AgoraInAppWebView(
      {required this.message_id,
      required this.action,
      required this.type,
      required this.channelId,
      required this.auth_token,
      required this.uId,
      super.key});

  @override
  State<AgoraInAppWebView> createState() => _AgoraInAppWebViewState();
}

class _AgoraInAppWebViewState extends State<AgoraInAppWebView> {
  late WebViewController controller;

  @override
  void initState() {
    // Per

    // final flutterWebviewPlugin = new FlutterWebviewPlugin();
    debugPrint("asdafsd{${widget.channelId}");
    debugPrint("asdafsd{${widget.message_id}");
    debugPrint("asdafsd{${widget.uId}");
    debugPrint("asdafsd{${widget.type}");
    debugPrint("asdafsd{${widget.action}");
    debugPrint("asdafsd{${widget.auth_token}");
    Uri baseUrl = Uri.parse('https://webdev.trydos.com');
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri(queryParameters: {
        'uid': widget.uId,
        'authToken': widget.auth_token,
        'message_id': widget.message_id,
        'type': widget.type,
        'action': widget.action,
        'ch_id': widget.channelId
      }, host: baseUrl.host, scheme: baseUrl.scheme, path: '/call_direct'));

    super.initState();
  }

  int loading = 0;
  late InAppWebViewController inAppWebViewController;

  @override
  Widget build(BuildContext context) {
    Uri baseUrl = Uri.parse('https://webdev.trydos.com');

    String source = Uri(queryParameters: {
      'uid': widget.uId,
      'authToken': widget.auth_token,
      'message_id': widget.message_id,
      'type': widget.type,
      'action': widget.action,
      'ch_id': widget.channelId
    }, host: baseUrl.host, scheme: baseUrl.scheme, path: '/call_direct')
        .toString();
    String urlBasd = source;
    log("asfsdsd${source}");

    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialOptions: InAppWebViewGroupOptions(
              // android: ,
              crossPlatform: InAppWebViewOptions(

                mediaPlaybackRequiresUserGesture: false,
 javaScriptCanOpenWindowsAutomatically: true,
               ),
            ),

            // onPermissionRequest: (controller, permissionRequest) async {
            //   return await PermissionResponse(
            //       action: PermissionResponseAction.GRANT,
            //       resources: [
            //         PermissionResourceType.CAMERA_AND_MICROPHONE,
            //         PermissionResourceType.PROTECTED_MEDIA_ID,
            //   ]);
            // },
            initialUrlRequest: URLRequest(url: WebUri(source)),
            androidOnPermissionRequest: (controller, origin, resources) async {
              return await PermissionRequestResponse(

                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },

            onProgressChanged: (controller, progress) {
              setState(() {
                loading = progress;
              });
            },
          ),
          if (loading < 100) Center(child: CircularProgressIndicator()),
          Text(
            urlBasd,
            style: TextStyle(color: Colors.teal),
          )
        ],
      ),
    );
  }
}
