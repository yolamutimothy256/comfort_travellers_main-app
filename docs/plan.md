# Comfort Busses Ticketing Plan

## Goal

Deliver a Flutter smart-ticketing app backed by Firebase that modernizes Comfort Busses' sales and validation workflow, featuring multi-provider auth, ticket lifecycle management, revenue analytics, QR support, and email delivery within a polished #d51f19-themed UI.

## Research Insights

- Firebase is the recommended backend for Flutter authentication, Firestore, and analytics ([firebase.flutter.dev](https://firebase.flutter.dev/)).
- `google_sign_in`, `firebase_auth`, and FirebaseUI simplify multi-provider auth flows.
- Firestore suits transactional ticketing data with compound queries for date filtering; Cloud Functions automate email dispatch via SendGrid or Mailgun.
- `qr_flutter` (generation) with `qr_code_scanner` (validation) provides reliable QR workflows.
- `fl_chart` or `syncfusion_flutter_charts` enable responsive dashboards; Firebase Analytics tracks revenue funnels.

## Architecture & Data

- Adopt feature-first Flutter foldering (`lib/features/...`) with shared `core/` services, theming, and routing.
- Define Firestore collections:
  - `users/{uid}`: profile, role, preferences.
  - `routes/{routeId}`: route metadata, pricing.
  - `trips/{tripId}`: schedule, vehicle, crew.
  - `tickets/{ticketId}`: user, trip, seat, amount, status, QR payload, issuedAt.
  - `transactions/{transactionId}`: ticketId, payment method, amount, timestamps.
- Secure with Firebase rules enforcing per-user read access and staff write privileges.

## Key Workstreams

1. **Environment Setup**

   - Scaffold Flutter project; configure Firebase (Android/iOS/Web) via `flutterfire configure`.
   - Add required packages: `firebase_core`, `cloud_firestore`, `firebase_auth`, `google_sign_in`, `firebase_analytics`, `qr_flutter`, `qr_code_scanner`, `intl`, `fl_chart` or `syncfusion_flutter_charts`, HTTP/email client, `riverpod` or `bloc` for state management.

2. **Authentication & Onboarding**

   - Implement email/password flows with form validation, password reset, and profile setup.
   - Integrate Google Sign-In; persist auth state, handle provider linking.
   - Create role-aware navigation (admin/agent/customer) using guarded routes.

3. **Ticket Lifecycle**

   - Build ticket issuance UI for agents: select route/trip, assign seat, capture passenger info, price.
   - Persist ticket to Firestore, generate unique QR payload (ticketId + signature) and store.
   - Implement passenger ticket views with status indicators and resend actions.
   - Provide date filtering via Firestore queries with composite indexes and quick filters (today, week, custom).

4. **Payments & Revenue Tracking**

   - Record transactions per issuance (including offline cash) with amount and method.
   - Aggregate revenue by day/trip using Firestore aggregation queries or scheduled Cloud Function rollups to `analytics/dailySummary`.
   - Surface analytics dashboard with charts for tickets sold, revenue, top routes, and payment breakdown.

5. **QR & Validation Workflow**

   - Generate QR images with `qr_flutter`; embed in ticket detail and email.
   - Build scanning screen for conductors using `qr_code_scanner`; lookup ticket, display validity, mark as used.
   - Log scan events to `ticketScans/` for audit.

6. **Email & Notifications**

   - Deploy Cloud Function triggered on ticket creation/update to send email via SendGrid template containing itinerary, QR code URL, and receipt.
   - Optionally add push notifications using Firebase Cloud Messaging for reminders or cancellations.

7. **UI/UX & Theming**

   - Create design system adhering to Material 3 with primary color `#d51f19`, neutral backgrounds, and accessible contrasts.
   - Build reusable components (buttons, cards, charts) and responsive layouts for mobile and tablet.
   - Include onboarding tips, offline indicators, and streamlined agent flows.

8. **Quality & Operations**

   - Implement state management tests, Firestore emulator-driven integration tests, and golden tests for UI.
   - Configure CI pipeline (e.g., GitHub Actions) for lint, test, and Flutter build.
   - Draft deployment checklist for Play Store and App Store, plus environment configuration documentation.

## Deliverables

- `docs/plan.md` capturing this roadmap with references.
- Flutter project bootstrap with Firebase configs.
- Auth, ticketing, analytics, QR, and email features implemented iteratively with tests.

## Next Steps

- Create `docs/plan.md` containing this plan for stakeholder review.
- Obtain approval, then proceed to project scaffolding and feature development.

### To-dos

- [ ] Create `docs/plan.md` with agreed architecture, research links, and roadmap.
- [ ] Initialize Flutter app and configure Firebase services for Android/iOS/Web.
- [ ] Build email-password and Google Sign-In flows with role-based navigation.
- [ ] Implement ticket issuance, filtering, analytics, QR, and email flows with tests.
