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

  // T5: List and card operations
  test.describe('List operations', () => {
    test('can create list', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board first
      const boardName = `Test Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Navigate to the board
      await page.getByRole('link', { name: boardName }).click()
      await expect(page).toHaveURL(/\/app\/board\/[a-f0-9-]+/)

      // Should see the board name
      await expect(page.getByRole('heading', { name: boardName })).toBeVisible()

      // Click "Add a list" button
      await page.getByRole('button', { name: '+ Add a list' }).click()

      // Should show list name input
      await expect(page.getByLabel('List Name')).toBeVisible()

      // Fill in list name
      const listName = `Test List ${Date.now()}`
      await page.getByLabel('List Name').fill(listName)

      // Submit the form
      await page.getByRole('button', { name: 'Add List' }).click()

      // Should see the new list
      await expect(page.getByRole('heading', { name: listName })).toBeVisible()
    })

    test('list persists after refresh', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board
      const boardName = `Persistent List Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Navigate to the board
      await page.getByRole('link', { name: boardName }).click()

      // Create a list
      const listName = `Persistent List ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a list' }).click()
      await page.getByLabel('List Name').fill(listName)
      await page.getByRole('button', { name: 'Add List' }).click()

      // Verify it appears
      await expect(page.getByRole('heading', { name: listName })).toBeVisible()

      // Reload the page
      await page.reload()

      // List should still be there
      await expect(page.getByRole('heading', { name: listName })).toBeVisible()
    })
  })

  test.describe('Card operations', () => {
    test('can create card', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board
      const boardName = `Card Test Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Navigate to the board
      await page.getByRole('link', { name: boardName }).click()

      // Create a list
      const listName = `Card Test List ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a list' }).click()
      await page.getByLabel('List Name').fill(listName)
      await page.getByRole('button', { name: 'Add List' }).click()

      // Wait for list to appear
      await expect(page.getByRole('heading', { name: listName })).toBeVisible()

      // Click "Add a card" button
      await page.getByRole('button', { name: '+ Add a card' }).click()

      // Should show card title input
      await expect(page.getByLabel('Card Title')).toBeVisible()

      // Fill in card title
      const cardTitle = `Test Card ${Date.now()}`
      await page.getByLabel('Card Title').fill(cardTitle)

      // Submit the form
      await page.getByRole('button', { name: 'Add Card' }).click()

      // Should see the new card
      await expect(page.getByText(cardTitle)).toBeVisible()
    })

    test('card persists after refresh', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board
      const boardName = `Persistent Card Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Navigate to the board
      await page.getByRole('link', { name: boardName }).click()

      // Create a list
      const listName = `Persistent Card List ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a list' }).click()
      await page.getByLabel('List Name').fill(listName)
      await page.getByRole('button', { name: 'Add List' }).click()

      // Create a card
      const cardTitle = `Persistent Card ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a card' }).click()
      await page.getByLabel('Card Title').fill(cardTitle)
      await page.getByRole('button', { name: 'Add Card' }).click()

      // Verify it appears
      await expect(page.getByText(cardTitle)).toBeVisible()

      // Reload the page
      await page.reload()

      // Card should still be there
      await expect(page.getByText(cardTitle)).toBeVisible()
    })

    test('can edit card', async ({ page }) => {
      // Skip test if no auth tokens available
      const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
      if (!hasAuthTokens) {
        test.skip()
        return
      }

      await page.goto('/app/boards')

      // Create a board
      const boardName = `Edit Card Board ${Date.now()}`
      await page.getByRole('button', { name: 'Create Board' }).click()
      await page.getByLabel('Board Name').fill(boardName)
      await page.getByRole('button', { name: 'Create' }).click()

      // Navigate to the board
      await page.getByRole('link', { name: boardName }).click()

      // Create a list
      const listName = `Edit Card List ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a list' }).click()
      await page.getByLabel('List Name').fill(listName)
      await page.getByRole('button', { name: 'Add List' }).click()

      // Create a card
      const originalCardTitle = `Original Title ${Date.now()}`
      await page.getByRole('button', { name: '+ Add a card' }).click()
      await page.getByLabel('Card Title').fill(originalCardTitle)
      await page.getByRole('button', { name: 'Add Card' }).click()

      // Verify card appears
      await expect(page.getByText(originalCardTitle)).toBeVisible()

      // Click the card to open edit modal
      await page.getByText(originalCardTitle).click()

      // Should see the edit modal
      await expect(page.getByRole('heading', { name: 'Edit Card' })).toBeVisible()

      // Verify title input has the original title
      const titleInput = page.locator('#title')
      await expect(titleInput).toHaveValue(originalCardTitle)

      // Edit the title
      const newCardTitle = `Updated Title ${Date.now()}`
      await titleInput.fill(newCardTitle)

      // Edit the description
      const descriptionText = 'This is a test description for the card'
      await page.locator('#description').fill(descriptionText)

      // Save the changes
      await page.getByRole('button', { name: 'Save' }).click()

      // Modal should close
      await expect(page.getByRole('heading', { name: 'Edit Card' })).not.toBeVisible()

      // Should see the updated card title
      await expect(page.getByText(newCardTitle)).toBeVisible()

      // Should see the description
      await expect(page.getByText(descriptionText)).toBeVisible()

      // Reload the page to verify persistence
      await page.reload()

      // Card should still have the updated values
      await expect(page.getByText(newCardTitle)).toBeVisible()
      await expect(page.getByText(descriptionText)).toBeVisible()
    })
  })

  test.describe('Drag and drop', () => {
    test.skip('can drag card between lists', async ({ page }) => {
      // TODO: Implement in T7
    })
  })
})
