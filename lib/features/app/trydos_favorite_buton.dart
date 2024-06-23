

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';

import '../../common/constant/design/assets_provider.dart';

class TrydosFavoriteButton extends StatelessWidget {
  const TrydosFavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      circleColor:
      CircleColor(start: Colors.redAccent, end: Colors.red),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Colors.red.shade300,
        dotSecondaryColor: Colors.red,
      ),
      likeBuilder: (bool isLiked) {
        return SvgPicture.asset(isLiked ? AppAssets.favoriteActiveSvg : AppAssets.favoriteSvg,);
      },
    );

  }
}
