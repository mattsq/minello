'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

/**
 * Update a card's position and/or list
 */
export async function updateCardPosition(
  cardId: string,
  listId: string,
  position: number,
  boardId: string
) {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    throw new Error('Unauthorized')
  }

  const { data, error } = await supabase
    .from('cards')
    .update({
      list_id: listId,
      position,
      updated_at: new Date().toISOString(),
    })
    .eq('id', cardId)
    .select()
    .single()

  if (error) {
    console.error('Error updating card position:', error)
    throw new Error('Failed to update card position')
  }

  revalidatePath(`/app/board/${boardId}`)
  return data
}
