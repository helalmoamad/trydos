# MARKET_URL endpoints the app really calls

Host: `MARKET_URL` = `https://trydos_develop.ramaaz.dev/` (branch `dev_new`).

**109 live calls, 108 distinct `VERB + path`.** Every row below is wired from a
data source through a repository and a use case to a live BLoC or Cubit. Rows
that exist in code but are no longer reached are **not** in the tables — they are
listed at the end instead.

## How a request lands on this host

The base URI is chosen by `ServerName` in
`lib/core/api/methods/detect_server.dart`. Three values reach `MARKET_URL`:

| `ServerName` | Base URI | Token sent |
| --- | --- | --- |
| `market` | `MarketUrls.baseUri` → `MARKET_URL` — always | market access token |
| `dashBoard` | `DashBoardUrls.baseUri` → `MARKET_URL` — always | market access token |
| `marketGO` | `MARKET_URL` **only when** `prefsRepository.myPhoneNumber.length > 7`, else `MARKETGo_URL` (`https://trydosv2.ramaaz.dev/`) | market access token |

So a `marketGO` row goes to this host for a user who has a stored phone number,
and to `trydosv2.ramaaz.dev` for a guest who does not. The `Server` column in
every table says which value the call uses, so the conditional rows are easy to
spot.

Two more things decide the real base at runtime:

- `main.dart:605` overwrites it from preferences — `MarketUrls.setBaseUrl =
  prefsRepository.getMarketUrl!`. The `.env` value is only the default; the
  developer screen `features/feed_back/.../edit_urls_page.dart` can change it.
- `Authorization`, `X-Seller-ID`, `country` and `lang` headers are injected
  centrally in `BaseApi`, so no row below sets them itself.

## How "really called" was decided

1. Collect every `ServerName.market` / `.dashBoard` / `.marketGO` in `lib/`,
   **after removing comments**. All of them sit in three data sources:
   `home_remote_data_source.dart` (66), `dashBoard_remote_data_source_model.dart`
   (37) and `auth_remote_datasource.dart` (10) — 113 calls.
2. For each call, follow data source → repository → use case → presentation. A
   call counts as live only when the use case class is referenced in
   **uncommented** presentation code and is actually invoked there, not merely
   declared.
3. Four of the 113 failed step 2. They are in the last section.

Comments are stripped at every step, because this repository keeps dead calls as
comments rather than deleting them. That is also why a plain `grep` over the
three data sources reports 125 calls instead of 113.

---

## Auth and session

`POST /api/v1/auth/phone/login` is **not** here — see the last section.

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| POST | `/api/v1/auth/phone/send_otp` | market | `auth_remote_datasource.dart:93` `sendOtp` |
| POST | `/api/v1/auth/phone/verify_otp_signup` | market | `:107` `verifyOtpSignUp` |
| POST | `/api/v1/auth/phone/verify_otp_singin` | market | `:213` `verifyOtpSignIn` |
| POST | `/api/v1/auth/phone/verify_otp` | market | `:125` `verifyOtpInProfile` |
| POST | `/api/v1/auth/phone/verify_otp_from_guest` | market | `:272` `verifyOtpFromGuest` |
| POST | `/api/v1/auth/register-guest` | marketGO | `:308` `registerGuest` |
| POST | `/api/v1/auth/refresh-token` | marketGO | `:328` `refreshToken` |

`verify_otp_singin` is spelled that way on the server too — it is not a typo in
the app.

