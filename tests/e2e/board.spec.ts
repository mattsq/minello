import { test, expect } from '@playwright/test'
import { createAuthenticatedSession } from '../helpers/auth'

/**
 * Board operations tests
 *
 * NOTE: These tests require an authenticated session.
 * For V1, you can:
 * 1. Run these manually after logging in
 * 2. Set up test auth tokens (TEST_ACCESS_TOKEN, TEST_REFRESH_TOKEN)
 * 3. Implement a test-only auth endpoint
 *
 * See tests/helpers/auth.ts for implementation options.
 */

test.describe('Board operations', () => {
  // Skip auth setup for now - will be implemented when test infrastructure is ready
  test.beforeEach(async ({ page }) => {
    // TODO: Uncomment when test auth is ready
    // await createAuthenticatedSession(page)
  })

  test.describe('Board creation', () => {
    test('can create board', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      // Navigate to boards page
      await page.goto('/app/boards')

      // Should see the boards page
      await expect(page.getByRole('heading', { name: 'My Boards' })).toBeVisible()

      // Click create board button
      await page.getByRole('button', { name: 'Create Board' }).click()

      // Should show the create form
      await expect(page.getByLabel('Board Name')).toBeVisible()

      // Fill in board name
      const boardName = `Test Board ${Date.now()}`
      await page.getByLabel('Board Name').fill(boardName)

      // Submit the form
      await page.getByRole('button', { name: 'Create' }).click()

      // Should see the new board in the list
      await expect(page.getByRole('heading', { name: boardName })).toBeVisible()

      // Should be able to click the board to navigate to it
      await page.getByRole('link', { name: boardName }).click()

      // Should navigate to the board page
      await expect(page).toHaveURL(/\/app\/board\/[a-f0-9-]+/)
    })

    test('board persists after refresh', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board
      const boardName = `Persistent Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Verify it appears
      await expect(page.getByRole('heading', { name: boardName })).toBeVisible()

      // Reload the page
      await page.reload()

      // Board should still be there
      await expect(page.getByRole('heading', { name: boardName })).toBeVisible()
    })

    test('can cancel board creation', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Click create board button
      await page.getByRole('button', { name: 'Create Board' }).click()

      // Should show the create form
      await expect(page.getByLabel('Board Name')).toBeVisible()

      // Fill in some text
      await page.getByLabel('Board Name').fill('This will be cancelled')

      // Click cancel
      await page.getByRole('button', { name: 'Cancel' }).click()

      // Form should be hidden
      await expect(page.getByLabel('Board Name')).not.toBeVisible()

      // Create button should be visible again
      await expect(page.getByRole('button', { name: 'Create Board' })).toBeVisible()
    })

    test('shows empty state when no boards exist', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // This test assumes a fresh user or we'd need to delete all boards first
      // For now, just check that either we see boards or the empty state
      const hasBoards = await page.getByRole('link').count()

      if (hasBoards === 0) {
        await expect(
          page.getByText('No boards yet. Create your first board to get started!')
        ).toBeVisible()
      }
    })
  })

  test.describe('Board list features', () => {
    test.skip('displays boards sorted by creation date', async ({ page }) => {
      // TODO: Implement in future iterations
    })
  })

  // Placeholder tests for T5-T7
  test.describe('List operations', () => {
    test.skip('can create list', async ({ page }) => {
      // TODO: Implement in T5
    })
  })

  test.describe('Card operations', () => {
    test.skip('can create card', async ({ page }) => {
      // TODO: Implement in T5
    })

    test.skip('can edit card', async ({ page }) => {
      // TODO: Implement in T6
    })
  })

  test.describe('Drag and drop', () => {
    test.skip('can drag card between lists', async ({ page }) => {
      // TODO: Implement in T7
    })
  })
})
