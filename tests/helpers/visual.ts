/**
 * Visual Regression Testing Helpers
 *
 * Provides utilities for capturing and comparing visual state of the application.
 * Uses Playwright's built-in screenshot comparison capabilities.
 */

import { Page, Locator, expect } from '@playwright/test';

export interface VisualCaptureOptions {
  /**
   * Capture full page instead of just viewport
   * @default false
   */
  fullPage?: boolean;

  /**
   * Clip screenshot to specific region
   */
  clip?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };

  /**
   * Maximum allowed pixel difference
   * @default 100
   */
  maxDiffPixels?: number;

  /**
   * Maximum allowed difference ratio (0-1)
   * @default 0.01 (1%)
   */
  maxDiffPixelRatio?: number;

  /**
   * Mask specific elements (e.g., timestamps, dynamic content)
   */
  mask?: Locator[];

  /**
   * Wait for specific timeout before capture (ms)
   */
  timeout?: number;
}

/**
 * Capture and verify the visual state of an entire page
 *
 * @example
 * ```ts
 * await captureVisualState(page, 'board-empty-state', {
 *   fullPage: true,
 *   mask: [page.getByText(/updated \d+ seconds ago/)]
 * });
 * ```
 */
export async function captureVisualState(
  page: Page,
  name: string,
  options: VisualCaptureOptions = {}
) {
  // Wait for page to stabilize
  if (options.timeout) {
    await page.waitForTimeout(options.timeout);
  }

  // Disable animations for consistent screenshots
  await page.addStyleTag({
    content: `
      *, *::before, *::after {
        animation-duration: 0s !important;
        animation-delay: 0s !important;
        transition-duration: 0s !important;
        transition-delay: 0s !important;
      }
    `
  });

  await expect(page).toHaveScreenshot(`${name}.png`, {
    fullPage: options.fullPage ?? false,
    clip: options.clip,
    maxDiffPixels: options.maxDiffPixels ?? 100,
    maxDiffPixelRatio: options.maxDiffPixelRatio ?? 0.01,
    animations: 'disabled',
    mask: options.mask,
  });
}

/**
 * Capture and verify the visual state of a specific component/element
 *
 * @example
 * ```ts
 * const card = page.getByRole('article', { name: 'Test Card' });
 * await captureComponentState(card, 'card-with-due-date');
 * ```
 */
export async function captureComponentState(
  element: Locator,
  name: string,
  options: Pick<VisualCaptureOptions, 'maxDiffPixels' | 'maxDiffPixelRatio' | 'mask'> = {}
) {
  await expect(element).toHaveScreenshot(`${name}-component.png`, {
    maxDiffPixels: options.maxDiffPixels ?? 50,
    maxDiffPixelRatio: options.maxDiffPixelRatio ?? 0.01,
    animations: 'disabled',
    mask: options.mask,
  });
}

/**
 * Wait for page to reach a stable visual state
 * Useful before taking screenshots to avoid flaky tests
 *
 * @example
 * ```ts
 * await waitForStableState(page);
 * await captureVisualState(page, 'stable-board');
 * ```
 */
export async function waitForStableState(page: Page) {
  // Wait for network to be idle
  await page.waitForLoadState('networkidle', { timeout: 10000 });

  // Wait a bit more for any CSS transitions/animations to complete
  await page.waitForTimeout(500);

  // Wait for any lazy-loaded images
  await page.evaluate(() => {
    const images = Array.from(document.images);
    return Promise.all(
      images
        .filter(img => !img.complete)
        .map(img => new Promise(resolve => {
          img.onload = img.onerror = resolve;
        }))
    );
  });
}

/**
 * Capture multiple visual states in sequence
 * Useful for documenting a user flow
 *
 * @example
 * ```ts
 * await captureFlow(page, [
 *   { name: 'empty-board', action: async () => {} },
 *   { name: 'after-create-list', action: async () => {
 *     await page.click('[aria-label="Add list"]');
 *   }},
 *   { name: 'after-add-card', action: async () => {
 *     await page.click('[aria-label="Add card"]');
 *   }}
 * ]);
 * ```
 */
export async function captureFlow(
  page: Page,
  steps: Array<{
    name: string;
    action: () => Promise<void>;
    options?: VisualCaptureOptions;
  }>
) {
  for (const step of steps) {
    await step.action();
    await waitForStableState(page);
    await captureVisualState(page, `flow-${step.name}`, step.options);
  }
}

/**
 * Mask dynamic content that changes between test runs
 * Common use case: timestamps, user IDs, random data
 *
 * @example
 * ```ts
 * const masks = await maskDynamicContent(page, [
 *   /updated \d+ seconds ago/,
 *   /created by user-[a-f0-9-]+/,
 * ]);
 *
 * await captureVisualState(page, 'board', { mask: masks });
 * ```
 */
export async function maskDynamicContent(
  page: Page,
  patterns: RegExp[]
): Promise<Locator[]> {
  const masks: Locator[] = [];

  for (const pattern of patterns) {
    masks.push(page.getByText(pattern));
  }

  return masks;
}
