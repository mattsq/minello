# FamilyBoard Task Pack

A Trello-like family task board PWA built with Next.js and Supabase.

## Project Status

Repository structure initialized (T0). See [CLAUDE.md](./CLAUDE.md) for full project specification and task breakdown.

## Tech Stack

- **Frontend**: Next.js 14 (App Router) + TypeScript
- **UI**: Minimal CSS (inline styles for now)
- **Drag & Drop**: @dnd-kit/*
- **Backend**: Supabase (Auth + Postgres with RLS)
- **Testing**: Playwright e2e
- **Deploy**: Vercel (or similar)

## Setup

### Prerequisites

- Node.js 18+ and pnpm
- Supabase account (for T1+)

### Installation

```bash
# Install dependencies
pnpm install

# Install Playwright browsers (for testing)
pnpm exec playwright install --with-deps

# Copy environment template
cp .env.example .env.local
# Then add your Supabase credentials to .env.local
```

### Development

```bash
# Start dev server
pnpm dev

# Run tests
pnpm test:e2e

# Run tests with UI
pnpm test:e2e:ui

# Build for production
pnpm build

# Lint
pnpm lint
```

## Project Structure

```
/
  app/                    # Next.js App Router pages
    (auth)/login/        # Login page
    app/                 # Protected app routes
      boards/            # Board list
      board/[boardId]/   # Board detail view
  components/            # React components
    Board/
    Lists/
    Cards/
    Invite/
  lib/                   # Shared utilities
    supabase/            # Supabase client
    db/                  # Database helpers
    positions.ts         # Position calculation for drag & drop
  supabase/              # Supabase configuration
    migrations/          # Database migrations
    seed.sql            # Seed data
    rls.sql             # Row Level Security policies
  tests/e2e/             # Playwright tests
  public/                # Static assets
    manifest.webmanifest # PWA manifest
    icons/              # PWA icons
```

## Implementation Tasks

See [CLAUDE.md](./CLAUDE.md) for detailed task breakdown (T0-T10).

### Completed
- ✅ T0: Project scaffold
- ✅ T1: Supabase client + session plumbing

### In Progress
- 🔄 T2: Database migrations + RLS

### TODO
- ⏳ T3: Workspace bootstrap
- ⏳ T4: Boards page
- ⏳ T5: Board view (lists + cards)
- ⏳ T6: Card edit modal
- ⏳ T7: Drag & drop
- ⏳ T8: Invites
- ⏳ T9: PWA polish
- ⏳ T10: Access control UI

## Environment Variables

Required environment variables (see `.env.example`):

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

**Important**: You must replace the placeholder values in `.env.local` with real Supabase credentials from your project to run the app and tests. Get these from your [Supabase project settings](https://supabase.com/dashboard/project/_/settings/api).

## License

Private family project
