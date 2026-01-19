import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Header from '@/components/Header'
import { ensureUserWorkspace } from '@/lib/workspace'

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Ensure user has a workspace (T3: workspace bootstrap)
  await ensureUserWorkspace(supabase)

  return (
    <div>
      <Header userEmail={user.email || 'Unknown'} />
      <main>{children}</main>
    </div>
  )
}
