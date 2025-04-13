//  CustomScrollView(
//                 key: TestVariables.kTestMode
//                     ? Key(WidgetsKeys.homepageScrollKey)
//                     : null,
//                 controller: scrollController,
//                 physics: const ClampingScrollPhysics(
//                     parent: AlwaysScrollableScrollPhysics()),
//                 scrollBehavior: const CupertinoScrollBehavior(),
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: _isLoading
//                         ? Center(
//                             child:
//                                 CircularProgressIndicator()) // إظهار مؤشر التحميل
//                         : SizedBox.shrink(),
//                   ),
//                   ////////////////////
//                   SliverToBoxAdapter(child: 50.verticalSpace),
//                   /////////////////////
//                   SliverToBoxAdapter(
//                     child: 40.verticalSpace,
//                   ),
//                   ////////////////////////
//                   SliverToBoxAdapter(
//                     child: storySection(currentLocale, context),
//                   ),
//                   SliverToBoxAdapter(
//                     child: 5.verticalSpace,
//                   ),
//                   BlocBuilder<AppBloc, AppState>(
//                     builder: (context, appState) {
//                       return BlocBuilder<HomeBloc, HomeState>(
//                         buildWhen: (p, c) {
//                           String? currentSlug = appState.tabIndex != -1
//                               ? (c
//                                       .mainCategoriesResponseModel
//                                       ?.data
//                                       ?.mainCategories?[appState.tabIndex]
//                                       .slug ??
//                                   "Empty")
//                               : "Empty";
//                           bool rebuild = (p
//                                       .getHomeBoutiquesPaginationObjectByMainCategory[
//                                           currentSlug]
//                                       ?.paginationStatus !=
//                                   c
//                                       .getHomeBoutiquesPaginationObjectByMainCategory[
//                                           currentSlug]
//                                       ?.paginationStatus ||
//                               p.currentIndexForMainCategoryEvent !=
//                                   c.currentIndexForMainCategoryEvent);
//                           if (!p.reRequestTheseBoutiques
//                                   .containsKey(currentSlug) &&
//                               c.reRequestTheseBoutiques[currentSlug] == true) {
//                             reRenderingListViewKey[currentSlug] = UniqueKey();
//                           }
//                           return rebuild;
//                         },
//                         builder: (context, homeState) {
//                           String? currentSlug = appState.tabIndex != -1
//                               ? (homeState
//                                       .mainCategoriesResponseModel
//                                       ?.data
//                                       ?.mainCategories?[appState.tabIndex]
//                                       .slug ??
//                                   "Empty")
//                               : "Empty";
//                           if (homeState.boutiquesForEveryMainCategoryThatDidPrefetch[
//                                       currentSlug] !=
//                                   true &&
//                               (homeState.getHomeBoutiquesPaginationObjectByMainCategory[
//                                           currentSlug] ==
//                                       null ||
//                                   ((homeState
//                                                   .getHomeBoutiquesPaginationObjectByMainCategory[
//                                                       currentSlug]
//                                                   ?.paginationStatus ==
//                                               PaginationStatus.loading ||
//                                           homeState
//                                                   .getHomeBoutiquesPaginationObjectByMainCategory[
//                                                       currentSlug]
//                                                   ?.paginationStatus ==
//                                               PaginationStatus.initial) &&
//                                       (homeState
//                                                   .getHomeBoutiquesPaginationObjectByMainCategory[
//                                                       currentSlug]
//                                                   ?.items
//                                                   .length ??
//                                               0) ==
//                                           0))) {
//                             return sliverListSeparated(
//                               key: TestVariables.kTestMode
//                                   ? Key(WidgetsKeys.boutiquesFailureStatusKey)
//                                   : null,
//                               itemBuilder: (_, index) => Padding(
//                                 padding:
//                                     HWEdgeInsets.symmetric(horizontal: 15.w),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20.0),
//                                   child: Shimmer.fromColors(
//                                     baseColor: Colors.grey.shade300,
//                                     highlightColor: Colors.grey.shade100,
//                                     enabled: true,
//                                     child: Stack(
//                                       alignment: Alignment.center,
//                                       children: [
//                                         Container(
//                                             width: 1.sw,
//                                             height: 235,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.0),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: const Color(0xff000000)
//                                                       .withOpacity(0.4),
//                                                   offset: Offset(0, 3),
//                                                   blurRadius: 6,
//                                                 )
//                                               ],
//                                             )),
//                                         Container(
//                                             margin: EdgeInsets.symmetric(
//                                                 horizontal: 20),
//                                             width: 1.sw,
//                                             height: 135,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20.0),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: const Color(0xff000000)
//                                                       .withOpacity(0.6),
//                                                   offset: Offset(0, 3),
//                                                   blurRadius: 6,
//                                                 )
//                                               ],
//                                             )),
//                                         Positioned(
//                                           bottom: 30,
//                                           child: Row(
//                                             children: List.generate(
//                                                 5,
//                                                 (index) => CircleAvatar(
//                                                       radius: 20,
//                                                     )),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               //HomePageCard(showWhite: index % 2 == 0),
//                               separator: SizedBox(
//                                 height: 20,
//                               ),
//                               childCount: 10,
//                             );
//                           }
//                           return sliverListSeparated(
//                             key: TestVariables.kTestMode
//                                 ? Key(WidgetsKeys.boutiquesSuccessStatusKey)
//                                 : reRenderingListViewKey[currentSlug],
//                             itemBuilder: (_, index) => Padding(
//                                 padding:
//                                     HWEdgeInsets.symmetric(horizontal: 15.w),
//                                 child: homeState
//                                         .getHomeBoutiquesPaginationObjectByMainCategory[
//                                             currentSlug]!
//                                         .items[index]
//                                         .banners
//                                         .isNullOrEmpty
//                                     ? SizedBox.shrink()
//                                     : HomePageCard2(
//                                         isShowPanelForVerified:
//                                             widget.isShowPanelForVerified,
//                                         key: TestVariables.kTestMode
//                                             ? Key(
//                                                 '${WidgetsKeys.boutiqueCardKey}$index')
//                                             : null,
//                                         category_Slug: currentSlug,
//                                         withSlidingImages: homeState
//                                                 .getHomeBoutiquesPaginationObjectByMainCategory[
//                                                     currentSlug]!
//                                                 .items[index]
//                                                 .banners!
//                                                 .length >
//                                             1,
//                                         boutique: homeState
//                                             .getHomeBoutiquesPaginationObjectByMainCategory[
//                                                 currentSlug]!
//                                             .items[index],
//                                       )

