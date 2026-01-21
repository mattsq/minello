'use client'

import { useEffect, useState, useRef, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { List, Card } from '@/lib/db/types'
import type { RealtimeChannel, RealtimePostgresChangesPayload } from '@supabase/supabase-js'

interface UseRealtimeBoardProps {
  boardId: string
  initialLists: List[]
  initialCards: Card[]
}

interface UseRealtimeBoardReturn {
  lists: List[]
  cards: Card[]
  setLists: (lists: List[]) => void
  setCards: (cards: Card[]) => void
  isConnected: boolean
}

/**
 * Custom hook for real-time board updates
 * Subscribes to Supabase Realtime for lists and cards changes
 * Handles INSERT, UPDATE, DELETE events with optimistic update support
 */
export function useRealtimeBoard({
  boardId,
  initialLists,
  initialCards,
}: UseRealtimeBoardProps): UseRealtimeBoardReturn {
  const [lists, setLists] = useState<List[]>(initialLists)
  const [cards, setCards] = useState<Card[]>(initialCards)
  const [isConnected, setIsConnected] = useState(false)

  // Track in-flight operations to prevent echo
  const inFlightOperations = useRef(new Set<string>())

  // Create a stable reference to add operation tracking
  const trackOperation = useCallback((key: string, durationMs = 500) => {
    inFlightOperations.current.add(key)
    setTimeout(() => {
      inFlightOperations.current.delete(key)
    }, durationMs)
  }, [])

  // Check if an operation is in-flight
  const isInFlight = useCallback((key: string) => {
    return inFlightOperations.current.has(key)
  }, [])

  // Enhanced setLists that tracks operations
  const setListsWithTracking = useCallback((newLists: List[] | ((prev: List[]) => List[])) => {
    setLists(prev => {
      const updated = typeof newLists === 'function' ? newLists(prev) : newLists

      // Track what changed
      if (Array.isArray(updated)) {
        updated.forEach(list => {
          trackOperation(`list-${list.id}`)
        })
      }

      return updated
    })
  }, [trackOperation])

  // Enhanced setCards that tracks operations
  const setCardsWithTracking = useCallback((newCards: Card[] | ((prev: Card[]) => Card[])) => {
    setCards(prev => {
      const updated = typeof newCards === 'function' ? newCards(prev) : newCards

      // Track what changed
      if (Array.isArray(updated)) {
        updated.forEach(card => {
          trackOperation(`card-${card.id}`)
        })
      }

      return updated
    })
  }, [trackOperation])

  useEffect(() => {
    const supabase = createClient()
    let listsChannel: RealtimeChannel
    let cardsChannel: RealtimeChannel

    // Handler for list changes
    const handleListChange = (payload: RealtimePostgresChangesPayload<List>) => {
      // Skip if this is our own recent operation
      if (payload.new && 'id' in payload.new && isInFlight(`list-${payload.new.id}`)) {
        return
      }

      if (payload.eventType === 'INSERT') {
        const newList = payload.new as List
        // Only add if it belongs to this board
        if (newList.board_id === boardId) {
          setLists(prev => {
            // Check if already exists (prevent duplicates)
            if (prev.some(l => l.id === newList.id)) {
              return prev
            }
            return [...prev, newList].sort((a, b) => a.position - b.position)
          })
        }
      } else if (payload.eventType === 'UPDATE') {
        const updatedList = payload.new as List
        setLists(prev =>
          prev
            .map(l => (l.id === updatedList.id ? updatedList : l))
            .sort((a, b) => a.position - b.position)
        )
      } else if (payload.eventType === 'DELETE') {
        const deletedList = payload.old as List
        setLists(prev => prev.filter(l => l.id !== deletedList.id))
        // Also remove cards from deleted list
        setCards(prev => prev.filter(c => c.list_id !== deletedList.id))
      }
    }

    // Handler for card changes
    const handleCardChange = (payload: RealtimePostgresChangesPayload<Card>) => {
      // Skip if this is our own recent operation
      if (payload.new && 'id' in payload.new && isInFlight(`card-${payload.new.id}`)) {
        return
      }

      if (payload.eventType === 'INSERT') {
        const newCard = payload.new as Card
        // Only add if it belongs to a list in this board
        setCards(prev => {
          // Check if already exists (prevent duplicates)
          if (prev.some(c => c.id === newCard.id)) {
            return prev
          }
          // Check if the list exists in our current lists
          const listExists = lists.some(l => l.id === newCard.list_id)
          if (listExists) {
            return [...prev, newCard].sort((a, b) => a.position - b.position)
          }
          return prev
        })
      } else if (payload.eventType === 'UPDATE') {
        const updatedCard = payload.new as Card
        setCards(prev => {
          // Check if card moved to a different board (via list change)
          const cardExists = prev.some(c => c.id === updatedCard.id)
          const listExists = lists.some(l => l.id === updatedCard.list_id)

          if (!listExists) {
            // Card moved to different board, remove it
            return prev.filter(c => c.id !== updatedCard.id)
          }

          if (!cardExists) {
            // Card moved to this board from another
            return [...prev, updatedCard].sort((a, b) => a.position - b.position)
          }

          // Normal update
          return prev
            .map(c => (c.id === updatedCard.id ? updatedCard : c))
            .sort((a, b) => a.position - b.position)
        })
      } else if (payload.eventType === 'DELETE') {
        const deletedCard = payload.old as Card
        setCards(prev => prev.filter(c => c.id !== deletedCard.id))
      }
    }

    // Subscribe to lists changes for this board
    listsChannel = supabase
      .channel(`board-${boardId}-lists`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'lists',
          filter: `board_id=eq.${boardId}`,
        },
        handleListChange
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          setIsConnected(true)
        } else if (status === 'CLOSED' || status === 'CHANNEL_ERROR') {
          setIsConnected(false)
        }
      })

    // Subscribe to cards changes
    // Note: We can't filter by board_id directly since cards don't have that column
    // So we subscribe to all card changes and filter client-side
    cardsChannel = supabase
      .channel(`board-${boardId}-cards`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'cards',
        },
        handleCardChange
      )
      .subscribe()

    // Cleanup subscriptions on unmount
    return () => {
      listsChannel?.unsubscribe()
      cardsChannel?.unsubscribe()
    }
  }, [boardId, lists, isInFlight])

  return {
    lists,
    cards,
    setLists: setListsWithTracking,
    setCards: setCardsWithTracking,
    isConnected,
  }
}
