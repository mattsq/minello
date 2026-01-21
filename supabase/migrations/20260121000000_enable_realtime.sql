-- Enable Realtime for FamilyBoard
-- This allows clients to subscribe to database changes in real-time

-- Enable Realtime replication for tables
-- Note: This adds tables to the supabase_realtime publication
-- RLS policies automatically apply to Realtime subscriptions

ALTER PUBLICATION supabase_realtime ADD TABLE boards;
ALTER PUBLICATION supabase_realtime ADD TABLE lists;
ALTER PUBLICATION supabase_realtime ADD TABLE cards;

-- Optional: Also add workspaces and workspace_members if needed for future features
-- ALTER PUBLICATION supabase_realtime ADD TABLE workspaces;
-- ALTER PUBLICATION supabase_realtime ADD TABLE workspace_members;
