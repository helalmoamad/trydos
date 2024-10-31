import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/test_utils/widgets_keys.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../blocs/app_bloc/app_state.dart';

class AnimatedSearchBar extends StatefulWidget {
  final double width;
  final TextEditingController textController;
  final int animationDurationInMilli;
  final onSuffixTap;
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

  final InputDecoration? searchDecoration;
  final Widget suffixWidget;
  final Widget prefixWidget;
  final FocusNode focusNode;

  final double? height;
  final ValueNotifier<bool>? hideTrendingAndHistory;

  const AnimatedSearchBar({
    Key? key,

    /// The width cannot be null
    required this.width,

    /// The textController cannot be null
    required this.textController,

    /// choose your custom color
    this.color = Colors.white,

    /// choose your custom color for the search when it is expanded
    this.textFieldColor = Colors.white,

    /// choose your custom color for the search when it is expanded
    this.searchIconColor = Colors.black,

    /// choose your custom color for the search when it is expanded
    this.textFieldIconColor = Colors.black,

    /// The onSuffixTap cannot be null
    required this.onSuffixTap,
    this.animationDurationInMilli = 375,

    /// make the search bar to open from right to left
    this.rtl = false,
    this.searchDecoration,
    this.onChanged,
    this.onFieldSubmitted,
    required this.suffixWidget,
    required this.prefixWidget,
    this.height,
    required this.focusNode,

    /// make the keyboard to show automatically when the searchbar is expanded
    this.autoFocus = false,

    /// TextStyle of the contents inside the searchbar
    this.style,

    /// close the search on suffix tap
    this.closeSearchOnSuffixTap = false,

    /// enable/disable the box shadow decoration
    this.boxShadow = true,

    /// can add list of inputformatters to control the input
    this.inputFormatters,
    required this.onClickClose,
    this.hideTrendingAndHistory,
  }) : super(key: key);

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  ///toggle - 0 => false or closed
  ///toggle 1 => true or open
  int toggle = 0;

  /// * use this variable to check current text from OnChange
  String textFieldValue = '';

  ///initializing the AnimationController
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

    ///Initializing the animationController which is responsible for the expanding and shrinking of the search bar
    _con = AnimationController(
      vsync: this,

      /// animationDurationInMilli is optional, the default value is 375
      duration: Duration(milliseconds: widget.animationDurationInMilli),
      reverseDuration: Duration(milliseconds: 0),
    );
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
          if (state.currentIndexForSearch == 0) {
            toggle = 0;
          }