## Customer profile and addresses

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/customer/info` | marketGO | `auth_remote_datasource.dart:143` `getCustomerInfo` |
| POST | `/api/v1/customer/update-name` | marketGO | `auth_remote_datasource.dart:177` `updateName` |
| POST | `/api/v1/customer/update-profile` | marketGO | `home_remote_data_source.dart:730` `updateProfile` |
| GET | `/api/v1/customer/address/list` | market | `home:765` `getCustomerAddresses` |
| POST | `/api/v1/customer/address/add` | market | `home:465` `addCustomerAddress` |
| POST | `/api/v1/customer/address/update` | market | `home:636` `updateCustomerAddress` |
| POST | `/api/v1/customer/address/delete` | market | `home:446` `deleteCustomerAddress` |
| POST | `/api/v1/customer/address/set-default` | market | `home:1089` `setCustomerAddressDefault` |

## Cart, old cart and coupon

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/cart/cart_shipping` | marketGO | `home:936` `getCartShippingItems` |
| GET | `/api/v1/cart/cart_overview` | marketGO | `home:1458` `getCartOverview` |
| GET | `/api/v1/cart/product_list_in_cart_and_old_cart` | marketGO | `home:976` `getProductsListInCart` |
| GET | `/api/v1/cart/check_availability_product_cart` | marketGO | `home:1427` `checkAvailabilityProductCart` |
| POST | `/api/v1/cart/add` | marketGO | `home:991` `addItemToCart` |
| POST | `/api/v1/cart/update` | marketGO | `home:1152` `updateItemInCart` |
| POST | `/api/v1/cart/remove` | marketGO | `home:1077` `removeItemToCart` |
| POST | `/api/v1/cart/convert_to_old` | marketGO | `home:1059` `convertItemInCartToOldCart` |
| GET | `/api/v1/old-cart/get_old_cart` | marketGO | `home:905` `getOldCartItems` |
| POST | `/api/v1/old-cart/hide` | marketGO | `home:1006` `hideItemsInOldCart` |
| GET | `/api/v1/coupon/apply` | marketGO | `home:1443` `applyCoupon` |

## Orders and checkout

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/customer/order/list` | market | `home:1491` `getOrders` |
| GET | `/api/v1/customer/order/getOrdersByOrderGroupID` | market | `home:1391` `getOrdersByOrderGroupID` |
| GET | `/api/v1/customer/order/getOrdersByCartGroupID` | market | `home:1409` `getOrdersByCartGroupID` |
| GET | `/api/v1/customer/order/getHiddenOrders` | market | `home:1045` `getHiddenOrders` |
| PATCH | `/api/v1/customer/order/{orderId}/visibility` | market | `home:1018` `setOrderVisibility` |
| PATCH | `/api/v1/customer/order/detail/{detailId}/visibility` | market | `home:1030` `setOrderDetailVisibility` |
| POST | `/api/v1/customer/order/checkout/{paymentMethod}` | market | `home:1373` `placeOrder` |
| POST | `/api/v1/customer/order/cancel` | market | `home:1541` `cancelOrder` |
| POST | `/api/v1/customer/order/cancel-item` | market | `home:1506` `cancelOrderItem` |
| POST | `/api/v1/customer/order/change-address` | market | `home:1556` `changeOrderAddress` |
| POST | `/api/v1/customer/order/change-item-variant` | market | `home:1591` `changeOrderItemVariant` |
| POST | `/api/v1/customer/order/report` | market | `home:1652` `reportOrderProduct` |
| GET | `/api/v1/web/product/delivery_times/{productId}` | market | `home:1974` `getDeliveredOrdersResponse` |

`delivery_times` is the one order call whose path constant lives in
`WebAppEndPoints`, not `MarketEndPoints` — but it is sent with
`ServerName.market`, so it goes to this host, not to `WEB_APP`.

## RDB payment

The app never talks to RDB. The backend creates the payment request and returns
a ten-digit code the customer types into the RDB app; the app only polls for its
state.

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| POST | `/api/v1/customer/order/checkout/rdb` | market | `home:1318` `checkoutRdb` |
| GET | `/api/v1/customer/order/rdb-request/{requestReference}` | market | `home:1337` `getRdbPaymentRequest` |
| POST | `/api/v1/customer/order/rdb-request/{requestReference}/cancel` | market | `home:1355` `cancelRdbPaymentRequest` |

These three are called from `rdb_payment_cubit.dart` without a use case layer.

## Returns

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/customer/order/return_requests/reasons` | market | `home:1609` `getReturnReasons` |
| GET | `/api/v1/customer/order/return_requests/store` | market | `home:1728` `storeReturnRequest` |
| GET | `/api/v1/customer/order/return_requests/view` | market | `home:1803` `orderReturnRequestsView` |
| GET | `/api/v1/customer/order/return_requests/order_details_by_group` | market | `home:1822` `getOrderReturnDetails` |
| POST | `/api/v1/customer/order/return_requests/bulk_cancel` | market | `home:1709` `cancelReturnRequest` |
| POST | `/api/v1/customer/order/return_requests/confirm_return_request` | market | `home:1765` `confirmReturnRequest` |
| POST | `/api/v1/customer/order/return_request_products/store` | market | `home:1671` `storeReturnRequestProduct` |
| POST | `/api/v1/customer/order/return_request_products/update` | market | `home:1690` `updateReturnRequestProduct` |
| GET | `/api/v1/customer/order/return_request_products/cancel` | market | `home:1746` `cancelReturnRequestProduct` |

