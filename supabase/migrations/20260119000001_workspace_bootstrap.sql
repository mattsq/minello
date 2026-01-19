-- Migration for T3: Workspace bootstrap on first login
-- Creates an RPC function that users can call to bootstrap their workspace

-- ============================================================================
-- WORKSPACE BOOTSTRAP FUNCTION
-- ============================================================================

-- Function to bootstrap a user's first workspace if they don't have one
-- Returns the workspace_id of either the existing or newly created workspace
CREATE OR REPLACE FUNCTION bootstrap_user_workspace()
RETURNS UUID AS $$
DECLARE
  v_workspace_id UUID;
  v_user_id UUID;
BEGIN
  -- Get current user ID
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Check if user is already a member of any workspace
  SELECT workspace_id INTO v_workspace_id
  FROM workspace_members
  WHERE user_id = v_user_id
  LIMIT 1;

  -- If user is already a member, return that workspace
  IF v_workspace_id IS NOT NULL THEN
    RETURN v_workspace_id;
  END IF;

  -- Otherwise, create a new workspace
  INSERT INTO workspaces (name, created_by)
  VALUES ('My Workspace', v_user_id)
  RETURNING id INTO v_workspace_id;

  -- Add user as a member of the new workspace
  INSERT INTO workspace_members (workspace_id, user_id, role)
  VALUES (v_workspace_id, v_user_id, 'editor');

  RETURN v_workspace_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION bootstrap_user_workspace() TO authenticated;
