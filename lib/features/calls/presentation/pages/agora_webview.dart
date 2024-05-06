import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_text_widget.dart';
import '../../../chat/presentation/manager/chat_event.dart';

class AgoraWebView extends StatefulWidget {
  String type;
  String channelId;
  String uId;
  String auth_token;
  String action;
  String message_id;

  AgoraWebView(
      {required this.message_id,
      required this.action,
      required this.type,
      required this.channelId,
      required this.auth_token,
      required this.uId,
      super.key});

  @override
  State<AgoraWebView> createState() => _AgoraWebViewState();
}

class _AgoraWebViewState extends State<AgoraWebView> {
  late WebViewController controller;
  late ChatBloc chatBloc;
  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
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

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      chatBloc.add(SendErrorChatToServerEvent(
          error: error.toString(), lastPage: "Agora_Web_View"));
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    Uri baseUrl = Uri.parse('https://webdev.trydos.com');

    String uasd = Uri(queryParameters: {
      'uid': widget.uId,
      'authToken': widget.auth_token,
      'message_id': widget.message_id,
      'type': widget.type,
      'action': widget.action,
      'ch_id': widget.channelId
    }, host: baseUrl.host, scheme: baseUrl.scheme, path: '/call_direct')
        .toString();
    String urlBasd = uasd;
    log("asfsdsd${uasd}");
    controller.setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (change) {
          setState(() {
            urlBasd = change.toString();
          });
          // if (change.url == 'https://youtube.com') Navigator.of(context).pop();
        },
        onProgress: (int progress) {
          setState(() {
            loading = progress;
          });
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          setState(() {
            loading = 100;
          });
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          debugPrint("asdsdfgdgv${request.url}");

          if (request.url.startsWith('https://www.youtube.com')) {
            Navigator.of(context).pop();
          }
// controller.goBack();
// // controller.clear
//             return NavigationDecision.prevent;
//           }
          return NavigationDecision.navigate;
        },
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (loading < 100) Center(child: CircularProgressIndicator()),
          MyTextWidget(
            urlBasd,
            style: TextStyle(color: Colors.teal),
          )
        ],
      ),
    );
  }
}
