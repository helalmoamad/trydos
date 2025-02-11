import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
        }, onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
        }, onWebResourceError: (WebResourceError error) {
          setState(() {
            _isLoading = false;
            _hasError = true; // Show error UI
          });
        }),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _reloadPage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadPage,
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            if (!_hasError) WebViewWidget(controller: _controller),
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
                      onPressed: _reloadPage,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
