import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/camera_profile.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/crope_image.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// أطوار شاشة الصورة — خمسةُ ألواحٍ في شاشةٍ واحدة.
enum _PhotoStage { empty, picking, uploading, preview, saved }

/// صورة الحساب — خمسةُ ألواح XD في شاشةٍ واحدة.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/PhotoScreen.tsx`:
///
/// >   `Home Page – 10`  فارغة: المربّع 350 × 350 (زاوية 30) برمز المستخدم
/// >                     الرماديّ، و«اختر» و«التقط صورة»، والبطاقة الرماديّة
/// >                     تحتهما؛
/// >   `Home Page – 12`  أثناء الاختيار: نافذةٌ بيضاء بظلٍّ علويٍّ ناعم تصعد
/// >                     من y 120 ما دام منتقي الهاتف مفتوحاً؛
/// >   `Home Page – 13`  أثناء الرفع: علامةُ try الرماديّة تدور في المربّع،
/// >                     و«يُرفع صورة الحساب …» تحتها؛
/// >   `Home Page – 14`  المعاينة: الصورة (خطّ أبيض 1.5، ظلّ 0 3 3 بـ16%)
/// >                     و«إضافة وحفظ»؛
/// >   `Home Page – 15`  بعد الحفظ: الصورة مع «اختر» و«التقط صورة» و«إزالة».
///
/// والويب لا يرفع شيئاً — «التصميم ينتظر الموافقة» — وعندنا الرفع حقيقيّ:
/// `UploadUserPhotoCloudinaryEvent` للصورة، و`UpdateProfileEvent(image:
/// "def.png")` للإزالة، وهو منطق `AddPhotoProfilePage` نفسه. والاختيار من
/// المعرض يمرّ بقاصّ الصورة (`CopperImage`) كما كان، والالتقاط بكاميرا
/// التطبيق (`CameraProfile`).
class PhotoPageV2 extends StatefulWidget {
  const PhotoPageV2({super.key});

  @override
  State<PhotoPageV2> createState() => _PhotoPageV2State();
}

