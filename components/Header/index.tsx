'use client'

import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'

interface HeaderProps {
  userEmail: string
}

export default function Header({ userEmail }: HeaderProps) {
  const router = useRouter()
  const supabase = createClient()

  const handleLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <header
      style={{
        backgroundColor: '#000',
        color: '#fff',
        padding: '1rem 2rem',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
      }}
    >
      <h1 style={{ fontSize: '1.5rem', margin: 0 }}>FamilyBoard</h1>
      <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
        <span data-testid="user-email">{userEmail}</span>
        <button
          onClick={handleLogout}
          data-testid="logout-button"
          style={{
            backgroundColor: '#fff',
            color: '#000',
            border: 'none',
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          Logout
        </button>
      </div>
    </header>
  )
}
