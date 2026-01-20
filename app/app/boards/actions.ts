'use server'

import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'

function getSiteUrl() {
  const configured = process.env.NEXT_PUBLIC_SITE_URL
  if (configured) {
    return configured.replace(/\/$/, '')
  }

  const vercelUrl = process.env.VERCEL_URL
  if (vercelUrl) {
    return `https://${vercelUrl}`
  }

  return 'http://localhost:3000'
}

export type InviteResult = {
  success: boolean
  error?: string
}

/**
 * Send an invite to join a workspace
 */
export async function inviteToWorkspace(
  workspaceId: string,
  email: string
): Promise<InviteResult> {
  try {
    const supabase = await createClient()

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return {
        success: false,
        error: 'Invalid email address',
      }
    }

    // Get current user
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser()

    if (userError || !user) {
      return {
        success: false,
        error: 'Not authenticated',
      }
    }

    // Check if there's already a pending invite for this email
    const { data: existingInvite } = await supabase
      .from('workspace_invites')
      .select('id')
      .eq('workspace_id', workspaceId)
      .eq('email', email.toLowerCase())
      .is('claimed_at', null)
      .maybeSingle()

    if (existingInvite) {
      return {
        success: false,
        error: 'An invite has already been sent to this email',
      }
    }

    // Create the invite record
    const { error: insertError } = await supabase
      .from('workspace_invites')
      .insert({
        workspace_id: workspaceId,
        email: email.toLowerCase(),
        invited_by: user.id,
      })

    if (insertError) {
      console.error('Error creating invite:', insertError)
      return {
        success: false,
        error: 'Failed to create invite',
      }
    }

    // Send Supabase invite email with a redirect to the app
    try {
      const admin = createAdminClient()
      const redirectTo = `${getSiteUrl()}/auth/callback`

      // Debug logging to identify the redirect URL being sent
      console.log('[INVITE DEBUG] Sending invite with redirectTo:', redirectTo)
      console.log('[INVITE DEBUG] NEXT_PUBLIC_SITE_URL:', process.env.NEXT_PUBLIC_SITE_URL)
      console.log('[INVITE DEBUG] VERCEL_URL:', process.env.VERCEL_URL)

      const { error: inviteError } = await admin.auth.admin.inviteUserByEmail(
        email.toLowerCase(),
        { redirectTo }
      )

      if (inviteError) {
        await supabase
          .from('workspace_invites')
          .delete()
          .eq('workspace_id', workspaceId)
          .eq('email', email.toLowerCase())
          .is('claimed_at', null)

        console.error('Error sending invite email:', inviteError)
        return {
          success: false,
          error: 'Failed to send invite email',
        }
      }
    } catch (err) {
      await supabase
        .from('workspace_invites')
        .delete()
        .eq('workspace_id', workspaceId)
        .eq('email', email.toLowerCase())
        .is('claimed_at', null)

      console.error('Exception sending invite email:', err)
      return {
        success: false,
        error: 'Failed to send invite email',
      }
    }

    // TEMPORARY DEBUG: Return debug info in success response
    const debugInfo = {
      redirectTo: `${getSiteUrl()}/auth/callback`,
      NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL || 'NOT_SET',
      VERCEL_URL: process.env.VERCEL_URL || 'NOT_SET',
    }

    return {
      success: true,
      // @ts-ignore - temporary debug field
      _debug: debugInfo,
    }
  } catch (err) {
    console.error('Exception in inviteToWorkspace:', err)
    return {
      success: false,
      error: 'An unexpected error occurred',
    }
  }
}

/**
 * Delete (revoke) an invite
 */
export async function revokeInvite(inviteId: string): Promise<InviteResult> {
  try {
    const supabase = await createClient()

    const { error } = await supabase
      .from('workspace_invites')
      .delete()
      .eq('id', inviteId)

    if (error) {
      console.error('Error revoking invite:', error)
      return {
        success: false,
        error: 'Failed to revoke invite',
      }
    }

    return {
      success: true,
    }
  } catch (err) {
    console.error('Exception in revokeInvite:', err)
    return {
      success: false,
      error: 'An unexpected error occurred',
    }
  }
}
