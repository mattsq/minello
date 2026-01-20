'use client'

import { useState } from 'react'
import type { Board as BoardType, List, Card } from '@/lib/db/types'
import Lists from '@/components/Lists'
import CardEditModal from '@/components/CardEditModal'

interface BoardProps {
  boardData: {
    board: BoardType
    lists: List[]
    cards: Card[]
  }
}

export default function Board({ boardData }: BoardProps) {
  const { board, lists: initialLists, cards: initialCards } = boardData
  const [lists, setLists] = useState(initialLists)
  const [cards, setCards] = useState(initialCards)
  const [selectedCard, setSelectedCard] = useState<Card | null>(null)

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

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Board header */}
      <div style={{
        padding: '1rem 2rem',
        borderBottom: '1px solid #e5e7eb',
        backgroundColor: '#fff'
      }}>
        <h1 style={{ fontSize: '1.5rem', fontWeight: 'bold', margin: 0 }}>
          {board.name}
        </h1>
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
  )
}