Two writes are sent as `GET`: `return_requests/store` and
`return_request_products/cancel`. That matches the server, but it is worth
knowing when reading the table.

## Notifications and device tokens

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| POST | `/api/v1/firebase_device_tokens` | marketGO | `home:1232` `storeFcmTokenOfMarket` |
| POST | `/api/v1/firebase_device_tokens/validate_token` | marketGO | `home:1522` `sendAcceptOfNotificationMarket` |
| GET | `/api/v1/firebase_device_tokens/my_firebase_settings` | marketGO | `home:503` `getMyFirebaseSettings` |
| POST | `/api/v1/firebase_device_tokens/update_firebase` | marketGO | `home:538` `updateFirebaseNotification` |
| POST | `/api/v1/firebase_device_tokens/update_whatsapp` | marketGO | `home:519` `updateWhatsappNotification` |
| POST | `/api/v1/firebase_device_tokens/update_email` | marketGO | `home:557` `updateEmailNotification` |
| POST | `/api/v1/firebase_device_tokens/update_notification_frequency` | marketGO | `home:576` `updateNotificationFrequency` |
| POST | `/api/v1/firebase_device_tokens/change_country_language` | marketGO | `home:485` `changeCountryLanguageFornotification` |
| POST | `/api/v1/firebase_device_tokens/subscribe_topic` | marketGO | `home:616` `subscribeTopicFornotification` |
| POST | `/api/v1/firebase_device_tokens/unsubscribe_topic` | marketGO | `home:596` `unSubscribeTopicFornotification` |
| GET | `/api/v1/user-notifications/get` | marketGO | `home:1474` `getUserNotifications` |
| GET | `/api/v1/web/notification_types/customer-notification-to-choose` | marketGO | `home:414` `getNotificationTypeForProduct` |

## Startup, country and product attributes

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/mobile/home/startingSettings` | marketGO | `home:88` `getStartingSettings` |
| GET | `/api/v1/mobile/home/currency` | marketGO | `home:705` `getCurrencyForCountry` |
| GET | `/api/v1/countries` | marketGO | `home:1181` `getAllowedCountries` |
| GET | `/api/v1/mobile/product/details_color_sync_attribute/{id}` | marketGO | `home:1575` `getProductColorSizeSyncAttribute` |

The product catalogue — search, filters, listing, product details, home sections,
categories, brands, boutiques — is **not** served from this host. Those calls go
to `ELASTIC_URL` or `WEB_APP`.

## Checklist

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| GET | `/api/v1/checklist` | marketGO | `home:1953` `getChecklist` |
| POST | `/api/v1/checklist` | marketGO | `home:1903` `addToChecklist` |
| GET | `/api/v1/checklist/product/{productId}/exist` | marketGO | `home:1936` `checkChecklistExist` |
| DELETE | `/api/v1/checklist/{productId}` | marketGO | `home:1919` `deleteFromChecklist` |

## Error log

| Verb | Path | Server | Dart |
| --- | --- | --- | --- |
| POST | `/api/v1/mobile_error_log/store` | marketGO | `home:877` `sendErrorToMobileErrorLog` |

---

## Seller dashboard

All of these use `ServerName.dashBoard`, which is `MARKET_URL` unconditionally.
Every call comes from `dashBoard_remote_data_source_model.dart`; the line number
is the Dart method.

### Permissions, members and the shop profile

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/auth/permissions` | `:38` `getUserPermission` |
| GET | `/api/v1/shop/users` | `:101` `getUsers` |
| GET | `/api/v1/shop/users/roles` | `:82` `getUserRoles` |
| POST | `/api/v1/shop/users/add` | `:115` `addUser` |
| PUT | `/api/v1/shop/users/role/update` | `:258` `updateUserRole` |
| DELETE | `/api/v1/shop/users/{userId}/delete` | `:243` `deleteUser` |
| DELETE | `/api/v1/shop/users/leave` | `:276` `leaveShop` |
| GET | `/api/v1/shop/info` | `:552` `getShopInfo` |
| PUT | `/api/v1/shop/info` | `:566` `updateShopInfo` |