          return AnimatedContainer(
            padding: EdgeInsets.only(left: 10, right: 10),
            duration: Duration(
                milliseconds:
                    (toggle == 1) ? widget.animationDurationInMilli : 0),
            height: widget.height ?? 48.0,
            width: (toggle == 0) ? 48.0 : widget.width,
            curve: Curves.easeOut,
            child: Stack(
              children: [
                ///Using Animated Positioned widget to expand and shrink the widget
                // AnimatedPositioned(
                //   duration: Duration(milliseconds: widget.animationDurationInMilli),
                //   top: 6.0,
                //   right: 7.0,
                //   curve: Curves.easeOut,
                //   child: AnimatedOpacity(
                //     opacity: (toggle == 0) ? 0.0 : 1.0,
                //     duration: Duration(milliseconds: 200),
                //     child: Container(
                //       padding: EdgeInsets.all(8.0),
                //       decoration: BoxDecoration(
                //         /// can add custom color or the color will be white
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: AnimatedBuilder(
                //         child: GestureDetector(
                //           onTap:  () {
                //             try {
                //
                //               // * if field empty then the user trying to close bar
                //               if (textFieldValue == '') {
                //                 unfocusKeyboard();
                //                 setState(() {
                //                   toggle = 0;
                //                 });
                //
                //                 ///reverse == close
                //                 _con.reverse();
                //               }
                //
                //               // * why not clear textfield here?
                //               widget.textController.clear();
                //               textFieldValue = '';
                //
                //               ///closeSearchOnSuffixTap will execute if it's true
                //               if (widget.closeSearchOnSuffixTap) {
                //                 unfocusKeyboard();
                //                 setState(() {
                //                   toggle = 0;
                //                 });
                //               }
                //             } catch (e) {
                //               ///print the error if the try block fails
                //               print(e);
                //             }
                //           },
                //
                //           child:widget.prefixWidget
                //         ),
                //         builder: (context, widget) {
                //           ///Using Transform.rotate to rotate the suffix icon when it gets expanded
                //           return Transform.rotate(
                //             angle: _con.value * 2.0 * pi,
                //             child: widget,
                //           );
                //         },
                //         animation: _con,
                //       ),
                //     ),
                //   ),
                // ),
                AnimatedPositioned(
                  duration: Duration(
                      milliseconds:
                          (toggle == 1) ? widget.animationDurationInMilli : 0),
                  left: (toggle == 0) ? 20.0 : 0.0,
                  curve: Curves.easeOut,
                  top: 0.0,

                  ///Using Animated opacity to change the opacity of th textField while expanding
                  child: AnimatedOpacity(
                    opacity: (toggle == 0) ? 0.0 : 1.0,
                    duration: Duration(milliseconds: (toggle == 1) ? 200 : 0),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: widget.width - 60,
                          height: widget.height,
                          child: TextFormField(
                              onFieldSubmitted: widget.onFieldSubmitted,
                              controller: widget.textController,
                              inputFormatters: widget.inputFormatters,
                              focusNode: focusNode,
                              cursorRadius: Radius.circular(10.0),
                              cursorWidth: 2.0,
                              onChanged: (value) {
                                textFieldValue = value;
                                widget.onChanged?.call(value);
                              },

                              ///style is of type TextStyle, the default is just a color black
                              style: widget.style != null
                                  ? widget.style
                                  : TextStyle(color: Colors.black),
                              cursorColor: Colors.black,
                              decoration: widget.searchDecoration),
                        ),
                        (toggle == 0)
                            ? SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  widget.hideTrendingAndHistory?.value = false;
                                  bool stop = widget.onClickClose.call();
                                  if (stop) return;
                                  toggle = 0;

                                  ///if the autoFocus is true, the keyboard will close, automatically
                                  setState(() {
                                    unfocusKeyboard();
                                  });

                                  ///reverse == close
                                  _con.reverse();
                                },
                                child: SizedBox(
                                  height: widget.height,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      SvgPicture.asset(
                                        AppAssets.closeSvg,
                                        height: 15,
                                        width: 30,
                                        color: Color(0xffFF5F61),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                ///Using material widget here to get the ripple effect on the prefix icon
                toggle != 0
                    ? SizedBox.shrink()
                    : Material(
                        /// can add custom color or the color will be white
                        /// toggle button color based on toggle state
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15.0),
                        child: GestureDetector(
                          key: Key(WidgetsKey.productListingSearchIconKey),

                          ///if toggle is 1, which means it's open. so show the back icon, which will close it.
                          ///if the toggle is 0, which means it's closed, so tapping on it will expand the widget.
                          ///prefixIcon is of type Icon
                          child: widget.suffixWidget,
                          onTap: () {
                            widget.onSuffixTap.call();
                            setState(
                              () {
                                ///if the search bar is closed
                                if (toggle == 0) {
                                  print('qqqqqqqqqqqqqqqqqq');
                                  toggle = 1;
                                  setState(
                                    () {
                                      ///if the autoFocus is true, the keyboard will pop open, automatically
                                      if (widget.autoFocus)
                                        FocusScope.of(context)
                                            .requestFocus(focusNode);
                                    },
                                  );

                                  ///forward == expand
                                  _con.forward();
                                  ////////////////////////////////////////////////
                                  Future.delayed(
                                    Duration(milliseconds: 300),
                                    () {
                                      FirebaseAnalyticsService
                                          .logEventForSession(
                                        eventName:
                                            AnalyticsEventsConst.buttonClicked,
                                        executedEventName:
                                            AnalyticsExecutedEventNameConst
                                                .openSearchFieldButton,
                                      );
                                    },
                                  );
                                } else {
                                  ///if the search bar is expanded
                                  toggle = 0;

                                  ///if the autoFocus is true, the keyboard will close, automatically
                                  setState(
                                    () {
                                      if (widget.autoFocus) unfocusKeyboard();
                                    },
                                  );

                                  ///reverse == close
                                  _con.reverse();
                                }
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        });
  }
}
