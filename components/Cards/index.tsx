'use client'

import { useState } from 'react'
import type { Card } from '@/lib/db/types'
import { createClient } from '@/lib/supabase/client'
import { between } from '@/lib/positions'
import { useDraggable, useDroppable } from '@dnd-kit/core'
import { CSS } from '@dnd-kit/utilities'

interface CardsProps {
  listId: string
  cards: Card[]
  onCardCreated: (card: Card) => void
  onCardClick: (card: Card) => void
}

interface DraggableCardProps {
  card: Card
  onCardClick: (card: Card) => void
}

function DraggableCard({ card, onCardClick }: DraggableCardProps) {
  const { attributes, listeners, setNodeRef: setDraggableRef, transform, isDragging } = useDraggable({
    id: card.id,
  })

  const { setNodeRef: setDroppableRef } = useDroppable({
    id: card.id,
  })

  // Combine refs
  const setRefs = (element: HTMLDivElement | null) => {
    setDraggableRef(element)
    setDroppableRef(element)
  }

  const style = {
    transform: CSS.Translate.toString(transform),
    opacity: isDragging ? 0.5 : 1,
  }

  return (
    <div
      ref={setRefs}
      {...listeners}
      {...attributes}
      onClick={(e) => {
        // Only trigger click if not dragging
        if (!isDragging) {
          onCardClick(card)
        }
      }}
      style={{
        backgroundColor: '#fff',
        border: '1px solid #e5e7eb',
        borderRadius: '4px',
        padding: '0.5rem',
        cursor: isDragging ? 'grabbing' : 'grab',
        fontSize: '0.875rem',
        ...style,
      }}
    >
      <div style={{ fontWeight: '500' }}>{card.title}</div>
      {card.description && (
        <div style={{
          fontSize: '0.75rem',
          color: '#6b7280',
          marginTop: '0.25rem'
        }}>
          {card.description}
        </div>
      )}
    </div>
  )
}

export default function Cards({ listId, cards, onCardCreated, onCardClick }: CardsProps) {
  const [isCreatingCard, setIsCreatingCard] = useState(false)
  const [newCardTitle, setNewCardTitle] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleCreateCard = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newCardTitle.trim() || isSubmitting) return

    setIsSubmitting(true)
    const supabase = createClient()

    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        alert('You must be logged in to create a card')
        return
      }

      // Calculate position - new card goes at the end
      const lastPosition = cards.length > 0
        ? Math.max(...cards.map(c => c.position))
        : 0
      const position = between(lastPosition, null)

      const { data, error } = await supabase
        .from('cards')
        .insert({
          list_id: listId,
          title: newCardTitle.trim(),
          position,
          created_by: user.id,
        })
        .select()
        .single()

      if (error) {
        console.error('Error creating card:', error)
        alert('Failed to create card')
        return
      }

      onCardCreated(data as Card)
      setNewCardTitle('')
      setIsCreatingCard(false)
    } catch (err) {
      console.error('Exception creating card:', err)
      alert('Failed to create card')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      gap: '0.5rem',
      flex: 1,
      overflow: 'auto'
    }}>
      {/* Render existing cards */}
      {cards.map(card => (
        <DraggableCard
          key={card.id}
          card={card}
          onCardClick={onCardClick}
        />
      ))}

      {/* Create new card */}
      {isCreatingCard ? (
        <form
          onSubmit={handleCreateCard}
          style={{
            backgroundColor: '#fff',
            border: '1px solid #e5e7eb',
            borderRadius: '4px',
            padding: '0.5rem'
          }}
        >
          <input
            type="text"
            value={newCardTitle}
            onChange={(e) => setNewCardTitle(e.target.value)}
            placeholder="Enter card title..."
            autoFocus
            aria-label="Card Title"
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
              disabled={isSubmitting || !newCardTitle.trim()}
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
              {isSubmitting ? 'Adding...' : 'Add Card'}
            </button>
            <button
              type="button"
              onClick={() => {
                setIsCreatingCard(false)
                setNewCardTitle('')
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
          onClick={() => setIsCreatingCard(true)}
          style={{
            width: '100%',
            padding: '0.5rem',
            backgroundColor: 'transparent',
            color: '#6b7280',
            border: 'none',
            borderRadius: '4px',
            fontSize: '0.875rem',
            cursor: 'pointer',
            textAlign: 'left'
          }}
        >
          + Add a card
        </button>
      )}
    </div>
  )
}
