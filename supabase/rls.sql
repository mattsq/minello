-- Row Level Security (RLS) Policy Documentation
-- FamilyBoard Task Pack

-- ============================================================================
-- OVERVIEW
-- ============================================================================
-- This document describes the Row Level Security strategy for FamilyBoard.
-- The actual policies are implemented in the migration file.
--
-- Security Model:
-- - All data access is gated by workspace membership
-- - Users can only access resources in workspaces they are members of
-- - RLS is enabled on all tables
-- - All policies use the is_workspace_member() helper function

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- is_workspace_member(workspace_id UUID) -> BOOLEAN
--   Returns true if the current authenticated user (auth.uid()) is a member
--   of the specified workspace.
--
--   Implementation: Checks workspace_members table for a row matching both
--   the workspace_id parameter and auth.uid()
--
--   Used by: All RLS policies to enforce workspace-based access control

-- ============================================================================
-- TABLE: workspaces
-- ============================================================================

-- SELECT Policy: "Users can view their workspaces"
--   Users can view workspaces where they are members
--   Predicate: is_workspace_member(workspaces.id)

-- INSERT Policy: "Users can create workspaces"
--   Users can create new workspaces (for T3 workspace bootstrap)
--   Predicate: auth.uid() = created_by
--   Note: User must set themselves as created_by

-- UPDATE Policy: "Members can update workspaces"
--   Members can update workspace details (name, etc.)
--   Predicate: is_workspace_member(workspaces.id)

-- DELETE Policy: "Creator can delete workspace"
--   Only the creator can delete the workspace
--   Predicate: created_by = auth.uid()
--   Note: Can be further restricted if needed (e.g., only if no members)

-- ============================================================================
-- TABLE: workspace_members
-- ============================================================================

-- SELECT Policy: "Users can view workspace members"
--   Users can see all members of workspaces they belong to
--   Predicate: is_workspace_member(workspace_id)

-- INSERT Policy: "Users can join workspaces"
--   Users can add themselves to workspaces (for bootstrap)
--   Predicate: user_id = auth.uid()
--   Note: This allows T3 workspace bootstrap to work

-- INSERT Policy: "Members can add members"
--   Existing members can invite new members to their workspace
--   Predicate: is_workspace_member(workspace_id)
--   Note: Used for T8 invite flow

-- DELETE Policy: "Users can leave workspaces"
--   Users can remove themselves from workspaces
--   Predicate: user_id = auth.uid()

-- DELETE Policy: "Members can remove members"
--   Members can remove other members from workspace
--   Predicate: is_workspace_member(workspace_id)
--   Note: V1 doesn't distinguish between owner/member roles for this

-- ============================================================================
-- TABLE: workspace_invites (T8)
-- ============================================================================

-- SELECT Policy: "Members can view workspace invites"
--   Members can view all invites for workspaces they belong to
--   Predicate: is_workspace_member(workspace_id)

-- INSERT Policy: "Members can create invites"
--   Members can create invites for their workspaces
--   Predicate: is_workspace_member(workspace_id) AND auth.uid() = invited_by
--   Note: Allows any member to invite others to the workspace

-- UPDATE Policy: "Members can update invites"
--   Members can update invites in their workspaces (for manual claim operations)
--   Predicate: is_workspace_member(workspace_id)

-- UPDATE Policy: "Users can claim their own invites"
--   Authenticated users can claim invites sent to their email
--   Predicate: email = (SELECT email FROM auth.users WHERE id = auth.uid())
--              AND claimed_at IS NULL
--   Note: This allows the auto-claim flow in T8 to work

-- DELETE Policy: "Members can revoke invites"
--   Members can delete (revoke) invites from their workspaces
--   Predicate: is_workspace_member(workspace_id)

-- ============================================================================
-- TABLE: boards
-- ============================================================================

-- SELECT Policy: "Users can view boards in their workspaces"
--   Users can view boards that belong to workspaces they are members of
--   Predicate: is_workspace_member(workspace_id)

-- INSERT Policy: "Members can create boards"
--   Members can create new boards in their workspaces
--   Predicate: is_workspace_member(workspace_id) AND auth.uid() = created_by

-- UPDATE Policy: "Members can update boards"
--   Members can update board details (name, etc.)
--   Predicate: is_workspace_member(workspace_id)

-- DELETE Policy: "Members can delete boards"
--   Members can delete boards in their workspaces
--   Predicate: is_workspace_member(workspace_id)

