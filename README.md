# Ares — Storefront & Live Admin Control Plane

A multi-page direct-to-consumer (DTC) storefront paired with a live admin dashboard for managing inventory, catalog items, orders, and storefront configuration in real time.

## Product Goal

Build a single-brand commerce experience with a dedicated back-office control plane—not a multi-vendor marketplace and not a single-page anchor-scroll landing page.

- **Customer Storefront:** Browse a focused product catalog, inspect product detail pages, add items to a cart, complete checkout, and view order confirmations across real URL routes.
- **Live Admin Dashboard:** Create and edit products, adjust stock quantities (supporting high-stock evergreen items such as `9999` alongside tight limited-drop inventory), update site copy/banners, and manage order fulfillment statuses.
- **Real-Time Sync:** Changes made in the admin dashboard or via checkout push live updates to connected storefront views without requiring a manual page reload.

## Brand & Design Boundary

- **Not HP:** Although visual tokens and structural rules are derived from `dope-design.md` (an HP-inspired design system reference)[cite: 1], **this application is not HP**, does not represent HP products or branding, and uses placeholder/custom brand identity and catalog data only.
- **Design System Authority:** `dope-design.md` is used strictly for visual tokens (colors, typography scale, spacing, radii, surface bands, and component geometry)[cite: 1]. Any HP-specific examples or brand names inside `dope-design.md` are reference artifacts only and must not leak into UI copy, logos, or domain data[cite: 1].
- **Central Stylesheet First:** Styling lives in a central stylesheet rather than per-page `.scss` files, exposing reusable classes like `text-primary` and `button-primary` for use directly in `.html` templates.

## Tech Stack

- **Frontend:** Angular (TypeScript, standalone components, `routerLink` + `<router-outlet>` multi-page routing)
- **Backend API:** Node.js + Express (REST endpoints + Server-Sent Events for live updates)
- **Database:** SQL Server Express (local database instance for products, site config, orders, and order items)
- **Styling / Design Spec:** Central `.scss` design system built from `dope-design.md` tokens and component conventions[cite: 1]

## Workspace Layout

```text
C:\Users\bdleg\Ares\
├── README.md
├── ARCHITECTURE.md
├── UI-SYSTEM.md
├── dope-design.md
├── Ares.code-workspace
├── Ares-UI/
│   └── src/
│       ├── styles/
│       │   └── design-system.scss
│       └── app/
│           ├── core/
│           ├── storefront/
│           └── admin/
└── Ares-backend/
    ├── sql/
    │   └── init.sql
    └── src/
        ├── db.ts
        ├── events.ts
        ├── routes/
        │   ├── storefront.ts
        │   └── admin.ts
        └── server.ts
```