/**
 * Example Visual Introspection Test
 *
 * This test demonstrates how to use the visual introspection helpers
 * to create comprehensive visual regression tests with accessibility
 * verification and debug capabilities.
 */

import { test, expect } from '@playwright/test';
import {
  captureVisualState,
  captureComponentState,
  waitForStableState,
  captureFlow,
  maskDynamicContent,
} from '../helpers/visual';
import {
  captureA11yTree,
  verifyA11yStructure,
  checkA11yViolations,
  findA11yNodes,
} from '../helpers/accessibility';
import { VisualDebugger } from '../helpers/debug';

/**
 * Example 1: Basic Visual Regression Test
 */
test('login page matches visual baseline', async ({ page }) => {
  await page.goto('/login');
  await waitForStableState(page);

  // Capture full page screenshot and compare to baseline
  await captureVisualState(page, 'login-page', {
    fullPage: true,
  });

  // Also verify accessibility tree structure
  await verifyA11yStructure(page, 'login-page', {
    role: 'WebArea',
    children: expect.arrayContaining([
      expect.objectContaining({
        role: 'heading',
        name: expect.stringContaining('Sign In'),
      }),
      expect.objectContaining({
        role: 'textbox',
        name: 'Email',
      }),
      expect.objectContaining({
        role: 'button',
        name: 'Send Magic Link',
      }),
    ]),
  });
});

/**
 * Example 2: Component-Level Visual Testing
 */
test('board card displays correctly', async ({ page }) => {
  // This test would normally require auth setup
  // For demo purposes, we'll skip if not authenticated
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  await page.goto('/app/board/test-board-id');
  await waitForStableState(page);

  // Find a card
  const card = page.getByRole('article', { name: /test card/i }).first();
  await expect(card).toBeVisible();

  // Capture just the card component
  await captureComponentState(card, 'board-card-default');

  // Open card modal
  await card.click();
  const modal = page.getByRole('dialog');
  await expect(modal).toBeVisible();

  // Capture modal component
  await captureComponentState(modal, 'card-modal-open');

  // Verify modal accessibility
  await verifyA11yStructure(page, 'card-modal', {
    role: 'dialog',
    name: expect.any(String),
    modal: true,
  });
});

/**
 * Example 3: User Flow with Visual Checkpoints
 */
test('create board flow visual progression', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  await page.goto('/app/boards');

  // Capture each step of the flow
  await captureFlow(page, [
    {
      name: 'boards-list-initial',
      action: async () => {
        // Initial state
      },
    },
    {
      name: 'create-board-modal-open',
      action: async () => {
        await page.getByRole('button', { name: /create board/i }).click();
      },
    },
    {
      name: 'create-board-form-filled',
      action: async () => {
        await page.getByLabel('Board name').fill('Test Board');
      },
    },
    {
      name: 'boards-list-with-new-board',
      action: async () => {
        await page.getByRole('button', { name: /create/i }).click();
        await expect(page.getByText('Test Board')).toBeVisible();
      },
    },
  ]);
});

/**
 * Example 4: Visual Testing with Dynamic Content Masking
 */
test('board view with masked timestamps', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  await page.goto('/app/board/test-board-id');
  await waitForStableState(page);

  // Mask dynamic content that changes between runs
  const masks = await maskDynamicContent(page, [
    /updated \d+ (second|minute|hour)s? ago/,
    /created \d+ (day|week|month)s? ago/,
    /user-[a-f0-9-]+/, // User IDs
  ]);

  // Capture with masked elements
  await captureVisualState(page, 'board-view-masked', {
    fullPage: true,
    mask: masks,
  });
});

/**
 * Example 5: Comprehensive Debug Capture
 */
test('drag and drop with full debug info', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  // Initialize debug helper
  const debug = new VisualDebugger(page, 'dnd-full-debug', {
    captureConsole: true,
    captureNetwork: true,
  });

  await page.goto('/app/board/test-board-id');
  await debug.captureAll('initial-load');

  // Find elements
  const card = page.getByRole('article', { name: /test card/i }).first();
  const sourceList = card.locator('..').locator('..');
  const targetList = page.getByRole('list', { name: /done/i });

  await debug.captureElement(card, 'card-before-drag');
  await debug.captureElement(sourceList, 'source-list-before');
  await debug.captureElement(targetList, 'target-list-before');

  // Perform drag
  await card.dragTo(targetList);
  await debug.waitAndCapture(500, 'after-drag-animation');

  // Verify and capture
  await expect(targetList.locator('article', { hasText: /test card/i })).toBeVisible();
  await debug.captureElement(targetList, 'target-list-after');

  // Reload and verify persistence
  await page.reload();
  await debug.captureAll('after-reload');

  await expect(targetList.locator('article', { hasText: /test card/i })).toBeVisible();
});

/**
 * Example 6: Accessibility Verification
 */
