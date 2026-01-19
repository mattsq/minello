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
 * Create an authenticated session for testing.
 *
 * For V1, this uses localStorage to set Supabase auth tokens.
 * This requires TEST_USER_EMAIL and TEST_USER_PASSWORD env vars
 * or a test-only API endpoint.
 *
 * Alternative approaches:
 * 1. Use Supabase admin API to create session tokens
 * 2. Create a test-only endpoint that generates sessions
 * 3. Integrate with test email service to extract magic links
 */
export async function createAuthenticatedSession(page: Page, email?: string) {
  const testEmail = email || process.env.TEST_USER_EMAIL || 'test@example.com'

  // Navigate to a test auth endpoint if available
  // For now, we'll use the magic link flow and rely on manual setup
  // or environment-specific test credentials

  // Check if we have test credentials that can bypass magic link
  if (process.env.TEST_USER_PASSWORD) {
    // If password auth is enabled in Supabase for testing
    await page.goto('/login')
    // This would need a password field in the login form
    // For now, this is a placeholder for future implementation
    throw new Error('Password auth not yet implemented in login form')
  }

  // For CI/test environments, you should:
  // 1. Have a dedicated Supabase project for testing
  // 2. Either use email automation or a test endpoint that sets auth session
  throw new Error(
    'Test authentication not fully implemented. ' +
    'For V1, tests requiring auth should be run manually or skipped. ' +
    'Set TEST_USER_EMAIL and implement session creation via Supabase admin API.'
  )
}

/**
 * Alternative: Set auth session directly using Supabase cookies
 * This requires having valid session tokens from a test user
 */
export async function setAuthSession(
  page: Page,
  accessToken: string,
  refreshToken: string
) {
  await page.goto('/')

  // Set Supabase auth in localStorage
  await page.evaluate(
    ({ access, refresh }) => {
      const authData = {
        access_token: access,
        refresh_token: refresh,
        expires_in: 3600,
        token_type: 'bearer',
        user: null, // Will be populated by Supabase
      }

      localStorage.setItem(
        'sb-' + window.location.hostname.split('.')[0] + '-auth-token',
        JSON.stringify(authData)
      )
    },
    { access: accessToken, refresh: refreshToken }
  )

  await page.reload()
}
