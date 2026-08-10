import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../common/helper/show_message.dart';
import '../../../../config/theme/typography.dart';
import '../../../../core/utils/extensions/build_context.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../app/app_widgets/gallery_and_camera_dialog_widget.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/my_text_widget.dart';
import '../../domain/use_cases/report_order_product_usecase.dart';
import '../manager/orderBloc/order_bloc.dart';
import '../manager/orderBloc/order_event.dart';
import '../manager/orderBloc/order_state.dart';

/// مجموعة نقاط بلاغ واحدة كما يعرّفها الخادم.
class _ReportGroup {
  const _ReportGroup({
    required this.key,
    required this.titleKey,
    required this.options,
  });

  /// مفتاح المجموعة المُرسَل في `points[i][point]`.
  final String key;

  /// مفتاح الترجمة لعنوان المجموعة.
  final String titleKey;

  /// خيارات المجموعة: مفتاح الإرسال ← مفتاح الترجمة.
  final Map<String, String> options;
}

/// المجموعات الأربع وقيمها — مطابقة لما يقبله الخادم حرفياً.
const List<_ReportGroup> _reportGroups = [
  _ReportGroup(
    key: 'product_quality',
    titleKey: LocaleKeys.report_product_quality,
    options: {
      'damaged': LocaleKeys.report_damaged,
      'not_as_described': LocaleKeys.report_not_as_described,
      'poor_material': LocaleKeys.report_poor_material,
      'wrong_item': LocaleKeys.report_wrong_item,
      'expired': LocaleKeys.report_expired,
    },
  ),
  _ReportGroup(
    key: 'delivery_time',
    titleKey: LocaleKeys.report_delivery_time,
    options: {
      'too_late': LocaleKeys.report_too_late,
      'missed_window': LocaleKeys.report_missed_window,
      'no_eta': LocaleKeys.report_no_eta,
      'faster_than_expected': LocaleKeys.report_faster_than_expected,
    },
  ),
  _ReportGroup(
    key: 'delivery_worker',
    titleKey: LocaleKeys.report_delivery_worker,
    options: {
      'rude': LocaleKeys.report_rude,
      'unprofessional': LocaleKeys.report_unprofessional,
      'no_show': LocaleKeys.report_no_show,
      'asked_extra_fee': LocaleKeys.report_asked_extra_fee,
      'polite': LocaleKeys.report_polite,
    },
  ),
  _ReportGroup(
    key: 'delivery_car',
    titleKey: LocaleKeys.report_delivery_car,
    options: {
      'dirty_vehicle': LocaleKeys.report_dirty_vehicle,
      'no_cooling': LocaleKeys.report_no_cooling,
      'unsafe_handling': LocaleKeys.report_unsafe_handling,
      'no_vehicle': LocaleKeys.report_no_vehicle,
    },
  ),
];

/// لوحة الإبلاغ عن منتج داخل طلب.
///
/// الاختيار متعدّد داخل كل مجموعة، والضغط على خيار مُختار يلغيه. الملاحظة
/// والصورة اختيارتان، وزرّ الإرسال يبقى معطَّلاً حتى يُختار خيار واحد على
/// الأقلّ من أي مجموعة.
class OrderReportPanel extends StatefulWidget {
  const OrderReportPanel({
    super.key,
    required this.scrollController,
    required this.orderId,
    required this.orderDetailId,
    required this.productId,
    required this.orderGroupId,
    required this.onClose,
    required this.onReported,
  });

  final ScrollController scrollController;
  final int orderId;
  final int orderDetailId;
  final int productId;
  final String orderGroupId;

  /// تُستدعى عند الإلغاء وعند نجاح الإرسال.
  final VoidCallback onClose;

  /// تُستدعى **عند النجاح فقط**، قبل الإغلاق: تتيح للصفحة تعليم المنتج
  /// كمُبلَّغ عنه في نسختها المحلّية فتتغيّر البطاقة فوراً بلا إعادة تحميل.
  final VoidCallback onReported;

  @override
  State<OrderReportPanel> createState() => _OrderReportPanelState();
}

class _OrderReportPanelState extends State<OrderReportPanel> {
  /// مفتاح المجموعة ← مفاتيح الخيارات المُختارة منها.
  final Map<String, Set<String>> _selected = {};
  final TextEditingController _noteController = TextEditingController();

  /// لتمرير حقل الملاحظة إلى داخل الشاشة عند فتح لوحة المفاتيح.
  final FocusNode _noteFocusNode = FocusNode();
  final GlobalKey _noteFieldKey = GlobalKey();

  File? _image;

  bool get _canSubmit => _selected.values.any((values) => values.isNotEmpty);

  @override
  void initState() {
    super.initState();
    // الحالة قد تكون success من بلاغ سابق في الجلسة نفسها
    context.read<OrderBloc>().add(const ResetReportOrderProductStatusEvent());

    // لوحة المفاتيح تغطّي الحقل لأنّ اللوحة بارتفاع ثابت: نمرّر إليه بعد
    // ظهورها (الإطار التالي لا يكفي — الحشو السفلي يتحرّك مع حركة اللوحة)
    _noteFocusNode.addListener(() {
      if (!_noteFocusNode.hasFocus) return;
      Future.delayed(const Duration(milliseconds: 300), () {
        final BuildContext? fieldContext = _noteFieldKey.currentContext;
        if (!mounted || fieldContext == null) return;
        Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 0.1,
        );
      });
    });
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _toggleOption(String groupKey, String optionKey) {
    setState(() {
      final Set<String> values = _selected.putIfAbsent(groupKey, () => {});
      // إعادة الضغط تلغي التحديد
      if (!values.remove(optionKey)) values.add(optionKey);
      if (values.isEmpty) _selected.remove(groupKey);
    });
  }

