/// Test ledger · wave 03 Browsing, search and the product page — the
/// catalogue response bodies.
///
/// `api/products/searchInCatalog` answers with one shape for everything: the
/// page of products and, alongside it, the facets the filter sheet is built
/// from (brands, colours, attributes, categories, the price band). Writing that
/// out in every test would bury the one field a test is about, so it is built
/// here and each test overrides only what it cares about.
library;

import 'dart:convert';

/// The cached copy of an envelope, as the app stores it in preferences.
String jsonOf(Map<String, dynamic> envelope) => jsonEncode(envelope);

/// One product, as a listing returns it.
///
/// Every product carries a brand and a category **on purpose**: the listing's
/// success branch reads `product.brand!.name` and `product.categories!` for its
/// analytics event without a null check, so a product without them throws
/// inside the handler. That is the server's contract, not a test convenience.
Map<String, dynamic> catalogueProduct({
  int id = 1,
  String? name,
  String? slug,
  num price = 100,
  String brand = 'acme',
  String category = 'dresses',
}) {
  return <String, dynamic>{
    'product_id': id,
    'boutique_id': 7,
    'name': name ?? 'Product $id',
    'slug': slug ?? 'product-$id',
    'price': price,
    'offer_price': price,
    'is_active': true,
    'brand': <String, dynamic>{
      'id': 3,
      'name': brand,
      'slug': brand,
      'icon': 'https://img.test/brand/$brand.png',
    },
    'categories': <Map<String, dynamic>>[
      <String, dynamic>{'id': 11, 'name': category, 'slug': category},
    ],
    'images': <Map<String, dynamic>>[
      <String, dynamic>{'file_path': 'https://img.test/product/$id.jpg'},
    ],
  };
}

/// A page of products plus the facets that describe the whole result.
///
/// [offset] is the server's cursor for the next page. The listing hands it back
/// verbatim on the next request, so a test that pages must give each page its
/// own offset or it cannot tell page 2 from a repeat of page 1.
Map<String, dynamic> productListingEnvelope({
  List<Map<String, dynamic>>? products,
  int? totalSize,
  List<num> offset = const <num>[],
  List<Map<String, dynamic>> brands = const <Map<String, dynamic>>[],
  List<String> colors = const <String>[],
  List<Map<String, dynamic>> attributes = const <Map<String, dynamic>>[],
  List<Map<String, dynamic>> categories = const <Map<String, dynamic>>[],
  Map<String, dynamic>? prices,
}) {
  final List<Map<String, dynamic>> page =
      products ?? <Map<String, dynamic>>[catalogueProduct()];
  return <String, dynamic>{
    'message': null,
    'data': <String, dynamic>{
      'total_size': totalSize ?? page.length,
      'limit': 10,
      'offset': offset,
      'products': page,
      'brands': brands,
      'colors': colors,
      'attributes': attributes,
      'categories': categories,
      'boutiques': <Map<String, dynamic>>[],
      'prices': prices,
    },
  };
}

/// A brand facet, as the filter sheet lists it.
Map<String, dynamic> brandFacet(String slug, {int id = 3}) =>
    <String, dynamic>{
      'id': id,
      'name': slug,
      'slug': slug,
      'icon': 'https://img.test/brand/$slug.png',
    };

/// An attribute facet — "Size", with the values the sheet offers.
Map<String, dynamic> attributeFacet({
  int id = 5,
  String name = 'Size',
  List<String> options = const <String>['S', 'M', 'L'],
}) =>
    <String, dynamic>{'id': id, 'name': name, 'options': options};

/// The main-category tabs across the top of the home screen, in server order.
Map<String, dynamic> mainCategoriesEnvelope(List<String> slugs) =>
    <String, dynamic>{
      'message': null,
      'data': <String, dynamic>{
        'mainCategories': <Map<String, dynamic>>[
          for (int i = 0; i < slugs.length; i++)
            <String, dynamic>{
              'id': i + 1,
              'name': slugs[i],
              'slug': slugs[i],
              'total_product': 10,
              'flat_photo_path': <String, dynamic>{
                'file_path': 'https://img.test/cat/${slugs[i]}.png',
              },
            },
        ],
      },
    };

