import { SupabaseClient } from '@supabase/supabase-js'

export type WorkspaceMember = {
  user_id: string
  role: string
  created_at: string
  users: {
    email: string
  }
}

export type WorkspaceInvite = {
  id: string
  email: string
  invited_by: string
  created_at: string
  claimed_at: string | null
}

/**
 * Ensures the current user has a workspace by calling the bootstrap RPC.
 * This will either return an existing workspace or create a new one.
 * Also claims any pending invites for the user's email.
 * Should be called on first authenticated visit.
 */
export async function ensureUserWorkspace(
  supabase: SupabaseClient
): Promise<string | null> {
  try {
    // First, claim any pending invites for this user's email
    // This will add them to invited workspaces
    const { error: claimError } = await supabase.rpc('claim_pending_invites')

    if (claimError) {
      console.error('Error claiming invites:', claimError)
      // Continue even if claiming fails - user might not have invites
    }

    // Then bootstrap workspace (which will return existing or create new)
    const { data, error } = await supabase.rpc('bootstrap_user_workspace')

    if (error) {
      console.error('Error bootstrapping workspace:', error)
      return null
    }

    return data as string
  } catch (err) {
    console.error('Exception bootstrapping workspace:', err)
    return null
  }
}

/**
 * Get all members of a workspace
 */
export async function getWorkspaceMembers(
  supabase: SupabaseClient,
  workspaceId: string
): Promise<WorkspaceMember[]> {
  try {
    const { data, error } = await supabase
      .from('workspace_members')
      .select(
        `
        user_id,
        role,
        created_at,
        users:user_id (email)
      `
      )
      .eq('workspace_id', workspaceId)

    if (error) {
      console.error('Error fetching workspace members:', error)
      return []
    }

    return (data || []) as unknown as WorkspaceMember[]
  } catch (err) {
    console.error('Exception fetching workspace members:', err)
    return []
  }
}

/**
 * Get all pending invites for a workspace
 */
export async function getWorkspaceInvites(
  supabase: SupabaseClient,
  workspaceId: string
): Promise<WorkspaceInvite[]> {
  try {
    const { data, error } = await supabase
      .from('workspace_invites')
      .select('*')
      .eq('workspace_id', workspaceId)
      .is('claimed_at', null)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching workspace invites:', error)
      return []
    }

    return data || []
  } catch (err) {
    console.error('Exception fetching workspace invites:', err)
    return []
  }
}
