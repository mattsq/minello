-- Initial schema for FamilyBoard
-- Creates all tables with RLS enabled and policies

-- ============================================================================
-- TABLES
-- ============================================================================

-- Workspaces table
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Workspace members table (junction table)
CREATE TABLE workspace_members (
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'editor',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (workspace_id, user_id)
);

-- Boards table
CREATE TABLE boards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lists table
CREATE TABLE lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  position NUMERIC NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Cards table
CREATE TABLE cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_at TIMESTAMPTZ,
  assignee_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  position NUMERIC NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- INDEXES for performance
-- ============================================================================

CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id);
CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id);
CREATE INDEX idx_boards_workspace_id ON boards(workspace_id);
CREATE INDEX idx_lists_board_id ON lists(board_id);
CREATE INDEX idx_lists_position ON lists(board_id, position);
CREATE INDEX idx_cards_list_id ON cards(list_id);
CREATE INDEX idx_cards_position ON cards(list_id, position);
CREATE INDEX idx_cards_assignee_id ON cards(assignee_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger to update updated_at on cards
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cards_updated_at
  BEFORE UPDATE ON cards
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- RLS HELPER FUNCTIONS
-- ============================================================================

-- Check if user is a member of a workspace
CREATE OR REPLACE FUNCTION is_workspace_member(workspace_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM workspace_members
    WHERE workspace_members.workspace_id = is_workspace_member.workspace_id
      AND workspace_members.user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: WORKSPACES
-- ============================================================================

-- Users can view workspaces they are members of
CREATE POLICY "Users can view their workspaces"
  ON workspaces FOR SELECT
  USING (is_workspace_member(id));

-- Users can create workspaces (for bootstrap)
CREATE POLICY "Users can create workspaces"
  ON workspaces FOR INSERT
  WITH CHECK (auth.uid() = created_by);

-- Members can update their workspaces
CREATE POLICY "Members can update workspaces"
  ON workspaces FOR UPDATE
  USING (is_workspace_member(id))
  WITH CHECK (is_workspace_member(id));

-- Only creator can delete workspace (optional, can be restricted further)
CREATE POLICY "Creator can delete workspace"
  ON workspaces FOR DELETE
  USING (created_by = auth.uid());

-- ============================================================================
-- RLS POLICIES: WORKSPACE_MEMBERS
-- ============================================================================

-- Users can view members of workspaces they belong to
CREATE POLICY "Users can view workspace members"
  ON workspace_members FOR SELECT
  USING (is_workspace_member(workspace_id));

-- Users can add themselves to workspaces (for bootstrap/invites)
CREATE POLICY "Users can join workspaces"
  ON workspace_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Members can add other members to their workspace
CREATE POLICY "Members can add members"
  ON workspace_members FOR INSERT
  WITH CHECK (is_workspace_member(workspace_id));

-- Members can leave workspace
CREATE POLICY "Users can leave workspaces"
  ON workspace_members FOR DELETE
  USING (user_id = auth.uid());

-- Members can remove other members
CREATE POLICY "Members can remove members"
  ON workspace_members FOR DELETE
  USING (is_workspace_member(workspace_id));

-- ============================================================================
-- RLS POLICIES: BOARDS
-- ============================================================================

-- Users can view boards in their workspaces
CREATE POLICY "Users can view boards in their workspaces"
  ON boards FOR SELECT
  USING (is_workspace_member(workspace_id));

-- Members can create boards in their workspaces
CREATE POLICY "Members can create boards"
  ON boards FOR INSERT
  WITH CHECK (
    is_workspace_member(workspace_id) AND
    auth.uid() = created_by
  );

-- Members can update boards in their workspaces
CREATE POLICY "Members can update boards"
  ON boards FOR UPDATE
  USING (is_workspace_member(workspace_id))
  WITH CHECK (is_workspace_member(workspace_id));

-- Members can delete boards in their workspaces
CREATE POLICY "Members can delete boards"
  ON boards FOR DELETE
  USING (is_workspace_member(workspace_id));

-- ============================================================================
-- RLS POLICIES: LISTS
-- ============================================================================

-- Users can view lists in boards they have access to
CREATE POLICY "Users can view lists in accessible boards"
  ON lists FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM boards
      WHERE boards.id = lists.board_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can create lists in accessible boards
CREATE POLICY "Members can create lists"
  ON lists FOR INSERT
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM boards
      WHERE boards.id = board_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can update lists in accessible boards
CREATE POLICY "Members can update lists"
  ON lists FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM boards
      WHERE boards.id = lists.board_id
        AND is_workspace_member(boards.workspace_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM boards
      WHERE boards.id = lists.board_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can delete lists in accessible boards
CREATE POLICY "Members can delete lists"
  ON lists FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM boards
      WHERE boards.id = lists.board_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- ============================================================================
-- RLS POLICIES: CARDS
-- ============================================================================

-- Users can view cards in lists they have access to
CREATE POLICY "Users can view cards in accessible lists"
  ON cards FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lists
      JOIN boards ON boards.id = lists.board_id
      WHERE lists.id = cards.list_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can create cards in accessible lists
CREATE POLICY "Members can create cards"
  ON cards FOR INSERT
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM lists
      JOIN boards ON boards.id = lists.board_id
      WHERE lists.id = list_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can update cards in accessible lists
CREATE POLICY "Members can update cards"
  ON cards FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM lists
      JOIN boards ON boards.id = lists.board_id
      WHERE lists.id = cards.list_id
        AND is_workspace_member(boards.workspace_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM lists
      JOIN boards ON boards.id = lists.board_id
      WHERE lists.id = cards.list_id
        AND is_workspace_member(boards.workspace_id)
    )
  );

-- Members can delete cards in accessible lists
CREATE POLICY "Members can delete cards"
  ON cards FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM lists
      JOIN boards ON boards.id = lists.board_id
      WHERE lists.id = cards.list_id
        AND is_workspace_member(boards.workspace_id)
    )
  );
