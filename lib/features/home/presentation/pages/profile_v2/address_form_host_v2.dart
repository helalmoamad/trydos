import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart'
    as address;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'address_form_page_v2.dart';
import 'map_picker_page_v2.dart';

/// ما يُشغّل [AddressFormPageV2]: الخريطة والترميز العكسيّ وأحداث الحفظ.
///
/// الصفحة تصميمٌ خالص، وهذه الودجة تملأ خاناتها بمنطقنا:
///
///  - **الخريطة** `GoogleMap` حقيقيّة داخل بطاقة الملفّ، ولمسُ الحبّة يأخذ
///    موقع الجهاز ويُحرّك الكاميرا إليه ويُسقط الدبّوس.
///  - **المنطقة** من ترميزٍ عكسيّ (`geocoding`) للنقطة التي حلّ عليها
///    الدبّوس: محافظةٌ ومدينةٌ ودولة. وهذا بديلُ منتقي المستويات الأربعة في
///    الملفّ — لا خدمة له عندنا (`GetProvincesByIsoEvent` يُعيد المحافظات
///    وحدها).
///  - **الحفظ** `AddAddressInfoClassEvent` و`EditAdressInfoClassEvent`،
///    بالحقول نفسها التي يرسلها نموذجُ السلّة.
///
/// وما لم يُربَط لأنّه لا يناسب اللوح: اسم المستلم وهاتفه وهاتفه البديل —
/// لا حقول لها في `– 94`، فتُرسَل كما جاءت في العنوان المُعدَّل، وتبقى فارغةً
/// في الجديد.
class AddressFormHostV2 extends StatefulWidget {
  const AddressFormHostV2({
    super.key,
    required this.countries,
    required this.initialIso,
    this.editing,
  });

  /// الدول المسموحة عندنا — بديلُ الأربع الوهميّة في الويب.
  final List<Country> countries;

  /// رمز الدولة الذي يفتح عليه النموذج.
  final String? initialIso;

  /// العنوان المُعدَّل، أو `null` لعنوانٍ جديد.
  final address.CustomerAddressesInfo? editing;

  @override
  State<AddressFormHostV2> createState() => _AddressFormHostV2State();
}

class _AddressFormHostV2State extends State<AddressFormHostV2> {
  late final TextEditingController _detail;
  late final TextEditingController _title;
  late String? _iso;

  GoogleMapController? _map;
  LatLng? _pin;
  bool _located = false;
  bool _sheetOpen = false;
  bool _busy = false;

  /// ما حلّه الدبّوس: محافظةٌ ومدينةٌ ودولة.
  address.RegionDetails? _region;

  /// مركزُ الخريطة قبل أن يُحدَّد موقع: وسطُ تركيا كما يفتح الملفّ.
  static const LatLng _start = LatLng(39.925533, 32.866287);

  @override
  void initState() {
    super.initState();
    final address.CustomerAddressesInfo? e = widget.editing;
    _detail = TextEditingController(text: e?.addressDetail ?? '');
    _title = TextEditingController(text: e?.address ?? '');
    _iso = e?.iso ?? widget.initialIso;
    _region = e?.regionDetails;
    _located = e != null;
    final double? lat = double.tryParse(e?.location?.latitude ?? '');
    final double? lng = double.tryParse(e?.location?.longitude ?? '');
    if (lat != null && lng != null) _pin = LatLng(lat, lng);
  }

  @override
  void dispose() {
    _detail.dispose();
    _title.dispose();
    _map?.dispose();
    super.dispose();
  }

  /// سطرُ «اختر من القائمة»: ما حلّه الدبّوس، أو تلميحُ المستويات.
  String get _placeLine {
    final List<String> parts = <String?>[
      _region?.province,
      _region?.city,
      _region?.country,
    ].whereType<String>().where((String e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return LocaleKeys.select_from_list.tr();
    return parts.join(' | ');
  }

  bool get _placeDone => _region != null && (_region?.country ?? '').isNotEmpty;

  /// يفتح شاشة الخريطة، فإن عاد بموضعٍ أسقط الدبّوس وحلّ المنطقة.
  ///
  /// بطاقةُ الملفّ تعرض الخريطة صغيرةً ولا تُحرَّر فيها؛ والاختيارُ يجري على
  /// شاشةٍ كاملة كما في صفحات الدفع — [MapPickerPageV2].
  Future<void> _locate() async {
    final LatLng? at = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(builder: (_) => MapPickerPageV2(start: _pin)),
    );
    if (at == null || !mounted) return;
    setState(() {
      _pin = at;
      _located = true;
    });
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(at, 16));
    await _resolve(at);
  }

