import { test, expect } from '@playwright/test'

/**
 * Access control tests
 *
 * Tests that users cannot access boards they don't have permission to view,
 * and that friendly error messages are shown.
 */

test.describe('Access control', () => {
  test.beforeEach(async ({ page }) => {
    // Skip test if no auth tokens available
    const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
    if (!hasAuthTokens) {
      test.skip()
      return
    }

    // Set auth cookies for authenticated tests
    if (process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN) {
      await page.goto('/')
      await page.evaluate(
        ({ accessToken, refreshToken }) => {
          document.cookie = `sb-access-token=${accessToken}; path=/; max-age=3600`
          document.cookie = `sb-refresh-token=${refreshToken}; path=/; max-age=3600`
        },
        {
          accessToken: process.env.TEST_ACCESS_TOKEN,
          refreshToken: process.env.TEST_REFRESH_TOKEN,
        }
      )
    }
  })

  test('shows access denied for non-existent board', async ({ page }) => {
    // Skip test if no auth tokens available
    const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
    if (!hasAuthTokens) {
      test.skip()
      return
    }

    // Try to access a board with a random UUID that doesn't exist
    const nonExistentBoardId = '00000000-0000-0000-0000-000000000000'
    await page.goto(`/app/board/${nonExistentBoardId}`)

    // Should show access denied message (RLS will deny access to non-existent boards)
    await expect(page.getByRole('heading', { name: 'Access Denied' })).toBeVisible()
    await expect(page.getByText("You don't have permission to view this board")).toBeVisible()

    // Should have a link to go back to boards
    const boardsLink = page.getByRole('link', { name: 'Go to Boards' })
    await expect(boardsLink).toBeVisible()

    // Clicking the link should navigate to boards page
    await boardsLink.click()
    await expect(page).toHaveURL('/app/boards')
  })

  test('shows board not found for invalid board ID format', async ({ page }) => {
    // Skip test if no auth tokens available
    const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
    if (!hasAuthTokens) {
      test.skip()
      return
    }

    // Try to access a board with an invalid UUID format
    await page.goto('/app/board/invalid-uuid-format')

    // Should show either access denied or not found
    // (Supabase will reject invalid UUID formats)
    const hasAccessDenied = await page.getByRole('heading', { name: 'Access Denied' }).isVisible()
    const hasNotFound = await page.getByRole('heading', { name: 'Board Not Found' }).isVisible()

    // One of these should be visible
    expect(hasAccessDenied || hasNotFound).toBe(true)

    // Should have a link to go back to boards
    await expect(page.getByRole('link', { name: 'Go to Boards' })).toBeVisible()
  })

  test('unauthenticated user is redirected to login', async ({ page }) => {
    // Create a new context without auth cookies
    const context = await page.context().browser()?.newContext()
    if (!context) {
      test.skip()
      return
    }

    const unauthPage = await context.newPage()

    // Try to access boards page without authentication
    await unauthPage.goto('/app/boards')

    // Should be redirected to login
    await expect(unauthPage).toHaveURL('/login')

    // Clean up
    await unauthPage.close()
    await context.close()
  })

  test('error UI matches app styling', async ({ page }) => {
    // Skip test if no auth tokens available
    const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
    if (!hasAuthTokens) {
      test.skip()
      return
    }

    const nonExistentBoardId = '00000000-0000-0000-0000-000000000000'
    await page.goto(`/app/board/${nonExistentBoardId}`)

    // Check that error display has proper styling
    const errorContainer = page.locator('div').filter({ hasText: 'Access Denied' }).first()
    await expect(errorContainer).toBeVisible()

    // Verify the link is styled as a button
    const link = page.getByRole('link', { name: 'Go to Boards' })
    await expect(link).toHaveCSS('background-color', 'rgb(0, 0, 0)') // black background
    await expect(link).toHaveCSS('color', 'rgb(255, 255, 255)') // white text
  })
})
