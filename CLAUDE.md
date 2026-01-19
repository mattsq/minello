# FamilyBoard Task Pack (PWA + Supabase)

## Goal

Build a small Trello-like board app for family use on phones:
- installable as a PWA
- secure hosted managed backend via Supabase (Auth + Postgres + RLS)
- minimal feature set that's hard to regress because Playwright e2e locks golden flows

Non-goals for V1: attachments, complex permissions, push notifications, multi-workspace UX polish, full realtime.

⸻

## Tech decisions (fixed)
- Frontend: Next.js (App Router) + TypeScript
- UI: minimal CSS (Tailwind optional, but keep it simple)
- DnD: @dnd-kit/*
- Backend: Supabase hosted (Auth + Postgres) with Row Level Security
- Tests: Playwright e2e
- Deploy: Vercel (or similar)

⸻

## Repo layout

```
/
  app/                    # Next.js App Router
    (auth)/
      login/
    app/
      boards/
      board/[boardId]/
  components/
    Board/
    Lists/
    Cards/
    Invite/
  lib/
    supabase/
    db/
    positions.ts
  supabase/
    migrations/
    seed.sql
    rls.sql
  tests/
    e2e/
      auth.spec.ts
      board.spec.ts
  package.json
  playwright.config.ts
  next.config.js
  public/
    manifest.webmanifest
    icons/
  TASKPACK.md (this doc)
```

⸻

## Data model (fixed)

Use sortable position for lists/cards (numeric, allow fractional inserts).

### Tables
- `workspaces(id uuid pk, name text, created_by uuid, created_at timestamptz)`
- `workspace_members(workspace_id uuid fk, user_id uuid fk, role text, created_at timestamptz, pk(workspace_id,user_id))`
- `boards(id uuid pk, workspace_id uuid fk, name text, created_by uuid, created_at timestamptz)`
- `lists(id uuid pk, board_id uuid fk, name text, position numeric, created_by uuid, created_at timestamptz)`
- `cards(id uuid pk, list_id uuid fk, title text, description text, due_at timestamptz null, assignee_id uuid null, position numeric, created_by uuid, updated_at timestamptz, created_at timestamptz)`

Optional V1.1
- `events(id uuid pk, workspace_id, actor_id, type, payload jsonb, created_at)`

⸻

## Security model (fixed)
- Login via Supabase Auth magic link (email).
- Every data row is gated by workspace membership via RLS.
- Roles exist but V1 treats all members as editors.

⸻

## Environment variables

Create `.env.local`:

```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...   # only if you add server-side admin tasks; avoid if possible
```

For tests (CI), either:
- use a dedicated Supabase project + test user credentials
- or run Supabase locally (optional; only if you want fully hermetic tests)

Keep V1 simple: hosted Supabase project + test account(s).

⸻

## Commands
- Dev: `pnpm dev`
- Lint: `pnpm lint`
- E2E: `pnpm test:e2e`

⸻

## UX scope (V1)

### Pages
- `/login` — email input → sends magic link
- `/app/boards` — list boards, create board
- `/app/board/[boardId]` — Trello-ish view: lists horizontally, cards vertically

### Core actions
- Create list
- Create card
- Edit card (title, description, due date, assignee)
- Drag card within a list to reorder
- Drag card between lists
- Invite member by email (adds membership when they sign up / confirm)

### Nice-to-have (only if cheap)
- Search within current board
- "Updated just now" toast, optimistic UI

⸻

## Golden acceptance tests (Playwright)

These tests define "done." Agents must not merge code that breaks them.

1. **Auth**
   - can visit /login, request magic link (stub or real test inbox)
   - once authenticated, redirected to /app/boards

2. **Board basics**
   - create board
   - create list
   - create card
   - edit card title + description

3. **DnD**
   - drag card from list A to list B
   - card appears in list B and persists after refresh

4. **Access control**
   - user who is NOT a member of a workspace cannot load its board data (expect empty/403-ish behavior in UI)
   - member can load

5. **Invites**
   - owner invites a second user email
   - second user signs in and sees the shared board

Pragmatic note: If inbox automation is too heavy for V1, you can:
- implement invites purely server-side (membership row created for email via RPC) and test via Supabase admin API in CI
- OR for local dev, temporarily allow a "dev accept invite" flow behind `NODE_ENV !== 'production'`.
But aim to land the real flow.

⸻

## Task list (ordered tickets)

Each ticket: Definition of Done, key files, and test expectations.

⸻

### T0 — Project scaffold

Goal: Next.js app with TS, lint, Playwright wired.

**Tasks**
- Create Next.js (App Router) project
- Add Playwright + config
- Add basic layout and routes placeholders

**DoD**
- `pnpm dev` runs
- `pnpm test:e2e` runs a trivial smoke test (homepage loads)

⸻

### T1 — Supabase client + session plumbing

Goal: Working Supabase client in browser, session persisted, protected routes.

**Tasks**
- Add `lib/supabase/client.ts` for browser client
- Add auth-aware layout for `/app/*` that redirects to `/login` when unauthenticated
- Add a basic header showing logged-in email + logout button

**DoD**
- Manual: login works, can access /app/boards
- Test: auth smoke test passes (can load app when authenticated)

⸻

### T2 — Database migrations + RLS skeleton

Goal: Schema exists in Supabase + RLS enforced.

**Tasks**
- Write SQL migration(s) in `supabase/migrations/` for tables
- Enable RLS on all tables
- Implement RLS policies that enforce workspace membership
- Add `supabase/seed.sql` with one workspace/board/lists/cards for local sanity
- Add `supabase/rls.sql` describing policies (for review)

**DoD**
- Running the SQL in Supabase creates schema cleanly
- A non-member cannot select boards/lists/cards from another workspace

RLS policy pattern (reference, not copy-paste gospel):
- A helper `is_member(workspace_id uuid)` implemented as a SQL function or inline `exists(...)`
- Boards: allow select if member of `boards.workspace_id`
- Lists: select if member of workspace via join to board
- Cards: select if member via list→board→workspace
- Writes: same predicate

⸻

### T3 — Workspace bootstrap on first login

Goal: First user gets a workspace automatically.

**Tasks**
- On first authenticated visit:
  - check if user is in `workspace_members`
  - if not, create workspace + membership
- Implement via:
  - a server action or API route that uses Supabase user session (no service role if possible)
  - OR a Supabase SQL function (RPC) callable by the user to create their workspace and membership

**DoD**
- New user signs in and ends up with a workspace + membership
- Existing user doesn't get duplicates

**Test**
- Can be covered indirectly by board tests (user sees /app/boards without manual setup)

⸻

### T4 — Boards page

Goal: List boards for the current user's workspace and create new board.

**Tasks**
- `/app/boards`:
  - query boards
  - create board modal/form
- Minimal UI, fast.

**DoD**
- Create board → shows immediately, persists after refresh
- Playwright: create board test

⸻

### T5 — Board view (lists + cards)

Goal: Render the board with columns and cards.

**Tasks**
- `/app/board/[boardId]` loads:
  - board metadata
  - lists ordered by position
  - cards per list ordered by position
- Add create-list and create-card flows
- Use optimistic updates for snappy feel (optional but nice)

**DoD**
- Can create list & card; reload persists
- Playwright: create list, create card

⸻

### T6 — Card edit modal

Goal: Edit card title/description/due date/assignee.

**Tasks**
- Card click opens modal
- Editable fields
- Save persists
- Updated timestamps maintained

**DoD**
- Playwright: edit card title/description

⸻

### T7 — Drag & drop reorder and move

Goal: DnD works and persists.

**Tasks**
- Use dnd-kit
- Implement:
  - reorder within list (update position)
  - move between lists (update list_id + position)
- position strategy:
  - when inserting between items, pick midpoint
  - if list gets "too dense," renormalize (optional; can defer)

**DoD**
- Drag card A from list 1 to list 2, refresh, remains moved
- Playwright: DnD test passes

⸻

### T8 — Invites (simple, secure)

Goal: Owner can invite family by email; invited user gains access after login.

Implementation options (pick one, but commit):

**Option 1 (recommended): "Invite table + auto-claim"**
- Create `workspace_invites(workspace_id, email, invited_by, created_at, claimed_at)`
- When a user logs in, server checks invites for their email and adds `workspace_members`, marks invite claimed.
- No need to send email from your app; you just tell family "log in with this email and you'll be added."

**Option 2: Supabase Auth admin invite**
- More complex; requires service role usage and email delivery settings.

**DoD**
- Owner enters email → invite row created
- Second user logs in with that email → membership created automatically
- Playwright: invite flow test

⸻

### T9 — PWA polish

Goal: Installable on phones.

**Tasks**
- Add `manifest.webmanifest`, icons, theme color
- Ensure proper `apple-touch-icon` tags
- Basic offline shell caching optional; don't get stuck here

**DoD**
- iOS "Add to Home Screen" results in standalone app-like launch
- Lighthouse PWA checks mostly green (don't chase perfection)

⸻

### T10 — Access control UI states

Goal: Friendly failure modes.

**Tasks**
- If board not found / not permitted: show "You don't have access" rather than crashing
- Handle auth expiry gracefully

**DoD**
- Playwright: access control test

⸻

## Implementation notes (to prevent agent thrash)

### Positioning helper (use this)

Create `lib/positions.ts`:
- `between(a: number | null, b: number | null) -> number`
  - if a null, return b - 1
  - if b null, return a + 1
  - else midpoint (a+b)/2
  - If midpoint equals a or b due to precision, trigger renormalization (can be TODO for V1)

Use `numeric` in Postgres; in TS treat as `number` but be mindful converting strings.

### Data fetching approach

Keep it simple:
- For board page: fetch lists and cards with a couple queries, then group client-side.
- Avoid premature realtime; add later if desired.

### Don't use service role unless unavoidable

If you do need it (e.g. for invite emailing), isolate to server routes only and never expose to client.

⸻

## Agent execution instructions (copy/paste into agent)

### Operating rules
- Always keep Playwright tests green.
- Don't introduce new libraries unless necessary.
- Keep UX minimal, functional, stable on mobile Safari.
- For each ticket: implement + update tests + update docs.

### Per-ticket output
- Summary of changes
- How to run
- What tests cover it
- Any follow-ups as separate TODOs (not "hidden work")

⸻

## Suggested first PR breakdown
1. T0 + T1 (scaffold + auth skeleton)
2. T2 + T3 (schema + RLS + workspace bootstrap)
3. T4 + T5 (boards + board view CRUD)
4. T6 + T7 (edit + DnD)
5. T8 (invites)
6. T9 + T10 (PWA + access UX)
