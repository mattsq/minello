-- Seed data for local development and testing
-- Creates a sample workspace, board, lists, and cards

-- IMPORTANT: This seed assumes you have a test user in auth.users
-- Replace the UUIDs below with actual user IDs from your Supabase auth.users table
-- Or run this after creating a test user via Supabase Auth

-- Note: In production, workspaces are created via T3 (workspace bootstrap)
-- This seed is purely for local development and testing

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Create a test workspace
-- Replace 'YOUR_USER_ID_HERE' with an actual UUID from auth.users
DO $$
DECLARE
  v_workspace_id UUID;
  v_board_id UUID;
  v_list_todo_id UUID;
  v_list_doing_id UUID;
  v_list_done_id UUID;
  v_user_id UUID;
BEGIN
  -- Try to get the first user from auth.users
  -- If no users exist, this seed will skip (safe for fresh installs)
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;

  IF v_user_id IS NOT NULL THEN
    -- Create workspace
    INSERT INTO workspaces (id, name, created_by)
    VALUES (
      gen_random_uuid(),
      'Family Workspace',
      v_user_id
    )
    RETURNING id INTO v_workspace_id;

    -- Add creator as member
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_user_id, 'owner');

    -- Create a sample board
    INSERT INTO boards (id, workspace_id, name, created_by)
    VALUES (
      gen_random_uuid(),
      v_workspace_id,
      'Family Tasks',
      v_user_id
    )
    RETURNING id INTO v_board_id;

    -- Create three lists: To Do, Doing, Done
    INSERT INTO lists (id, board_id, name, position, created_by)
    VALUES (
      gen_random_uuid(),
      v_board_id,
      'To Do',
      1000,
      v_user_id
    )
    RETURNING id INTO v_list_todo_id;

    INSERT INTO lists (id, board_id, name, position, created_by)
    VALUES (
      gen_random_uuid(),
      v_board_id,
      'Doing',
      2000,
      v_user_id
    )
    RETURNING id INTO v_list_doing_id;

    INSERT INTO lists (id, board_id, name, position, created_by)
    VALUES (
      gen_random_uuid(),
      v_board_id,
      'Done',
      3000,
      v_user_id
    )
    RETURNING id INTO v_list_done_id;

    -- Create sample cards in To Do
    INSERT INTO cards (list_id, title, description, position, created_by)
    VALUES
      (v_list_todo_id, 'Plan family dinner', 'Decide on menu and shopping list', 1000, v_user_id),
      (v_list_todo_id, 'Fix leaky faucet', 'Kitchen sink is dripping', 2000, v_user_id),
      (v_list_todo_id, 'Schedule dentist appointment', 'Annual checkup for the kids', 3000, v_user_id);

    -- Create sample cards in Doing
    INSERT INTO cards (list_id, title, description, position, created_by, due_at)
    VALUES
      (v_list_doing_id, 'Grocery shopping', 'Get items for the week', 1000, v_user_id, now() + interval '2 days'),
      (v_list_doing_id, 'Organize garage', 'Clear out old boxes', 2000, v_user_id, NULL);

    -- Create sample cards in Done
    INSERT INTO cards (list_id, title, description, position, created_by)
    VALUES
      (v_list_done_id, 'Pay electricity bill', 'Completed online', 1000, v_user_id),
      (v_list_done_id, 'Water the plants', 'All plants watered', 2000, v_user_id);

    RAISE NOTICE 'Seed data created successfully for user %', v_user_id;
    RAISE NOTICE 'Workspace ID: %', v_workspace_id;
    RAISE NOTICE 'Board ID: %', v_board_id;
  ELSE
    RAISE NOTICE 'No users found in auth.users - skipping seed data';
    RAISE NOTICE 'Create a user via Supabase Auth first, then run this seed again';
  END IF;
END $$;
