# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Menucito is a multitenant Rails 8 app for restaurant management: QR-code public menus, table service (open table → multi-round ordering → close/pay), counter sales (POS), a kitchen display, cash sessions, and discounts. UI copy and user-facing text are in Spanish.

## Commands

Start the app (Rails server + JS watch + CSS watch, via Procfile.dev):
```
bin/dev
```

Lint (Rubocop, Omakase style — CI runs this):
```
bin/rubocop
```

Security scans (both run in CI):
```
bin/brakeman --no-pager
bin/bundler-audit
```

Build JS/CSS manually (normally handled by `bin/dev` watchers):
```
yarn build
yarn build:css
```

DB setup:
```
bin/rails db:prepare
```

There is currently no test suite (no `test/` or `spec/` directory) — do not assume `bin/rails test` or `rspec` work.

## Multitenancy — the most important thing to understand

Every tenant-scoped model uses `acts_as_tenant :restaurant` (`config/initializers/acts_as_tenant.rb` sets `require_tenant = true`, so any query without a tenant set raises `ActsAsTenant::Errors::NoTenantSet`).

The tenant is resolved from the subdomain in `ApplicationController#set_current_tenant_from_subdomain`, which runs as a `before_action` on **every** request: it looks up `Restaurant.find_by(subdomain: ..., active: true)` and sets `ActsAsTenant.current_tenant`. If no subdomain matches an active restaurant, it renders `public/404.html` and halts.

- In development, any subdomain of `lvh.me` / `localhost` works (see `config/environments/development.rb`), e.g. `pizzeria.lvh.me:3000`.
- The signup flow (`SignupsController`) is the one place that `skip_before_action :set_current_tenant_from_subdomain` — it's meant to be visited on the bare marketing host (no subdomain yet) and creates the `Restaurant` + first `owner` user inside `ActsAsTenant.with_tenant(@restaurant) { ... }` before the tenant otherwise exists.
- Any new tenant-scoped model must both `belongs_to :restaurant` and declare `acts_as_tenant :restaurant`, and needs `restaurant_id` in its table/index (follow the pattern in `db/schema.rb`).

## Auth and roles

Authentication is Devise (`database_authenticatable, recoverable, rememberable, validatable` — no registrations, since signup is a custom tenant-creation flow, not self-serve Devise registration).

`AuthenticatedController` (most controllers inherit from this, not `ApplicationController` directly) adds `authenticate_user!` plus `verify_user_belongs_to_tenant`, which signs a user out if their `restaurant_id` doesn't match the current tenant — this prevents a session for restaurant A from being used on restaurant B's subdomain.

Roles live on `User` as an enum (`waiter, cashier, kitchen, admin, owner`) with predicate helper methods that combine roles into permission groups, not raw role checks:
- `front_of_house?` — waiter/cashier/admin/owner (can sell/serve tables)
- `can_manage_cash?` — cashier/admin/owner
- `kitchen_access?` — kitchen/admin/owner
- `can_manage_restaurant?` — admin/owner (menu, discounts, tables setup, staff)

Controllers gate actions with `before_action { require_permission!(:front_of_house?) }` (defined in `AuthenticatedController`), passing one of the predicate methods above — don't check `current_user.role` directly in controllers/views, use these predicates. `User#home_path` decides the post-login landing page from the same predicates (kitchen-only staff land on `/kitchen`, everyone else on `/pos`).

## Domain model

`Restaurant` is the tenant root. Everything else (`User`, `DiningTable`, `MenuCategory`, `MenuItem`, `Discount`, `Order`, `OrderItem`, `Payment`, `CashSession`, `CashMovement`) belongs to it and is tenant-scoped.

Order flow:
- `Order` has `order_type` (`counter`, `table_service`, `qr_order`) and `status` (`open → sent_to_kitchen → served → paid`, or `cancelled`).
- `Order#recalculate_totals!` recomputes `subtotal`/`discount_amount`/`total` from `order_items` + the attached `discount` — call it after mutating line items rather than hand-updating totals.
- `OrderItem#status` (`pending → printed → served`) tracks kitchen progress independently of the order's own status.
- `DiningTable#open_order` finds the table's current non-terminal order; `DiningTable#status` (`free/occupied/reserved/closing`) is managed alongside order lifecycle in `DiningTablesController`/`OrdersController`, not automatically by callbacks.

Cash flow:
- `CashSession` (`open`/`closed`) tracks a till. `Restaurant#current_cash_session` finds the open one.
- `CashSession#close!` snapshots `expected_amount` (`opening_amount + cash_payments_total + movements_total`) vs `counted_amount` into `difference_amount`.
- `CashMovement#kind` (in/out) adjusts the till outside of order payments (e.g. cash drops, payouts).

Discounts: `Discount#kind` is `percentage` or `fixed_amount`; `Discount#amount_for(subtotal)` computes the discount and clamps it to the subtotal.

## Frontend

Hotwire stack: Turbo + Stimulus, esbuild for JS bundling, Tailwind v4 (CSS-first config via `@theme` in `app/assets/stylesheets/application.tailwind.css`, no `tailwind.config.js`). Custom theme tokens (`--color-ink`, `--color-paper`, `--color-yellow`, etc.) implement a neobrutalist design system — thick borders, hard drop shadows, high-contrast accent colors. `docs/MOBILE_DESIGN.md` documents the mobile-specific rules for this system (touch target sizes, shadow scaling, safe-area padding) if you're touching responsive/mobile UI.

Stimulus controllers live in `app/javascript/controllers/` and are registered in `app/javascript/controllers/index.js`.

Two distinct layouts beyond `application.html.erb`: `app.html.erb` (authenticated staff UI, sidebar nav gated per-role as above) and `public_menu.html.erb` (the customer-facing QR menu, no auth, tenant-scoped only).
