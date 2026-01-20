-- Migration for T8: Workspace invites
-- Creates workspace_invites table and auto-claim functionality

-- ============================================================================
-- WORKSPACE INVITES TABLE
-- ============================================================================

-- Table to store pending workspace invitations
CREATE TABLE workspace_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  invited_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  claimed_at TIMESTAMPTZ,
  UNIQUE(workspace_id, email)
);

-- Index for faster lookups by email
CREATE INDEX idx_workspace_invites_email ON workspace_invites(email) WHERE claimed_at IS NULL;
CREATE INDEX idx_workspace_invites_workspace_id ON workspace_invites(workspace_id);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE workspace_invites ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: WORKSPACE_INVITES
-- ============================================================================

-- Users can view invites in their workspaces
CREATE POLICY "Members can view workspace invites"
  ON workspace_invites FOR SELECT
  USING (is_workspace_member(workspace_id));

-- Members can create invites for their workspaces
CREATE POLICY "Members can create invites"
  ON workspace_invites FOR INSERT
  WITH CHECK (
    is_workspace_member(workspace_id) AND
    auth.uid() = invited_by
  );

-- Members can delete invites from their workspaces (revoke invites)
CREATE POLICY "Members can revoke invites"
  ON workspace_invites FOR DELETE
  USING (is_workspace_member(workspace_id));

-- Members can update invites in their workspaces (for claiming)
CREATE POLICY "Members can update invites"
  ON workspace_invites FOR UPDATE
  USING (is_workspace_member(workspace_id))
  WITH CHECK (is_workspace_member(workspace_id));

-- Allow users to claim their own invites (when they sign up/login)
-- This policy allows authenticated users to update invites sent to their email
CREATE POLICY "Users can claim their own invites"
  ON workspace_invites FOR UPDATE
  USING (
    email = (SELECT email FROM auth.users WHERE id = auth.uid()) AND
    claimed_at IS NULL
  )
  WITH CHECK (
    email = (SELECT email FROM auth.users WHERE id = auth.uid())
  );

-- ============================================================================
-- AUTO-CLAIM INVITES FUNCTION
-- ============================================================================

-- Function to claim any pending invites for the current user's email
-- and add them to the corresponding workspaces
-- Returns the number of invites claimed
CREATE OR REPLACE FUNCTION claim_pending_invites()
RETURNS INTEGER AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_invite RECORD;
  v_claimed_count INTEGER := 0;
BEGIN
  -- Get current user ID and email
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get user's email
  SELECT email INTO v_user_email
  FROM auth.users
  WHERE id = v_user_id;

  IF v_user_email IS NULL THEN
    RETURN 0;
  END IF;

  -- Find and claim all pending invites for this email
  FOR v_invite IN
    SELECT id, workspace_id
    FROM workspace_invites
    WHERE email = v_user_email
      AND claimed_at IS NULL
  LOOP
    -- Check if user is not already a member
    IF NOT EXISTS (
      SELECT 1
      FROM workspace_members
      WHERE workspace_id = v_invite.workspace_id
        AND user_id = v_user_id
    ) THEN
      -- Add user to workspace
      INSERT INTO workspace_members (workspace_id, user_id, role)
      VALUES (v_invite.workspace_id, v_user_id, 'editor')
      ON CONFLICT (workspace_id, user_id) DO NOTHING;
    END IF;

    -- Mark invite as claimed
    UPDATE workspace_invites
    SET claimed_at = now()
    WHERE id = v_invite.id;

    v_claimed_count := v_claimed_count + 1;
  END LOOP;

  RETURN v_claimed_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION claim_pending_invites() TO authenticated;
