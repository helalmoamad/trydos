# Mobile API Endpoints — Answer

Host: `https://trydos_develop.ramaaz.dev`
App: Flutter, branch `dev_new`

---

## ✅ Used — the app sends these to this host

```
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/startingSettings
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/currency
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/details_color_sync_attribute/{id}
```

Also used on this host, not in your list:

```
GET  https://trydos_develop.ramaaz.dev/api/v1/countries
```

> These four go to this host only when the user is **signed in**. For a guest
> the app sends the same paths to `trydosv2.ramaaz.dev`.

---

## ❌ Not used — the app never sends these to this host

```
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/get-colors-and-sizes
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/mainCategories
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/mainCategoriesRelatedWithBoutique
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/home_sections
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/boutiques
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/boutiquesCheckCache
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/categories
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/home/brands
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/details/{slug}
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/authenticated_details/{slug}
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/details_without_similar_related_products/{slug}
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/likesCommentsSharesDetails/{slug}
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/product/quickView/{slug}
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/products
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/products/with_filter
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/products/filters
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/search
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/search/with_filter
POST https://trydos_develop.ramaaz.dev/api/v1/mobile/search/filters
GET  https://trydos_develop.ramaaz.dev/api/v1/mobile/countries
```

---

## Before you delete

Some of these paths are alive in the app on a **different host**
(`trydos.ramaaz.dev`), so the path is not dead everywhere:

```
api/mobile/product/details/{slug}      ← replaces /api/v1/mobile/product/details/{slug}
api/mobile/product/qty/{slug}          ← replaces /api/v1/mobile/product/authenticated_details/{slug}
api/home/mainCategories                ← replaces /api/v1/mobile/home/mainCategoriesRelatedWithBoutique
api/home/boutiques                     ← replaces /api/v1/mobile/home/boutiques
api/products/searchInCatalog           ← replaces /api/v1/mobile/search/with_filter
api/products/featured                  ← replaces /api/v1/mobile/search/with_filter
```

And `/api/v1/mobile/countries` is unused only because the app calls
`/api/v1/countries` instead — same host, no `/mobile`.

The web platform and the seller dashboard were not checked. This list is for
the mobile app only.