test('board has no accessibility violations', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  await page.goto('/app/board/test-board-id');
  await waitForStableState(page);

  // Check for common a11y violations
  const violations = await checkA11yViolations(page);

  // Log violations if any
  if (violations.length > 0) {
    console.log('Accessibility violations found:');
    violations.forEach((v) => {
      console.log(`  - [${v.type}] ${v.message}`);
    });
  }

  // Test should fail if violations exist
  expect(violations).toHaveLength(0);

  // Also verify specific a11y tree structure
  const tree = await captureA11yTree(page, 'board-a11y');

  // Verify there are lists
  const lists = findA11yNodes(tree, { role: 'list' });
  expect(lists.length).toBeGreaterThan(0);

  // Verify cards are accessible
  const cards = findA11yNodes(tree, { role: 'article' });
  expect(cards.length).toBeGreaterThan(0);

  // Each card should have a name
  cards.forEach((card) => {
    expect(card.name).toBeTruthy();
  });
});

/**
 * Example 7: Timeline Recording
 */
test('record timeline of complex interaction', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  const debug = new VisualDebugger(page, 'timeline-example');
  const timeline = debug.createTimeline();

  await timeline.mark('test-start');

  await page.goto('/app/boards');
  await timeline.mark('boards-page-loaded');

  await page.getByRole('button', { name: /create board/i }).click();
  await timeline.mark('create-modal-opened');

  await page.getByLabel('Board name').fill('Timeline Test Board');
  await timeline.mark('form-filled');

  await page.getByRole('button', { name: /create/i }).click();
  await timeline.mark('board-created');

  // Wait for navigation
  await page.waitForURL(/\/app\/board\/.+/);
  await timeline.mark('navigated-to-board');

  await page.getByRole('button', { name: /add list/i }).click();
  await timeline.mark('add-list-clicked');

  await page.getByLabel('List name').fill('To Do');
  await page.getByRole('button', { name: /add/i }).click();
  await timeline.mark('list-created');

  // Save timeline with all screenshots
  const timelinePath = await timeline.save();
  console.log(`Timeline saved: ${timelinePath}`);
});

/**
 * Example 8: Mobile Visual Testing
 */
test('board is visually correct on mobile', async ({ page, browserName }) => {
  // Only run on mobile viewports
  test.skip(browserName !== 'webkit', 'Mobile test - WebKit only');
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  // Set mobile viewport
  await page.setViewportSize({ width: 375, height: 667 }); // iPhone SE

  await page.goto('/app/board/test-board-id');
  await waitForStableState(page);

  // Capture mobile view
  await captureVisualState(page, 'board-mobile-iphone-se', {
    fullPage: true,
  });

  // Verify touch-friendly UI elements
  const addListButton = page.getByRole('button', { name: /add list/i });
  const buttonBox = await addListButton.boundingBox();

  // Button should be at least 44x44 (Apple's minimum touch target)
  expect(buttonBox?.width).toBeGreaterThanOrEqual(44);
  expect(buttonBox?.height).toBeGreaterThanOrEqual(44);
});

/**
 * Example 9: Visual Regression After Code Change
 *
 * This demonstrates how an agent would verify visual changes
 */
test('verify new badge styling', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  await page.goto('/app/board/test-board-id');

  // Locate card with due date badge
  const cardWithBadge = page.getByRole('article').filter({
    has: page.getByText('Due Soon'),
  });

  await expect(cardWithBadge).toBeVisible();

  // Capture the badge component specifically
  const badge = cardWithBadge.getByText('Due Soon');
  await captureComponentState(badge, 'due-soon-badge');

  // Verify accessibility
  const a11yTree = await captureA11yTree(page);
  const badges = findA11yNodes(a11yTree, { role: 'status' });

  expect(badges.length).toBeGreaterThan(0);
  expect(badges.some((b) => b.name === 'Due Soon')).toBe(true);

  // Capture full card with badge
  await captureComponentState(cardWithBadge, 'card-with-due-badge');
});

/**
 * Example 10: Performance-Aware Visual Testing
 */
test('board loads and renders within performance budget', async ({ page }) => {
  test.skip(!process.env.TEST_ACCESS_TOKEN, 'Requires authentication');

  const debug = new VisualDebugger(page, 'performance-visual');

  // Start measuring
  const startTime = Date.now();

  await page.goto('/app/board/test-board-id');

  // Wait for first paint
  await page.waitForLoadState('domcontentloaded');
  const domContentLoaded = Date.now() - startTime;

  await debug.capture('dom-content-loaded');

  // Wait for full load
  await waitForStableState(page);
  const fullyLoaded = Date.now() - startTime;

  await debug.captureAll('fully-loaded');

  // Performance budget checks
  expect(domContentLoaded).toBeLessThan(2000); // 2 seconds
  expect(fullyLoaded).toBeLessThan(5000); // 5 seconds

  console.log(`Performance:
    - DOM Content Loaded: ${domContentLoaded}ms
    - Fully Loaded: ${fullyLoaded}ms
  `);

  // Visual should match despite load time
  await captureVisualState(page, 'board-performance-test', {
    fullPage: true,
  });
});