  /// ترميزٌ عكسيّ للنقطة — بديلُ منتقي المستويات في الملفّ.
  Future<void> _resolve(LatLng at) async {
    try {
      final List<Placemark> marks = await placemarkFromCoordinates(
        at.latitude,
        at.longitude,
      );
      if (marks.isEmpty || !mounted) return;
      final Placemark m = marks.first;
      setState(() {
        _region = address.RegionDetails(
          country: m.country ?? '',
          province: m.administrativeArea ?? '',
          city: m.locality ?? m.subAdministrativeArea ?? '',
          town: m.subLocality ?? '',
          street: m.street ?? '',
          building: m.name ?? '',
          zip: m.postalCode ?? '',
        );
        if ((m.isoCountryCode ?? '').isNotEmpty) {
          _iso = m.isoCountryCode!.toLowerCase();
        }
      });
    } catch (e) {
      devLog('address_form_host_v2: reverse geocode failed', e);
    }
  }

  Country? get _country {
    final String? iso = _iso?.toLowerCase();
    if (iso == null) return null;
    for (final Country c in widget.countries) {
      if ((c.iso ?? '').toLowerCase() == iso) return c;
    }
    return null;
  }

  Widget? _flagOf(String? iso, double size) {
    if (iso == null || iso.isEmpty) return null;
    return CountryFlag.fromCountryCode(
      iso.toUpperCase(),
      theme: ImageTheme(
        width: size.w,
        height: size.w,
        shape: RoundedRectangle(5.r),
      ),
    );
  }

  void _save() {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);
    final address.CustomerAddressesInfo info = address.CustomerAddressesInfo(
      id: widget.editing?.id,
      address: _title.text.trim(),
      addressDetail: _detail.text.trim(),
      iso: _iso,
      location: address.Location(
        latitude: (_pin?.latitude ?? '').toString(),
        longitude: (_pin?.longitude ?? '').toString(),
      ),
      regionDetails: _region,
      // لا حقول لها في اللوح: تُحفَظ كما جاءت في المُعدَّل، وتبقى فارغةً في
      // الجديد.
      contactInfo: widget.editing?.contactInfo,
      isDefault: widget.editing?.isDefault,
    );
    setState(() => _busy = true);
    bloc.add(
      widget.editing == null
          ? AddAddressInfoClassEvent(addressInfoClassToSave: info)
          : EditAdressInfoClassEvent(
              addressInfoClassToSave: info,
              preIdToEdit: widget.editing!.id ?? 0,
            ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AddressFormPageV2(
      map: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pin ?? _start,
          zoom: _pin == null ? 5 : 16,
        ),
        onMapCreated: (GoogleMapController c) => _map = c,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        // الخريطة في البطاقة معاينةٌ لا تُحرَّر: اللمسُ عليها يفتح شاشة
        // الاختيار، كما تفعل الحبّة.
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        onTap: (LatLng _) => _locate(),
        markers: _pin == null
            ? const <Marker>{}
            : <Marker>{
                Marker(markerId: const MarkerId('pin'), position: _pin!),
              },
      ),
      located: _located,
      onLocate: _locate,
      countryName: _country?.name ?? '',
      countryFlag: _flagOf(_iso, 18),
      onPickCountry: () => setState(() => _sheetOpen = true),
      placeLine: _placeLine,
      placeDone: _placeDone,
      detail: _detail,
      title: _title,
      busy: _busy,
      onSave: _save,
      countrySheetOpen: _sheetOpen,
      countrySheet: CountrySheetV2(
        open: _sheetOpen,
        value: _iso,
        countries: widget.countries
            .where((Country c) => (c.iso ?? '').isNotEmpty)
            .map(
              (Country c) => (
                iso: c.iso!.toLowerCase(),
                name: c.name ?? '',
                flag: _flagOf(c.iso, 30) ?? const SizedBox.shrink(),
              ),
            )
            .toList(),
        onPick: (String iso) => setState(() {
          _iso = iso;
          _sheetOpen = false;
        }),
        onClose: () => setState(() => _sheetOpen = false),
      ),
    );
  }
}
