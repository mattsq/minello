import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('can visit login page and see magic link form', async ({ page }) => {
    await page.goto('/login')

    await expect(page.getByRole('heading', { name: 'Login' })).toBeVisible()
    await expect(page.getByPlaceholder('Enter your email')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Send Magic Link' })).toBeVisible()
  })

  test('can submit email for magic link', async ({ page }) => {
    await page.goto('/login')

    const emailInput = page.getByPlaceholder('Enter your email')
    await emailInput.fill('test@example.com')

    await page.getByRole('button', { name: 'Send Magic Link' }).click()

    // Should show success message
    await expect(page.getByText('Check your email for the login link!')).toBeVisible()

    // Email input should be cleared
    await expect(emailInput).toHaveValue('')
  })

  test('unauthenticated user cannot access app routes', async ({ page }) => {
    // Try to access boards page
    await page.goto('/app/boards')

    // Should be redirected to login
    await expect(page).toHaveURL('/login')
  })

  // Note: Full auth flow test with actual magic link requires either:
  // 1. Email service integration in test environment
  // 2. Test API to create authenticated sessions
  // This will be expanded when we have test user setup
  test.skip('authenticated user can access boards and logout', async ({ page }) => {
    // TODO: Implement with test auth helper in later tickets
    // This would test:
    // 1. Login with test credentials
    // 2. See user email in header
    // 3. Access /app/boards
    // 4. Click logout
    // 5. Redirected to login
  })
})
