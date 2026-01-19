import { Page } from '@playwright/test'

/**
 * Test helper for authentication.
 *
 * For magic link auth, full e2e testing requires email service integration.
 * As a pragmatic V1 approach, we test the UI flows and will add full
 * authenticated session tests when we have:
 * 1. Test email inbox automation, or
 * 2. A test API endpoint that creates authenticated sessions
 *
 * This helper will be expanded in future tickets.
 */

export async function loginWithMagicLink(page: Page, email: string) {
  await page.goto('/login')
  await page.getByPlaceholder('Enter your email').fill(email)
  await page.getByRole('button', { name: 'Send Magic Link' }).click()
}

/**
 * Future: Add helper to programmatically create authenticated session
 * This would use Supabase admin API or test endpoint to bypass magic link
 */
export async function createAuthenticatedSession(page: Page, email: string) {
  // TODO: Implement in later tickets with test user setup
  // Options:
  // 1. Use Supabase admin API to create session tokens
  // 2. Create a test-only endpoint that generates sessions
  // 3. Integrate with test email service to extract magic links
  throw new Error('Not yet implemented - will be added when needed for board tests')
}
