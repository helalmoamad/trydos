

/*class FiltersLoadingListPage extends StatefulWidget {
  const FiltersLoadingListPage({super.key, required this.countOfListInPage,
  required this.currentColor,
  required this.productItem,
  required this.boutiqueId,
  required this.boutiqueIcon,
  required this.currentColorName,
    required this.maxAllowedToAddCart,
      required this.productSlugForTopic,
       required this.countOfPieces,
  required this.productDescription,

  required this.currentColornum,
  required this.productIdForCashData});

  final int countOfListInPage;
  final Products productItem;
  final int currentColor;
  final int boutiqueId;
  final String boutiqueIcon;

  final String currentColorName;

  final String productDescription;
  final String currentColornum;

  final String productIdForCashData;
  final int countOfPieces;
  final String maxAllowedToAddCart;
    final String productSlugForTopic;
  @override
  State<FiltersLoadingListPage> createState() => _FiltersLoadingListPageState();
}

class _FiltersLoadingListPageState extends State<FiltersLoadingListPage> {
   final ValueNotifier<int> currentActiveTab= ValueNotifier(3);
    final ValueNotifier<double> workOnBlurNotifier = ValueNotifier(0);
  final PanelController panelController = PanelController();
    Offset? offsetOfColorsGallerySlider;
    Gallery3DController? gallery3dControllerForCircles;
      final GlobalKey colorsGallerySliderKey = GlobalKey();
        List<SyncColorImage> syncColorImageList = [];
          List<double>? orginalHeight;
  List<double>? orginalWidth;
  List<String> images = [];
      int currentIndexInSlider=0;
  @override
  void initState() {
     int currentColor = homeBloc.state.currentSelectedColorForEveryProduct[
            widget.productItem.id.toString()] ??
        (widget.productItem.syncColorImages?.length ?? 0) ~/ 2;
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList.removeWhere((element) => element.images.isNullOrEmpty);
    syncColorImageList = [
      ...syncColorImageList,
      ...syncColorImageList,
    ];
    images = syncColorImageList.map((e) => e.images![0].filePath!).toList();
    orginalHeight = syncColorImageList
        .map((e) => double.parse(e.images![0].originalHeight!))
        .toList();
    orginalWidth = syncColorImageList
        .map((e) => double.parse(e.images![0].originalWidth!))
        .toList();

    gallery3dControllerForCircles =
        syncColorImageList.isNullOrEmpty || syncColorImageList.length < 3
            ? null
            : Gallery3DController(
                itemCount: syncColorImageList.length,
                autoLoop: false,
                minScale: (syncColorImageList.length) == 4
                    ? 0.7
                    : (syncColorImageList.length) <= 8
                        ? 0.55
                        : 0.4,
                initialIndex: currentColor,
                primaryshiftingOffsetDivision: (syncColorImageList.length) == 4
                    ? 4.5
                    : (syncColorImageList.length) <= 8
                        ? 1.6
                        : 1.6,
                scrollTime: 1);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return ValueListenableBuilder<int>(
        valueListenable: currentActiveTab,
        builder: (context, currentTab, _) {
          return ValueListenableBuilder<double>(
              valueListenable: workOnBlurNotifier,
              child: SlidingUpPanel(
            /*    denyVericalSliding:  (currentPosition) {
                        if (panelController.panelPosition != 1) {
                          return false;
                        }
                        if (gallery3dControllerForCircles != null) {
                          if (offsetOfColorsGallerySlider == null) {
                            final RenderBox renderBox = colorsGallerySliderKey
                                .currentContext!
                                .findRenderObject() as RenderBox;
                            offsetOfColorsGallerySlider =
                                renderBox.localToGlobal(Offset.zero);
                          }
                          if (currentPosition.dx >=
                                  offsetOfColorsGallerySlider!.dx &&
                              currentPosition.dx <=
                                  (offsetOfColorsGallerySlider!.dx + 200) &&
                              currentPosition.dy >= (288.h + (35.w + 10.h)) &&
                              currentPosition.dy <=
                                  (288.h + (70.w + 70.w + 10.h))) {
                            userWantToScrollHorizontally = true;
                          }
                        }
                        return userWantToScrollHorizontally;
                      }*/
             
                controller:panelController,
                maxHeight: 
                             1.sh - 179 //330.h + 70.w + 305
                            ,
                minHeight: 78,
                onPanelClosed: () {
               /*   widget.addToBagButtonShapeNotifier.value = 0;
                  setState(
                    () {
                      tag = 'cart';
                    },
                  );*/
                 
                /*  homeBloc.add(
                    AddMultiItemsToCartEvent(
                      maxAllowed: widget.maxAllowedToAddCart,
                      boutiqueIcon: widget.boutiqueIcon,
                      productSlugForTopic: widget.productSlugForTopic,
                      boutiqueId: widget.boutiqueId,
                      products: widget.productItem,
                      id: widget.productItem.id.toString(),
                    ),
                  );*/
            
                //  sizeIsNotAvailableNotifier.value = null;
               //   firstOpenOfPanel = true;
               //   denySlidingBackForSlidingUpPanels.value = false;
               //   currentActiveTab.value = -1;
               //   tag = '';
                },
                onPanelOpened: () {
                 // denySlidingBackForSlidingUpPanels.value = true;
               //   firstOpenOfPanel = false;
                },
                color: currentTab == 3 ? Colors.transparent : Colors.white,
                boxShadow: [
                  CustomBoxShadow(
                      color: Colors.transparent,
                      offset: Offset(10.0, 10.0),
                      blurRadius: 10.0,
                      blurStyle: BlurStyle.outer)
                ],
                isDraggable: (currentTab == -1 ? false : true),
                onPanelSlide: currentTab == 3
                    ? (percentOfOpenPart) {
                        workOnBlurNotifier.value =
                            20 * (percentOfOpenPart - 0.6);
                   
                      }
                    : null,
                panelBuilder: (controller) => Column(
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentTab == 3) ...{
                      SizedBox(
                        height: 1.sh - (288.h + 70.w + 305) - 180,
                      ),
                      LocalHero(
                              tag: 'cart',
                              child: ProductDetailsImageWidget(
                                width: 198.w,
                                height: 280.h,
                                imageWidth: 320,
                                imageHeight: 464,
                                orginalWidth: double.tryParse(
                                    gallery3dControllerForCircles != null
                                        ?widget. orginalWidth![currentIndexInSlider]
                                            .toString()
                                        : widget.productItem.images![0]
                                            .originalWidth
                                            .toString()),
                                orginalHeight: double.tryParse(
                                    gallery3dControllerForCircles != null
                                        ? widget.orginalHeight![currentIndexInSlider]
                                            .toString()
                                        : widget.productItem.images![0]
                                            .originalHeight
                                            .toString()),
                                imageUrl: gallery3dControllerForCircles != null
                                    ? images[currentIndexInSlider]
                                    : widget.productItem.images![0].filePath,
                              ))
                          ,
                      5.verticalSpace,
                      Material(
                        color: Colors.transparent,
                        child: gallery3dControllerForCircles != null
                            ? Directionality(
                                textDirection: TextDirection.ltr,
                                child: Gallery3D(
                                    key: colorsGallerySliderKey,
                                 
                                    controller: gallery3dControllerForCircles!,
                                    denyScrolling: false,
                                    width: 200,
                                    stopScrollingOnEdges:
                                        (double primaryDelta) {
                                      return (primaryDelta <= 0 &&
                                              gallery3dControllerForCircles!
                                                      .currentIndex ==
                                                  (syncColorImageList.length ~/
                                                          2 -
                                                      1)) ||
                                          (primaryDelta >= 0 &&
                                              gallery3dControllerForCircles!
                                                      .currentIndex ==
                                                  0);
                                    },
                                    changingPagesScrollOffset: 0.1,
                                    isClip: false,
                                    onItemChanged: (index) {
                                      currentIndexInSlider = index;
                                      homeBloc.add(AddCurrentSelectedColorEvent(
                                          currentSelectedColor: index %
                                              (syncColorImageList.length ~/ 2),
                                          productId: widget.productItem.id
                                              .toString()));
                                    },
                                    itemConfig: GalleryItemConfig(
                                        width: 70.w,
                                        height: 70.w,
                                        radius: 180,
                                        isShowTransformMask: false,
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            offset: Offset(0, 3),
                                            blurRadius: 6,
                                          ),
                                        ]),
                                    itemBuilder: (context, index) {
                                      return Visibility(
                                        visible: ((gallery3dControllerForCircles
                                                            ?.currentIndex ??
                                                        0) <
                                                    (syncColorImageList
                                                            .length ~/
                                                        2) &&
                                                index <
                                                    (syncColorImageList
                                                            .length ~/
                                                        2)) ||
                                            ((gallery3dControllerForCircles
                                                            ?.currentIndex ??
                                                        0) >=
                                                    (syncColorImageList
                                                            .length ~/
                                                        2) &&
                                                index >=
                                                    (syncColorImageList
                                                            .length ~/
                                                        2)),
                                        child: ProductListingImageWidget(
                                        
                                          width: 70.w,
                                          height: 70.w,
                                          imageWidth: 70,
                                          imageHeight: 70,
                                          imageUrl: images[index],
                                          innerShadowYOffset: 4,
                                          borderColor: index ==
                                                  currentIndexInSlider
                                              ? Color(int.parse(
                                                  '0xff${widget.productItem.colors![currentIndexInSlider % widget.productItem.colors!.length].color!.substring(1)}'))
                                              : Colors.white,
                                          circleShape: true,
                                        ),
                                      );
                                    }),
                              )
                            : SizedBox(
                                height: 70.w,
                              ),
                      ),
                      5.verticalSpace,
                    },
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) =>
                                previous.getCurrencyForCountryModel !=
                                    current.getCurrencyForCountryModel ||
                                previous.CurrentColorSizeForCart?["size"] !=
                                    current.CurrentColorSizeForCart?["size"] ||
                                previous.currentSelectedColorForEveryProduct !=
                                    current
                                        .currentSelectedColorForEveryProduct ||
                                previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                    current
                                        .getProductDetailWithoutSimilarRelatedProductsStatus,
                            builder: (context, state) {
                              print(
                                  "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${widget.productItem.price!}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!}");
                              return ProductDetailsSheetHeader(
                                decimalPoint: state
                                        .startingSetting?.decimalPointSetting ??
                                    2,
                                priceSymbol: state.getCurrencyForCountryModel!
                                        .data!.currency!.symbol ??
                                    "",
                                addToBagButtonShapeNotifier:
                                    widget.addToBagButtonShapeNotifier,
                                price: (widget.productItem.price! *
                                        state.getCurrencyForCountryModel!.data!
                                            .currency!.exchangeRate!)
                                    .toString(),
                                offerPrice: (widget.productItem.offerPrice! *
                                        state.getCurrencyForCountryModel!.data!
                                            .currency!.exchangeRate!)
                                    .toString(),
                              );
                            }),
                        currentTab != -1
                            ? Positioned(
                                top: 7,
                                child: SvgPicture.asset(
                                  AppAssets.minusMarkSvg,
                                  width: 25,
                                  color: Colors.grey.shade200,
                                ))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    currentTab < 3 && currentTab >= 0
                        ? SizedBox(
                            height: 358,
                            child: PageView(
                              physics: const cupertino.ClampingScrollPhysics(),
                              scrollBehavior:
                                  const cupertino.CupertinoScrollBehavior(),
                              controller: pageController,
                              onPageChanged: (index) {
                                currentActiveTab.value = index;
                                if (idsOfChatCardsToShare.value.isNotEmpty) {
                                  idsOfChatCardsToShare.value = [];
                                }
                              },
                              children: [
                                ProductDetailsSheetCommentsContent(
                                    productSlugForTopic:
                                        widget.productSlugForTopic,
                                    productSlug: widget.productItem.slug ?? "",
                                    productId: widget.productItem.id.toString(),
                                    scrollController:
                                        currentTab == 0 ? controller : null),
                                BlocBuilder<HomeBloc, HomeState>(
                                    buildWhen: (p, c) =>
                                        p.CurrentColorSizeForCart?["size"] !=
                                        c.CurrentColorSizeForCart?["size"],
                                    builder: (context, state) {
                                      return ProductDetailsSheetShareContent(
                                          currentSize: state
                                                      .CurrentColorSizeForCart !=
                                                  null
                                              ? state.CurrentColorSizeForCart![
                                                      "size"] ??
                                                  ""
                                              : "",
                                          currentColor: widget.currentColorName,
                                          productDescription:
                                              widget.productDescription,
                                          productItem: widget.productItem,
                                          focusNode: _focusNode,
                                          scrollController: currentTab == 1
                                              ? controller
                                              : null,
                                          idsOfChatCardsToShare:
                                              idsOfChatCardsToShare);
                                    }),
                                ProductDetailsSheetMoreOptionsContent(
                                  productSlugForTopic:
                                      widget.productSlugForTopic,
                                  productSlug: widget.productItem.slug ?? "",
                                  scrollController:
                                      currentTab == 2 ? controller : null,
                                  productId: widget.productItem.id.toString(),
                                )
                              ],
                            ),
                          )
                        : currentTab == 3
                            ? BlocBuilder<HomeBloc, HomeState>(
                                buildWhen: (p, c) =>
                                    p.currentSelectedColorForEveryProduct[
                                            widget.productItem.id.toString()] !=
                                        c.currentSelectedColorForEveryProduct[
                                            widget.productItem.id.toString()] ||
                                    p.CurrentColorSizeForCart?["size"] !=
                                        c.CurrentColorSizeForCart?["size"],
                                builder: (context, state) {
                                  return SelectSizeContent(
                                    productId: widget.productItem.id.toString(),
                                    sizes: state.sizes ?? [],
                                    sizesQuantities:
                                        state.sizesQuantities ?? [],
                                    scrollController: controller,
                                    selectedColorName: widget
                                            .productItem.colors.isNullOrEmpty
                                        ? null
                                        : widget
                                            .productItem
                                            .colors![
                                                state.currentSelectedColorForEveryProduct[
                                                        widget.productItem.id
                                                            .toString()] ??
                                                    (widget
                                                                .productItem
                                                                .syncColorImages
                                                                ?.length ??
                                                            0) ~/
                                                        2]
                                            .name
                                            .toString(),
                                    selectedColor: widget
                                            .productItem.colors.isNullOrEmpty
                                        ? null
                                        : Color(int.parse(
                                            '0xff${widget.productItem.colors![state.currentSelectedColorForEveryProduct[widget.productItem.id.toString()] ?? (widget.productItem.syncColorImages?.length ?? 0) ~/ 2].color!.substring(1)}')),
                                    sizeIsNotAvailableNotifier:
                                        sizeIsNotAvailableNotifier,
                                    addToBagButtonShapeNotifier:
                                        widget.addToBagButtonShapeNotifier,
                                  );
                                },
                              )
                            : const SizedBox.shrink(),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
              ),
              builder: (context, blurValue, child) {
                return Stack(
                  children: [
                    ClipRect(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: currentTab == 3 ? blurValue : 0,
                              sigmaY: currentTab == 3 ? blurValue : 0),
                          child: child!),
                    ),
                /*    if (currentTab == 3) ...{
                      Positioned(
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10.0),
                          child: Transform.translate(
                            offset: Offset(0, -50),
                            child: tag == ''
                                ? SizedBox.shrink()
                                : Visibility(
                                    visible: tag == 'cart',
                                    child: LocalHero(
                                      tag: 'cart',
                                      child: SvgPicture.asset(
                                        AppAssets.bagsSvg,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    }*/
                  ],
                );
              });
        });
  }
}
*/