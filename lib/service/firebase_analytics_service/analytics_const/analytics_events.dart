class AnalyticsEventsConst {
  // static const buttonClicked = 'button_clicked';
  // static const programmingEvent = 'programming_event';
  static const startSession = 'start_session';
  // static const viewedProduct = 'viewed_product';
  // static const viewedBoutique = 'viewed_boutique';

  static const CLICK = "button_clicked";
  static const PROGRAMMING_EVENT = "programming_event";
  static const VIEW_PRODUCT_EVENT = "view_product_event";
  static const VIEW_BOUTIQUE_EVENT = "view_boutique_event";
  static const ENABLE_PRODUCT_NOTIFICATIONS = "enable_product_notifications";
  static const LOGIN = "login";
  static const SIGN_UP = "sign_up";
  static const SCREEN_VIEW = "screen_view_event";
  static const VIEW_IMAGE = "view_image";
  static const LOGIN_START = "login_start";
  static const VIEW_COMMENTS = "view_comments";
  static const READ_MORE_ABOUT_PRODUCT = "read_more_about_product";
  static const CONFIRM_PHONE_NUMBER = "confirm_phone_number";
  static const VERIFY_OTP = "verify_otp";
  static const VERIFY_OTP_SIGNIN = "verify_otp_login";
  static const VERIFY_OTP_SIGNUP = "verify_otp_signup";
  static const TIMER_EXPIRED = "timer_expired";
  static const SEND_OTP = "send_otp";
  static const RESEND_OTP = "resend_otp";
  static const CHANGE_SIZE = "change_size";
  static const EXCEPTION = "exception";
  static const CANCEL_LOGIN = "cancel_login";
  static const SIGNUP_START = "sign_up_start";
  static const CREATE_ACCOUNT_CONTINUE = "create_account_continue";
  static const CANCEL_SIGNUP = "cancel_signup";
  static const LATER_TAKE_LOOK_CLICKED = "later_take_look_clicked";
  static const TERMS_SERVICES = "terms_services";
/////////////////////////////// checkout  //////////////////////////////////////
  static const addToCart = "add_to_cart";
  static const removeFromCart = "remove_from_cart";
  static const viewCart = "view_cart";
  static const beginCheckout = "begin_checkout";
  static const addPaymentInfo = "add_payment_info";
  static const addShippingInfo = "add_shipping_info";

  static const purchase = "purchase";
  static const refund = "refund";
  static const postPurchaseRating = "post_purchase_rating";
  /////////////////////////////// home  //////////////////////////////////////
  static const viewBoutique = "view_boutique";
  static const viewCategory = "view_category";
  static const viewItemList = "view_item_list";
  static const viewTimeProduct = "view_time_product";
  static const viewItem = "view_item";
  static const changeColor = "change_color";
  static const itemVariantExchange = "item_variant_exchange";
  static const search = "search";
  static const viewPromotion = "view_promotion";
  static const applyFilter = "apply_filter";
  static const viewStory = "view_story";
  static const customEventWithPreviousButton =
      "custom_event_with_previous_button";
  static const likeItem = "like_item";
  static const shareContent = "share_content";
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
