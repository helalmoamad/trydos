import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// شاشةُ اختيار الموقع على الخريطة.
///
/// بطاقةُ الملفّ (`Home Page – 94`) تعرض الخريطة صغيرةً ولا تُحرّر فيها؛
/// واختيارُ النقطة يجري على شاشةٍ كاملة كما في صفحات الدفع، ثمّ يُعاد الموضع
/// إلى النموذج.
///
/// الدبّوس ثابتٌ في مركز الشاشة وتتحرّك الخريطة تحته — وهي الطريقة التي
/// يعرفها المستخدم من شاشة عنوان التوصيل.
class MapPickerPageV2 extends StatefulWidget {
  const MapPickerPageV2({super.key, this.start});

  /// الموضع الذي تفتح عليه، أو `null` فمن موقع الجهاز.
  final LatLng? start;

  @override
  State<MapPickerPageV2> createState() => _MapPickerPageV2State();
}

class _MapPickerPageV2State extends State<MapPickerPageV2> {
  GoogleMapController? _map;
  LatLng? _at;

  /// وسطُ تركيا، حيث يفتح الملفّ خريطته.
  static const LatLng _fallback = LatLng(39.925533, 32.866287);

  @override
  void initState() {
    super.initState();
    _at = widget.start;
    if (widget.start == null) _locate();
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    final loc.Location service = loc.Location();
    try {
      if (!await service.serviceEnabled() && !await service.requestService()) {
        return;
      }
      loc.PermissionStatus granted = await service.hasPermission();
      if (granted == loc.PermissionStatus.denied) {
        granted = await service.requestPermission();
      }
      if (granted != loc.PermissionStatus.granted) return;
      final loc.LocationData where = await service.getLocation();
      final double? lat = where.latitude;
      final double? lng = where.longitude;
      if (lat == null || lng == null || !mounted) return;
      final LatLng at = LatLng(lat, lng);
      setState(() => _at = at);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(at, 16));
    } catch (e) {
      devLog('map_picker_page_v2: locate failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XdColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            XdScreenHeader(
              title: LocaleKeys.locate_your_location_on_map.tr(),
              small: true,
              shadow: true,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _at ?? _fallback,
                      zoom: _at == null ? 5 : 16,
                    ),
                    onMapCreated: (GoogleMapController c) => _map = c,
                    // الخريطة عرضٌ أصليّ (PlatformView)، ولا تصلها الإيماءة
                    // ما لم تُطلَب صراحةً: فلتر يُبقيها في حلبة الإيماءات مع
                    // ما فوقها فلا يصل إلى الخريطة سحبٌ ولا تقريب.
                    // و`EagerGestureRecognizer` يُسلّمها اللمسةَ فوراً.
                    gestureRecognizers:
                        const <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            EagerGestureRecognizer.new,
                          ),
                        },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    // الخريطة تتحرّك تحت الدبّوس، فموضعُها هو المركز.
                    onCameraMove: (CameraPosition p) => _at = p.target,
                    onCameraIdle: () => setState(() {}),
                  ),
                  // الدبّوس ثابتٌ في المركز، ويرتفع بنصف طوله ليقع طرفُه
                  // على النقطة.
                  IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 37.53.h),
                      child: const XdSvg(
                        'pin',
                        folder: kXdSharedSvg,
                        w: 28.96,
                        h: 37.53,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 20.w,
                    bottom: 20.h,
                    child: XdTap(
                      scale: 0.92,
                      onTap: _locate,
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: XdColors.white,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0x29000000),
                              offset: Offset(0, 2.h),
                              blurRadius: 4.r,
                            ),
                          ],
                        ),
                        child: const XdSvg(
                          'navigation',
                          folder: kXdSharedSvg,
                          w: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            XdWideButton(
              label: LocaleKeys.your_location_on_map.tr(),
              disabled: _at == null,
              onTap: () => Navigator.of(context).pop(_at),
            ),
          ],
        ),
      ),
    );
  }
}
