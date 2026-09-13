import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/constant/design/assets_provider.dart';
import '../../../common/test_utils/widgets_keys.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_state.dart';
import 'package:trydos/common/helper/dev_log.dart';

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
    super.key,
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
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  int toggle = 0;
  bool prevFocusStatus = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (kDebugMode) {
      devLog(
        'Focus status changed: ${widget.focusNode.hasFocus}, prevFocusStatus: $prevFocusStatus',
      );
    }
    if (!prevFocusStatus && widget.focusNode.hasFocus) {
      if (mounted) {
        setState(() => prevFocusStatus = true);
      }
    } else if (prevFocusStatus && !widget.focusNode.hasFocus) {
      if (mounted) {
        setState(() => prevFocusStatus = false);
      }
    }
  }

  void unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (p, c) => p.currentIndexForSearch != c.currentIndexForSearch,
      listener: (context, state) {
        if (state.currentIndexForSearch == 0 && toggle != 0) {
          setState(() {
            toggle = 0;
          });
          if (widget.focusNode.hasFocus) {
            widget.focusNode.unfocus();
          }
        }
      },
      buildWhen: (p, c) => p.currentIndexForSearch != c.currentIndexForSearch,
      builder: (context, state) {
        return AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            TextFormField(
                              autocorrect: false,
                              enableSuggestions: false,
                              onFieldSubmitted: widget.onFieldSubmitted,
                              controller: widget.textController,
                              inputFormatters: widget.inputFormatters,
                              focusNode: widget.focusNode,
                              cursorRadius: const Radius.circular(10.0),
                              onChanged: (value) {
                                widget.onChanged?.call(value);
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
                            IgnorePointer(
                              // يستمع للمحرّر وحده: تغيّر النص يعيد بناء طبقة
                              // الاقتراح فقط بدل الشريط كاملاً
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: widget.textController,
                                builder: (context, editingValue, _) {
                                  final inputText = editingValue.text;
                                  final String finalSuggestion =
                                      widget.suggestion ?? '';

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
                                      } catch (e) {
                                        devLog('animated_search_bar.dart: ignored error', e);
                                      }
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
                      if (toggle != 0)
                        InkWell(
                          onTap: () {
                            widget.hideTrendingAndHistory?.value = false;
                            bool stop = widget.onClickClose.call();
                            if (stop) return;

                            setState(() {
                              toggle = 0;
                              unfocusKeyboard();
                            });
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
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xffFF5F61),
                                    BlendMode.srcIn,
                                  ),
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
              if (toggle == 0)
                Material(
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
                          if (widget.autoFocus) {
                            FocusScope.of(
                              context,
                            ).requestFocus(widget.focusNode);
                          }
                        } else {
                          toggle = 0;
                          if (widget.autoFocus) unfocusKeyboard();
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
