# Trydos Mobile App — Feature Summary at a Glance

**Scope:** the Flutter mobile app (`dev_new`). Product features are shared with the web platform;
this document reports **the app's** status for each.
**Companion:** the web platform has its own summary — shared feature definitions are identical by
design, and any divergence is called out explicitly below.
**Last updated:** 2026-07-29

Three buckets only: **what's done**, **what's left to do**, **what's a placeholder to fill**.

---

## 📊 Completion by domain

**% complete = (🟢 Live + 🔧 Internal) ÷ Total** — a feature counts only when it is fully done.
Anything 🟡 Partial or ⚪ Placeholder counts as **not done**.

| Domain | Total | 🟢 Live | 🟡 Partial | ⚪ Placeholder | 🔧 Internal | % Complete |
|--------|:-----:|:------:|:---------:|:-------------:|:----------:|:----------:|
| A. Shopping & Product Discovery | 33 | 30 | 2 | 1 | 0 | **95%** |
| B. Cart, Checkout & Orders | 29 | 26 | 3 | 0 | 0 | **85%** |
| C. Payments, Wallet & Banking | 6 | 1 | 2 | 3 | 0 | **10%** |
| D. Accounts & Authentication | 30 | 23 | 2 | 4 | 1 | **80%** |
| E. Chat & Calls | 25 | 25 | 0 | 0 | 0 | **95%** ¹ |
| F. Stories | 7 | 6 | 1 | 0 | 0 | **86%** |
| G. Notifications | 10 | 9 | 0 | 0 | 1 | **95%** |
| H. Seller Dashboard | 15 | — | — | — | — | **⚠️ needs re-count** ² |
| I. Platform & Foundations (mobile) | — | — | — | — | — | **⚠️ needs re-count** ³ |

¹ All 25 chat feature IDs are Live. A cluster of inert chat sub-controls (Edit message,
Category/Reminder, Archive — see the placeholder list) still needs to be finished or removed, but
these are sub-controls of shipped features, not standalone feature IDs, so they are tracked as
line-items without docking a chat feature.

² **Divergence from web.** The web summary reports H at 80%. The mobile dashboard currently ships
**4 screens** (`dashboard`, `select shop`, `orders`, `order details`). Product management/add,
locations (warehouses / pickup points), shop info & branding, image gallery, seller stories
management, comments/reviews management, bulk Excel upload and team/roles were **not found in the
mobile codebase**. Re-count required before publishing a number — see "Mobile gaps" below.

³ **Not comparable to web.** The web's Platform domain is built on SEO (sitemaps, robots,
canonical/hreflang, structured data), PWA + web push, security headers, bot detection and
cookie-consent — none of which exist in a native app. The mobile equivalents are listed separately
in "Mobile platform foundations" below and need their own feature IDs before a percentage is
meaningful.

**Reading the total:** A–G are shared, backend-driven feature sets and track the web 1:1. H and I
are deliberately left unscored rather than copied, because the evidence shows they differ.

---

## ✅ What we did (live & in use)

Whole domains shipped and working:

- **Shopping & discovery (A)** — homepage feed, category nav, featured/flash/boutiques, full search (text, voice, image, trending, history, in-catalog), listing grid + filters + sort, product detail page, gallery, variants, reviews, Q&A, share, related, wishlist, compare, luck rewards.
- **Cart, checkout & orders (B)** — add-to-cart with variants, cart drawer, coupons, address + map picker, OTP pre-order, payment-method selection, place order, gateway, confirmation/invoice, order history + tracking, change address/variant, report, hide/restore, rate & review, order chat, returns (create + photos).
- **Accounts & auth (D)** — phone + OTP login end-to-end (SMS/WhatsApp, resend + rate-limit, outcome screens), guest registration + upgrade, session re-auth, logout, full profile & settings (edit info, change phone, avatar, size profile, addresses, country/language).
- **Chat & calls (E)** — 1-to-1 voice/video (Agora), call history, delivery-worker calls, time limits; full messaging (rich types, voice notes, camera, reply, delete, typing, presence, receipts, pin/mute/delete, search, contacts sync, shared media, order chat).
- **Stories (F)** — view, post customer story, seller/admin stories, shoppable, delete, report.
- **Notifications (G)** — FCM push, foreground handling, toasts, notification center + bell, preferences, topic subscribe, chat/order/marketing push.

### Mobile platform foundations (replaces the web's domain I)

4 languages + RTL (Arabic, English, Kurdish, Turkish) · multi-country + currency · CallKit incoming-call
integration · background-isolate push handler · offline media cache on disk · hydrated state persistence ·
runtime permissions (camera, gallery, contacts, notifications) · deep links & sharing · Sentry + Firebase
Analytics + PostHog.

