import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_screenutil not required here
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/test_utils/widgets_keys.dart';
import '../blocs/app_bloc/app_state.dart';

class AnimatedSearchBar extends StatefulWidget {
  final double width;
  final TextEditingController textController;
  final int animationDurationInMilli;
  final VoidCallback onSuffixTap;
  final bool rtl;

  final bool autoFocus;
  final void Function(String)? onFieldSubmitted;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final Color? textFieldColor;
  final Color? searchIconColor;
  final Color? textFieldIconColor;
  final List<TextInputFormatter>? inputFormatters;
  final bool boxShadow;
  final Function(String)? onChanged;
  final bool Function() onClickClose;
  final String? suggestion;

  final InputDecoration? searchDecoration;
  final Widget suffixWidget;
  final Widget prefixWidget;
  final FocusNode focusNode;

  final double? height;
  final ValueNotifier<bool>? hideTrendingAndHistory;

  const AnimatedSearchBar({
    Key? key,
    required this.width,
    required this.textController,
    this.color = Colors.white,
    this.textFieldColor = Colors.white,
    this.searchIconColor = Colors.black,
    this.textFieldIconColor = Colors.black,
    required this.onSuffixTap,
    this.animationDurationInMilli = 375,
    this.rtl = false,
    this.searchDecoration,
    this.onChanged,
    this.onFieldSubmitted,
    required this.suffixWidget,
    required this.prefixWidget,
    this.height,
    required this.focusNode,
    this.autoFocus = false,
    this.style,
    this.closeSearchOnSuffixTap = false,
    this.boxShadow = true,
    this.inputFormatters,
    required this.onClickClose,
    this.suggestion,
    this.hideTrendingAndHistory,
  }) : super(key: key);

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  int toggle = 0;
  String textFieldValue = '';
  late AnimationController _con;
  late FocusNode focusNode;
  bool prevFocusStatus = false;

