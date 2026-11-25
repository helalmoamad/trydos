import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/features/authentication/presentation/pages/qr_account_import.dart';
import 'package:trydos/generated/locale_keys.g.dart';

class QrLoginScannerPage extends StatefulWidget {
  const QrLoginScannerPage({super.key});

  @override
  State<QrLoginScannerPage> createState() => _QrLoginScannerPageState();
}

class _QrLoginScannerPageState extends State<QrLoginScannerPage> {
  late final MobileScannerController _controller;
  bool _isProcessing = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    Future.microtask(() async {
      final granted = await _ensureCameraPermission();
      if (!mounted) return;
      if (granted) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _controller.start();
      } else {
        setState(() {
          _permissionDenied = true;
        });
        showWarningMessage(
          context,
          LocaleKeys.camera_permission_required_message.tr(),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    String? rawValue;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        rawValue = value;
        break;
      }
    }
    if (rawValue == null) return;

    setState(() => _isProcessing = true);

    // المنطقُ نفسُه، في `qr_account_import.dart` — تتقاسمه هذه الصفحةُ
    // ونافذةُ QR في التصميم الجديد.
    final bool imported = await importQrAccount(rawValue);
    if (!mounted) return;
    if (imported) {
      showSuccessMessage(
        context,
        LocaleKeys.account_import_success_message.tr(),
      );
      Navigator.of(context).pop(true);
      return;
    }
    showWarningMessage(context, LocaleKeys.qr_invalid_code_message.tr());
    setState(() => _isProcessing = false);
  }

  Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      return false;
    }
    status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _retryPermissionRequest() async {
    final granted = await _ensureCameraPermission();
    if (!mounted) return;
    if (granted) {
      setState(() {
        _permissionDenied = false;
      });
      await _controller.start();
    } else {
      showWarningMessage(
        context,
        LocaleKeys.camera_permission_still_denied.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(LocaleKeys.qr_login_screen_title.tr()),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                _isProcessing
                    ? LocaleKeys.qr_processing_message.tr()
                    : LocaleKeys.qr_instruction_message.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: CustomPaint(painter: _ScannerOverlayPainter()),
            ),
          ),
          if (_permissionDenied)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        LocaleKeys.qr_permission_overlay_message.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryPermissionRequest,
                      child: Text(LocaleKeys.try_again.tr()),
                    ),
                  ],
                ),
              ),
            ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const overlaySize = 260.0;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: overlaySize,
      height: overlaySize,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
