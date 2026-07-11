class AnalyticsEventsConst {
  static const CLICK = "button_clicked"; //
  static const PROGRAMMING_EVENT = "programming_event"; //
  static const VIEW_PRODUCT_EVENT = "view_item"; //
  static const VIEW_ITEM_PRODUCT = "view_time_product"; //
  static const CUSTOM_USER_MAPPING = "custom_user_mapping"; //
  static const VIEW_BOUTIQUE_EVENT = "view_boutique_event"; //
  static const LOGIN = "login"; //
  static const SIGN_UP = "sign_up"; //
  static const SCREEN_VIEW = "screen_view_event"; //
  static const LOGIN_START = "login_start"; //
  static const CONFIRM_PHONE_NUMBER = "confirm_phone_number"; //
  static const VERIFY_OTP = "verify_otp"; //
  static const TIMER_EXPIRED = "timer_expired"; //
  static const SEND_OTP = "send_otp"; //
  static const RESEND_OTP = "resend_otp"; //
  static const EXCEPTION = "exception"; //
  static const CANCEL_LOGIN = "cancel_login"; //
  static const SIGNUP_START = "sign_up_start"; //
  static const CREATE_ACCOUNT_CONTINUE = "create_account_continue"; //
  static const CANCEL_SIGNUP = "cancel_signup"; //
  static const LATER_TAKE_LOOK_CLICKED = "later_take_look_clicked"; //
  static const TERMS_SERVICES = "terms_services"; //
  static const ADD_TO_CART = "add_to_cart"; //
  static const REMOVE_FROM_CART = "remove_from_cart"; //
  static const VIEW_CART = "view_cart"; //
  static const BEGIN_CHECKOUT = "begin_checkout"; //
  static const ADD_PAYMENT = "add_payment_info"; //
  static const ADD_ADDRESS = "add_shipping_info"; //
  static const PURCHASE = "purchase"; //
  static const VIEW_ITEMS_LIST = "view_item_list"; //
  static const ITEM_VARIANT_EXCHANGE = "item_variant _exchange"; //
  static const SEARCH = "search"; //
  static const VIEW_STORY = "view_story"; //
  static const LIKE_ITEM = "like_item"; //
  static const SHARE_CONTENT = "share_content"; //
  static const COUPON_VIEWED = "coupon_page_viewed"; //
  static const COUPON_USED = "coupon_used"; //
  static const VIEW_IMAGE = "view_image"; //
  static const ZOOM_IMAGE = "zoom_image"; //
  static const VIEW_SIZE_COLOR_CHART = "view_size_color_chart"; //
  static const CHANGE_SIZE = "change_size"; //
  static const CHANGE_COLOR = "change_color"; //
  static const APPLY_FILTER = "apply_filter"; //
  static const VIEW_COMMENTS = "view_comments"; //
  static const READ_MORE = "read_more_about_product"; //
  static const ENABLE_PRODUCT_NOTIFICATION = "enable_product_notifications"; //
  static const ADD_TO_FAV = "add_product_to_favorites"; //
  static const RECOMENDED = "recommended"; //

  // Legacy aliases for backward compatibility
  static const viewCategory = "view_category";
  static const viewPromotion = "view_promotion";
  static const customEventWithPreviousButton =
      "custom_event_with_previous_button";

  static const refund = "refund";
  static const postPurchaseRating = "post_purchase_rating";
  static const VERIFY_OTP_SIGNIN = "verify_otp_login";
  static const VERIFY_OTP_SIGNUP = "verify_otp_signup";

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //// added By Ali
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  static const view_story_button = "view_story_button";
  static const add_to_cart_widget_opened = "add_to_cart_widget_opened";
  static const add_to_cart_buy_clicked = "add_to_cart_buy_clicked";
  static const order_add_to_cart = "order_add_to_cart";
  static const cart_item_qty_increased = "cart_item_qty_increased";
  static const cart_item_qty_decreased = "cart_item_qty_decreased";
  static const cart_item_removed = "cart_item_removed";
  static const cart_item_moved_to_old = "cart_item_moved_to_old";
  static const old_cart_item_removed = "old_cart_item_removed";
  static const old_cart_cleared = "old_cart_cleared";
  static const order_cart_viewed = "order_cart_viewed";
  static const coupon_apply_attempt = "coupon_apply_attempt";
  static const coupon_apply_succeeded = "coupon_apply_succeeded";
  static const coupon_apply_failed = "coupon_apply_failed";
  static const discount_totals_shown = "discount_totals_shown";
  static const order_coupon_used = "order_coupon_used";
  static const order_begin_checkout = "order_begin_checkout";
  static const checkout_address_screen_viewed =
      "checkout_address_screen_viewed";
  static const address_list_opened = "address_list_opened";
  static const address_add_started = "address_add_started";
  static const address_saved = "address_saved";
  static const address_save_failed = "address_save_failed";
  static const address_selected = "address_selected";
  static const address_deleted = "address_deleted";
  static const payment_method_selected = "payment_method_selected";
  static const checkout_confirm_clicked = "checkout_confirm_clicked";
  static const checkout_blocked_address_missing =
      "checkout_blocked_address_missing";
  static const checkout_blocked_payment_missing =
      "checkout_blocked_payment_missing";
  static const checkout_blocked_balance_insufficient =
      "checkout_blocked_balance_insufficient";
  static const checkout_blocked_phone_unverified =
      "checkout_blocked_phone_unverified";
  static const checkout_blocked_cart_unavailable =
      "checkout_blocked_cart_unavailable";
  static const checkout_empty_cart = "checkout_empty_cart";
  static const verify_flow_opened = "verify_flow_opened";
  static const verify_otp_failed = "verify_otp_failed";
  static const verify_completed_returned_to_checkout =
      "verify_completed_returned_to_checkout";
  static const terms_agreed_toggled = "terms_agreed_toggled";
  static const place_order_clicked = "place_order_clicked";
  static const place_order_blocked_terms_not_agreed =
      "place_order_blocked_terms_not_agreed";
  static const place_order_blocked_phone_unverified =
      "place_order_blocked_phone_unverified";
  static const place_order_blocked_cart_unavailable =
      "place_order_blocked_cart_unavailable";
  static const place_order_empty_cart = "place_order_empty_cart";
  static const order_submit_attempt = "order_submit_attempt";
  static const payment_redirect_opened = "payment_redirect_opened";
  static const order_place_failed = "order_place_failed";
  static const wallet_modal_opened = "wallet_modal_opened";
  static const wallet_payment_attempt = "wallet_payment_attempt";
  static const wallet_payment_blocked_insufficient =
      "wallet_payment_blocked_insufficient";
  static const wallet_payment_processing = "wallet_payment_processing";
  static const wallet_payment_succeeded = "wallet_payment_succeeded";
  static const wallet_payment_timeout = "wallet_payment_timeout";
  static const wallet_payment_failed = "wallet_payment_failed";
  static const wallet_currency_changed = "wallet_currency_changed";
  static const wallet_data_load_failed = "wallet_data_load_failed";
  static const wallet_balance_refreshed = "wallet_balance_refreshed";
  static const order_completed = "order_completed";
  static const order_success_done_clicked = "order_success_done_clicked";
  static const order_history_viewed = "order_history_viewed";
  static const order_history_filtered = "order_history_filtered";
  static const order_details_viewed = "order_details_viewed";
  static const order_item_change_requested = "order_item_change_requested";
  static const order_address_changed = "order_address_changed";
  static const order_cancelled = "order_cancelled";
  static const order_item_cancelled = "order_item_cancelled";
  static const order_return_requested = "order_return_requested";
  static const order_item_rated = "order_item_rated";
  static const order_item_reported = "order_item_reported";
  static const order_options_opened = "order_options_opened";
  static const order_item_options_opened = "order_item_options_opened";
  static const order_pack_hidden = "order_pack_hidden";
  static const order_item_hidden = "order_item_hidden";
  static const story_product_clicked = "story_product_clicked";
  static const story_link_clicked = "story_link_clicked";
  static const story_uploaded = "story_uploaded";
  static const chat_opened = "chat_opened";
  static const chat_message_sent = "chat_message_sent";
  static const chat_product_shared = "chat_product_shared";
  static const delivery_stats_viewed = "delivery_stats_viewed";
  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////
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
