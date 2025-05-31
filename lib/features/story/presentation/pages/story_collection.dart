import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as filter;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/payment_method.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/typography.dart';
import 'package:trydos/service/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/no_image_widget.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../app/trydos_shimmer_loading.dart';
import '../../../home/data/models/get_home_boutiqes_model.dart' as banner;
import '../../../home/presentation/manager/homeBloc/home_event.dart'
    as homeEvent;
import '../../data/models/get_stories_model.dart';
import '../bloc/story_state.dart';
import '../widget/animated_builder.dart';
import 'dart:ui';

// ignore: must_be_immutable
class StoryCollection extends StatefulWidget {
  final int collectionIndex;
  final AnimationController animatedController;
  final bool stopAnimationAndVideo;
  final bool screenChanged;
  final void Function(int collectionIndex, bool isReachTheLeftMost)
      onReachStoryAtEdge;

  @override
  State<StoryCollection> createState() => _StoryCollectionState();

  const StoryCollection(
      {Key? key,
      required this.collectionIndex,
      required this.animatedController,
      required this.onReachStoryAtEdge,
      required this.screenChanged,
      required this.stopAnimationAndVideo})
      : super(key: key);
}

class _StoryCollectionState extends ThemeState<StoryCollection> {
  late PageController pageController;
  VideoPlayerController? _videoController;

  LongPressDownDetails details = LongPressDownDetails();
  var init;
  bool fromBoutiqueListing = false;
  @override
  void initState() {
    debugPrint('initState ${widget.collectionIndex}');
    GetIt.I<StoryBloc>().add(StorySelectedEvent(
        collectionIndex: widget.collectionIndex,
        selectedStoryIndexInCollection: -1,
        currentPage: -1));
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      debugPrint(error.toString());
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };

