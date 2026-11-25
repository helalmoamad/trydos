# Wallet — what the backend must provide

The wallet section is **design-complete and API-free**. Every screen draws the
numbers and strings the web design file ships with. Nothing in
`lib/features/wallet/` calls the server yet, by instruction.

The switch is one line — `lib/features/wallet/wallet_config.dart`:

```dart
const bool kWalletApisLive = false;
```

This file lists, screen by screen, the data each board needs. Use it to decide
which endpoints to hand over; each row names the Dart constant that holds the
placeholder today, so wiring is a search-and-replace, not a redesign.

---

## 1. Balances — `Home Page – 11`, `– 17`

Screen: `wallet_page_v2.dart`. Placeholder: `kWalletCards` in
`wallet_design.dart`.

| Field | Shown as | Today |
| --- | --- | --- |
| currency code | `USD`, `SYP` | `'USD'`, `'SYP'` |
| balance | the big number on the purple card | `'1000'` |
| currency name | the line over the cards | translation key |

A real reply needs one row per currency the client holds, each with its code,
its balance and its display name. The data layer for this already exists:
`WalletRemoteDataSource.getCurrencies()` and `getBalance(assetId)` are written
against the live routes in `wallet_url_routes.dart`; only the page still reads
the file's numbers.

## 2. Transactions — the list under the cards

Screen: `wallet_page_v2.dart` (`_WalletEntryRow`). Placeholder:
`kWalletEntries`.

**No endpoint exists for this.** `getEntries(assetId)` throws
`UnimplementedError` on purpose. Each entry the design draws needs:

| Field | Shown as |
| --- | --- |
| kind | the row's icon (deposit / withdrawal / order / refund / request) |
| direction | the arrow: in (dark, down) or out (orange, up) |
| title | the row's first line |
| date | `03.march` |
| note | the second line (branch name, order number, network) |
| amount + unit | the right-hand number |
| status | `succeeded`, `blocked`, or waiting |
| due time / day / month | a waiting entry's countdown |
| receipt id | present only when the row opens a receipt |

The first row of the list is drawn with a 0.5 line around it and a Bold
amount — the backend only has to say which row is the latest, or return them
newest-first.

## 3. Wallet info — `– 23`

Screen: `wallet_info_sheet_v2.dart`. Needs the client's **name**, **id** and
**phone number**. The QR code is generated on the device from the client id, so
the server sends no image. Passed in from `wallet_page_v2.dart` as literals
today.

## 4. Receipt — `– 18`

Screen: `wallet_receipt_v2.dart`. Needs, for one transaction: number, date,
reference, amount, currency code, sender, receiver, type and status. Today
`WALLET_RECEIPT`'s values, passed in from `wallet_page_v2.dart`.

## 5. Cash in — `– 22`, `– 26`, `– 31`, `– 32`

Screen: `wallet_cash_in_sheet_v2.dart`. Placeholders: `WalletCashInData`,
`WalletBankAccountData` in `wallet_cash_in_design.dart`.

- **Ways** (`– 22`) is static: the five tiles are a fixed list. Only the
  "Soon available" flag on the cards tile would come from a config.
- **Cash deposit** (`– 26`) needs a **deposit code** and the client's three
  fields (name, id, phone). The code is drawn from the file's SVG
  (`qrCashIn.svg`) — the real one must arrive as a payload to encode, not as an
  image, so the app can draw it at both sizes (300.12 and 350.37).
- **From my rdb** (`– 32`) needs the client's **rdb account**: id, phone, full
  name, plus the currency name. And a route for "Connect & request from your
  rdb" to post the typed amount to.
- The four actions on `– 26` (request / copy / download / share): **request**
  has no route yet; copy and share work on the client id; download opens the
  picture board (`– 31`), drawn in-app.

## 6. Cash in with crypto — `– 33`, `– 34`, `– 37`, `– 38`, `– 39`

Same screen. Placeholder: `WalletCryptoData`.

| Field | Today | Needed from |
| --- | --- | --- |
| coin / chain / standard | `USDT` / `Tron` / `TRC 20` | the networks the server supports |
| fee | `0.1` (110 USDT for 100 USD) | a live rate |
| wallet address | the file's SVG | **a payload to encode in the QR** |
| life of the code | `30 * 60 - 1` seconds | the server's own expiry |
| expiry date / time | `27/08/2024 13:30` | the server's own expiry |

"Generate QR code" shows the safety rules (`– 39`), and "I agree" moves to the
code board (`– 37`). That is where the request must actually be created. The
rules themselves are static text and need nothing.

The three wallet apps on `– 37` (Trust, MetaMask, Binance) are deep links the
design does not specify; they take no tap yet.

## 7. Cash out — `– 21`, `– 19`, `– 20`, `– 25`, `– 27`, `– 29`, `– 35`, `– 36`

Screen: `wallet_cash_out_sheet_v2.dart`. Placeholders:
`WalletRecipientData`, `WalletBankAccountData`, `kWalletProviders`.

- **Ways** (`– 21`) is static: the brand card and three provider photos.
- The **recipient** fields (phone, full name) are filled from the file. A real
  form must look the recipient up by their Trydos phone number and return the
  name to show — the design draws the name as read-only with an eye.
- The **authorized recipient** (`– 25`, `– 27`) is typed by the client: phone
  and full name. Both go with the request.
- `– 20` compares the typed amount with the balance and shows "Your Balance is
  insufficient". The comparison is local, against the balance from §1 — so
  that balance must be correct before this is trusted.
- **Withdrawal Now** (`– 29`) opens the code reader (`– 30`), which shows a
  black box with the file's `scanCode` mark. The real board needs a **code for
  the branch employee to read**.
- **To my rdb** (`– 35`, `– 36`) needs the client's own rdb account and a route
  for "Withdrawal To rdb".

## 8. Withdrawal request — `– 101`, `– 28`, `– 24`

Screen: `wallet_withdrawal_request_v2.dart`. Placeholder:
`WalletRequestData`.

- `– 101` verifies a **six-digit code sent to WhatsApp**. Today **any** six
  digits pass and the screen moves on after 600 ms. This needs the send and
  verify routes, plus the masked number to show (`+90 5x2 8xx xx00`) and the
  real resend window (two minutes today, copied from the login flow).
- `– 28` needs the created request: its **QR payload**, its reference/id, its
  date, the amount, the type, the client's name and the authorized recipient's
  name when there is one.
- `– 24` is the picture of the same request, drawn in-app.

---

## Notes for whoever wires this

1. **The bloc is not hydrated** (`wallet_bloc.dart`). A stale money figure is
   worse than no figure. Keep it that way.
2. `wallet_url_routes.dart` is a **protected runtime path** (see `CLAUDE.md`).
   Adding a route there needs an approved change, not a drive-by edit.
3. Every placeholder is a named constant in a `*_design.dart` file, with the XD
   board it came from in the doc comment above it. Replacing one is local: the
   layout reads the value, never the source.
4. The QR codes of the cash-in and cash-out boards are **design SVGs**, not
   generated codes — unlike the wallet-info and receipt boards, which generate
   theirs from the client id and the receipt number. When the payloads arrive,
   swap those `XdSvg` calls for `WalletQr` at the same size and the boards stay
   pixel-correct: `WalletQr` draws the same module shape the file's artwork
   has, so generated and cut codes look like one family.