---

## 🟡 What we have to do (partial — one core piece missing)

Shared with web unless marked:

| ID | Feature | The one thing it needs |
|----|---------|------------------------|
| SD-17 | Boutique storefront | Drive "verified / top-seller" trust badges from real shop data (hardcoded today) — or remove them. |
| SD-27 | Specs & size guide | Build the real measurement / size-conversion chart (IN/CM & EU/US/UK toggles are decorative). |
| CO-17 | Cancel whole order | Send the cancel **reason** to the backend (analytics-only today); wire the dead terms link. |
| CO-18 | Cancel single item | Send the cancel **reason** to the backend (not persisted today). |
| CO-28 | Manage a return | Replace hardcoded fake tracking timers ("3 H") and flat "3 USD" refund with real amount / currency / SLA. |
| ST-07 | Story viewer tracking | Wire per-story **view-time** to backend/analytics — not reported today. |
| PW-01 | Wallet balance & history | **On hold by choice** — awaiting the external wallet package; no in-app work planned until it ships. |
| PW-04 | Pay order with wallet | Swap the **dummy test widget** for the real external widget; allow failed payment to retry in place. |
| AC-06 | Privacy / terms consent | Wire the dead "Terms" link + add a Privacy link to real pages; ideally persist consent server-side. |
| AC-09 | QR-code login | Replace the local **mock** with real backend endpoints and mint a real session on approval. |
| SL-04 | Product editing (add & edit) | Slated for the planned AI-driven editor. **Mobile:** not present — see gaps below. |
| SL-06 | Boutiques management | Decide whether sellers may **delete** a boutique. **Mobile:** not present — see gaps below. |
| SL-07 | Orders & fulfillment | Finish whole-order status change; build or hide payment/refund/shipping/tracking actions. |

---

## ⚪ Placeholders to fill (scaffolded but not functional)

| ID | Placeholder | What must be filled in |
|----|-------------|------------------------|
| PW-02 | Add funds (bank deposit) | Deposit flow expected from the external wallet package. |
| PW-05 | Bank cards | Empty shell — build the screen, or hide it from the menu until real. |
| PW-06 | Full digital bank | Wire the external banking widget + server bridge behind a feature flag, verify token handoff. Blocked on external dev. |
| AC-27 | Privacy Policy page | Real counsel-reviewed copy + design; link from consent gate + settings. |
| AC-28 | Terms of Service page | Real legal copy + design; enable the settings link. |
| AC-29 | About page | Real content + design; wire the settings "About Us" link. |
| AC-30 | Contact page | Real content + design; enable the settings link. |
| CH · Edit message | Chat edit action | Build the edit service + wire the empty Save handler — or remove the option. |
| CH · Category / Reminder | Chat message options | Implement both actions, or remove the inert buttons. |
| CH · Archive | Chat archive | Implement Archive (sibling to working Pin/Mute/Delete), or remove it. |

**Not applicable to mobile** (web-only items, excluded deliberately): SEO/sitemaps, PWA & web push,
security headers, bot detection, cookie-consent / GDPR banner, `href="#"` link fixes.

**SD-24 Virtual try-on** — present on web as a placeholder; **no implementation exists in the mobile
app at all**. Decide whether mobile is in scope before it appears on a mobile roadmap.

---

## ⚠️ Mobile gaps vs. the web platform

These are the only places where the app is **behind** the shared feature set. They are the honest
reason H and I above are unscored.

| Area | Web status | Mobile status |
|------|-----------|---------------|
| Seller — product management (browse & add) | shipped | not found |
| Seller — locations (warehouses / pickup points) | shipped | not found |
| Seller — shop info & branding | shipped | not found |
| Seller — image gallery | shipped | not found |
| Seller — seller stories management | shipped | not found |
| Seller — comments / reviews management | shipped | not found |
| Seller — bulk Excel upload | shipped | not found |
| Seller — team & roles | shipped | not found |
| Virtual try-on | placeholder | absent |

The mobile seller dashboard ships **shop picker + orders + order details** only.

---

## 📌 Confidence & method

- **A–G percentages** are taken from the shared feature inventory; spot-checked against the mobile
  codebase (search, cart, orders, chat, stories, notifications, auth screens all present).
- **H and I** are unscored because direct inspection contradicted the shared numbers.
- Everything under "Engineering work" and "Mobile gaps" was verified directly against the code.
- **Not verified:** exact per-feature counts inside A–G. Confirm against the full feature inventory
  before treating the percentages as final.