    return Hero(
      tag: widget.collectionIndex,
      createRectTween: HeroAnimationAsset.customTweenRect,
      child: BlocConsumer<StoryBloc, StoryState>(
        listener: (ctx, state) {},
        buildWhen: (previous, current) =>
            previous.storiesCollections[widget.collectionIndex]
                    .selectedStoriesStatusForCollection !=
                current.storiesCollections[widget.collectionIndex]
                    .selectedStoriesStatusForCollection ||
            previous.currentStoryInEachCollection[widget.collectionIndex] !=
                current.currentStoryInEachCollection[widget.collectionIndex] ||
            previous.storiesCollections[widget.collectionIndex].stories!
                    .length !=
                current
                    .storiesCollections[widget.collectionIndex].stories!.length,
        builder: (context, state) {
          //todo the initial story
//        int currentInitialIndex = state.currentStoryInEachCollection!;
//        List<Story> collectionOfSelectedStory =
//            state.stories[widget.collectionIndex].stories!;
//        var currentStoryInEachCollection = collectionOfSelectedStory[currentInitialIndex];
          pageController = PageController(
              initialPage:
                  state.currentStoryInEachCollection[widget.collectionIndex]!);
          widget.animatedController.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.animatedController.stop();
              widget.animatedController.reset();

              if ((state.currentStoryInEachCollection[widget.collectionIndex]! +
                      1) >=
                  state.storiesCollections[widget.collectionIndex].stories!
                      .length) {
                widget.onReachStoryAtEdge.call(widget.collectionIndex, false);
              } else {
                //   Future.delayed(Duration(milliseconds: 330),
                //         () => Navigator.of(context).pop());
                GetIt.I<StoryBloc>().add(StorySelectedEvent(
                    collectionIndex: widget.collectionIndex,
                    currentPage: -1,
                    selectedStoryIndexInCollection:
                        state.currentStoryInEachCollection[
                                widget.collectionIndex]! +
                            1));
              }
            }
          });
          return Stack(
            children: [
//          MyTextWidget('${state.selectedStoriesStatus}'),
//          state.selectedStoriesStatus==SelectedStoriesStatus.success?MyTextWidget('${state.imageDetail!.width}'):MyTextWidget('data')
              GestureDetector(
                onLongPressDown: (_) {
                  details = _;
                },
                onLongPressStart: (_) {
                  widget.animatedController.stop();
                  _videoController?.pause();
                },
                onLongPressUp: () {
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double dy = details.localPosition.dy;
                  if (dy > screenHeight * 3 / 3.7) {
                    return;
                  }
                  widget.animatedController.forward();
                  _videoController?.play();
                },

                // onVerticalDragUpdate: (details) {
                //   if (details.delta.direction > 0) {
                //     Navigator.pop(context);
                //   }
                // },
                onLongPressCancel: () {
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double screenWidth = MediaQuery.of(context).size.width;
                  final double dx = details.localPosition.dx;
                  final double dy = details.localPosition.dy;
                  if (dy > screenHeight * 3 / 3.7) {
                    return;
                  }
                  debugPrint(dx.toString());
                  _videoController?.dispose();
                  _videoController = null;
                  init = null;
                  if (LanguageService.rtl) {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! +
                              1) >=
                          state.storiesCollections[widget.collectionIndex]
                              .stories!.length) {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                          collectionIndex: widget.collectionIndex,
                          selectedStoryIndexInCollection: 0,
                          currentPage: -1,
                        ));
                        Navigator.of(context).pop();
                      } else {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                            collectionIndex: widget.collectionIndex,
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! +
                                    1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! -
                              1) >
                          0) {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! -
                                    1,
                            currentPage: -1,
                            collectionIndex: widget.collectionIndex));
                      } else {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            currentPage: -1,
                            selectedStoryIndexInCollection: 0,
                            collectionIndex: widget.collectionIndex));
                      }
                    }
                  } else {
                    if (dx > screenWidth * 1 / 2) {
                      widget.animatedController.stop();
                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! +
                              1) >=
                          state.storiesCollections[widget.collectionIndex]
                              .stories!.length) {
                        widget.onReachStoryAtEdge
                            .call(widget.collectionIndex, false);
                      } else {
                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                            collectionIndex: widget.collectionIndex,
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! +
                                    1));
                      }
                    } else if (dx < screenWidth * 1 / 2) {
                      widget.animatedController.stop();

                      widget.animatedController.reset();
                      if ((state.currentStoryInEachCollection[
                                  widget.collectionIndex]! -
                              1) >
                          0) {
                        context.read<StoryBloc>().add(StorySelectedEvent(
                            currentPage: -1,
                            selectedStoryIndexInCollection:
                                state.currentStoryInEachCollection[
                                        widget.collectionIndex]! -
                                    1,
                            collectionIndex: widget.collectionIndex));
                      } else {
                        widget.onReachStoryAtEdge
                            .call(widget.collectionIndex, true);
                      }
                    }
                  }
                },
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemBuilder: (context, index) {
//todo check whether photo or video and start processing
                    if (state.storiesCollections[widget.collectionIndex]
                            .selectedStoriesStatusForCollection ==
                        SelectedStoriesStatus.failure)
                      return Center(
                        child: ElevatedButton(
                            onPressed: () {
                              GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                  currentPage: -1,
                                  selectedStoryIndexInCollection:
                                      state.currentStoryInEachCollection[
                                          widget.collectionIndex]!,
                                  collectionIndex: widget.collectionIndex));
                            },
                            child: MyTextWidget(LocaleKeys.try_again.tr())),
                      );
                    else if (state
                            .storiesCollections[widget.collectionIndex]
                            .stories![state.currentStoryInEachCollection[
                                widget.collectionIndex]!]
                            .isPhoto ==
                        1) {
                      widget.animatedController.duration =
                          const Duration(seconds: 4);
                      widget.animatedController.forward();
                      if (state.storiesCollections[widget.collectionIndex]
                              .selectedStoriesStatusForCollection ==
                          SelectedStoriesStatus.loading) {
                        widget.animatedController.stop();
                        return TrydosShimmerLoading(
                          width: 60,
                          height: 60,
                          logoTextHeight: 14,
                          logoTextWidth: 20.w,
                        );
                      }
                      if (state.storiesCollections[widget.collectionIndex]
                                  .selectedStoriesStatusForCollection ==
                              SelectedStoriesStatus.success ||
                          state.storiesCollections[widget.collectionIndex]
                                  .selectedStoriesStatusForCollection ==
                              SelectedStoriesStatus.init) {
                        widget.animatedController.forward();
                        if (widget.stopAnimationAndVideo) {
                          print("111111111111111111111111");
                          widget.animatedController.stop();
                        } else {
                          print("112222222222222211111111111");
                          widget.animatedController.forward();
                        }
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            MyCachedNetworkImage(
                              fromStory: true,
                              imageUrl: state
                                  .storiesCollections[widget.collectionIndex]
                                  .stories![state.currentStoryInEachCollection[
                                      widget.collectionIndex]!]
                                  .photoPath!,
                              callWhenDisplayImage: () {
                                Story story = state
                                    .storiesCollections[widget.collectionIndex]
                                    .stories![state
                                        .currentStoryInEachCollection[
                                    widget.collectionIndex]!];

                                if (!(story.isSeen ?? false)) {
                                  GetIt.I<StoryBloc>().add(IncreaseViewersEvent(
                                      collectionId: state
                                          .storiesCollections[
                                              widget.collectionIndex]
                                          .id
                                          .toString(),
                                      storyId: story.id.toString()));
                                }
                                if (widget.stopAnimationAndVideo) {
                                  widget.animatedController.stop();
                                } else {
                                  Future.delayed(
                                      Duration(milliseconds: 300),
                                      () =>
                                          widget.animatedController.forward());
                                }
                              },
                              callWhenLoadingImage: () {
                                widget.animatedController.stop();
                              },
                              width: state
                                          .storiesCollections[
                                              widget.collectionIndex]
                                          .imageDetail ==
                                      null
                                  ? 1.sw
                                  : state
                                      .storiesCollections[
                                          widget.collectionIndex]
                                      .imageDetail!
                                      .width
                                      .toDouble(),
                              height: state
                                          .storiesCollections[
                                              widget.collectionIndex]
                                          .imageDetail ==
                                      null
                                  ? (1.sh - 50)
                                  : state
                                      .storiesCollections[
                                          widget.collectionIndex]
                                      .imageDetail!
                                      .height
                                      .toDouble(),
                              imageFit: BoxFit.contain,
                            ),
                            state
                                        .storiesCollections[
                                            widget.collectionIndex]
                                        .stories![
                                            state.currentStoryInEachCollection[
                                                widget.collectionIndex]!]
                                        .oneLink ==
                                    null
                                ? SizedBox.shrink()
                                : Positioned(
                                    bottom: 0,
                                    child: _handleWithUrlWidget((state
                                            .storiesCollections[
                                                widget.collectionIndex]
                                            .stories![state
                                                    .currentStoryInEachCollection[
                                                widget.collectionIndex]!]
                                            .oneLink ??
                                        "")))
                          ],
                        );
                      } else {
                        widget.animatedController.stop();
                        return Container();
                      }
                    } else {
                      if (_videoController == null) {
                        _videoController = VideoPlayerController.networkUrl(
                            Uri.parse(state
                                .storiesCollections[widget.collectionIndex]
                                .stories![state.currentStoryInEachCollection[
                                    widget.collectionIndex]!]
                                .fullVideoPath!));
                        init = _videoController!.initialize().then((_) {
                          widget.animatedController.duration =
                              _videoController!.value.duration;
                          if (widget.stopAnimationAndVideo) {
                            _videoController?.pause();
                            widget.animatedController.stop();
                          } else {
                            _videoController?.play();
                            widget.animatedController.forward();
                          }
                          _videoController!.addListener(() {
                            if (!_videoController!.value.isPlaying) {
                              widget.animatedController.stop();
                            } else {
                              widget.animatedController.forward();
                            }
                          });
                        }, onError: (e) {
                          GetIt.I<StoryBloc>().add(LoadFailureEvent(
                              collectionId: widget.collectionIndex));
                        });
                      }
                      if (widget.collectionIndex != state.currentPage) {
                        _videoController?.pause();
                        widget.animatedController.stop();
                      } else {
                        if (widget.stopAnimationAndVideo) {
                          _videoController?.pause();
                          widget.animatedController.stop();
                        } else {
                          _videoController?.play();
                          if (_videoController != null) {
                            if (_videoController!.value.isInitialized) {
                              widget.animatedController.forward();
                            }
                          }
                        }
                      }
                      return FutureBuilder(
                        future: init,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Story story = state
                                    .storiesCollections[widget.collectionIndex]
                                    .stories![
                                state.currentStoryInEachCollection[
                                    widget.collectionIndex]!];
                            if (!(story.isSeen ?? false)) {
                              GetIt.I<StoryBloc>().add(IncreaseViewersEvent(
                                  collectionId: state.storiesCollections[
                                          widget.collectionIndex]
                                      .toString(),
                                  storyId: story.id.toString()));
                            }
                            return FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VideoPlayer(
                                      _videoController!,
                                    ),
                                    state
                                                .storiesCollections[
                                                    widget.collectionIndex]
                                                .stories![state
                                                        .currentStoryInEachCollection[
                                                    widget.collectionIndex]!]
                                                .oneLink ==
                                            null
                                        ? SizedBox.shrink()
                                        : Positioned(
                                            bottom: 0,
                                            child: _handleWithUrlWidget(state
                                                    .storiesCollections[
                                                        widget.collectionIndex]
                                                    .stories![state
                                                            .currentStoryInEachCollection[
                                                        widget
                                                            .collectionIndex]!]
                                                    .oneLink ??
                                                ""))
                                  ],
                                ),
                              ),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: TrydosLoader(),
                            );
                          } else if (snapshot.hasError)
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        GetIt.I<StoryBloc>().add(StorySelectedEvent(
                                            selectedStoryIndexInCollection:
                                                state.currentStoryInEachCollection[
                                                    widget.collectionIndex]!,
                                            currentPage: -1,
                                            collectionIndex:
                                                widget.collectionIndex));
                                      },
                                      child:
                                          MyTextWidget(LocaleKeys.trye.tr())),
                                ),
                              ),
                            );
                          return Container(
                            color: Colors.amberAccent,
                            width: 200,
                            height: 200,
                          );
                        },
                      );
                    }
                  },
                  itemCount: state.storiesCollections[widget.collectionIndex]
                      .stories!.length,
                ),
              ),
              Positioned(
                  top: 40.0,
                  left: 10.0,
                  right: 10.0,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Row(
                      children: state
                          .storiesCollections[widget.collectionIndex].stories!
                          .map((e) => AnimatedBar(
                              animController: widget.animatedController,
                              collectionIndex: widget.collectionIndex,
                              position: state
                                  .storiesCollections[widget.collectionIndex]
                                  .stories!
                                  .indexOf(e)))
                          .toList(),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: state.storiesCollections[widget.collectionIndex].photoPath == null
                                  ? NoImageWidget(
                                      height: 40,
                                      width: 40,
                                      textStyle: context
                                          .textTheme.bodyMedium?.br
                                          .copyWith(
                                              color: const Color(0xff6638FF),
                                              letterSpacing: 0.18,
                                              height: 1.33),
                                      name: state.storiesCollections[widget.collectionIndex].name == null
                                          ? LocaleKeys.uk.tr()
                                          : HelperFunctions.getTheFirstTwoLettersOfName(
                                              state
                                                  .storiesCollections[
                                                      widget.collectionIndex]
                                                  .name!))
                                  : MyCachedNetworkImage(
                                      width: 40,
                                      height: 40,
                                      imageFit: BoxFit.cover,
                                      imageUrl: ((state
                                                  .storiesCollections[widget.collectionIndex]
                                                  .photoPath
                                                  .toString()
                                                  .contains("cloudinary"))
                                              ? ""
                                              : "${dotenv.env['Profile_Images_Url']}") +
                                          state.storiesCollections[widget.collectionIndex].photoPath),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.only(start: 10),
                              child: MyTextWidget(
                                  style: textTheme.bodyLarge?.rr
                                      .copyWith(color: Colors.white),
                                  state
                                              .storiesCollections[
                                                  widget.collectionIndex]
                                              .name ==
                                          null
                                      ? LocaleKeys.uk.tr()
                                      : state
                                          .storiesCollections[
                                              widget.collectionIndex]
                                          .name!),
                            )
                          ]),
                          Container(
                            width: 200,
                            height: 20,
                            child: Text(
                              "${(HelperFunctions.getZonedDateWithoutUtcForm(state.storiesCollections[widget.collectionIndex].stories![state.currentStoryInEachCollection[widget.collectionIndex]!].createdAt ?? "")).toString().split(".").first}",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.ba.copyWith(
                                fontSize: 12,
                                color: Colors.blue,
                                letterSpacing: 0.18,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ])),
            ],
          );
        },
      ),
    );
  }

  void parseUrl(String url) {
    fromBoutiqueListing = false;
    final uri = Uri.parse(url);

    // دالة لفك التشفير المزدوج للمعاملات
    String? decodeParam(String? param) {
      if (param == null) return null;
      try {
        return Uri.decodeComponent(Uri.decodeComponent(param));
      } catch (e) {
        print('خطأ في فك التشفير: $e');
        return null;
      }
    }

    // دالة لتحويل النص المشفر إلى قائمة نصوص
    List<String> parseListParam(String? param) {
      final decoded = decodeParam(param);
      if (decoded == null) return [];
      try {
        final list = jsonDecode(decoded);
        if (list is List) {
          return list.map((e) => e.toString()).toList();
        } else {
          print('المعطى ليس قائمة JSON');
          return [];
        }
      } catch (e) {
        print('خطأ في تحويل JSON: $e');
        return [];
      }
    }

    //
    // استخراج وتحليل المعاملات
    final categories = parseListParam(uri.queryParameters['categories']);
    final brands = parseListParam(uri.queryParameters['brands']);
    final sizes = parseListParam(uri.queryParameters['sizes']);
    final colors = parseListParam(uri.queryParameters['colors']);
    final boutiques = parseListParam(uri.queryParameters['boutiques']);
    final coupon = decodeParam(uri.queryParameters['coupon']);
    if (coupon != null) {
      prefsRepository.setOrderCoupon(coupon);
    }

    List<Boutique>? boutiquesFilter = [];
    boutiques.forEach((element) =>
        boutiquesFilter.add(Boutique(id: 0, name: "null", slug: element)));
    List<Brand>? brandFilter = [];
    brands.forEach((element) =>
        brandFilter.add(Brand(id: 0, name: "null", slug: element)));
    List<filter.Category>? categoriesFilter = [];
    categories.forEach((element) => categoriesFilter
        .add(filter.Category(id: 0, name: "null", slug: element)));
    print('الفئات: $categories');
    print('العلامات: $brands');
    print('المقاسات: $sizes');
    print('الألوان: $colors');
    print('البوتيكات: $boutiques');
    if (!(url.contains("boutique/listing")) && (url.contains("boutique"))) {
      String boutiueSlug = "";
      boutiueSlug = url.split("/").toList().last;
      boutiueSlug = boutiueSlug.split("?").first;
      fromBoutiqueListing = true;
      BlocProvider.of<BoutiqueBloc>(context)
          .add(GetFiltersForNavigatorFromLinkToListingPageEvent(
              fromHomePageSearch: false,
              boutiqueSlug: boutiueSlug,
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: Filter(
                attributes: sizes.isNullOrEmpty
                    ? []
                    : [Attribute(id: 0, name: "size", options: sizes)],
                brands: brandFilter,
                categories: categoriesFilter,
                colors: colors,
              ))));
    } else {
      BlocProvider.of<BoutiqueBloc>(context)
          .add(GetFiltersForNavigatorFromLinkToListingPageEvent(
              fromHomePageSearch: true,
              boutiqueSlug: "search",
              filtersChoosedByUser: GetProductFiltersModel(
                  filters: Filter(
                attributes: sizes.isNullOrEmpty
                    ? []
                    : [Attribute(id: 0, name: "size", options: sizes)],
                brands: brandFilter,
                categories: categoriesFilter,
                boutiques: boutiquesFilter,
                colors: colors,
              ))));
    }
  }

  void tapOnUrl(String uri) async {
    try {
      if (uri.contains("trydos")) {
        if (uri.contains("products")) {
          String? uriWithFilter;
          String? colorName;
          String uriWithoutFilter = uri.split("?").toList().first;
          if (uri.split("?").toList().length > 1) {
            uriWithFilter = uri.split("?").toList()[1];
          }
          if (uriWithFilter != null) {
            colorName = uriWithFilter.split("&").firstWhere(
                  (element) => element.contains("color"),
                  orElse: () => "",
                );
            if (colorName != "") {
              colorName = colorName.split("=").toList().last;
            }
          }
          BlocProvider.of<HomeBloc>(context).add(
              homeEvent.ChangeStatusOFGetProductsDetailsToSuccessEvent(
                  isStatusInitaial: true));
          BlocProvider.of<HomeBloc>(context)
              .add(homeEvent.GetFullProductDetailsEvent(
            currentColorName: colorName == "" ? null : colorName,
            productSlug: uriWithoutFilter.split("/").toList().last,
          ));

          Future.delayed(
              Duration(milliseconds: 300),
              () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductDetailsPage(
                        productSlugForOpeningChatDirectly:
                            uriWithoutFilter.split("/").toList().last,
                        fromNotification: false,
                      ))));
          return;
        }
        if (uri.contains("boutique")) {
          BlocProvider.of<BoutiqueBloc>(context).add(ChangeAppliedFiltersEvent(
              boutiqueSlug: "search", resetAppliedFilters: true));
          BlocProvider.of<BoutiqueBloc>(context).add(ChangeSelectedFiltersEvent(
              boutiqueSlug: "search",
              fromHomePageSearch: true,
              resetChoosedFilters: true,
              requestToUpdateFilters: false));
          parseUrl(uri);

          return;
        }
      } else {
        await launchUrl(Uri.parse(uri));
      }
      // Navigator.of(context).pop();
    } catch (e) {}
  }

  Widget _handleWithUrlWidget(String url) {
    return Material(
      color: Color.fromRGBO(0, 0, 0, 0),
      child: BlocListener<BoutiqueBloc, BoutiqueState>(
        listenWhen: (previous, current) =>
            previous.getFiltersForNavigatorFromLinkToListingPageStatus !=
            current.getFiltersForNavigatorFromLinkToListingPageStatus,
        listener: (context, boutiqueState) async {
          if (boutiqueState.getFiltersForNavigatorFromLinkToListingPageStatus ==
              GetFiltersForNavigatorFromLinkToListingPageStatus.success) {
            if (fromBoutiqueListing) {
              BlocProvider.of<BoutiqueBloc>(context)
                  .add(ChangeAppliedFiltersEvent(
                boutiqueSlug: boutiqueState.appliedFiltersByUser["link"]
                        ?.filters?.boutiques?[0].slug ??
                    "",
                filtersAppliedByUser: boutiqueState.appliedFiltersByUser["link"]
                    ?.copyWith(
                        filters: boutiqueState
                            .appliedFiltersByUser["link"]?.filters
                            ?.copyWithSaveOtherField(boutiques: [])),
              ));

              BlocProvider.of<BoutiqueBloc>(context).add(
                  GetProductsWithFiltersEvent(
                      getWithoutFilter: true,
                      cashedOrginalBoutique: false,
                      boutiqueSlug: boutiqueState.appliedFiltersByUser["link"]
                              ?.filters?.boutiques?[0].slug ??
                          "",
                      fromSearch: false,
                      category: null,
                      context: context,
                      searchText: null,
                      offset: 1));
              await Future.delayed(
                Duration(milliseconds: 300),
                () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductListingPage(
                          fromBackground: false,
                          boutiqueSlug: boutiqueState
                                  .appliedFiltersByUser["link"]
                                  ?.filters
                                  ?.boutiques?[0]
                                  .slug ??
                              "",
                          banner: [
                            (boutiqueState.appliedFiltersByUser["link"]?.filters
                                ?.boutiques?[0].banner)!
                          ],
                          boutiqueFirstBanner: boutiqueState
                              .appliedFiltersByUser["link"]
                              ?.filters
                              ?.boutiques?[0]
                              .banner
                              ?.filePath),
                )),
              );
              return;
            }

            await Future.delayed(
                Duration(milliseconds: 300),
                () => Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProductListingPage(
                            getProductFiltersModel:
                                boutiqueState.appliedFiltersByUser["link"],
                            fromNotificationCategory: true,
                            fromBackground: false,
                            fromSearch: true,
                            boutiqueSlug: "search"))));
          }
        },
        child: BlocBuilder<BoutiqueBloc, BoutiqueState>(
          buildWhen: (previous, current) =>
              previous.getFiltersForNavigatorFromLinkToListingPageStatus !=
              current.getFiltersForNavigatorFromLinkToListingPageStatus,
          builder: (context, boutiqueState) {
            if (boutiqueState
                    .getFiltersForNavigatorFromLinkToListingPageStatus ==
                GetFiltersForNavigatorFromLinkToListingPageStatus.loading) {}
            return Container(
              width: 300,
              height: 100,
              child: InkWell(
                onTap: () {
                  _videoController?.pause();
                  widget.animatedController.stop();
                  tapOnUrl(url);
                },
                child: Center(
                  child: boutiqueState
                              .getFiltersForNavigatorFromLinkToListingPageStatus ==
                          GetFiltersForNavigatorFromLinkToListingPageStatus
                              .loading
                      ? Container(
                          height: 30,
                          width: 30,
                          color: Colors.white,
                          child: TrydosLoader(
                            size: 28,
                            color: Colors.black,
                          ))
                      : Container(
                          width: 300,
                          height: 100,
                          child: Center(
                            child: Text(
                              url,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: context.textTheme.bodyMedium?.ba.copyWith(
                                decorationColor: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.blue,
                                letterSpacing: 0.18,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeroAnimationAsset {
  static Tween<Rect?> customTweenRect(Rect? begin, Rect? end) =>
      CustomRectTween(end: end, begin: begin);
}

//////////////////////////////////////////////////////////////////////////////

class CustomRectTween extends RectTween {
  CustomRectTween({
    Rect? begin,
    Rect? end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.fastEaseInToSlowEaseOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, elasticCurveValue)!,
      lerpDouble(begin!.top, end!.top, elasticCurveValue)!,
      lerpDouble(begin!.right, end!.right, elasticCurveValue)!,
      lerpDouble(begin!.bottom, end!.bottom, elasticCurveValue)!,
    );
  }
}
