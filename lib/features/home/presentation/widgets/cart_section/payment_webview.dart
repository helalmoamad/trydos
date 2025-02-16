import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/trydos_shimmer_loading.dart';

class PaymentWebview extends StatefulWidget {
  final String url;
  const PaymentWebview({
    super.key,
    required this.url,
  });

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    //////////////////////////
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        await _reloadPage();
      },
    );
  }

  Future<void> _reloadPage() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      webViewController?.loadUrl(
        urlRequest: URLRequest(
          url: await webViewController?.getUrl(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.canPop(context)) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();

              return false;
            }
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await _reloadPage();
                },
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              buildWebView(),
              ///////////////
              if (_isLoading)
                TrydosShimmerLoading(
                  width: 1.sw,
                  logoTextWidth: 30,
                  height: 1.sh,
                  logoTextHeight: 30,
                  circleDimensions: 30,
                  radius: 0,
                ),
              ///////////////
              if (_hasError && !_isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      const Text("Failed to load page. Please try again."),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          _reloadPage();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(
          widget.url,
        ),
      ),
      onWebViewCreated: (controller) {
        webViewController = controller;
        ////////////////////////////////////
        controller.addJavaScriptHandler(
          handlerName: "closeIframe",
          callback: (args) {
            debugPrint("Received 'closeIframe' event from JavaScript!");
            /////////////////////////////
            Navigator.pop(context);
          },
        );
      },
      pullToRefreshController: pullToRefreshController,
      initialSettings: InAppWebViewSettings(
        isInspectable: kDebugMode,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllow: "camera; microphone",
        javaScriptEnabled: true,
        iframeAllowFullscreen: true,
      ),
      onLoadStart: (controller, url) {
        setState(
          () {
            _isLoading = true;
            _hasError = false;
          },
        );
      },
      onLoadStop: (controller, url) async {
        setState(() {
          _isLoading = false;
        });
        /////////////////
        await controller.evaluateJavascript(source: """
            window.addEventListener('message', (event) => {
              if (event.data === 'close-iframe') {
                window.flutter_inappwebview.callHandler('closeIframe');
              }
            });
          """);
      },
      onReceivedError: (controller, request, error) {
        setState(
          () {
            _hasError = true;
            _isLoading = false;
          },
        );
      },
    );
  }
}