class _PhotoPageV2State extends State<PhotoPageV2>
    with SingleTickerProviderStateMixin {
  late final HomeBloc _home;
  final PrefsRepository _prefs = GetIt.I<PrefsRepository>();

  /// الصورة المقصوصة التي ينتظرها الحفظ — يملؤها `CopperImage`.
  final ValueNotifier<File?> _draft = ValueNotifier<File?>(null);
  final ValueNotifier<bool> _cameraOpen = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _saveVisible = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _newImage = ValueNotifier<bool>(false);

  /// دورانُ علامة الرفع: دورةٌ كاملة كلَّ 2.4 ثانية، بسرعةٍ ثابتة.
  late final AnimationController _spin;

  _PhotoStage _stage = _PhotoStage.empty;
  bool _showWhy = true;
  List<CameraDescription> _cameras = <CameraDescription>[];

  /// المربّع 350 × 350 على (40، 120)، 40 من الحافّتين.
  static const double _boxY = 120;
  static const double _boxX = 40;
  static const double _boxH = 350;
  static const double _boxRadius = 30;

  /// صفُّ الإجراءات على y 490 (20 تحت المربّع)، ونصُّه على خطّ الأساس 527.
  static const double _actionsY = 490;
  static const double _labelBaseline = 527;

  @override
  void initState() {
    super.initState();
    _home = BlocProvider.of<HomeBloc>(context);
    _home.add(UpdateProfileEvent(changeStatusToInit: true));
    _stage = _hasPhoto ? _PhotoStage.saved : _PhotoStage.empty;
    _draft.addListener(_onDraft);
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _draft.removeListener(_onDraft);
    _draft.dispose();
    _cameraOpen.dispose();
    _saveVisible.dispose();
    _newImage.dispose();
    _spin.dispose();
    super.dispose();
  }

  bool get _hasPhoto =>
      (_prefs.myProfilePhoto ?? '').isNotEmpty &&
      _prefs.myProfilePhoto != 'def.png';

  /// وصلت صورةٌ من القاصّ أو الكاميرا: اللوح 13 ثمّ 14.
  void _onDraft() {
    if (_draft.value == null) return;
    setState(() => _stage = _PhotoStage.preview);
  }

  Future<void> _choose() async {
    setState(() => _stage = _PhotoStage.picking);
    final AssetEntity? asset = await HelperFunctions.getAssetFromGallery(
      context,
    );
    if (!mounted) return;
    if (asset == null) {
      setState(
        () => _stage = _hasPhoto ? _PhotoStage.saved : _PhotoStage.empty,
      );
      return;
    }
    if (asset.type == AssetType.video) {
      showWarningMessage(context, 'only photo');
      setState(
        () => _stage = _hasPhoto ? _PhotoStage.saved : _PhotoStage.empty,
      );
      return;
    }
    final File? file = await asset.originFile;
    if (!mounted || file == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CopperImage(
          image: file,
          visibleNewImage: _newImage,
          visiblePersonPhoto: _draft,
          visibleSave: _saveVisible,
          visiblecamera: _cameraOpen,
        ),
      ),
    );
    if (!mounted) return;
    if (_draft.value == null) {
      setState(
        () => _stage = _hasPhoto ? _PhotoStage.saved : _PhotoStage.empty,
      );
    }
  }

  Future<void> _takePhoto() async {
    _cameras = await availableCameras();
    if (!mounted) return;
    _cameraOpen.value = true;
    setState(() {});
  }

  void _cancel() {
    _draft.value = null;
    setState(() => _stage = _hasPhoto ? _PhotoStage.saved : _PhotoStage.empty);
  }

  void _save() {
    final File? file = _draft.value;
    if (file == null) return;
    setState(() => _stage = _PhotoStage.uploading);
    _home.add(UploadUserPhotoCloudinaryEvent(file, false));
  }

  void _remove() {
    _home.add(UpdateProfileEvent(image: 'def.png'));
    _draft.value = null;
    setState(() => _stage = _PhotoStage.empty);
  }

  @override
  Widget build(BuildContext context) {
    // كاميرا التطبيق تفتح شاشتها كما كانت.
    if (_cameraOpen.value && _cameras.isNotEmpty) {
      return CameraProfile(
        _cameras,
        _draft,
        _cameraOpen,
        _newImage,
        _saveVisible,
        // صفحةٌ كاملة لا صندوق 406: الصفحة القديمة تضعها داخل مربّع الصورة،
        // ونحن نفتحها شاشةً.
        fullScreen: true,
      );
    }

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (HomeState p, HomeState c) =>
          p.uploadUserPhotoCloudinaryStatus !=
          c.uploadUserPhotoCloudinaryStatus,
      listener: (BuildContext context, HomeState state) {
        if (state.uploadUserPhotoCloudinaryStatus ==
            UploadUserPhotoCloudinaryStatus.success) {
          _draft.value = null;
          setState(() => _stage = _PhotoStage.saved);
        } else if (state.uploadUserPhotoCloudinaryStatus ==
            UploadUserPhotoCloudinaryStatus.failure) {
          setState(() => _stage = _PhotoStage.preview);
        }
      },
      child: _page(),
    );
  }

  Widget _page() {
    final bool showCancel =
        _stage == _PhotoStage.picking ||
        _stage == _PhotoStage.uploading ||
        _stage == _PhotoStage.preview;

    return Stack(
      children: <Widget>[
        XdScreenPage(
          header: XdScreenHeader(
            title: LocaleKeys.profile_photo.tr(),
            nudge: 1,
            onBack: () => Navigator.of(context).maybePop(),
            action: showCancel ? LocaleKeys.cancel.tr() : null,
            onAction: _cancel,
          ),
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 771 .. 895 في الملفّ: 37 فوق الأسفل.
              if (_showWhy && _stage == _PhotoStage.empty)
                Padding(
                  padding: EdgeInsets.only(bottom: 37.h),
                  // البطاقة نفسها التي ترسمها شاشة العناوين: الملفّ يُمرّر
                  // لها العنوان والفقرة نفسيهما هنا أيضاً.
                  child: XdWhyCard(
                    onClose: () => setState(() => _showWhy = false),
                  ),
                ),
              if (_stage == _PhotoStage.preview)
                XdWideButton(label: LocaleKeys.add_save.tr(), onTap: _save),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_box(), _underBox()],
          ),
        ),
        // اللوح 12: نافذةٌ بيضاء تصعد من y 120 ما دام المنتقي مفتوحاً.
        if (_stage == _PhotoStage.picking) _pickingSheet(),
      ],
    );
  }

  /// المربّع. الفارغ والرافع يتقاسمان المظهر الرماديّ بخطّ 0.5؛ والصورة
  /// تأخذ الخطّ الأبيض والظلّ.
  Widget _box() {
    final bool showPhoto =
        _stage != _PhotoStage.uploading &&
        (_draft.value != null || (_stage == _PhotoStage.saved && _hasPhoto));
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (_boxY - kXdBodyY).h,
        start: _boxX.w,
      ),
      child: Container(
        width: Xd.fill(_boxX),
        height: _boxH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(_boxRadius.r),
          border: Border.all(
            color: showPhoto ? XdColors.white : XdColors.line,
            width: showPhoto ? 1.5 : 0.5,
          ),
          boxShadow: showPhoto
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 3.h),
                    blurRadius: 3.r,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: _boxBody(showPhoto),
      ),
    );
  }

  Widget _boxBody(bool showPhoto) {
    if (_stage == _PhotoStage.uploading) {
      // العلامة تدور ما دامت الصورة تُرفع: 151 × 151 في مركز المربّع.
      return Center(
        child: RotationTransition(
          turns: _spin,
          child: const XdSvg(
            'uploadingMark',
            folder: kXdSharedSvg,
            w: 151,
            h: 150.99,
          ),
        ),
      );
    }
    if (showPhoto) {
      return _draft.value != null
          ? Image.file(_draft.value!, fit: BoxFit.cover, width: double.infinity)
          : MyCachedNetworkImage(
              imageUrl: _prefs.myProfilePhoto ?? '',
              width: Xd.fill(_boxX),
              height: _boxH.h,
              imageFit: BoxFit.cover,
              radius: 0,
            );
    }
    // رمز المستخدم الرماديّ على (104.68، 162.45): يحفظ مسافته عن مركز
    // المربّع، فيُوسَّط ويُزاح.
    // رمز المستخدم الرماديّ على (104.68، 162.45) من اللوح — أي 64.68 من
    // حافّة المربّع اليسرى. والملفّ يحفظ مسافته عن **مركز** المربّع
    // (`fromCentre`)، فيبقى موسَّطاً على شاشةٍ أضيق بدل أن يفيض.
    return Stack(
      children: <Widget>[
        Positioned(
          left: Xd.fill(_boxX) / 2 - (_boxH / 2 - 64.68).w,
          top: (162.45 - _boxY).h,
          child: const XdSvg(
            'avatarBig',
            folder: kXdSharedSvg,
            w: 221.01,
            h: 264.71,
          ),
        ),
      ],
    );
  }

  /// تحت المربّع: إمّا سطرُ الرفع، وإمّا صفُّ الإجراءات.
  Widget _underBox() {
    if (_stage == _PhotoStage.uploading) {
      return Padding(
        padding: EdgeInsets.only(top: (_actionsY - 470).h),
        child: SizedBox(
          width: 1.sw,
          height: 18.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const XdSvg('uploadingIcon', folder: kXdSharedSvg, w: 18),
              SizedBox(width: 6.w),
              XdText(
                LocaleKeys.uploading_profile_photo.tr(),
                size: 14,
                color: XdColors.hint,
              ),
            ],
          ),
        ),
      );
    }

    final bool saved = _stage == _PhotoStage.saved && _hasPhoto;
    // أيقونات 20 × 20 على y 490، ونصوصٌ 11 على خطّ الأساس 527، كلٌّ موسَّطٌ
    // تحت أيقونته، والأيقونات 88 متباعدة. وإجراءان يتوسّطان على 167 و255 —
    // فالزوج 4 يسارَ الوسط في الملفّ، ومن هنا الحشوة. وثلاثةٌ على 126 و214
    // و303: الصفّ بكسلٌ يسارَ الوسط، و«إزالة» بكسلٌ أبعدُ يميناً.
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (_actionsY - 470).h,
        end: (saved ? 2 : 8).w,
      ),
      child: SizedBox(
        width: 1.sw,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _action('choose', 20, 20, LocaleKeys.choose.tr(), _choose),
            SizedBox(width: 28.w),
            _action(
              'takePhoto',
              20,
              20,
              LocaleKeys.take_photo.tr(),
              _takePhoto,
            ),
            if (saved) ...<Widget>[
              SizedBox(width: 28.w),
              _action(
                'remove',
                17.24,
                20.99,
                LocaleKeys.remove.tr(),
                _remove,
                nudge: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _action(
    String icon,
    double w,
    double h,
    String label,
    VoidCallback onTap, {
    double nudge = 0,
  }) {
    return XdTap(
      scale: 0.92,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: nudge.w),
        child: SizedBox(
          width: 60.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              XdSvg(icon, folder: kXdSharedSvg, w: w, h: h),
              Padding(
                padding: EdgeInsets.only(
                  top: (_labelBaseline - 11 - _actionsY - h).h,
                ),
                // `OverflowBox` يأخذ حجمه من `constraints.biggest`،
                // و`Column` يُعطي أبناءه ارتفاعاً غير محدود — فيلزم حدٌّ،
                // وهو صندوق سطر النصّ.
                child: SizedBox(
                  height: Xd.lineBox(11).h,
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    child: XdText(label, size: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// اللوح 12: نافذةٌ بيضاء حافّتُها العليا على y 120، بظلٍّ علويٍّ ناعم.
  /// وتترك اللمسات تمرّ فوقها فيبقى «إلغاء» في الترويسة عاملاً.
  Widget _pickingSheet() {
    return Positioned(
      left: 0,
      right: 0,
      top: (_boxY - Xd.statusBar).h + MediaQuery.paddingOf(context).top,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: XdColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(XdSheet.radius.r),
              topRight: Radius.circular(XdSheet.radius.r),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x1A000000),
                offset: Offset(0, -3.h),
                blurRadius: 10.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