/// One boutique card on the home screen.
///
/// It carries a banner **on purpose**: the handler reads `banners?.first`
/// without checking the list is non-empty. Pass `withBanner: false` to build
/// the shape that exposes that — see the pinned test.
Map<String, dynamic> homeBoutique(
  String slug, {
  int id = 1,
  bool withBanner = true,
}) =>
    <String, dynamic>{
      'id': id,
      'name': slug,
      'slug': slug,
      'description': 'the $slug boutique',
      'num_available_product': 12,
      if (withBanner)
        'banners': <Map<String, dynamic>>[
          <String, dynamic>{'file_path': 'https://img.test/boutique/$slug.jpg'},
        ],
    };

/// A page of boutiques for one main-category tab.
Map<String, dynamic> homeBoutiquesEnvelope({
  List<Map<String, dynamic>>? boutiques,
  String? offset,
  int? total,
}) {
  final List<Map<String, dynamic>> page =
      boutiques ?? <Map<String, dynamic>>[homeBoutique('b1')];
  return <String, dynamic>{
    'message': null,
    'data': <String, dynamic>{
      'total': total ?? page.length,
      'limit': 10,
      'offset': offset,
      'boutiques': page,
    },
  };
}

/// The products `n` .. `n + count - 1`, so two pages never share an id.
List<Map<String, dynamic>> productRange(int n, int count) =>
    <Map<String, dynamic>>[
      for (int i = 0; i < count; i++) catalogueProduct(id: n + i),
    ];

/// The product page's own payload — a richer product than a listing card.
///
/// `api/mobile/product/details/<slug>` answers with the product under `data`,
/// and the page reads it back from
/// `state.cachedProductWithoutRelatedProductsModel[id].product`.
Map<String, dynamic> productDetailsEnvelope({
  int id = 77,
  String slug = 'silk-dress',
  num price = 120,
  num offerPrice = 99.5,
  bool isLiked = false,
  List<String> sizes = const <String>['S', 'M'],
  List<Map<String, dynamic>>? colors,
  List<Map<String, dynamic>>? variations,
}) =>
    <String, dynamic>{
      'message': null,
      'data': <String, dynamic>{
        'id': id,
        'slug': slug,
        'price': price,
        'offer_price': offerPrice,
        'price_formatted': '$price',
        'is_liked': isLiked,
        'is_active': true,
        'sizes': sizes,
        'images': <Map<String, dynamic>>[
          <String, dynamic>{'file_path': 'https://img.test/p/$id-a.jpg'},
          <String, dynamic>{'file_path': 'https://img.test/p/$id-b.jpg'},
        ],
        'colors': colors ??
            <Map<String, dynamic>>[
              <String, dynamic>{
                'name': 'red',
                'color_code': '#f00',
                'option': 'red',
              },
              <String, dynamic>{
                'name': 'blue',
                'color_code': '#00f',
                'option': 'blue',
              },
            ],
        'variation': variations ??
            <Map<String, dynamic>>[
              productVariation(id: 1, color: 'red', size: 'S', qty: 4),
              productVariation(id: 2, color: 'red', size: 'M', qty: 0),
              productVariation(id: 3, color: 'blue', size: 'M', qty: 7),
            ],
      },
    };

/// One sellable combination: a colour, a size, and how many are left.
///
/// The id goes out as a **string**: `Variation.id` is a `String?` filled
/// straight from the json with no conversion, so a numeric id from the server
/// would throw while parsing the product.
Map<String, dynamic> productVariation({
  required int id,
  required String color,
  required String size,
  required int qty,
  num price = 120,
}) =>
    <String, dynamic>{
      'id': 'v$id',
      // `type` is the join key: the product page composes "<colour>-<size>"
      // from what the user picked and finds the variation whose type contains
      // it. Everything about a chosen variant — its price, its stock — is
      // reached through this string.
      'type': '$color-$size',
      'color': <String, dynamic>{'name': color, 'code': '#000'},
      'size': size,
      'qty': qty,
      'price': price,
      'offer_price': price,
      'sku': 'sku-$id',
    };