  @override
  void initState() {
    focusNode = widget.focusNode;
    focusNode.addListener(() {
      if (!prevFocusStatus) {
        if (mounted) {
          setState(() {
            prevFocusStatus = true;
          });
          if (!focusNode.hasFocus) {
            prevFocusStatus = false;
          }
        }
      }
    });

    super.initState();

    _con = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDurationInMilli),
      reverseDuration: const Duration(),
    );

    // ensure we rebuild on controller changes (live suggestions)
    widget.textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _con.dispose();
    super.dispose();
  }

  unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) => p.currentIndexForSearch != c.currentIndexForSearch,
      builder: (context, state) {
        if (kDebugMode) {
          // helpful for debugging
          //print('AnimatedSearchBar.build toggle=$toggle currentIndexForSearch=${state.currentIndexForSearch}');
        }

        if (state.currentIndexForSearch == 0 && toggle != 0) {
          toggle = 0;

          // الإغلاق البرمجي كان **بصرياً فقط**: يغيّر toggle ولا يمسّ
          // focusNode. فيبقى التركيز على حقل لم يعد ظاهراً، ويستعيده Flutter
          // تلقائياً حين يُكشف المسار عند الرجوع — فيظهر الكيبورد بلا سبب
          // مفهوم للمستخدم.
          //
          // التحرير بعد الإطار لا داخله: تعديل التركيز أثناء البناء غير مسموح.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && focusNode.hasFocus) focusNode.unfocus();
          });
        }

        return AnimatedContainer(
          padding: const EdgeInsets.only(left: 10, right: 10),
          duration: Duration(
            milliseconds: (toggle == 1) ? widget.animationDurationInMilli : 0,
          ),
          height: widget.height ?? 48.0,
          width: (toggle == 0) ? 48.0 : widget.width,
          curve: Curves.easeOut,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(
                  milliseconds: (toggle == 1)
                      ? widget.animationDurationInMilli
                      : 0,
                ),
                left: (toggle == 0) ? 20.0 : 0.0,
                curve: Curves.easeOut,
                top: 0.0,
                child: AnimatedOpacity(
                  opacity: (toggle == 0) ? 0.0 : 1.0,
                  duration: Duration(milliseconds: (toggle == 1) ? 200 : 0),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: widget.width - 60,
                        height: widget.height,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Text field painted first
                            TextFormField(
                              autocorrect: false,
                              enableSuggestions: false,
                              onFieldSubmitted: widget.onFieldSubmitted,
                              controller: widget.textController,
                              inputFormatters: widget.inputFormatters,
                              focusNode: focusNode,
                              cursorRadius: const Radius.circular(10.0),
                              onChanged: (value) {
                                textFieldValue = value;
                                widget.onChanged?.call(value);
                                if (mounted) setState(() {});
                              },
                              style:
                                  widget.style ??
                                  const TextStyle(color: Colors.black),
                              cursorColor: Colors.black,
                              decoration: (widget.searchDecoration != null)
                                  ? widget.searchDecoration!.copyWith(
                                      filled: false,
                                      fillColor: Colors.transparent,
                                    )
                                  : const InputDecoration(),
                            ),

                            // suggestion overlay on top (non-interactive)
                            IgnorePointer(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final inputText = widget.textController.text;
                                  String finalSuggestion =
                                      widget.suggestion ?? '';
                                  try {
                                    // intentionally left blank: keep safe access pattern for bloc
                                  } catch (_) {}

                                  if (inputText.isNotEmpty &&
                                      finalSuggestion.isNotEmpty &&
                                      finalSuggestion.toLowerCase().startsWith(
                                        inputText.toLowerCase(),
                                      ) &&
                                      finalSuggestion.length >
                                          inputText.length) {
                                    final suffix = finalSuggestion.substring(
                                      inputText.length,
                                    );

                                    EdgeInsets resolvedPadding =
                                        const EdgeInsets.all(2);
                                    if (widget
                                            .searchDecoration
                                            ?.contentPadding !=
                                        null) {
                                      try {
                                        resolvedPadding = widget
                                            .searchDecoration!
                                            .contentPadding!
                                            .resolve(
                                              Directionality.of(context),
                                            );
                                      } catch (_) {}
                                    }

                                    final bool isRtl =
                                        widget.rtl ||
                                        Directionality.of(context) ==
                                            TextDirection.rtl;

                                    if (isRtl) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: resolvedPadding.right,
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: RichText(
                                            textDirection: TextDirection.rtl,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: finalSuggestion
                                                      .substring(
                                                        0,
                                                        inputText.length,
                                                      ),
                                                  style: const TextStyle(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: "             ",
                                                ),
                                                TextSpan(
                                                  text: suffix,
                                                  style: const TextStyle(
                                                    color: Color(0xff8D8D8D),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: resolvedPadding.left,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          style:
                                              widget.style ??
                                              const TextStyle(
                                                color: Colors.black,
                                              ),
                                          children: [
                                            TextSpan(
                                              text: finalSuggestion.substring(
                                                0,
                                                inputText.length,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: "            ",
                                            ),
                                            TextSpan(
                                              text: suffix,
                                              style: const TextStyle(
                                                color: Color(0xff8D8D8D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      (toggle == 0)
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                widget.hideTrendingAndHistory?.value = false;
                                bool stop = widget.onClickClose.call();
                                if (stop) return;
                                toggle = 0;

                                setState(() {
                                  unfocusKeyboard();
                                });

                                _con.reverse();
                              },
                              child: SizedBox(
                                height: widget.height,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 15),
                                    SvgPicture.asset(
                                      AppAssets.closeSvg,
                                      height: 15,
                                      width: 30,
                                      // ignore: deprecated_member_use
                                      color: const Color(0xffFF5F61),
                                    ),
                                    const SizedBox(width: 25),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              toggle != 0
                  ? const SizedBox.shrink()
                  : Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15.0),
                      child: GestureDetector(
                        key: const Key(WidgetsKeys.productListingSearchIconKey),
                        child: widget.suffixWidget,
                        onTap: () {
                          widget.onSuffixTap.call();
                          setState(() {
                            if (toggle == 0) {
                              toggle = 1;
                              if (widget.autoFocus)
                                FocusScope.of(context).requestFocus(focusNode);
                              _con.forward();
                            } else {
                              toggle = 0;
                              if (widget.autoFocus) unfocusKeyboard();
                              _con.reverse();
                            }
                          });
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
