import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Board from '@/components/Board'
import type { Board as BoardType, List, Card } from '@/lib/db/types'

interface BoardPageParams {
  params: { boardId: string }
}

async function getBoardData(boardId: string) {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    redirect('/login')
  }

  // Fetch board
  const { data: board, error: boardError } = await supabase
    .from('boards')
    .select('*')
    .eq('id', boardId)
    .single()

  if (boardError || !board) {
    console.error('Board fetch error:', boardError)
    return null
  }

  // Fetch lists ordered by position
  const { data: lists, error: listsError } = await supabase
    .from('lists')
    .select('*')
    .eq('board_id', boardId)
    .order('position', { ascending: true })

  if (listsError) {
    console.error('Lists fetch error:', listsError)
    return { board: board as BoardType, lists: [], cards: [] }
  }

  // Fetch all cards for this board
  const listIds = (lists || []).map(l => l.id)
  let cards: Card[] = []

  if (listIds.length > 0) {
    const { data: cardsData, error: cardsError } = await supabase
      .from('cards')
      .select('*')
      .in('list_id', listIds)
      .order('position', { ascending: true })

    if (cardsError) {
      console.error('Cards fetch error:', cardsError)
    } else {
      cards = cardsData as Card[]
    }
  }

  return {
    board: board as BoardType,
    lists: (lists || []) as List[],
    cards,
  }
}

export default async function BoardPage({ params }: BoardPageParams) {
  const boardData = await getBoardData(params.boardId)

  if (!boardData) {
    return (
      <div style={{ padding: '2rem' }}>
        <h1>Board not found</h1>
        <p>You don&apos;t have access to this board or it doesn&apos;t exist.</p>
      </div>
    )
  }

  return <Board boardData={boardData} />
}
