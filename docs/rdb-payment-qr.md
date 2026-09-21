# RDB payment QR — one payload for the website and the app

Date: 2026-09-20. Trydos mobile + web reference. It records the exact text the
payment QR carries, so the website and the Flutter app produce the same code and
the Ramaaz Digital Bank (RDB) app scans both the same way.

## 1. The payload

```
MERPAY:mp.cwewkCUKhUSP-MjXRCTJxg
```

That is the literal prefix `MERPAY:` followed by the **`request_code`** returned
by the Trydos backend when the payment request is created
(`POST api/v1/customer/order/checkout/rdb`).

| Part | Source | Example |
|---|---|---|
| prefix | constant, uppercase, with the colon | `MERPAY:` |
| code | `data.request_code` of the checkout response, verbatim | `mp.cwewkCUKhUSP-MjXRCTJxg` |

Rules:

- No spaces, no newline, no URL, no JSON around it.
- The code is case-sensitive and may contain `-` and `_`; copy it verbatim.
- Do **not** encode `short_code` (the 10 digits). That one is for typing by hand.
- Do **not** encode `payment_url` / `qr_payload` / `deep_link`; they are `null`
  in this release, and the RDB scanner expects the `MERPAY:` payload.
- Hide the QR when `request_code` is missing; the digits stay visible so the
  customer can still type them.

This was confirmed by decoding the QR the Trydos website already renders.

## 2. How each client uses it

| | Website | Flutter app |
|---|---|---|
| QR content | `MERPAY:<request_code>` | same |
| 10-digit code shown as text | yes | yes, large, with a copy button |
| Payment status | polls the Trydos backend | polls every 4 s, plus on app resume |

The customer has two ways to pay, on both clients: scan the QR with the RDB app,
or open the RDB app, choose "Pay a request" and type the 10 digits. Someone else
with an RDB account can pay on the customer's behalf either way.

## 3. QR encoding settings used by the app

| Setting | Value |
|---|---|
| Symbology | QR Code (model 2) |
| Encoding mode | automatic (alphanumeric/byte, the payload is not digits-only) |
| Error correction | **M** |
| Colours | black modules on white |
| Size | 180 logical pixels, inside a white box with 10 logical pixels of quiet zone |
| Library | `qr_flutter` 4.1.0 |

The website should keep whatever settings it already has; only the payload text
has to match. If the web uses a different error-correction level or size, that
is fine — it changes nothing for the scanner.

## 4. Open questions for the RDB team

1. Is `MERPAY:` the final, stable prefix, and is it case-sensitive?
2. Does the scanner accept a QR that carries only the 10-digit `short_code`, or
   is the `MERPAY:` payload the only accepted form? (The app assumes the second.)
3. When `payment_url` becomes available, should the QR switch to that URL, or
   stay on `MERPAY:<request_code>`?
4. What does the app show when the scanned request is already paid, expired, or
   cancelled, and when a short code has been recycled for a newer request?

## 5. Where this lives in the app

- Payload built in `lib/features/home/presentation/pages/rdb_payment_page.dart`
  (`_qrPayload`, constant `_qrPrefix`).
- `request_code` parsed in
  `lib/features/home/data/models/rdb_payment_request_model.dart`.

Changing the payload is a one-line change in `_qrPayload`.
