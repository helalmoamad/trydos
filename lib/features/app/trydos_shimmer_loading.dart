import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/constant.dart';

class TrydosShimmerLoading extends StatefulWidget {
  const TrydosShimmerLoading(
      {super.key,
      required this.width,
      this.radius = 15,
      required this.logoTextWidth,
      required this.height,
      required this.logoTextHeight,
      this.circleDimensions});

  final double width, logoTextWidth;
  final double height, logoTextHeight;
  final double? circleDimensions;
  final double radius;

  @override
  State<TrydosShimmerLoading> createState() => _TrydosShimmerLoadingState();
}

class _TrydosShimmerLoadingState extends State<TrydosShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300));
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          color: Color(0xffE6E6E6),
          borderRadius: BorderRadius.circular(widget.radius)),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.25).animate(controller),
                  child: SizedBox(
                    width: widget.circleDimensions ?? 18,
                    height: widget.circleDimensions ?? 18,
                    child: SvgPicture.string(
                      '<svg viewBox="0.0 0.0 17.9 17.9" ><defs><linearGradient id="gradient" x1="0.5" y1="0.542607" x2="0.5" y2="0.0"><stop offset="0.0" stop-color="#f53c3c" /><stop offset="1.0" stop-color="#ff9696" /></linearGradient></defs><path transform="translate(0.0, 0.0)" d="M 8.928571701049805 0 C 3.997458934783936 0 0 3.997458934783936 0 8.928571701049805 C 0 13.85968399047852 3.997458934783936 17.85714340209961 8.928571701049805 17.85714340209961 C 13.85968399047852 17.85714340209961 17.85714340209961 13.85968399047852 17.85714340209961 8.928571701049805 C 17.85714340209961 3.997458934783936 13.85968399047852 0 8.928571701049805 0 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.5,
                ),
                Transform.translate(
                  offset: Offset(-2, 0),
                  child: SizedBox(
                    width: 7.15,
                    height: 10.7,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 3.0,
                            height: 7.0,
                            child: SvgPicture.string(
                              '<svg viewBox="0.0 0.0 3.4 7.1" ><path transform="matrix(0.34202, 0.939693, -0.939693, 0.34202, 1.01, 0.0)" d="M 3.564741611480713 1.071428537368774 C 3.336870670318604 1.071428537368774 3.099845886230469 1.05858039855957 2.860253572463989 1.033239722251892 C 2.81120753288269 1.028049826622009 2.774945497512817 0.9760611653327942 2.779263734817505 0.9171169400215149 C 2.783578634262085 0.8581728935241699 2.826834917068481 0.8145961165428162 2.875883340835571 0.8197823762893677 C 3.11030125617981 0.844578742980957 3.342066287994385 0.8571485280990601 3.564741611480713 0.8571485280990601 C 3.798471689224243 0.8571485280990601 4.04051399230957 0.8433361053466797 4.284150123596191 0.8160967826843262 C 4.333175182342529 0.8106138110160828 4.376611709594727 0.8539344668388367 4.381172180175781 0.9128528237342834 C 4.385733127593994 0.9717668890953064 4.349688053131104 1.023974061012268 4.300667285919189 1.029455542564392 C 4.051564693450928 1.057307600975037 3.803963422775269 1.071428537368774 3.564741611480713 1.071428537368774 Z M 1.461333870887756 0.7589243054389954 C 1.454721927642822 0.7589243054389954 1.448010921478271 0.7580350041389465 1.441292405128479 0.7561798095703125 C 1.002870082855225 0.6351372599601746 0.5514427423477173 0.4817298054695129 0.06121794134378433 0.2871977388858795 C 0.01446835696697235 0.2686454355716705 -0.01091760210692883 0.2080555558204651 0.004519362933933735 0.1518670618534088 C 0.01995637081563473 0.09567852318286896 0.07037163525819778 0.06516924500465393 0.1171248406171799 0.08372166007757187 C 0.6020399928092957 0.2761494815349579 1.048236131668091 0.427799791097641 1.481209635734558 0.5473424196243286 C 1.529196500778198 0.5605892539024353 1.559161305427551 0.6180804967880249 1.548135280609131 0.6757518649101257 C 1.5386563539505 0.7253445982933044 1.501945614814758 0.7589243054389954 1.461333870887756 0.7589243054389954 Z M 5.69659948348999 0.7380787134170532 C 5.656629085540771 0.7380787134170532 5.620270729064941 0.7055432200431824 5.610167980194092 0.6568265557289124 C 5.598258018493652 0.5994124412536621 5.627330780029297 0.5412653088569641 5.675104141235352 0.526955783367157 C 6.129480838775635 0.3908322155475616 6.582267284393311 0.2160782068967819 7.020889282226562 0.007540833204984665 C 7.066670894622803 -0.01422605942934752 7.118471145629883 0.01273520849645138 7.136582851409912 0.06775783002376556 C 7.154693603515625 0.1227806657552719 7.132259845733643 0.185029000043869 7.086477279663086 0.2067955881357193 C 6.640559196472168 0.4187999963760376 6.180217266082764 0.5964682698249817 5.718230724334717 0.7348716259002686 C 5.710993766784668 0.7370400428771973 5.703735828399658 0.7380787134170532 5.69659948348999 0.7380787134170532 Z" fill="#000000" stroke="none" stroke-width="0.5" stroke-dasharray="4 4" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
                              allowDrawingOutsideViewBox: true,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 4.0,
                            height: 4.0,
                            child: SvgPicture.string(
                              '<svg viewBox="3.6 7.1 3.6 3.6" ><path transform="translate(3.57, 7.14)" d="M 1.785714149475098 3.571428298950195 C 0.799491822719574 3.571428298950195 0 2.771936655044556 0 1.785714149475098 C 0 0.7994919419288635 0.799491822719574 0 1.785714149475098 0 C 2.771937131881714 0 3.571428298950195 0.7994919419288635 3.571428298950195 1.785714149475098 C 3.571428298950195 2.771936655044556 2.771937131881714 3.571428298950195 1.785714149475098 3.571428298950195 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                              allowDrawingOutsideViewBox: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: widget.height / 10,
            ),
            SvgPicture.asset(
              AppAssets.trydosTextSvg,
              width: widget.logoTextWidth,
              height: widget.logoTextHeight,
            )
          ],
        ),
      ),
    );
  }
}
