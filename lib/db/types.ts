/**
 * Database types matching Supabase schema
 */

export interface Workspace {
  id: string
  name: string
  created_by: string
  created_at: string
}

export interface WorkspaceMember {
  workspace_id: string
  user_id: string
  role: string
  created_at: string
}

export interface Board {
  id: string
  workspace_id: string
  name: string
  created_by: string
  created_at: string
}

export interface List {
  id: string
  board_id: string
  name: string
  position: number
  created_by: string
  created_at: string
}

export interface Card {
  id: string
  list_id: string
  title: string
  description: string | null
  due_at: string | null
  assignee_id: string | null
  position: number
  created_by: string
  updated_at: string
  created_at: string
}

/**
 * Extended types with relationships
 */

export interface ListWithCards extends List {
  cards: Card[]
}

export interface BoardWithLists extends Board {
  lists: ListWithCards[]
}