//                                 //HomePageCard(showWhite: index % 2 == 0),
//                                 ),
//                             separator: SizedBox(
//                               height: 20,
//                             ),
//                             childCount: homeState
//                                     .getHomeBoutiquesPaginationObjectByMainCategory[
//                                         currentSlug]
//                                     ?.items
//                                     .length ??
//                                 0,
//                           );
//                         },
//                       );
//                     },
//                   ),
//                   SliverToBoxAdapter(
//                     child: 20.verticalSpace,
//                   ),
//                   BlocBuilder<AppBloc, AppState>(
//                     builder: (context, appState) {
//                       return BlocBuilder<HomeBloc, HomeState>(
//                           buildWhen: (p, c) {
//                         String? currentSlug = appState.tabIndex != -1
//                             ? (c.mainCategoriesResponseModel?.data
//                                     ?.mainCategories?[appState.tabIndex].slug ??
//                                 "Empty")
//                             : "Empty";
//                         bool rebuild = (p
//                                     .getHomeBoutiquesPaginationObjectByMainCategory[
//                                         currentSlug]
//                                     ?.paginationStatus !=
//                                 c
//                                     .getHomeBoutiquesPaginationObjectByMainCategory[
//                                         currentSlug]
//                                     ?.paginationStatus ||
//                             p.currentIndexForMainCategoryEvent !=
//                                 c.currentIndexForMainCategoryEvent);
//                         return rebuild;
//                       }, builder: (context, state) {
//                         String? currentSlug = appState.tabIndex != -1
//                             ? (state.mainCategoriesResponseModel?.data
//                                     ?.mainCategories?[appState.tabIndex].slug ??
//                                 "Empty")
//                             : "Empty";
//                         if (((state
//                                         .getHomeBoutiquesPaginationObjectByMainCategory[
//                                             currentSlug]
//                                         ?.items
//                                         .length ??
//                                     0) !=
//                                 0) &&
//                             state
//                                     .getHomeBoutiquesPaginationObjectByMainCategory[
//                                         currentSlug]
//                                     ?.paginationStatus ==
//                                 PaginationStatus.loading) {
//                           return SliverToBoxAdapter(
//                             child: Center(
//                               child: TrydosLoader(),
//                             ),
//                           );
//                         }
//                         return SliverToBoxAdapter();
//                       });
//                     },
//                   ),
//                   SliverToBoxAdapter(
//                     child: 20.verticalSpace,
//                   ),
//                 ],
//               ),