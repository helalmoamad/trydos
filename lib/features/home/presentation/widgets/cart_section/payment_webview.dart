import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/trydos_shimmer_loading.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class PaymentWebview extends StatefulWidget {
  final String url;
  final String cartGroupId;
  const PaymentWebview({
    super.key,
    required this.url,
    required this.cartGroupId,
  });

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    LastPagesTracker.push("PaymentWebview Page");
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
    setState(
      () {
        _isLoading = true;
        _hasError = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.canPop(context)) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              /////////////////////////////////////////////
              BlocProvider.of<OrderBloc>(context).add(
                GetOrdersByCartGroupIDEvent(
                  cartGroupId: widget.cartGroupId,
                ),
              );

              return false;
            }
          }
          //////////////////
          BlocProvider.of<OrderBloc>(context).add(
            GetOrdersByCartGroupIDEvent(
              cartGroupId: widget.cartGroupId,
            ),
          );

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
              if (!_hasError) buildWebView(),
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
                          await _reloadPage();
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
            /////////////////////////////
            if (!_isClosing && mounted && Navigator.of(context).canPop()) {
              debugPrint("Received 'closeIframe' event from JavaScript!");
              _isClosing = true;
              Navigator.of(context).pop();
              /////////////////////////////////////////////
              BlocProvider.of<OrderBloc>(context).add(
                GetOrdersByCartGroupIDEvent(
                  cartGroupId: widget.cartGroupId,
                ),
              );
            }
            ///////////////////////////////////
          },
        );
      },
      pullToRefreshController: pullToRefreshController,
      initialSettings: InAppWebViewSettings(
        isInspectable: kDebugMode,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllow: "camera; microphone",
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
