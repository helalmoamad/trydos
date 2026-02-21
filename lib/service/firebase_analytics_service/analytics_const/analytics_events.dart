class AnalyticsEventsConst {
  static const CLICK = "button_clicked";
  static const PROGRAMMING_EVENT = "programming_event";
  static const VIEW_PRODUCT_EVENT = "view_item";
  static const VIEW_ITEM_PRODUCT = "view_time_product";
  static const CUSTOM_USER_MAPPING = "custom_user_mapping";
  static const VIEW_BOUTIQUE_EVENT = "view_boutique_event";
  static const LOGIN = "login";
  static const SIGN_UP = "sign_up";
  static const SCREEN_VIEW = "screen_view_event";
  static const LOGIN_START = "login_start";
  static const CONFIRM_PHONE_NUMBER = "confirm_phone_number";
  static const VERIFY_OTP = "verify_otp";
  static const TIMER_EXPIRED = "timer_expired";
  static const SEND_OTP = "send_otp";
  static const RESEND_OTP = "resend_otp";
  static const EXCEPTION = "exception";
  static const CANCEL_LOGIN = "cancel_login";
  static const SIGNUP_START = "sign_up_start";
  static const CREATE_ACCOUNT_CONTINUE = "create_account_continue";
  static const CANCEL_SIGNUP = "cancel_signup";
  static const LATER_TAKE_LOOK_CLICKED = "later_take_look_clicked";
  static const TERMS_SERVICES = "terms_services";
  static const ADD_TO_CART = "add_to_cart";
  static const REMOVE_FROM_CART = "remove_from_cart";
  static const VIEW_CART = "view_cart";
  static const BEGIN_CHECKOUT = "begin_checkout";
  static const ADD_PAYMENT = "add_payment_info";
  static const ADD_ADDRESS = "add_shipping_info";
  static const PURCHASE = "purchase";
  static const VIEW_ITEMS_LIST = "view_item_list";
  static const ITEM_VARIANT_EXCHANGE = "item_variant _exchange";
  static const SEARCH = "search";
  static const VIEW_STORY = "view_story";
  static const LIKE_ITEM = "like_item";
  static const SHARE_CONTENT = "share_content";
  static const COUPON_VIEWED = "coupon_page_viewed";
  static const COUPON_USED = "coupon_used";
  static const VIEW_IMAGE = "view_image";
  static const ZOOM_IMAGE = "zoom_image";
  static const VIEW_SIZE_COLOR_CHART = "view_size_color_chart";
  static const CHANGE_SIZE = "change_size";
  static const CHANGE_COLOR = "change_color";
  static const APPLY_FILTER = "apply_filter";
  static const VIEW_COMMENTS = "view_comments";
  static const READ_MORE = "read_more_about_product";
  static const ENABLE_PRODUCT_NOTIFICATION = "enable_product_notifications";
  static const ADD_TO_FAV = "add_product_to_favorites";
  static const RECOMENDED = "recommended";

  // Legacy aliases for backward compatibility
  static const viewCategory = "view_category";
  static const viewPromotion = "view_promotion";
  static const customEventWithPreviousButton =
      "custom_event_with_previous_button";

  static const refund = "refund";
  static const postPurchaseRating = "post_purchase_rating";
  static const VERIFY_OTP_SIGNIN = "verify_otp_login";
  static const VERIFY_OTP_SIGNUP = "verify_otp_signup";
}

class GlobalPlatform {
  static const WEB = "web";
  static const MOBILE = "mobile";
}

class GA_PAYMENTS {
  static const WALLET = "wallet";
  static const CRYPTO = "crypto";
  static const CREDIT = "credit";
  static const COD = "cash_on_delivery";
}