-- ============================================================================
-- TABLE: lists
-- ============================================================================

-- SELECT Policy: "Users can view lists in accessible boards"
--   Users can view lists in boards they have access to
--   Predicate: EXISTS (
--     SELECT 1 FROM boards
--     WHERE boards.id = lists.board_id
--       AND is_workspace_member(boards.workspace_id)
--   )
--   Note: Traverses list -> board -> workspace membership

-- INSERT Policy: "Members can create lists"
--   Members can create lists in accessible boards
--   Predicate: auth.uid() = created_by AND <board access check>

-- UPDATE Policy: "Members can update lists"
--   Members can update list details (name, position, etc.)
--   Predicate: <board access check via EXISTS>

-- DELETE Policy: "Members can delete lists"
--   Members can delete lists in accessible boards
--   Predicate: <board access check via EXISTS>

-- ============================================================================
-- TABLE: cards
-- ============================================================================

-- SELECT Policy: "Users can view cards in accessible lists"
--   Users can view cards in lists they have access to
--   Predicate: EXISTS (
--     SELECT 1 FROM lists
--     JOIN boards ON boards.id = lists.board_id
--     WHERE lists.id = cards.list_id
--       AND is_workspace_member(boards.workspace_id)
--   )
--   Note: Traverses card -> list -> board -> workspace membership

-- INSERT Policy: "Members can create cards"
--   Members can create cards in accessible lists
--   Predicate: auth.uid() = created_by AND <list access check>

-- UPDATE Policy: "Members can update cards"
--   Members can update card details (title, description, position, etc.)
--   Predicate: <list access check via EXISTS>
--   Note: Allows moving cards between lists (list_id update)

-- DELETE Policy: "Members can delete cards"
--   Members can delete cards in accessible lists
--   Predicate: <list access check via EXISTS>

-- ============================================================================
-- SECURITY CONSIDERATIONS
-- ============================================================================

-- 1. All tables have RLS enabled - no exceptions
-- 2. No data can be accessed without workspace membership
-- 3. The is_workspace_member() function is SECURITY DEFINER to allow
--    checking workspace_members table even when querying other tables
-- 4. V1 treats all workspace members equally (no role distinction for access)
-- 5. created_by fields are enforced on INSERT to track ownership
-- 6. Foreign key cascades ensure data consistency:
--    - Deleting workspace -> deletes members, boards
--    - Deleting board -> deletes lists
--    - Deleting list -> deletes cards
--    - Deleting user -> removes memberships, sets assignee_id to NULL

-- ============================================================================
-- TESTING RLS
-- ============================================================================

-- To test RLS policies:
-- 1. Create two test users (User A and User B)
-- 2. Create a workspace as User A
-- 3. Create a board, list, and card as User A
-- 4. Attempt to access as User B (should fail - no results)
-- 5. Add User B as workspace member
-- 6. Attempt to access as User B (should succeed)
-- 7. Remove User B from workspace
-- 8. Attempt to access as User B (should fail again)
--
-- To test invite flow (T8):
-- 1. User A creates an invite for userb@example.com
-- 2. User B logs in with userb@example.com
-- 3. claim_pending_invites() is called during bootstrap
-- 4. User B is automatically added to workspace_members
-- 5. User B can now access the workspace data

-- Example test queries (run as User B after User A creates data):
--
-- SET ROLE authenticated;
-- SET request.jwt.claims.sub = '<user_b_id>';
--
-- -- Should return empty (User B not a member)
-- SELECT * FROM workspaces;
-- SELECT * FROM boards;
-- SELECT * FROM lists;
-- SELECT * FROM cards;
--
-- -- After adding User B to workspace:
-- INSERT INTO workspace_members (workspace_id, user_id, role)
-- VALUES ('<workspace_id>', '<user_b_id>', 'editor');
--
-- -- Should now return data
-- SELECT * FROM workspaces;
-- SELECT * FROM boards;
-- SELECT * FROM lists;
-- SELECT * FROM cards;

-- ============================================================================
-- MAINTENANCE NOTES
-- ============================================================================

-- When adding new tables:
-- 1. Enable RLS: ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;
-- 2. Add policies that check workspace membership
-- 3. Document policies in this file
-- 4. Test with multiple users

-- When modifying policies:
-- 1. Update the migration file with new policies
-- 2. Update this documentation
-- 3. Test access patterns thoroughly
-- 4. Consider performance implications of complex EXISTS checks
