import { test, expect } from '@playwright/test'

test.describe('Smoke tests', () => {
  test('homepage loads', async ({ page }) => {
    await page.goto('/')
    // Should redirect to login
    await expect(page).toHaveURL(/\/login/)
  })

  test('login page displays', async ({ page }) => {
    await page.goto('/login')
    await expect(page.locator('h1')).toHaveText('Login')
  })
})
