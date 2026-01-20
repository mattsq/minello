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

  test('PWA manifest is accessible', async ({ page }) => {
    const response = await page.goto('/manifest.webmanifest')
    expect(response?.status()).toBe(200)
    const manifest = await response?.json()
    expect(manifest.name).toBe('FamilyBoard Task Pack')
    expect(manifest.display).toBe('standalone')
  })

  test('PWA icons are accessible', async ({ page }) => {
    const icons = [
      '/icons/icon-192x192.png',
      '/icons/icon-512x512.png',
      '/icons/apple-touch-icon.png',
    ]

    for (const icon of icons) {
      const response = await page.goto(icon)
      expect(response?.status()).toBe(200)
      expect(response?.headers()['content-type']).toContain('image/png')
    }
  })

  test('PWA meta tags are present', async ({ page }) => {
    await page.goto('/login')

    // Check manifest link
    const manifestLink = page.locator('link[rel="manifest"]')
    await expect(manifestLink).toHaveAttribute('href', '/manifest.webmanifest')

    // Check apple-touch-icon
    const appleTouchIcon = page.locator('link[rel="apple-touch-icon"]')
    await expect(appleTouchIcon).toHaveCount(1)

    // Check theme-color meta tag
    const themeColor = page.locator('meta[name="theme-color"]')
    await expect(themeColor).toHaveAttribute('content', '#3b82f6')
  })
})
