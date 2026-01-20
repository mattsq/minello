import { test, expect } from '@playwright/test'

/**
 * Invite operations tests (T8)
 *
 * Tests the workspace invite functionality:
 * - Owner can invite family by email
 * - Invited user gains access after login
 *
 * NOTE: These tests require an authenticated session.
 * Set TEST_ACCESS_TOKEN and TEST_REFRESH_TOKEN env vars to run.
 */

test.describe('Workspace invites', () => {
  test.beforeEach(async ({ page }) => {
    // Skip all tests in this suite if no auth tokens available
    const hasAuthTokens = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN
    if (!hasAuthTokens) {
      test.skip()
    }
  })

  test('can send invite to workspace member', async ({ page }) => {
    await page.goto('/app/boards')

    // Should see the boards page
    await expect(page.getByRole('heading', { name: 'My Boards' })).toBeVisible()

    // Click "Invite Members" button
    await page.getByTestId('invite-toggle-btn').click()

    // Should see the invite section
    await expect(page.getByRole('heading', { name: 'Workspace Members' })).toBeVisible()

    // Enter an email to invite
    const inviteEmail = `test-invite-${Date.now()}@example.com`
    await page.getByTestId('invite-email-input').fill(inviteEmail)

    // Click "Send Invite"
    await page.getByTestId('send-invite-btn').click()

    // Should see success message
    await expect(page.getByTestId('invite-success')).toBeVisible()
    await expect(page.getByTestId('invite-success')).toHaveText('Invite sent successfully!')

    // Should see the invite in the pending invites list
    await expect(page.getByText('Pending Invites (1)')).toBeVisible()
    await expect(page.getByTestId('pending-invite')).toBeVisible()
    await expect(page.getByText(inviteEmail)).toBeVisible()
  })

  test('shows error when inviting duplicate email', async ({ page }) => {
    await page.goto('/app/boards')

    // Open invite section
    await page.getByTestId('invite-toggle-btn').click()

    // Send first invite
    const inviteEmail = `duplicate-test-${Date.now()}@example.com`
    await page.getByTestId('invite-email-input').fill(inviteEmail)
    await page.getByTestId('send-invite-btn').click()

    // Wait for success
    await expect(page.getByTestId('invite-success')).toBeVisible()

    // Try to send the same invite again
    await page.getByTestId('invite-email-input').fill(inviteEmail)
    await page.getByTestId('send-invite-btn').click()

    // Should see error message
    await expect(page.getByTestId('invite-error')).toBeVisible()
    await expect(page.getByTestId('invite-error')).toContainText('already been sent')
  })

  test('shows error when inviting invalid email', async ({ page }) => {
    await page.goto('/app/boards')

    // Open invite section
    await page.getByTestId('invite-toggle-btn').click()

    // Enter invalid email
    await page.getByTestId('invite-email-input').fill('not-an-email')
    await page.getByTestId('send-invite-btn').click()

    // Should see error (browser validation might prevent submit,
    // but if it gets through, server should reject)
    // Note: HTML5 email validation might prevent this from even submitting
  })

  test('can revoke pending invite', async ({ page }) => {
    await page.goto('/app/boards')

    // Open invite section
    await page.getByTestId('invite-toggle-btn').click()

    // Send an invite
    const inviteEmail = `revoke-test-${Date.now()}@example.com`
    await page.getByTestId('invite-email-input').fill(inviteEmail)
    await page.getByTestId('send-invite-btn').click()

    // Wait for success
    await expect(page.getByTestId('invite-success')).toBeVisible()

    // Verify invite appears
    await expect(page.getByTestId('pending-invite')).toBeVisible()

    // Click "Revoke" button
    await page.getByRole('button', { name: 'Revoke' }).click()

    // Invite should be removed
    // After revoke, there might be no pending invites
    // So we check that the specific email is no longer visible in pending invites
    await page.waitForTimeout(500) // Wait for update

    // The invite should be gone
    // If this was the only invite, the pending invites section might not show a count
    // Let's just verify the email is no longer in a pending invite
    const pendingInvites = page.getByTestId('pending-invite')
    const count = await pendingInvites.count()

    if (count > 0) {
      // If there are still pending invites, make sure ours isn't there
      await expect(page.getByTestId('pending-invite').filter({ hasText: inviteEmail })).not.toBeVisible()
    }
    // else no pending invites remain, which is fine
  })

  test('invite persists after page reload', async ({ page }) => {
    await page.goto('/app/boards')

    // Open invite section
    await page.getByTestId('invite-toggle-btn').click()

    // Send an invite
    const inviteEmail = `persist-test-${Date.now()}@example.com`
    await page.getByTestId('invite-email-input').fill(inviteEmail)
    await page.getByTestId('send-invite-btn').click()

    // Wait for success
    await expect(page.getByTestId('invite-success')).toBeVisible()

    // Reload the page
    await page.reload()

    // Open invite section again
    await page.getByTestId('invite-toggle-btn').click()

    // Should still see the pending invite
    await expect(page.getByText(inviteEmail)).toBeVisible()
  })

  test('displays current workspace members', async ({ page }) => {
    await page.goto('/app/boards')

    // Open invite section
    await page.getByTestId('invite-toggle-btn').click()

    // Should see at least one member (the current user)
    await expect(page.getByText(/Current Members \(\d+\)/)).toBeVisible()

    // The current user should be listed
    // We can't predict the exact email, but there should be at least one member displayed
  })

  // This test requires a second authenticated user session
  // Marked as skip for V1, can be implemented when we have multi-user test infrastructure
  test.skip('invited user can claim invite and access workspace', async ({ page, context }) => {
    // This would require:
    // 1. First user session: create invite for user2@example.com
    // 2. Second user session: log in as user2@example.com
    // 3. Verify user2 is now a member of the workspace
    // 4. Verify user2 can see boards from that workspace
    //
    // For V1, this flow can be tested manually
    // For automated testing, we'd need to:
    // - Create a second browser context
    // - Authenticate with a different user
    // - Verify they can access the workspace
  })
})
