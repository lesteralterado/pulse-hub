# PulseHub Admin Dashboard

Separate web-based Admin Dashboard for PulseHub (project brief section 29),
giving administrators platform control through their own app rather than
inside the Flutter mobile app.

Talks to the **same Supabase project** as the Flutter app (`profiles`,
`user_roles`, and the rest of the shared schema) — this is a second client
on the existing backend, not a separate one.

## Tech stack

- Next.js (App Router) + TypeScript + Tailwind CSS
- Supabase (`@supabase/ssr` for cookie-based server auth)
- Vitest + React Testing Library

## Getting started

1. Copy `.env.local.example` to `.env.local` and fill in the same Supabase
   project URL/publishable key the mobile app uses.
2. `npm install`
3. `npm run dev` — http://localhost:3000

Sign in with an account that has the `admin` or `super_admin` role in
`user_roles` (see `supabase/migrations/0001_profiles_and_roles.sql` at the
repo root). Any other signed-in account lands on `/not-authorized`.

## Running checks

```
npm run build   # type-check + production build
npm test        # vitest
```

## Phase status

**Foundation (done):** project scaffold, Supabase auth, session proxy
(`src/proxy.ts`), RBAC guard (`src/lib/auth/current-admin.ts`), sidebar nav
for all 14 sections from the brief's Admin Dashboard Navigation, and an
Overview dashboard shell with placeholder metrics (brief section 31).

**Not yet built:** every section beyond the Overview shell is a
"coming soon" stub — User Management, Community/Learning/Meeting/
Subscription administration, BOT Chain monitoring, and CaryPact
administration (brief sections 32–38) are later phases. Real Overview
metrics also need read access to rows beyond the signed-in admin's own —
`user_roles`' current RLS policy only allows a user to read their own
roles (correct for the mobile app), so an admin-scoped read policy is
required before any of those sections can query real data.
