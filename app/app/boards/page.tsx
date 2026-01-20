'use client'

import { useEffect, useState, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  ensureUserWorkspace,
  getWorkspaceMembers,
  getWorkspaceInvites,
  type WorkspaceMember,
  type WorkspaceInvite,
} from '@/lib/workspace'
import { inviteToWorkspace, revokeInvite } from './actions'
import Link from 'next/link'

type Board = {
  id: string
  name: string
  created_at: string
}

export default function BoardsPage() {
  const [boards, setBoards] = useState<Board[]>([])
  const [loading, setLoading] = useState(true)
  const [creating, setCreating] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [newBoardName, setNewBoardName] = useState('')
  const [workspaceId, setWorkspaceId] = useState<string | null>(null)
  const [showInviteSection, setShowInviteSection] = useState(false)
  const [members, setMembers] = useState<WorkspaceMember[]>([])
  const [invites, setInvites] = useState<WorkspaceInvite[]>([])
  const [inviteEmail, setInviteEmail] = useState('')
  const [inviting, setInviting] = useState(false)
  const [inviteError, setInviteError] = useState<string | null>(null)
  const [inviteSuccess, setInviteSuccess] = useState<string | null>(null)

  const supabase = createClient()

  const loadMembersAndInvites = useCallback(async (wsId: string) => {
    const [membersData, invitesData] = await Promise.all([
      getWorkspaceMembers(supabase, wsId),
      getWorkspaceInvites(supabase, wsId),
    ])
    setMembers(membersData)
    setInvites(invitesData)
  }, [supabase])

  const loadBoards = useCallback(async () => {
    setLoading(true)
    try {
      // Ensure user has a workspace
      const wsId = await ensureUserWorkspace(supabase)
      if (!wsId) {
        console.error('Failed to ensure workspace')
        setLoading(false)
        return
      }
      setWorkspaceId(wsId)

      // Fetch boards
      const { data, error } = await supabase
        .from('boards')
        .select('id, name, created_at')
        .eq('workspace_id', wsId)
        .order('created_at', { ascending: false })

      if (error) {
        console.error('Error loading boards:', error)
      } else {
        setBoards(data || [])
      }

      // Load members and invites
      await loadMembersAndInvites(wsId)
    } catch (err) {
      console.error('Exception loading boards:', err)
    } finally {
      setLoading(false)
    }
  }, [supabase, loadMembersAndInvites])

  useEffect(() => {
    loadBoards()
  }, [loadBoards])

  async function createBoard(e: React.FormEvent) {
    e.preventDefault()
    if (!newBoardName.trim() || !workspaceId) return

    setCreating(true)
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) {
        console.error('No user found')
        return
      }

      const { data, error } = await supabase
        .from('boards')
        .insert({
          name: newBoardName.trim(),
          workspace_id: workspaceId,
          created_by: user.id,
        })
        .select('id, name, created_at')
        .single()

      if (error) {
        console.error('Error creating board:', error)
      } else if (data) {
        // Add to list immediately (optimistic update)
        setBoards([data, ...boards])
        setNewBoardName('')
        setShowForm(false)
      }
    } catch (err) {
      console.error('Exception creating board:', err)
    } finally {
      setCreating(false)
    }
  }

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault()
    if (!inviteEmail.trim() || !workspaceId) return

    setInviting(true)
    setInviteError(null)
    setInviteSuccess(null)

    try {
      const result = await inviteToWorkspace(workspaceId, inviteEmail.trim())

      if (result.success) {
        setInviteSuccess('Invite sent successfully!')
        setInviteEmail('')
        // Reload invites
        if (workspaceId) {
          await loadMembersAndInvites(workspaceId)
        }
        // Clear success message after 3 seconds
        setTimeout(() => setInviteSuccess(null), 3000)
      } else {
        setInviteError(result.error || 'Failed to send invite')
      }
    } catch (err) {
      console.error('Exception sending invite:', err)
      setInviteError('An unexpected error occurred')
    } finally {
      setInviting(false)
    }
  }

  async function handleRevokeInvite(inviteId: string) {
    if (!workspaceId) return

    try {
      const result = await revokeInvite(inviteId)

      if (result.success) {
        // Reload invites
        await loadMembersAndInvites(workspaceId)
      } else {
        console.error('Failed to revoke invite:', result.error)
      }
    } catch (err) {
      console.error('Exception revoking invite:', err)
    }
  }

  if (loading) {
    return (
      <div style={{ padding: '2rem' }}>
        <p>Loading boards...</p>
      </div>
    )
  }

  return (
    <div style={{ padding: '2rem', maxWidth: '800px', margin: '0 auto' }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '2rem',
        }}
      >
        <h1 style={{ margin: 0 }}>My Boards</h1>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          {!showForm && (
            <button
              onClick={() => setShowForm(true)}
              style={{
                padding: '0.5rem 1rem',
                backgroundColor: '#0070f3',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              Create Board
            </button>
          )}
          <button
            onClick={() => setShowInviteSection(!showInviteSection)}
            style={{
              padding: '0.5rem 1rem',
              backgroundColor: showInviteSection ? '#666' : '#0070f3',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
            }}
            data-testid="invite-toggle-btn"
          >
            {showInviteSection ? 'Hide Members' : 'Invite Members'}
          </button>
        </div>
      </div>

      {showForm && (
        <form
          onSubmit={createBoard}
          style={{
            marginBottom: '2rem',
            padding: '1rem',
            border: '1px solid #ddd',
            borderRadius: '4px',
            backgroundColor: '#f9f9f9',
          }}
        >
          <div style={{ marginBottom: '1rem' }}>
            <label
              htmlFor="board-name"
              style={{ display: 'block', marginBottom: '0.5rem' }}
            >
              Board Name
            </label>
            <input
              id="board-name"
              type="text"
              value={newBoardName}
              onChange={(e) => setNewBoardName(e.target.value)}
              placeholder="Enter board name"
              autoFocus
              required
              style={{
                width: '100%',
                padding: '0.5rem',
                fontSize: '1rem',
                border: '1px solid #ddd',
                borderRadius: '4px',
              }}
            />
          </div>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <button
              type="submit"
              disabled={creating || !newBoardName.trim()}
              style={{
                padding: '0.5rem 1rem',
                backgroundColor: '#0070f3',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: creating ? 'not-allowed' : 'pointer',
                opacity: creating || !newBoardName.trim() ? 0.6 : 1,
              }}
            >
              {creating ? 'Creating...' : 'Create'}
            </button>
            <button
              type="button"
              onClick={() => {
                setShowForm(false)
                setNewBoardName('')
              }}
              style={{
                padding: '0.5rem 1rem',
                backgroundColor: '#fff',
                color: '#333',
                border: '1px solid #ddd',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              Cancel
            </button>
          </div>
        </form>
      )}

      {showInviteSection && (
        <div
          style={{
            marginBottom: '2rem',
            padding: '1.5rem',
            border: '1px solid #ddd',
            borderRadius: '4px',
            backgroundColor: '#f9f9f9',
          }}
        >
          <h2 style={{ marginTop: 0, marginBottom: '1rem' }}>
            Workspace Members
          </h2>

          {/* Invite form */}
          <form
            onSubmit={handleInvite}
            style={{
              marginBottom: '1.5rem',
              padding: '1rem',
              border: '1px solid #ddd',
              borderRadius: '4px',
              backgroundColor: '#fff',
            }}
          >
            <label
              htmlFor="invite-email"
              style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 500 }}
            >
              Invite by Email
            </label>
            <div style={{ display: 'flex', gap: '0.5rem' }}>
              <input
                id="invite-email"
                type="email"
                value={inviteEmail}
                onChange={(e) => setInviteEmail(e.target.value)}
                placeholder="email@example.com"
                required
                data-testid="invite-email-input"
                style={{
                  flex: 1,
                  padding: '0.5rem',
                  fontSize: '1rem',
                  border: '1px solid #ddd',
                  borderRadius: '4px',
                }}
              />
              <button
                type="submit"
                disabled={inviting || !inviteEmail.trim()}
                data-testid="send-invite-btn"
                style={{
                  padding: '0.5rem 1rem',
                  backgroundColor: '#0070f3',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: inviting || !inviteEmail.trim() ? 'not-allowed' : 'pointer',
                  opacity: inviting || !inviteEmail.trim() ? 0.6 : 1,
                }}
              >
                {inviting ? 'Sending...' : 'Send Invite'}
              </button>
            </div>
            {inviteError && (
              <p
                style={{
                  marginTop: '0.5rem',
                  marginBottom: 0,
                  color: '#d32f2f',
                  fontSize: '0.875rem',
                }}
                data-testid="invite-error"
              >
                {inviteError}
              </p>
            )}
            {inviteSuccess && (
              <p
                style={{
                  marginTop: '0.5rem',
                  marginBottom: 0,
                  color: '#2e7d32',
                  fontSize: '0.875rem',
                }}
                data-testid="invite-success"
              >
                {inviteSuccess}
              </p>
            )}
          </form>

          {/* Members list */}
          <div style={{ marginBottom: '1.5rem' }}>
            <h3 style={{ marginTop: 0, marginBottom: '0.75rem', fontSize: '1rem' }}>
              Current Members ({members.length})
            </h3>
            {members.length === 0 ? (
              <p style={{ color: '#666', margin: 0 }}>No members found</p>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                {members.map((member) => (
                  <div
                    key={member.user_id}
                    style={{
                      padding: '0.75rem',
                      backgroundColor: '#fff',
                      border: '1px solid #ddd',
                      borderRadius: '4px',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <div>
                      <div style={{ fontWeight: 500 }}>
                        {member.users?.email || 'Unknown'}
                      </div>
                      <div style={{ fontSize: '0.875rem', color: '#666' }}>
                        {member.role}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Pending invites */}
          {invites.length > 0 && (
            <div>
              <h3 style={{ marginTop: 0, marginBottom: '0.75rem', fontSize: '1rem' }}>
                Pending Invites ({invites.length})
              </h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                {invites.map((invite) => (
                  <div
                    key={invite.id}
                    style={{
                      padding: '0.75rem',
                      backgroundColor: '#fff',
                      border: '1px solid #ddd',
                      borderRadius: '4px',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                    data-testid="pending-invite"
                  >
                    <div>
                      <div style={{ fontWeight: 500 }}>{invite.email}</div>
                      <div style={{ fontSize: '0.875rem', color: '#666' }}>
                        Invited {new Date(invite.created_at).toLocaleDateString()}
                      </div>
                    </div>
                    <button
                      onClick={() => handleRevokeInvite(invite.id)}
                      style={{
                        padding: '0.25rem 0.75rem',
                        backgroundColor: '#fff',
                        color: '#d32f2f',
                        border: '1px solid #d32f2f',
                        borderRadius: '4px',
                        cursor: 'pointer',
                        fontSize: '0.875rem',
                      }}
                    >
                      Revoke
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {boards.length === 0 ? (
        <div
          style={{
            padding: '2rem',
            textAlign: 'center',
            color: '#666',
            border: '2px dashed #ddd',
            borderRadius: '4px',
          }}
        >
          <p>No boards yet. Create your first board to get started!</p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {boards.map((board) => (
            <Link
              key={board.id}
              href={`/app/board/${board.id}`}
              style={{
                padding: '1rem',
                border: '1px solid #ddd',
                borderRadius: '4px',
                textDecoration: 'none',
                color: 'inherit',
                backgroundColor: '#fff',
                transition: 'all 0.2s',
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.borderColor = '#0070f3'
                e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,112,243,0.1)'
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.borderColor = '#ddd'
                e.currentTarget.style.boxShadow = 'none'
              }}
            >
              <h3 style={{ margin: 0, marginBottom: '0.5rem' }}>{board.name}</h3>
              <p style={{ margin: 0, fontSize: '0.875rem', color: '#666' }}>
                Created {new Date(board.created_at).toLocaleDateString()}
              </p>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
