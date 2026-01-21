'use client'

import { useState, useEffect } from 'react'
import type { Board as BoardType, List, Card } from '@/lib/db/types'
import Lists from '@/components/Lists'
import CardEditModal from '@/components/CardEditModal'
import { DndContext, DragEndEvent, DragOverlay, PointerSensor, useSensor, useSensors } from '@dnd-kit/core'
import { between } from '@/lib/positions'
import { updateCardPosition } from '@/app/app/board/[boardId]/actions'
import { useRealtimeBoard } from '@/lib/hooks/useRealtimeBoard'
import ConnectionStatus from '@/components/ConnectionStatus'

interface BoardProps {
  boardData: {
    board: BoardType
    lists: List[]
    cards: Card[]
  }
}

export default function Board({ boardData }: BoardProps) {
  const { board, lists: initialLists, cards: initialCards } = boardData

  // Use realtime hook instead of plain useState
  const { lists, cards, setLists, setCards, isConnected } = useRealtimeBoard({
    boardId: board.id,
    initialLists,
    initialCards,
  })

  const [selectedCard, setSelectedCard] = useState<Card | null>(null)
  const [activeCard, setActiveCard] = useState<Card | null>(null)

  // Configure sensors for drag and drop
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8, // Require 8px movement before drag starts (prevents accidental drags)
      },
    })
  )

  // Close modal if selected card is deleted, or update it if changed
  useEffect(() => {
    if (selectedCard) {
      const currentCard = cards.find(c => c.id === selectedCard.id)
      if (!currentCard) {
        // Card was deleted, close modal
        setSelectedCard(null)
      } else if (currentCard.updated_at !== selectedCard.updated_at) {
        // Card was updated by someone else, update the modal data
        setSelectedCard(currentCard)
      }
    }
  }, [cards, selectedCard])

  // Group cards by list_id for easy access
  const cardsByListId = cards.reduce((acc, card) => {
    if (!acc[card.list_id]) {
      acc[card.list_id] = []
    }
    acc[card.list_id].push(card)
    return acc
  }, {} as Record<string, Card[]>)

  const handleListCreated = (newList: List) => {
    setLists([...lists, newList])
  }

  const handleCardCreated = (newCard: Card) => {
    setCards([...cards, newCard])
  }

  const handleCardClick = (card: Card) => {
    setSelectedCard(card)
  }

  const handleCardSave = (updatedCard: Card) => {
    setCards(cards.map(c => c.id === updatedCard.id ? updatedCard : c))
  }

  const handleModalClose = () => {
    setSelectedCard(null)
  }

  const handleDragStart = (event: DragEndEvent) => {
    const { active } = event
    const draggedCard = cards.find(c => c.id === active.id)
    if (draggedCard) {
      setActiveCard(draggedCard)
    }
  }

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event
    setActiveCard(null)

    if (!over) return

    const cardId = active.id as string
    const overId = over.id as string

    // Find the dragged card
    const draggedCard = cards.find(c => c.id === cardId)
    if (!draggedCard) return

    // Determine if we're dropping over a list or another card
    const targetList = lists.find(l => l.id === overId)
    const targetCard = cards.find(c => c.id === overId)

    let newListId: string
    let newPosition: number

    if (targetList) {
      // Dropped directly on a list (empty list or at the end)
      newListId = targetList.id
      const listCards = cards.filter(c => c.list_id === newListId && c.id !== cardId)
      const lastPosition = listCards.length > 0
        ? Math.max(...listCards.map(c => c.position))
        : 0
      newPosition = between(lastPosition, null)
    } else if (targetCard) {
      // Dropped on another card
      newListId = targetCard.list_id
      const listCards = cards
        .filter(c => c.list_id === newListId && c.id !== cardId)
        .sort((a, b) => a.position - b.position)

      const targetIndex = listCards.findIndex(c => c.id === targetCard.id)

      if (targetIndex === -1) {
        // Target card not found, place at end
        const lastPosition = listCards.length > 0
          ? Math.max(...listCards.map(c => c.position))
          : 0
        newPosition = between(lastPosition, null)
      } else {
        // Insert before the target card
        const prevCard = targetIndex > 0 ? listCards[targetIndex - 1] : null
        const prevPosition = prevCard ? prevCard.position : null
        const nextPosition = targetCard.position
        newPosition = between(prevPosition, nextPosition)
      }
    } else {
      return
    }

    // Optimistic update
    const updatedCard = {
      ...draggedCard,
      list_id: newListId,
      position: newPosition,
    }
    setCards(cards.map(c => c.id === cardId ? updatedCard : c))

    // Persist to server
    try {
      await updateCardPosition(cardId, newListId, newPosition, board.id)
    } catch (error) {
      console.error('Failed to update card position:', error)
      // Revert optimistic update on error
      setCards(cards)
      alert('Failed to update card position')
    }
  }

  return (
    <DndContext
      sensors={sensors}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        {/* Board header */}
        <div style={{
          padding: '1rem 2rem',
          borderBottom: '1px solid #e5e7eb',
          backgroundColor: '#fff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <h1 style={{ fontSize: '1.5rem', fontWeight: 'bold', margin: 0 }}>
            {board.name}
          </h1>
          <ConnectionStatus isConnected={isConnected} />
        </div>

        {/* Board content - horizontal scrolling lists */}
        <div style={{
          flex: 1,
          overflow: 'auto',
          padding: '1rem',
          backgroundColor: '#f3f4f6'
        }}>
          <Lists
            boardId={board.id}
            lists={lists}
            cardsByListId={cardsByListId}
            onListCreated={handleListCreated}
            onCardCreated={handleCardCreated}
            onCardClick={handleCardClick}
          />
        </div>

        {/* Card edit modal */}
        {selectedCard && (
          <CardEditModal
            card={selectedCard}
            boardId={board.id}
            onClose={handleModalClose}
            onSave={handleCardSave}
          />
        )}
      </div>

      {/* Drag overlay - shows the dragged card while dragging */}
      <DragOverlay>
        {activeCard ? (
          <div style={{
            backgroundColor: '#fff',
            border: '1px solid #e5e7eb',
            borderRadius: '4px',
            padding: '0.5rem',
            fontSize: '0.875rem',
            boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
            minWidth: '250px',
            opacity: 0.9,
          }}>
            <div style={{ fontWeight: '500' }}>{activeCard.title}</div>
            {activeCard.description && (
              <div style={{
                fontSize: '0.75rem',
                color: '#6b7280',
                marginTop: '0.25rem'
              }}>
                {activeCard.description}
              </div>
            )}
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  )
}
