# Admin Web Panel - Implementation Plan (Nuxt 3)

## Overview
A separate Nuxt 3 web admin panel for managing routes, trips, vehicles, users, tickets, reports, and notifications. Built with Yarn and deployed on Firebase Hosting. Uses Firebase Auth and Firestore with role-based access.

## Tech Stack
- Framework: Nuxt 3 + TypeScript
- UI: Tailwind CSS + Naive UI (component library)
- State: Pinia
- Utilities: VueUse, Zod (validation), Day.js (dates)
- Charts: Apache ECharts
- Firebase (Web v10 modular): Auth, Firestore, Storage, Analytics, Cloud Messaging (optional)
- Hosting: Firebase Hosting (CI via GitHub Actions)

## Authentication & Authorization
- Firebase Auth (Email/Password, Google)
- Role stored in `users/{uid}.role ∈ {admin, agent, customer}`
- Middleware guard: blocks access if role not in required set
- Firestore rules enforce server-side permissions (admins write; agents limited)

## Firestore Collections Used
- `users` (roles, profile)
- `routes` (name, origin, destination, basePrice, stops, isActive)
- `trips` (routeId, times, vehicleId, seats, isActive)
- `vehicles` (vehicleNumber, status, crew)
- `tickets` (userId, tripId, routeId, amount, status)
- `transactions` (amount, method, ticketId)
- `vehicleLocations` (for tracking)

Recommended indexes:
- `tickets`: userId ASC, issuedAt DESC
- `trips`: routeId ASC, isActive ASC, departureTime ASC

## Pages
- Dashboard
  - KPIs: Tickets sold (today), Revenue (UGX), Active trips, Vehicles online
  - Charts (ECharts): Sales over time, Top routes, Payment breakdown
- Routes
  - List, filter, create, edit, activate/deactivate
- Trips
  - Schedule trips: departure/arrival, vehicle, seats; activate/cancel
  - Seat availability preview
- Vehicles
  - CRUD vehicles; assign to route/trip; crew assignment
- Tickets
  - Search/filter by id/user/date/status; view/cancel/use
- Users
  - List; promote/demote roles; deactivate
- Reports
  - Daily/weekly/monthly: tickets, revenue, top routes
  - CSV export
- Notifications (Phase 2)
  - Send schedule-change/booking/payment notifications via FCM

## Nuxt Structure
- `middleware/auth.global.ts`: fetch user + role; protect routes
- `plugins/firebase.client.ts`: init Firebase app, auth, firestore
- `plugins/naive-ui.client.ts`: register Naive UI
- `plugins/echarts.client.ts`: register ECharts
- `layouts/default.vue`: sidebar, topbar, breadcrumbs, dark mode
- `pages/`
  - `index.vue` (Dashboard)
  - `routes/index.vue`, `routes/new.vue`, `routes/[id].vue`
  - `trips/index.vue`, `trips/new.vue`, `trips/[id].vue`
  - `vehicles/index.vue`, `vehicles/new.vue`, `vehicles/[id].vue`
  - `tickets/index.vue`, `tickets/[id].vue`
  - `users/index.vue`, `users/[id].vue`
  - `reports/index.vue`
- `stores/`
  - `auth.store.ts`, `routes.store.ts`, `trips.store.ts`, `vehicles.store.ts`, `tickets.store.ts`, `users.store.ts`
- `components/`
  - tables, forms, filters, date-range, seat-map, charts (ECharts wrappers)

## Security Rules Alignment (High-level)
- Admins: write all admin-managed collections
- Agents: limited writes (issue/cancel tickets), read routes/trips/vehicles
- Customers: read-only where appropriate
- Validate critical fields; use server timestamps

## Milestones
1. Bootstrap + Auth
   - Nuxt 3 with Yarn, Tailwind, Pinia, Naive UI, ECharts
   - Firebase init, auth flows, role guard
2. Routes
   - Routes CRUD + validation (Zod)
3. Trips
   - Trip scheduling, seat availability preview, actions
4. Vehicles
   - Vehicle CRUD, crew assignment
5. Tickets
   - Search/filter, detail, cancel/use
6. Users
   - Role management, deactivate
7. Reports
   - KPIs + ECharts dashboards + CSV export
8. Notifications (Phase 2)
   - FCM topic/user notifications for events
9. CI/CD & Hosting
   - Firebase Hosting, GitHub Actions, environment secrets

## Yarn Commands (setup)
- Create: `yarn dlx nuxi init comfort-admin`
- Dev deps: `yarn add -D tailwindcss postcss autoprefixer @types/node`
- App deps: `yarn add firebase pinia @vueuse/core naive-ui echarts zod dayjs`
- Tailwind init: `npx tailwindcss init -p`
- Dev: `yarn dev`

## Firebase Hosting
- Initialize: `firebase init hosting`
  - Select project, set `dist` (or `.output/public` if using Nitro static)
- Build & deploy:
  - Build: `yarn build`
  - Preview: `firebase hosting:channel:deploy preview-<branch>`
  - Deploy: `firebase deploy --only hosting`
- CI: GitHub Actions to build and deploy on main

## Environment
- `.env` variables (exposed via Nuxt runtime config):
  - `NUXT_PUBLIC_FIREBASE_API_KEY`, `NUXT_PUBLIC_FIREBASE_AUTH_DOMAIN`, `NUXT_PUBLIC_FIREBASE_PROJECT_ID`, `NUXT_PUBLIC_FIREBASE_APP_ID`, `NUXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`, `NUXT_PUBLIC_FIREBASE_STORAGE_BUCKET`, etc.

## UX Guidelines
- Tables with server-side pagination & filters
- Zod for form schema validation
- Toasts/modals for CRUD ops
- Keyboard shortcuts: `/` search, `N` new item

## Risks & Mitigations
- Permissions drift → reinforce in Firestore rules and code guards
- Index gaps → capture console error links and add to indexes config
- Data consistency → prefer server timestamps and transactional updates where needed

## Next Steps
- Confirm branding and navigation items
- Scaffold project with the dependencies listed
- Implement auth shell + protected routes
- Start with Routes CRUD, then Trips scheduling
