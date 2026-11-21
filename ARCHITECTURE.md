# Architecture & Routing Specification

## System Overview

The application splits into three clear layers:

1. **Angular Client (`Ares-UI/`):** Multi-page routed SPA with separate layout shells for the public storefront and the admin dashboard, styled through a central `.scss` design system.
2. **Node.js + Express API (`Ares-backend/`):** Handles catalog/bootstrap reads, transactional checkout writes, admin CRUD/inventory/site-config mutations, and Server-Sent Events (SSE) broadcasts.
3. **SQL Server Express (`Ares-backend/sql/init.sql`):** Local relational store persisting `Products`, `SiteConfig`, `Orders`, and `OrderItems`.

## Multi-Page Routing Rules (No Single-Page Anchor Scrolling)

All primary navigation and page transitions must use real Angular routes (`routerLink` and `<router-outlet>`) so the browser URL changes cleanly on every view transition. Do **not** implement fake single-page `#section` scroll navigation for top-level pages.

### Public Storefront Routes
- `/` — Home (hero, featured items, highlights)
- `/catalog` — Full product catalog with stock status indicators
- `/product/:slug` — Product detail page (description, pricing, stock availability, add to cart)
- `/info` — Brand info, shipping/fulfillment details, and FAQs
- `/cart` — Cart review and quantity adjustments
- `/checkout` — Checkout form and order submission
- `/order/:orderNumber` — Order confirmation view

### Admin Dashboard Routes
- `/admin` — Operational overview (inventory counts, limited drops, recent orders)
- `/admin/products` — Product catalog & inventory editor (create/edit items, stock counts, limited-drop toggles)
- `/admin/site` — Live storefront configuration editor (hero copy, banners, featured flags)
- `/admin/orders` — Order list and status management (`Pending`, `Packed`, `Shipped`, `Canceled`)

## Styling & Central Stylesheet Convention

- Define design tokens, surface bands, typography utilities, and component classes (such as `text-primary`, `text-ink`, `surface-cloud`, `button-primary`, `button-outline`, and `card-product`) in a central stylesheet (`Ares-UI/src/styles/design-system.scss`) imported into the global Angular styles.
- Apply those shared classes directly in component `.html` templates instead of creating separate `.scss` files for every page.
- Reserve component-level `.scss` files only for rare view-specific layout adjustments that cannot be expressed cleanly via shared classes.

## Data & Inventory Flow

- **Evergreen vs. Limited Drop Stock:** Standard catalog products can hold high stock (e.g., `9999`) for frictionless testing, while limited-drop items use small quantities (e.g., `1`–`5`) to demonstrate stock decrements and sold-out states.
- **Checkout Transaction:** Order creation (`POST /api/orders`) validates stock and writes `Orders` and `OrderItems` inside a SQL Server transaction before broadcasting a live update event over SSE (`/api/events`).
- **Live Storefront Sync:** Admin updates to inventory, product fields, or `SiteConfig` trigger SSE notifications so storefront components refresh active data automatically.