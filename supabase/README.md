# Supabase Database Setup

This directory contains the database migrations, RLS policies, and seed data for the FamilyBoard application.

## Files

- **migrations/** - SQL migration files that create the database schema
- **seed.sql** - Sample data for local development and testing
- **rls.sql** - Documentation of Row Level Security policies

## How to Run Migrations

### Option 1: Supabase Dashboard (Recommended for hosted projects)

1. Log in to your [Supabase Dashboard](https://app.supabase.com)
2. Navigate to your project
3. Go to **SQL Editor**
4. Copy and paste the contents of `migrations/20260119000000_initial_schema.sql`
5. Click **Run** to execute the migration

### Option 2: Supabase CLI (For local development)

If you're running Supabase locally or using the CLI:

```bash
# Make sure you're in the project root
cd /home/user/minello

# Run the migration
supabase db push

# Or apply migrations individually
supabase db execute --file supabase/migrations/20260119000000_initial_schema.sql
```

### Option 3: Direct psql (Advanced)

If you have direct PostgreSQL access:

```bash
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/migrations/20260119000000_initial_schema.sql
```

## Running Seed Data

**IMPORTANT:** Only run seed data AFTER you have:
1. Applied the migration
2. Created at least one user via Supabase Auth (e.g., sign up through the app)

To apply seed data:

1. Go to **SQL Editor** in Supabase Dashboard
2. Copy and paste the contents of `seed.sql`
3. Click **Run**

The seed script will automatically find the first user in your `auth.users` table and create sample data for them.

## What Gets Created

### Migration (`20260119000000_initial_schema.sql`)

Creates the following tables:
- **workspaces** - Top-level organizational unit
- **workspace_members** - Junction table for user-workspace relationships
- **boards** - Kanban boards within workspaces
- **lists** - Columns within boards
- **cards** - Individual tasks/cards within lists

Also includes:
- Indexes for performance
- RLS policies for security
- Helper function `is_workspace_member()`
- Triggers for automatic timestamp updates

### Seed Data (`seed.sql`)

Creates a sample workspace with:
- 1 workspace named "Family Workspace"
- 1 board named "Family Tasks"
- 3 lists: "To Do", "Doing", "Done"
- 7 sample cards distributed across the lists

## Verifying the Setup

After running the migration, you can verify it worked:

```sql
-- Check that tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check that RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Should show rowsecurity = true for all tables
```

## Security

All tables have Row Level Security (RLS) enabled. This means:
- Users can only access data in workspaces they are members of
- All queries are automatically filtered by workspace membership
- No data leaks between workspaces

See `rls.sql` for detailed documentation of the security policies.

## Troubleshooting

### Migration fails with "relation already exists"

The tables were already created. You can either:
- Drop the existing tables: **BE CAREFUL - THIS DELETES DATA**
- Skip to running seed data if you just need sample data

### Seed data returns "No users found"

You need to create a user first:
1. Go to your app's login page
2. Sign up with an email
3. Then run the seed script

### RLS policies blocking queries

Make sure you're authenticated:
- In the dashboard, queries run as the `postgres` user (bypasses RLS)
- In your app, make sure the Supabase client is properly initialized with auth

## Next Steps

After setting up the database:
1. Proceed to **T3** - Workspace bootstrap on first login
2. Test that the schema works by creating a board through the UI (once T4 is implemented)
3. Verify RLS is working by trying to access data from a different user
