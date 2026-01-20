# FamilyBoard Task Pack

A Trello-like family task board PWA built with Next.js and Supabase.

## Project Status

**All core features complete!** ✅

This is a fully functional Trello-like family task board PWA with:
- 🔐 Magic link authentication via Supabase
- 📱 PWA support for mobile installation
- 🎯 Drag & drop task management
- 👥 Workspace invites and access control
- 🔒 Row-level security (RLS)
- ✅ Full e2e test coverage with Playwright

See [CLAUDE.md](./CLAUDE.md) for full project specification and implementation details.

## Features

- 📋 **Task Boards** - Create multiple boards for different family projects
- 📝 **Lists & Cards** - Organize tasks in customizable lists
- 🎯 **Drag & Drop** - Intuitively move cards within and between lists
- ✏️ **Rich Cards** - Add descriptions, due dates, and assignees
- 👥 **Family Sharing** - Invite family members by email
- 🔐 **Secure Auth** - Magic link authentication (no passwords!)
- 🔒 **Private Workspaces** - Data isolated with row-level security
- 📱 **Mobile First** - Installable PWA for iOS and Android
- ⚡ **Real-time Updates** - See changes persist instantly

## Tech Stack

- **Frontend**: Next.js 14 (App Router) + TypeScript
- **UI**: Minimal CSS (inline styles for simplicity)
- **Drag & Drop**: @dnd-kit/* (sortable, sensors, utilities)
- **Backend**: Supabase (Auth + Postgres with RLS)
- **Testing**: Playwright e2e (full coverage)
- **Deploy**: Vercel (or similar)

## Quick Start

1. **Clone and install**
   ```bash
   git clone <repo-url>
   cd minello
   pnpm install
   ```

2. **Set up Supabase**
   - Create a new project at [supabase.com](https://supabase.com)
   - Run the migrations in `supabase/migrations/` via the Supabase SQL editor
   - Copy your project URL and anon key

3. **Configure environment**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your Supabase credentials
   ```

4. **Run the app**
   ```bash
   pnpm dev
   # Visit http://localhost:3000
   ```

5. **Run tests** (optional)
   ```bash
   pnpm exec playwright install --with-deps
   pnpm test:e2e
   ```

## Setup

### Prerequisites

- Node.js 18+ and pnpm
- Supabase account (free tier works fine)

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

See [CLAUDE.md](./CLAUDE.md) for detailed task breakdown and specifications.

### All Tasks Completed ✅

- ✅ **T0**: Project scaffold - Next.js + TypeScript + Playwright setup
- ✅ **T1**: Supabase client + session plumbing - Auth flow and protected routes
- ✅ **T2**: Database migrations + RLS - Full schema with Row Level Security policies
- ✅ **T3**: Workspace bootstrap - Auto-create workspace on first login
- ✅ **T4**: Boards page - List and create boards
- ✅ **T5**: Board view - Lists and cards with CRUD operations
- ✅ **T6**: Card edit modal - Edit title, description, due date, assignee
- ✅ **T7**: Drag & drop - Reorder cards within/between lists using @dnd-kit
- ✅ **T8**: Workspace invites - Email-based invite system with auto-claim
- ✅ **T9**: PWA polish - Installable with manifest and icons
- ✅ **T10**: Access control UI - Graceful handling of unauthorized access

### Test Coverage

All golden acceptance tests passing:
- ✅ Authentication flow (magic link)
- ✅ Board CRUD operations
- ✅ Drag & drop persistence
- ✅ Access control enforcement
- ✅ Workspace invite flow

## Usage

1. **First Login**: Visit `/login` and enter your email - you'll receive a magic link
2. **Auto Workspace**: On first login, a workspace is automatically created for you
3. **Create Boards**: Start by creating a board for a project (e.g., "House Chores", "Vacation Planning")
4. **Add Lists**: Create lists to organize your workflow (e.g., "To Do", "In Progress", "Done")
5. **Add Cards**: Create cards for individual tasks with details, due dates, and assignments
6. **Drag & Drop**: Move cards between lists or reorder within a list
7. **Invite Family**: Use the invite feature to add family members by email
8. **Mobile**: Add to your phone's home screen for app-like experience

## Environment Variables

Required environment variables (see `.env.example`):

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_SITE_URL=https://your-app.vercel.app
```

**Important**: You must replace the placeholder values in `.env.local` with real Supabase credentials from your project to run the app and tests. Get these from your [Supabase project settings](https://supabase.com/dashboard/project/_/settings/api). `SUPABASE_SERVICE_ROLE_KEY` is required for sending invite emails.

## Deployment

The app is configured for deployment to Vercel with automatic deploys.

### One-Time Setup

1. **Create Vercel Project**
   - Go to [vercel.com](https://vercel.com) → New Project → Import from GitHub
   - Select the repository
   - Vercel auto-detects Next.js

2. **Configure Environment Variables in Vercel Dashboard**
   - Go to Project Settings → Environment Variables
   - Add:
     - `NEXT_PUBLIC_SUPABASE_URL` = your production Supabase URL
     - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = your production anon key
     - `SUPABASE_SERVICE_ROLE_KEY` = your Supabase service role key (for invite emails)
     - `NEXT_PUBLIC_SITE_URL` = `https://your-app.vercel.app`

3. **Get Vercel IDs for GitHub Secrets**
   ```bash
   # Link your local project to Vercel
   npx vercel link

   # Copy orgId and projectId from .vercel/project.json
   ```

4. **Add GitHub Repository Secrets**
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add the following secrets:
     - `VERCEL_TOKEN` - Create at [vercel.com/account/tokens](https://vercel.com/account/tokens)
     - `VERCEL_ORG_ID` - From `.vercel/project.json`
     - `VERCEL_PROJECT_ID` - From `.vercel/project.json`

5. **Configure Supabase Auth Redirects**
   - In Supabase Dashboard → Authentication → URL Configuration
   - Add your Vercel domain to "Redirect URLs": `https://your-app.vercel.app/**`

### Deployment Flow

- **PRs**: When you open a PR, CI runs lint/build/tests, then deploys a preview. A comment is posted with the preview URL.
- **Main**: When you merge to main, CI runs all checks, then deploys to production.

### Running Migrations on Production

To run database migrations on your production Supabase:

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Paste and run the migration SQL from `supabase/migrations/`

Alternatively, use the Supabase CLI:
```bash
supabase db push --linked
```

## License

Private family project