/// The live stock answer from `api/mobile/product/qty/<slug>`.
Map<String, dynamic> productQuantityEnvelope({
  int id = 77,
  int availableQuantity = 3,
  List<Map<String, dynamic>>? variations,
}) =>
    <String, dynamic>{
      'isSuccessful': true,
      'code': 200,
      'data': <String, dynamic>{
        'id': id,
        'available_quantity': availableQuantity,
        'variations': variations ??
            <Map<String, dynamic>>[
              productVariation(id: 1, color: 'red', size: 'S', qty: 4),
            ],
      },
    };

/// The related rail under a product page.
Map<String, dynamic> relatedProductsEnvelope({
  List<Map<String, dynamic>>? products,
}) =>
    <String, dynamic>{
      'isSuccessful': true,
      'code': 200,
      'data': <String, dynamic>{
        'products': products ?? <Map<String, dynamic>>[],
        'offset': <int>[],
        'total_size': (products ?? const <Map<String, dynamic>>[]).length,
      },
    };

/// One buyer review, as the comment server lists it.
Map<String, dynamic> buyerComment({
  required int id,
  String text = 'Good fabric',
  int stars = 5,
  bool isLiked = false,
  int totalLikes = 0,
}) =>
    <String, dynamic>{
      'id': id,
      'comment': text,
      'star_rating': stars,
      'is_liked': isLiked,
      'total_likes': totalLikes,
      // `product_id` is a `String?` on the model, filled straight from the
      // json — a numeric id here throws while parsing the page of reviews.
      'product_id': '77',
      'variant': 'red-M',
      'created_at': '2026-01-01T00:00:00Z',
      // `Customer.id` is a `String?` filled straight from the json, like
      // `product_id` above.
      'customer': <String, dynamic>{'id': '5', 'name': 'A buyer'},
    };

/// A page of buyer reviews.
Map<String, dynamic> buyersCommentsEnvelope({
  List<Map<String, dynamic>>? comments,
}) {
  final List<Map<String, dynamic>> page =
      comments ?? <Map<String, dynamic>>[buyerComment(id: 1)];
  return <String, dynamic>{
    'code': 200,
    'data': <String, dynamic>{
      'buyers_comments': page,
      'total': page.length,
      'offset': <dynamic>[],
    },
  };
}

/// One question-and-answer entry, the other tab beside the reviews.
Map<String, dynamic> fqaComment({required int id, String text = 'Does it run small?'}) =>
    <String, dynamic>{
      'id': id,
      'comment': text,
      'product_id': '77',
      'is_liked': false,
      'total_likes': 0,
      'created_at': '2026-01-01T00:00:00Z',
      // `Customer.id` is a `String?` filled straight from the json, like
      // `product_id` above.
      'customer': <String, dynamic>{'id': '5', 'name': 'A buyer'},
    };

/// A page of questions.
Map<String, dynamic> fqaCommentsEnvelope({List<Map<String, dynamic>>? comments}) {
  final List<Map<String, dynamic>> page =
      comments ?? <Map<String, dynamic>>[fqaComment(id: 100)];
  return <String, dynamic>{
    'code': 200,
    'data': <String, dynamic>{
      'fqa_comments': page,
      'total': page.length,
      'offset': <dynamic>[],
    },
  };
}

/// What the comment server answers when a review is created.
Map<String, dynamic> createdCommentEnvelope({
  String commentId = '9',
  String text = 'Runs small but lovely',
  String rating = '4',
}) =>
    <String, dynamic>{
      'message': 'created',
      'data': <String, dynamic>{
        'comment_id': commentId,
        'product_id': '77',
        'user_id': '5',
        'user_name': 'A buyer',
        'text': text,
        'rating': rating,
        'variant': 'red-M',
        'user_type': 'user',
        'status': 'published',
        'created_at': '2026-01-02T00:00:00Z',
      },
    };
