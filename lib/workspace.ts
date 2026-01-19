import { SupabaseClient } from '@supabase/supabase-js'

/**
 * Ensures the current user has a workspace by calling the bootstrap RPC.
 * This will either return an existing workspace or create a new one.
 * Should be called on first authenticated visit.
 */
export async function ensureUserWorkspace(
  supabase: SupabaseClient
): Promise<string | null> {
  try {
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
