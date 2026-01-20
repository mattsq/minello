'use client'

import { useState } from 'react'
import type { List, Card } from '@/lib/db/types'
import Cards from '@/components/Cards'
import { createClient } from '@/lib/supabase/client'
import { between } from '@/lib/positions'

interface ListsProps {
  boardId: string
  lists: List[]
  cardsByListId: Record<string, Card[]>
  onListCreated: (list: List) => void
  onCardCreated: (card: Card) => void
  onCardClick: (card: Card) => void
}

export default function Lists({
  boardId,
  lists,
  cardsByListId,
  onListCreated,
  onCardCreated,
  onCardClick,
}: ListsProps) {
  const [isCreatingList, setIsCreatingList] = useState(false)
  const [newListName, setNewListName] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleCreateList = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newListName.trim() || isSubmitting) return

    setIsSubmitting(true)
    const supabase = createClient()

    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        alert('You must be logged in to create a list')
        return
      }

      // Calculate position - new list goes at the end
      const lastPosition = lists.length > 0
        ? Math.max(...lists.map(l => l.position))
        : 0
      const position = between(lastPosition, null)

      const { data, error } = await supabase
        .from('lists')
        .insert({
          board_id: boardId,
          name: newListName.trim(),
          position,
          created_by: user.id,
        })
        .select()
        .single()

      if (error) {
        console.error('Error creating list:', error)
        alert('Failed to create list')
        return
      }

      onListCreated(data as List)
      setNewListName('')
      setIsCreatingList(false)
    } catch (err) {
      console.error('Exception creating list:', err)
      alert('Failed to create list')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div style={{
      display: 'flex',
      gap: '1rem',
      alignItems: 'flex-start',
      minHeight: '100%'
    }}>
      {/* Render existing lists */}
      {lists.map(list => (
        <div
          key={list.id}
          style={{
            backgroundColor: '#fff',
            borderRadius: '8px',
            padding: '0.75rem',
            minWidth: '280px',
            maxWidth: '280px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
            display: 'flex',
            flexDirection: 'column',
            maxHeight: 'calc(100vh - 180px)'
          }}
        >
          {/* List header */}
          <h2 style={{
            fontSize: '0.875rem',
            fontWeight: '600',
            margin: '0 0 0.75rem 0',
            padding: '0.25rem 0.5rem'
          }}>
            {list.name}
          </h2>

          {/* Cards in this list */}
          <Cards
            listId={list.id}
            cards={cardsByListId[list.id] || []}
            onCardCreated={onCardCreated}
            onCardClick={onCardClick}
          />
        </div>
      ))}

      {/* Create new list */}
      <div style={{
        minWidth: '280px',
        maxWidth: '280px'
      }}>
        {isCreatingList ? (
          <form
            onSubmit={handleCreateList}
            style={{
              backgroundColor: '#fff',
              borderRadius: '8px',
              padding: '0.75rem',
              boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
            }}
          >
            <input
              type="text"
              value={newListName}
              onChange={(e) => setNewListName(e.target.value)}
              placeholder="Enter list name..."
              autoFocus
              aria-label="List Name"
              disabled={isSubmitting}
              style={{
                width: '100%',
                padding: '0.5rem',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                marginBottom: '0.5rem',
                fontSize: '0.875rem'
              }}
            />
            <div style={{ display: 'flex', gap: '0.5rem' }}>
              <button
                type="submit"
                disabled={isSubmitting || !newListName.trim()}
                style={{
                  padding: '0.5rem 1rem',
                  backgroundColor: '#3b82f6',
                  color: '#fff',
                  border: 'none',
                  borderRadius: '4px',
                  fontSize: '0.875rem',
                  cursor: isSubmitting ? 'not-allowed' : 'pointer',
                  opacity: isSubmitting ? 0.6 : 1
                }}
              >
                {isSubmitting ? 'Adding...' : 'Add List'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setIsCreatingList(false)
                  setNewListName('')
                }}
                disabled={isSubmitting}
                style={{
                  padding: '0.5rem 1rem',
                  backgroundColor: '#fff',
                  color: '#374151',
                  border: '1px solid #d1d5db',
                  borderRadius: '4px',
                  fontSize: '0.875rem',
                  cursor: isSubmitting ? 'not-allowed' : 'pointer'
                }}
              >
                Cancel
              </button>
            </div>
          </form>
        ) : (
          <button
            onClick={() => setIsCreatingList(true)}
            style={{
              width: '100%',
              padding: '0.75rem',
              backgroundColor: 'rgba(0,0,0,0.05)',
              color: '#374151',
              border: 'none',
              borderRadius: '8px',
              fontSize: '0.875rem',
              cursor: 'pointer',
              textAlign: 'left',
              fontWeight: '500'
            }}
          >
            + Add a list
          </button>
        )}
      </div>
    </div>
  )
}
