/// نموذج `GET {MARKET_API}/shop/info` — ملف المتجر العام.
///
/// الاستجابة تُقرأ بتسامح: الغلاف قد يكون `{ success, message, data }` وقد يكون
/// السجلّ نفسه بلا غلاف، فنقرأ `data ?? root` كما يفعل عميل الويب. ولا توجد
/// قائمة حقول منشورة لهذه النقطة، فكل حقل يُقرأ دفاعياً ويُقبل غيابه.
class GetShopInfoModel {
  final bool? success;
  final String? message;

  final String? name;
  final String? address;
  final String? contact;

  /// قد تعود باسم ملف مجرّد أو مسار فرعي أو رابط كامل — ثلاثتها مقبولة.
  final String? image;
  final String? banner;

  final ShopCurrency? currency;

  /// `is_new_products_approval`: الغياب أو `null` يعني **غير مقيَّد**، فنعتبره
  /// `true`. القيمة الكاذبة الصريحة وحدها (`false` / `0` / نصّهما) تقيّد البائع.
  final bool isNewProductsApproval;

  /// المتجر الذي حُمّل من أجله هذا السجلّ. لا ترسله الخلفية — نكتبه محلياً من
  /// `X-Seller-ID` وقت نجاح التحميل، وعليه تعتمد فحوص الانتماء قبل الحفظ.
  final String? loadedForSellerId;

  const GetShopInfoModel({
    this.success,
    this.message,
    this.name,
    this.address,
    this.contact,
    this.image,
    this.banner,
    this.currency,
    this.isNewProductsApproval = true,
    this.loadedForSellerId,
  });

  /// السجلّ الفارغ: يُستعمل لمسح ما هو محمَّل عند تبديل المتجر، لأن
  /// `DashBoardState.copyWith` لا يستطيع إعادة أي حقل إلى `null`.
  const GetShopInfoModel.empty() : this();

  bool get isEmpty =>
      name == null &&
      address == null &&
      contact == null &&
      image == null &&
      banner == null &&
      loadedForSellerId == null;

  static bool _readApprovalFlag(dynamic raw) {
    if (raw == null) return true; // غائب = غير مقيَّد
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final String text = raw.toString().trim().toLowerCase();
    if (text.isEmpty) return true;
    return text != 'false' && text != '0';
  }

  static String? _readString(dynamic raw) {
    if (raw == null) return null;
    final String text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory GetShopInfoModel.fromJson(dynamic response) {
    if (response is! Map) return const GetShopInfoModel();

    final Map root = response;
    // الغلاف قد يحمل `data`، وقد يكون السجلّ نفسه هو الجذر.
    final dynamic payload = root['data'];
    final Map record = payload is Map ? payload : root;

    return GetShopInfoModel(
      success: root['success'] is bool ? root['success'] as bool : null,
      message: _readString(root['message']),
      name: _readString(record['name']),
      address: _readString(record['address']),
      contact: _readString(record['contact']),
      image: _readString(record['image']),
      banner: _readString(record['banner']),
      currency: record['currency'] is Map
          ? ShopCurrency.fromJson(record['currency'] as Map)
          : null,
      isNewProductsApproval: _readApprovalFlag(record['is_new_products_approval']),
    );
  }

  GetShopInfoModel copyWith({
    bool? success,
    String? message,
    String? name,
    String? address,
    String? contact,
    String? image,
    String? banner,
    ShopCurrency? currency,
    bool? isNewProductsApproval,
    String? loadedForSellerId,
  }) => GetShopInfoModel(
    success: success ?? this.success,
    message: message ?? this.message,
    name: name ?? this.name,
    address: address ?? this.address,
    contact: contact ?? this.contact,
    image: image ?? this.image,
    banner: banner ?? this.banner,
    currency: currency ?? this.currency,
    isNewProductsApproval: isNewProductsApproval ?? this.isNewProductsApproval,
    loadedForSellerId: loadedForSellerId ?? this.loadedForSellerId,
  );

  @override
  bool operator ==(Object other) =>
      other is GetShopInfoModel &&
      other.name == name &&
      other.address == address &&
      other.contact == contact &&
      other.image == image &&
      other.banner == banner &&
      other.currency == currency &&
      other.isNewProductsApproval == isNewProductsApproval &&
      other.loadedForSellerId == loadedForSellerId;

  @override
  int get hashCode => Object.hash(
    name,
    address,
    contact,
    image,
    banner,
    currency,
    isNewProductsApproval,
    loadedForSellerId,
  );
}

class ShopCurrency {
  final String? code;
  final String? name;

  const ShopCurrency({this.code, this.name});

  factory ShopCurrency.fromJson(Map json) => ShopCurrency(
    code: json['code']?.toString(),
    name: json['name']?.toString(),
  );

  @override
  bool operator ==(Object other) =>
      other is ShopCurrency && other.code == code && other.name == name;

  @override
  int get hashCode => Object.hash(code, name);
}

/// استجابة `PUT {MARKET_API}/shop/info`.
///
/// نموذج صغير خاص بالكتابة بدل توسيع `ReadOnlyMessageFromApiModel`: ذاك مشترك
/// مع الرئيسية والطلبات والمستخدمين والستوري، ولا يحمل `success` — وبدونه لا
/// يمكن تمييز `HTTP 200` مع `success: false` عن النجاح.
class UpdateShopInfoResponseModel {
  final bool? success;
  final String? message;

  const UpdateShopInfoResponseModel({this.success, this.message});

  /// النجاح يُقرَّر من العَلَم لا من رمز HTTP. غياب العَلَم يُعامَل نجاحاً،
  /// لأن الطلب وصل هنا أصلاً بعد نجاح النقل.
  bool get isSuccess => success ?? true;

  factory UpdateShopInfoResponseModel.fromJson(dynamic response) {
    if (response is! Map) return const UpdateShopInfoResponseModel();
    return UpdateShopInfoResponseModel(
      success: response['success'] is bool
          ? response['success'] as bool
          : null,
      message: response['message']?.toString() ?? response['detail']?.toString(),
    );
  }
}
