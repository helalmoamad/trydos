import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class StarRatingWidget extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final Function(double, String) onRatingChanged;
  final bool isInteractive;
  final Color starColor;
  final Color emptyStarColor;

  const StarRatingWidget({
    Key? key,
    this.initialRating = 0.0,
    this.initialComment = "",
    required this.onRatingChanged,
    this.emptyStarColor = Colors.white,
    this.isInteractive = true,
    this.starColor = const Color(0xFF402CDD),
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _currentRating;
  late double _previousRating;
  Timer? _debounceTimer;

  final TextEditingController _commentController = TextEditingController();

  // إضافة ValueNotifier للتحكم في حالة الزر
  late ValueNotifier<bool> _isCommentEmptyNotifier;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _previousRating = widget.initialRating;
    _commentController.text = widget.initialComment;

    // تهيئة ValueNotifier
    _isCommentEmptyNotifier = ValueNotifier<bool>(true);

    // إضافة listener للتحقق من نص التعليق
    _commentController.addListener(_checkCommentEmpty);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _commentController.removeListener(_checkCommentEmpty);
    _commentController.dispose();
    _isCommentEmptyNotifier.dispose();
    super.dispose();
  }

  // دالة للتحقق من أن التعليق فارغ أم لا
  void _checkCommentEmpty() {
    _isCommentEmptyNotifier.value = (_commentController.text.trim().isEmpty ||
        (_commentController.text == widget.initialComment &&
            _currentRating == widget.initialRating));
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating ||
        widget.initialComment != _commentController.text) {
      _currentRating = widget.initialRating;
      _previousRating = widget.initialRating;
      _commentController.text = widget.initialComment;
    }
  }

  void _debouncedRatingUpdate(double rating) {
    // إلغاء Timer السابق إذا كان موجود
    _debounceTimer?.cancel();

    // إنشاء Timer جديد لمدة ثانية واحدة
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _showCommentBottomSheet();
    });
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ignore: deprecated_member_use
      builder: (context) => WillPopScope(
        onWillPop: () async {
          if (mounted) {
            setState(() {
              _currentRating = _previousRating;
            });
            // إلغاء Timer إذا كان موجود
            _debounceTimer?.cancel();
          }
          return true;
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!mounted) return;
                      setState(() {
                        _currentRating = _previousRating;
                      });
                      _debounceTimer?.cancel();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                LocaleKeys.add_comment_for_rating.tr(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _currentRating,
                minRating: 1,
                allowHalfRating: true,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => SvgPicture.asset(
                  AppAssets.starFilledSvg,
                  width: 24.0,
                  height: 24.0,
                  colorFilter: ColorFilter.mode(
                    widget.starColor,
                    BlendMode.srcIn,
                  ),
                ),
                unratedColor: Colors.grey[400],
                onRatingUpdate: (rating) {
                  if (!mounted) return;
                  setState(() {
                    _currentRating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: LocaleKeys.write_your_comment_here.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.starColor),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (!mounted) return;
                        setState(() {
                          _currentRating = _previousRating;
                        });
                        _debounceTimer?.cancel();
                      },
                      child: Text(
                        LocaleKeys.cancel.tr(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isCommentEmptyNotifier,
                      builder: (context, isCommentEmpty, child) {
                        return ElevatedButton(
                          onPressed: isCommentEmpty
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  if (!mounted) return;
                                  widget.onRatingChanged(
                                      _currentRating, _commentController.text);
                                  _previousRating = _currentRating;
                                  _commentController.clear();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCommentEmpty
                                ? Colors.grey[400]
                                : widget.starColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.initialRating > 0
                                    ? LocaleKeys.edit.tr()
                                    : LocaleKeys.add.tr(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send, size: 18),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SizedBox(
      width: 80,
      height: 26,
      child: RatingBar.builder(
        initialRating: _currentRating,
        maxRating: 5,
        wrapAlignment: WrapAlignment.center,
        allowHalfRating: true,
        itemSize: 16,
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
              width: 20.0, // منطقة لمس أكبر
              height: 20.0,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starFilledSvg,
                  width: 16.0,
                  height: 16.0,
                  colorFilter: ColorFilter.mode(
                    widget.starColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          } else {
            return Container(
              width: 20, // منطقة لمس أكبر
              height: 20,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.starOutlineSvg,
                  width: 16.0,
                  height: 16.0,
                ),
              ),
            );
          }
        },
        onRatingUpdate: (rating) {
          // حفظ التقييم السابق قبل التحديث
          _previousRating = _currentRating;
          setState(() {
            _currentRating = rating;
          });
          _debouncedRatingUpdate(rating);
        },
      ),
    );
  }
}
