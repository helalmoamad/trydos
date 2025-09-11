import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';

import 'dart:async';

class StarRatingProductWidget extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final bool isInteractive;
  final Color starColor;
  final Color emptyStarColor;
  final double itemSize;
  final double itemWidth;
  final double svgWidth;
  final double itemHeight;
  final double widgetWidth;
  final double widgetHeight;
  const StarRatingProductWidget({
    Key? key,
    this.initialRating = 0.0,
    required this.itemHeight,
    required this.widgetWidth,
    required this.widgetHeight,
    required this.itemWidth,
    required this.svgWidth,
    required this.onRatingChanged,
    required this.itemSize,
    this.emptyStarColor = Colors.white,
    this.isInteractive = true,
    this.starColor = const Color(0xFF402CDD),
  }) : super(key: key);

  @override
  State<StarRatingProductWidget> createState() =>
      _StarRatingProductWidgetState();
}

class _StarRatingProductWidgetState extends State<StarRatingProductWidget> {
  late double _currentRating;

  Timer? _debounceTimer;

  // إضافة ValueNotifier للتحكم في حالة الزر
  late ValueNotifier<bool> _isCommentEmptyNotifier;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;

    // تهيئة ValueNotifier
    _isCommentEmptyNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();

    _isCommentEmptyNotifier.dispose();
    super.dispose();
  }

  // دالة للتحقق من أن التعليق فارغ أم لا

  @override
  void didUpdateWidget(StarRatingProductWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  void _debouncedRatingUpdate(double rating) {
    // إلغاء Timer السابق إذا كان موجود
    _debounceTimer?.cancel();

    // إنشاء Timer جديد لمدة ثانية واحدة
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      widget.onRatingChanged(_currentRating);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widgetWidth,
      height: widget.widgetHeight,
      child: RatingBar.builder(
        initialRating: _currentRating,
        maxRating: 5,
        wrapAlignment: WrapAlignment.center,
        allowHalfRating: true,
        itemSize: widget.itemSize,
        ignoreGestures: !widget.isInteractive,
        itemBuilder: (context, index) {
          // حساب التقييم الحالي لهذه النجمة
          final starValue = index + 1.0;
          final isFullStar = _currentRating >= starValue;
          final isHalfStar =
              _currentRating >= (starValue - 0.5) && _currentRating < starValue;

          if (isFullStar || isHalfStar) {
            // نجمة ممتلئة أو نصف ممتلئة
            return Container(
              width: widget.itemWidth, // منطقة لمس أكبر
              height: widget.itemHeight,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starFilledSvg,
                  width: widget.svgWidth,
                  colorFilter: ColorFilter.mode(
                    widget.starColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          } else {
            return Container(
              width: widget.itemWidth, // منطقة لمس أكبر
              height: widget.itemHeight,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starOutlineSvg,
                  width: widget.svgWidth,
                ),
              ),
            );
          }
        },
        onRatingUpdate: (rating) {
          setState(() {
            _currentRating = rating;
          });
          _debouncedRatingUpdate(rating);
        },
      ),
    );
  }
}