  void _submit() {
    final List<ReportPoint> points = _selected.entries
        .map((e) => ReportPoint(point: e.key, values: e.value.toList()))
        .toList();

    context.read<OrderBloc>().add(
      ReportOrderProductEvent(
        params: ReportOrderProductParams(
          orderId: widget.orderId,
          orderDetailId: widget.orderDetailId,
          productId: widget.productId,
          orderGroupId: widget.orderGroupId,
          points: points,
          note: _noteController.text.trim(),
          image: _image,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    await showDialog<void>(
      context: context,
      builder: (_) => GalleryAndCameraDialogWidget(
        onChooseFileFromGalleryAction: (AssetEntity? assetEntity) async {
          if (assetEntity == null) return;
          final File? picked = await assetEntity.originFile;
          if (picked == null) {
            showMessage(LocaleKeys.error_picking_file.tr(), hasError: true);
            return;
          }
          if (mounted) setState(() => _image = picked);
        },
        onChooseFileFromCameraAction: (File? file) {
          if (file == null) return;
          if (mounted) setState(() => _image = file);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (p, c) =>
          p.reportOrderProductStatus != c.reportOrderProductStatus,
      listener: (context, state) {
        if (state.reportOrderProductStatus == ReportOrderProductStatus.success) {
          widget.onReported();
          widget.onClose();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
              ),
            ),
            SizedBox(height: 16.h),
            MyTextWidget(
              LocaleKeys.report_this_product.tr(),
              style: context.textTheme.titleLarge?.rq.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: MyTextWidget(
                LocaleKeys.report_this_product_subtitle.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.rq.copyWith(
                  color: const Color(0xff8E8E8E),
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                // الحشو السفلي يتبع ارتفاع لوحة المفاتيح، فلا تغطّي المحتوى
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
                  bottom: 16.h + MediaQuery.viewInsetsOf(context).bottom,
                ),
                children: [
                  ..._reportGroups.map(_buildGroup),
                  SizedBox(height: 8.h),
                  _buildNotesField(context),
                  SizedBox(height: 16.h),
                  _buildPhotoSection(context),
                  SizedBox(height: 24.h),
                  _buildSubmitButton(context),
                  SizedBox(height: 12.h),
                  Center(
                    child: InkWell(
                      onTap: widget.onClose,
                      child: MyTextWidget(
                        LocaleKeys.cancel.tr(),
                        style: context.textTheme.titleMedium?.rq.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(_ReportGroup group) {
    final Set<String> selected = _selected[group.key] ?? const {};

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextWidget(
            group.titleKey.tr(),
            style: context.textTheme.titleSmall?.rq.copyWith(
              color: const Color(0xff8E8E8E),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: group.options.entries.map((option) {
              final bool isSelected = selected.contains(option.key);
              return InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => _toggleOption(group.key, option.key),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff402CDD)
                          : Colors.transparent,
                    ),
                  ),
                  child: MyTextWidget(
                    option.value.tr(),
                    style: context.textTheme.titleSmall?.rq.copyWith(
                      fontSize: 12.sp,
                      color: isSelected
                          ? const Color(0xff402CDD)
                          : const Color(0xff505050),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextWidget(
              LocaleKeys.report_additional_notes.tr(),
              style: context.textTheme.titleSmall?.rq.copyWith(fontSize: 12.sp),
            ),
            SizedBox(width: 4.w),
            MyTextWidget(
              LocaleKeys.report_optional.tr(),
              style: context.textTheme.titleSmall?.rq.copyWith(
                fontSize: 11.sp,
                color: const Color(0xff8E8E8E),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          key: _noteFieldKey,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xffE0E0E0)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            minLines: 3,
            style: context.textTheme.titleSmall?.rq.copyWith(fontSize: 12.sp),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: LocaleKeys.report_write_more_details.tr(),
              hintStyle: context.textTheme.titleSmall?.rq.copyWith(
                fontSize: 12.sp,
                color: const Color(0xffAFAFAF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextWidget(
              LocaleKeys.report_add_a_photo.tr(),
              style: context.textTheme.titleSmall?.rq.copyWith(fontSize: 12.sp),
            ),
            SizedBox(width: 4.w),
            MyTextWidget(
              LocaleKeys.report_optional.tr(),
              style: context.textTheme.titleSmall?.rq.copyWith(
                fontSize: 11.sp,
                color: const Color(0xff8E8E8E),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_image == null)
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 70.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xff402CDD), width: 0.5),
              ),
              child: MyTextWidget(
                LocaleKeys.report_add_a_photo.tr(),
                style: context.textTheme.titleSmall?.rq.copyWith(
                  fontSize: 12.sp,
                  color: const Color(0xff402CDD),
                ),
              ),
            ),
          )
        else
          // صورة واحدة فقط: يُستبدل الصندوق بمعاينتها مع زرّ إزالة
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _image!,
                  width: 57.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                child: InkWell(
                  onTap: () => setState(() => _image = null),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14.sp,
                      color: const Color(0xffFF5F61),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (p, c) =>
          p.reportOrderProductStatus != c.reportOrderProductStatus,
      builder: (context, state) {
        final bool isLoading =
            state.reportOrderProductStatus == ReportOrderProductStatus.loading;

        return InkWell(
          // زرّ معطَّل ما لم يُختَر خيار واحد على الأقلّ
          onTap: (!_canSubmit || isLoading) ? null : _submit,
          child: Container(
            width: double.infinity,
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _canSubmit
                  ? const Color(0xff402CDD)
                  : const Color(0xffD4D4D4),
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: isLoading
                ? TrydosLoader(size: 20.w)
                : MyTextWidget(
                    LocaleKeys.report_submit.tr(),
                    style: context.textTheme.titleMedium?.rq.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