### Orders

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/orders` | `:162` `getOrders` **and** `:176` `newGetOrders` |
| PUT | `/api/v1/shop/orders/status` | `:225` `changeOrderStatus` |
| PUT | `/api/v1/shop/orders/details/status/confirmed` | `:193` `ChangeOrderDetailStatusToConfirmed` |
| PUT | `/api/v1/shop/orders/details/status/packed` | `:209` `ChangeOrderDetailStatusToPacked` |

Two Dart methods send the same `GET /api/v1/shop/orders`, with different
response models (`GetSellerOrdersModel` and `NewOrdersResponse`). Both are live;
this is the one duplicated path in the whole list.

### Locations

A location is never deleted, only deactivated — there is no `DELETE` here. Every
write is a `POST`, update included, because the shop id travels in
`RequestConfig.extraHeaders`, which only `post.dart` honours.

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/locations` | `:604` `getShopLocations` |
| POST | `/api/v1/shop/locations` | `:641` `createShopLocation` |
| GET | `/api/v1/shop/locations/lookups` | `:625` `getLocationFormCountries` |
| GET | `/api/v1/shop/locations/{id}/edit` | `:662` `getShopLocationForEdit` |
| POST | `/api/v1/shop/locations/{id}/update` | `:677` `updateShopLocation` |
| POST | `/api/v1/shop/locations/{id}/change-status` | `:699` `changeShopLocationStatus` |

### Boutiques

Same shape as Locations, and no delete either.

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/boutiques` | `:146` `getBoutiques` |
| POST | `/api/v1/shop/boutiques` | `:769` `createBoutique` |
| GET | `/api/v1/shop/boutiques/lookups` | `:752` `getBoutiqueLookups` |
| GET | `/api/v1/shop/boutiques/{id}/edit` | `:790` `getBoutiqueForEdit` |
| POST | `/api/v1/shop/boutiques/{id}/update` | `:807` `updateBoutique` |
| POST | `/api/v1/shop/boutiques/{id}/change-status` | `:829` `changeBoutiqueStatus` |
| GET | `/api/v1/languages` | `:736` `getBoutiqueLanguages` |

`/api/v1/languages` is the only dashboard call that is not under `/shop/`. It
fills the boutique form's language tabs.

### Products, images and uploads

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/products` | `:131` `getProducts` |
| GET | `/api/v1/shop//products/images` | `:521` `getGalleryImages` |
| DELETE | `/api/v1/shop//products/images` | `:993` `deleteGalleryImages` |
| POST | `/api/v1/shop/uploads/presigned-url` | `:291` `getPresignedUrl` |

The double slash in `/api/v1/shop//products/images` is real, not a typo in this
file. `DashBoardEndPoints.getGalleryImagesEP` is `'/products/images'.shopScope()`
with a leading slash, and `shopScope()` already ends in one. Both calls have been
working against the server with that path, so do not "fix" the constant without
checking the server first.

