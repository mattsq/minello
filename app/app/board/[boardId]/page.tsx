import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Board from '@/components/Board'
import type { Board as BoardType, List, Card } from '@/lib/db/types'
import Link from 'next/link'

interface BoardPageParams {
  params: { boardId: string }
}

type ErrorType = 'not_found' | 'access_denied' | 'auth_expired'

async function getBoardData(boardId: string): Promise<{ board: BoardType; lists: List[]; cards: Card[] } | { error: ErrorType }> {
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
    // If there's no error but no board, it means RLS denied access
    // If there's an error, check if it's a not found error
    if (!boardError || boardError.code === 'PGRST116') {
      return { error: 'access_denied' }
    }
    return { error: 'not_found' }
  }

  // Fetch lists ordered by position
  const { data: lists, error: listsError } = await supabase
    .from('lists')
    .select('*')
    .eq('board_id', boardId)
    .order('position', { ascending: true })

  if (listsError) {
    console.error('Lists fetch error:', listsError)
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

function ErrorDisplay({ errorType }: { errorType: ErrorType }) {
  const messages = {
    not_found: {
      title: 'Board Not Found',
      description: 'This board does not exist or may have been deleted.',
    },
    access_denied: {
      title: 'Access Denied',
      description: "You don't have permission to view this board. Please ask the board owner to invite you.",
    },
    auth_expired: {
      title: 'Session Expired',
      description: 'Your session has expired. Please log in again.',
    },
  }

  const message = messages[errorType]

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '60vh',
        padding: '2rem',
        textAlign: 'center',
      }}
    >
      <div
        style={{
          maxWidth: '500px',
          backgroundColor: '#f8f9fa',
          padding: '2rem',
          borderRadius: '8px',
          border: '1px solid #dee2e6',
        }}
      >
        <h1
          style={{
            fontSize: '2rem',
            marginBottom: '1rem',
            color: '#212529',
          }}
        >
          {message.title}
        </h1>
        <p
          style={{
            fontSize: '1rem',
            color: '#6c757d',
            marginBottom: '2rem',
            lineHeight: '1.5',
          }}
        >
          {message.description}
        </p>
        <Link
          href="/app/boards"
          style={{
            display: 'inline-block',
            backgroundColor: '#000',
            color: '#fff',
            padding: '0.75rem 1.5rem',
            borderRadius: '4px',
            textDecoration: 'none',
            fontWeight: '500',
          }}
        >
          Go to Boards
        </Link>
      </div>
    </div>
  )
}

export default async function BoardPage({ params }: BoardPageParams) {
  const result = await getBoardData(params.boardId)

  if ('error' in result) {
    return <ErrorDisplay errorType={result.error} />
  }

  return <Board boardData={result} />
}
