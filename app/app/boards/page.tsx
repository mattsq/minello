'use client'

import { useEffect, useState, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { ensureUserWorkspace } from '@/lib/workspace'
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

  const supabase = createClient()

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
    } catch (err) {
      console.error('Exception loading boards:', err)
    } finally {
      setLoading(false)
    }
  }, [supabase])

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
