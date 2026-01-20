'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/lib/db/types'
import { createClient } from '@/lib/supabase/client'

interface CardEditModalProps {
  card: Card
  boardId: string
  onClose: () => void
  onSave: (updatedCard: Card) => void
}

interface WorkspaceMember {
  user_id: string
}

export default function CardEditModal({ card, boardId, onClose, onSave }: CardEditModalProps) {
  const [title, setTitle] = useState(card.title)
  const [description, setDescription] = useState(card.description || '')
  const [dueAt, setDueAt] = useState(card.due_at ? card.due_at.split('T')[0] : '')
  const [assigneeId, setAssigneeId] = useState(card.assignee_id || '')
  const [members, setMembers] = useState<WorkspaceMember[]>([])
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    async function fetchMembers() {
      const supabase = createClient()

      // Get workspace_id from board
      const { data: board } = await supabase
        .from('boards')
        .select('workspace_id')
        .eq('id', boardId)
        .single()

      if (!board) return

      // Get workspace members
      const { data: membersData } = await supabase
        .from('workspace_members')
        .select('user_id')
        .eq('workspace_id', board.workspace_id)

      if (membersData) {
        setMembers(membersData)
      }
    }

    fetchMembers()
  }, [boardId])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)

    try {
      const supabase = createClient()

      const updates: {
        title: string
        description: string | null
        due_at: string | null
        assignee_id: string | null
      } = {
        title,
        description: description || null,
        due_at: dueAt ? new Date(dueAt).toISOString() : null,
        assignee_id: assigneeId || null
      }

      const { data, error } = await supabase
        .from('cards')
        .update(updates)
        .eq('id', card.id)
        .select()
        .single()

      if (error) {
        alert('Failed to update card: ' + error.message)
        return
      }

      if (data) {
        onSave(data)
        onClose()
      }
    } catch (err) {
      alert('Failed to update card')
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose()
    }
  }

  return (
    <div
      onClick={handleBackdropClick}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000
      }}
    >
      <div
        style={{
          backgroundColor: '#fff',
          borderRadius: '8px',
          padding: '24px',
          width: '90%',
          maxWidth: '500px',
          maxHeight: '90vh',
          overflow: 'auto'
        }}
      >
        <h2 style={{ marginTop: 0, marginBottom: '20px', fontSize: '20px', fontWeight: 'bold' }}>
          Edit Card
        </h2>

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '16px' }}>
            <label
              htmlFor="title"
              style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}
            >
              Title
            </label>
            <input
              id="title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              style={{
                width: '100%',
                padding: '8px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                fontSize: '14px',
                boxSizing: 'border-box'
              }}
            />
          </div>

          <div style={{ marginBottom: '16px' }}>
            <label
              htmlFor="description"
              style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}
            >
              Description
            </label>
            <textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={4}
              style={{
                width: '100%',
                padding: '8px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                fontSize: '14px',
                resize: 'vertical',
                fontFamily: 'inherit',
                boxSizing: 'border-box'
              }}
            />
          </div>

          <div style={{ marginBottom: '16px' }}>
            <label
              htmlFor="due_at"
              style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}
            >
              Due Date
            </label>
            <input
              id="due_at"
              type="date"
              value={dueAt}
              onChange={(e) => setDueAt(e.target.value)}
              style={{
                width: '100%',
                padding: '8px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                fontSize: '14px',
                boxSizing: 'border-box'
              }}
            />
          </div>

          <div style={{ marginBottom: '24px' }}>
            <label
              htmlFor="assignee"
              style={{ display: 'block', marginBottom: '4px', fontWeight: '500' }}
            >
              Assignee
            </label>
            <select
              id="assignee"
              value={assigneeId}
              onChange={(e) => setAssigneeId(e.target.value)}
              style={{
                width: '100%',
                padding: '8px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                fontSize: '14px',
                boxSizing: 'border-box'
              }}
            >
              <option value="">Unassigned</option>
              {members.map((member) => (
                <option key={member.user_id} value={member.user_id}>
                  {member.user_id}
                </option>
              ))}
            </select>
          </div>

          <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
            <button
              type="button"
              onClick={onClose}
              disabled={isSubmitting}
              style={{
                padding: '8px 16px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                backgroundColor: '#fff',
                color: '#374151',
                cursor: isSubmitting ? 'not-allowed' : 'pointer',
                fontSize: '14px'
              }}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting || !title.trim()}
              style={{
                padding: '8px 16px',
                border: 'none',
                borderRadius: '4px',
                backgroundColor: isSubmitting || !title.trim() ? '#9ca3af' : '#3b82f6',
                color: '#fff',
                cursor: isSubmitting || !title.trim() ? 'not-allowed' : 'pointer',
                fontSize: '14px'
              }}
            >
              {isSubmitting ? 'Saving...' : 'Save'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