### Vendor requests

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/vendor-requests` | `:397` `getVendorRequest` |
| POST | `/api/v1/shop/vendor-requests` | `:411` `submitVendorRequest` |
| PUT | `/api/v1/shop/vendor-requests` | `:429` `updateVendorRequest` |

`updateVendorRequestEP(int vendorRequestId)` takes an id and then ignores it —
the path has no id segment. The id travels in the body.

### Excel import and export

These three use `ServerName.market`, not `dashBoard`. Same host; the path
constants live in `WebAppEndPoints`.

| Verb | Path | Dart |
| --- | --- | --- |
| GET | `/api/v1/shop/excel/categories` | `:450` `getCategories` |
| GET | `/api/v1/shop/excel/downloadExcel/{categoryId}` | `:464` `downloadExcel` |
| GET | `/api/v1/shop/excel/getUploadedExcelFiles?page={page}` | `:488` `getUploadedExcelFiles` |

`downloadExcel` asks for `ResponseType.bytes` and writes the file to the app's
documents directory.

---

## Defined but no longer requested

These resolve to real `MARKET_URL` paths and are easy to mistake for live ones.
They are not in the tables above.

### Wired to a data source, but the caller is commented out

| Verb | Path | Where the chain breaks |
| --- | --- | --- |
| POST | `/api/v1/customer/product_comment/order` | `order_bloc.dart:82` — `AddOrderCommentUseCase` field commented out |
| POST | `/api/v1/customer/product_comment/order/update` | `order_bloc.dart:83` — `UpdateOrderCommentUseCase` field commented out |
| GET | `/api/v1/mobile/get-colors-and-sizes` | `home_bloc.dart:444` field commented out; the handler at `:1152` is inside a `/* */` block |
| POST | `/api/v1/auth/phone/login` | `LoginToMarketUseCase` is referenced only by DI — no BLoC uses it |

The path for all four still exists down to the data source, so a one-line
uncomment brings any of them back.

### Endpoint constants with no caller at all

In `MarketEndPoints`, never referenced from live code:

```
addCommentEP                              api/v1/customer/product_comment
getBrandEP                                api/v1/mobile/home/brands
getCategoryEP                             api/v1/mobile/home/categories
getCommentForProductEP                    api/v1/mobile/product/likesCommentsSharesDetails/{id}
getCustomerWalletEP                       api/v1/customer/wallet/list
getHomeBoutiqesEP                         api/v1/mobile/home/boutiques
getHomeSectionsEP                         api/v1/mobile/home/home_sections
getMainCategoriesEP                       api/v1/mobile/home/mainCategories
getMainCategoriesRelatedWithBoutiquesEP   api/v1/mobile/home/mainCategoriesRelatedWithBoutique
getOrderReturnDetailsEP                   api/v1/customer/order/return_requests/order_details?return_request_id={id}
getProductDetailWithoutSimilarRelatedProducts
                                          api/v1/mobile/product/details_without_similar_related_products/{id}
getProductFiltersEP                       api/v1/mobile/search/filters
getProductListingWithFiltersEP            api/v1/mobile/search/with_filter
getProductListingWithoutFiltersEP         api/v1/mobile/products
getSearchResultEP                         api/v1/products/search
registerEP                                api/v1/auth/register
verifyGuestPhoneEP                        api/v1/auth/firebase/verify-guest-phone
```

`DashBoardEndPoints` has none — every constant there has a live caller.

Two constants in `MarketEndPoints` are referenced in live code, but the request
that carries them **never reaches this host**:

- `storeFcmEP` (`api/v1/firebase_device_tokens`) — `AuthRemoteDatasource`
  `storeFcmToken` picks it whenever the server is not chat, and the base comes
  from that same `serverName`, never from `MarketUrls`. Only two events reach
  that method: `StoreFcmTokenInChatEvent`, dispatched once from
  `notification_process.dart:91` with `ServerName.chat` — which takes the
  `ChatEndPoints` branch instead — and `StoreFcmTokenInStoryEvent`, which is
  dispatched nowhere but its own retry at `auth_bloc.dart:334`. So this constant
  is currently sent to no server at all. The live
  `POST /api/v1/firebase_device_tokens` row in the notifications table is a
  different call, `storeFcmTokenOfMarket` in the home data source.
- `refreshTokenEP` (`api/v1/auth/refresh-token`) — `refreshChatToken` reuses the
  same constant with `ServerName.chat`, so that one goes to `CHAT_NEST_URL`.
  `refreshToken` (`marketGO`) is the row listed in the auth table.

Two upload endpoints are commented out in `market_url_routes.dart` itself,
because uploading moved to the media server's gated flow:
`uploadUserPhotoModelEP` and `uploadImagesForReturnProductEP`, both
`api/v1/storage/storage-upload`.

---

## Reproducing this list

```bash
# every market-server call, comments included (over-counts: 125)
grep -rn "ServerName.market\b\|ServerName.dashBoard\b\|ServerName.marketGO\b" \
  --include=*.dart lib/ | grep -v detect_server.dart
```

The three data sources are the only files that matter. Nothing else in `lib/`
builds a request to this host: the only other references to `MarketUrls` are
`main.dart:605` (the preferences override) and the developer URL editor.
