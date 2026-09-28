# RDB deep link — reading the payment code from the link

Date: 2026-09-21. From the Trydos mobile team to the Ramaaz Digital Bank (RDB)
app team. It describes the link the Trydos app opens when the customer taps
**Open the wallet app** on the payment screen, and what the RDB app should do
with it.

Related: `docs/rdb-payment-qr.md` (the QR that carries the same payload).

## 1. What the customer sees

On the Trydos payment screen there are now three ways to pay the same request:

1. scan the QR with the RDB app;
2. type the 10-digit code by hand in "Pay a request";
3. **tap "Open the wallet app"** — this opens the RDB app directly, and the
   payment code travels with the link. This document is about this third way.

## 2. The link

Base (already live, provided by RDB):

```
https://rdb-ms.yazan-adnof.workers.dev
```

What the Trydos app opens:

```
https://rdb-ms.yazan-adnof.workers.dev/?code=MERPAY%3Amp.cwewkCUKhUSP-MjXRCTJxg
```

| Part | Value |
|---|---|
| host + path | `https://rdb-ms.yazan-adnof.workers.dev/` |
| query parameter | `code` |
| value, before encoding | `MERPAY:<request_code>` |
| value, as sent | URL-encoded, so the colon becomes `%3A` |

`<request_code>` is the `request_code` of the payment request, exactly as RDB
returned it to the Trydos backend (for example `mp.cwewkCUKhUSP-MjXRCTJxg`).

**The value of `code` is byte-for-byte the same string the QR carries.** One
payload, two transports. If the RDB app already has QR-payload parsing, it can
reuse it after URL-decoding.

## 3. What we ask the RDB app to do

1. Keep handling this host as an App Link / Universal Link, as it does today.
2. Read the `code` query parameter and URL-decode it. The result is
   `MERPAY:<request_code>`.
3. Strip the `MERPAY:` prefix and treat the rest as the payment-request code —
   the same code your scanner produces today.
4. Open the "pay a request" screen with that code filled in, showing the
   merchant name and the amount, and let the customer confirm.

### 3.1 Cases to handle

| Case | Expected behaviour |
|---|---|
| App installed, user signed in | open "pay a request" with the code filled in |
| App installed, user not signed in | sign in first, then continue to the same request |
| App not installed | never happens from the Trydos app: the button is hidden unless the package `com.rdb.www` is installed on the device |
| `code` missing or unreadable | open the app normally, no error screen |
| Request already paid / expired / cancelled | a clear message, not a generic failure |
| Payer is not the buyer | must keep working: paying someone else's code is a feature Trydos customers use |

## 4. Parsing example

```
incoming: https://rdb-ms.yazan-adnof.workers.dev/?code=MERPAY%3Amp.cwewkCUKhUSP-MjXRCTJxg
1. read query parameter          -> "MERPAY%3Amp.cwewkCUKhUSP-MjXRCTJxg"
2. URL-decode                    -> "MERPAY:mp.cwewkCUKhUSP-MjXRCTJxg"
3. remove the "MERPAY:" prefix   -> "mp.cwewkCUKhUSP-MjXRCTJxg"
4. this is the request_code      -> open "pay a request" with it
```

Notes:

- The code is case-sensitive and may contain `-`, `_` and `.`.
- Do not assume a fixed length.
- Be tolerant: if the value arrives without the `MERPAY:` prefix, accept it as
  the bare `request_code`.

## 4.1 One thing we need from you for iOS

On Android we check that the package `com.rdb.www` is installed before showing
the button, so the link never lands in a browser.

On iOS there is no way to ask about a Universal Link. The only check Apple
allows is `canOpenURL` on a **custom scheme**. So please tell us:

- the RDB app's custom URL scheme (for example `rdb://`), and whether it can
  carry the same `code` value;
- the App Store id of the app.

Until then the button stays hidden on iPhone.

## 5. If you prefer another shape

We can change the link on our side in one line. Tell us which you want and we
will follow:

- path style: `https://rdb-ms.yazan-adnof.workers.dev/pay/mp.cwewkCUKhUSP-MjXRCTJxg`
- a custom scheme: `rdb://pay?code=...`
- a different parameter name, or the bare code with no prefix.

Until then, the app uses the form in section 2.

## 6. Test material

Open this on a device with the RDB app installed (fake code, not a live
request):

```
https://rdb-ms.yazan-adnof.workers.dev/?code=MERPAY%3Amp.cwewkCUKhUSP-MjXRCTJxg
```

Expected: the RDB app opens on the "pay a request" screen with
`mp.cwewkCUKhUSP-MjXRCTJxg` already filled in.

## 7. Where this lives in the Trydos app

`lib/features/home/presentation/widgets/cart_section/rdb_payment_dialog.dart` —
constants `_walletDeepLink` and `_qrPrefix`, builder `_walletAppUrl`.
