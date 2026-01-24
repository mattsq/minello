/**
 * Visual State Documentation Generator
 *
 * Automatically generates visual documentation of all key app states.
 * Useful for agents to understand what the app looks like without running it.
 *
 * Usage:
 *   pnpm tsx scripts/generate-visual-docs.ts
 */

import { chromium, Browser, Page } from '@playwright/test';
import fs from 'fs/promises';
import path from 'path';

interface VisualState {
  name: string;
  url: string;
  description: string;
  interactions?: string[];
  requiresAuth?: boolean;
  waitFor?: string; // Selector to wait for
  viewport?: { width: number; height: number };
  setup?: (page: Page) => Promise<void>;
}

/**
 * Define all visual states to document
 */
const VISUAL_STATES: VisualState[] = [
  // Public pages
  {
    name: 'login-page',
    url: '/login',
    description: 'Magic link authentication page',
    interactions: [
      'Email input field',
      'Send Magic Link button',
      'Form validation',
    ],
    waitFor: 'input[type="email"]',
  },

  // Authenticated pages
  {
    name: 'boards-list-empty',
    url: '/app/boards',
    description: 'Boards list page with no boards',
    requiresAuth: true,
    interactions: [
      'Create Board button',
      'Empty state message',
    ],
    waitFor: 'button',
  },

  {
    name: 'boards-list-with-boards',
    url: '/app/boards',
    description: 'Boards list page with multiple boards',
    requiresAuth: true,
    interactions: [
      'Board cards',
      'Create Board button',
      'Board navigation',
    ],
    waitFor: 'button',
    setup: async (page) => {
      // Create a test board for this screenshot
      const createButton = page.getByRole('button', { name: /create board/i });
      if (await createButton.isVisible()) {
        await createButton.click();
        await page.getByLabel(/board name/i).fill('Example Board');
        await page.getByRole('button', { name: /create/i }).click();
        await page.waitForTimeout(1000);
        await page.goto('/app/boards');
      }
    },
  },

  {
    name: 'board-empty',
    url: '/app/board/new',
    description: 'Empty board with no lists',
    requiresAuth: true,
    interactions: [
      'Add List button',
      'Board header',
      'Empty state',
    ],
    waitFor: 'main',
  },

  {
    name: 'board-with-lists',
    url: '/app/board/example',
    description: 'Board with multiple lists and cards',
    requiresAuth: true,
    interactions: [
      'Lists displayed horizontally',
      'Cards within lists',
      'Add List button',
      'Add Card buttons',
      'Drag and drop functionality',
    ],
    waitFor: 'main',
    setup: async (page) => {
      // This would need an actual board ID
      // For now, we'll capture what's available
    },
  },

  {
    name: 'card-modal',
    url: '/app/board/example',
    description: 'Card edit modal',
    requiresAuth: true,
    interactions: [
      'Title input',
      'Description textarea',
      'Due date picker',
      'Assignee dropdown',
      'Save/Cancel buttons',
    ],
    waitFor: 'main',
    setup: async (page) => {
      // Click first card to open modal
      const card = page.getByRole('article').first();
      if (await card.isVisible()) {
        await card.click();
        await page.waitForTimeout(500);
      }
    },
  },

  // Mobile views
  {
    name: 'board-mobile-iphone12',
    url: '/app/board/example',
    description: 'Board view on iPhone 12',
    requiresAuth: true,
    viewport: { width: 390, height: 844 },
    waitFor: 'main',
  },

  {
    name: 'board-mobile-iphone-se',
    url: '/app/board/example',
    description: 'Board view on iPhone SE (small screen)',
    requiresAuth: true,
    viewport: { width: 375, height: 667 },
    waitFor: 'main',
  },

  // Error states
  {
    name: 'board-not-found',
    url: '/app/board/non-existent-board-id',
    description: 'Board not found error state',
    requiresAuth: true,
    interactions: [
      'Error message',
      'Return to boards link',
    ],
    waitFor: 'main',
  },
];

/**
 * Main documentation generator
 */
async function generateVisualDocs() {
  console.log('🚀 Starting visual documentation generation...\n');

  // Ensure output directory exists
  const outputDir = path.join(process.cwd(), 'docs', 'visual-states');
  await fs.mkdir(outputDir, { recursive: true });

  // Launch browser
  const browser = await chromium.launch({ headless: true });

  // Check if we have auth credentials
  const hasAuth = process.env.TEST_ACCESS_TOKEN && process.env.TEST_REFRESH_TOKEN;

  if (!hasAuth) {
    console.log('⚠️  No auth tokens found. Only public pages will be documented.');
    console.log('   Set TEST_ACCESS_TOKEN and TEST_REFRESH_TOKEN to document authenticated pages.\n');
  }

  const docs: string[] = [
    '# Visual State Reference',
    '',
    'Auto-generated visual documentation of FamilyBoard app states.',
    '',
    `_Generated: ${new Date().toISOString()}_`,
    '',
    '## Table of Contents',
    '',
  ];

  // Generate TOC
  for (const state of VISUAL_STATES) {
    if (state.requiresAuth && !hasAuth) continue;
    docs.push(`- [${formatName(state.name)}](#${state.name})`);
  }
  docs.push('');

  // Process each visual state
  for (const state of VISUAL_STATES) {
    if (state.requiresAuth && !hasAuth) {
      console.log(`⏭️  Skipping ${state.name} (requires auth)`);
      continue;
    }

    console.log(`📸 Capturing: ${state.name}`);

    try {
      await captureVisualState(browser, state, outputDir, docs);
    } catch (error) {
      console.error(`❌ Failed to capture ${state.name}:`, error);
      docs.push(`## ${formatName(state.name)}`);
      docs.push(`**Status:** ⚠️ Failed to capture`);
      docs.push(`**Error:** ${error instanceof Error ? error.message : 'Unknown error'}`);
      docs.push('');
    }
  }

  // Write documentation file
  const docsPath = path.join(process.cwd(), 'docs', 'VISUAL_STATES.md');
  await fs.writeFile(docsPath, docs.join('\n'));

  await browser.close();

  console.log('\n✅ Visual documentation generated successfully!');
  console.log(`📄 Documentation: ${docsPath}`);
  console.log(`📁 Screenshots: ${outputDir}`);
}

/**
 * Capture a single visual state
 */
async function captureVisualState(
  browser: Browser,
  state: VisualState,
  outputDir: string,
  docs: string[]
) {
  const page = await browser.newPage({
    viewport: state.viewport || { width: 1280, height: 720 },
  });

  // Set auth if required
  if (state.requiresAuth) {
    await setAuthTokens(page);
  }

  // Navigate to URL
  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  await page.goto(`${baseUrl}${state.url}`, {
    waitUntil: 'networkidle',
    timeout: 30000,
  });

  // Wait for specific element if specified
  if (state.waitFor) {
    await page.waitForSelector(state.waitFor, { timeout: 10000 });
  }

  // Run setup if provided
  if (state.setup) {
    await state.setup(page);
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
    `,
  });

  // Wait a bit for everything to settle
  await page.waitForTimeout(500);

  // Capture screenshot
  const screenshotPath = path.join(outputDir, `${state.name}.png`);
  await page.screenshot({
    path: screenshotPath,
    fullPage: true,
  });

  // Capture accessibility tree
  const a11ySnapshot = await page.accessibility.snapshot();
  const a11yPath = path.join(outputDir, `${state.name}-a11y.json`);
  await fs.writeFile(a11yPath, JSON.stringify(a11ySnapshot, null, 2));

  // Capture DOM snapshot
  const html = await page.content();
  const htmlPath = path.join(outputDir, `${state.name}.html`);
  await fs.writeFile(htmlPath, html);

  // Get page metrics
  const metrics = await page.evaluate(() => ({
    title: document.title,
    url: window.location.href,
    width: window.innerWidth,
    height: window.innerHeight,
  }));

  // Add to documentation
  docs.push(`## ${formatName(state.name)}`);
  docs.push('');
  docs.push(`**URL:** \`${state.url}\``);
  docs.push(`**Description:** ${state.description}`);
  if (state.viewport) {
    docs.push(`**Viewport:** ${state.viewport.width}x${state.viewport.height}`);
  }
  docs.push(`**Page Title:** ${metrics.title}`);
  docs.push('');

  if (state.interactions && state.interactions.length > 0) {
    docs.push('**Key Interactions:**');
    state.interactions.forEach((interaction) => {
      docs.push(`- ${interaction}`);
    });
    docs.push('');
  }

  docs.push('**Visual State:**');
  docs.push('');
  docs.push(`![${state.name}](./visual-states/${state.name}.png)`);
  docs.push('');

  // Add accessibility tree summary
  const a11ySummary = generateA11ySummary(a11ySnapshot);
  docs.push('**Accessibility Tree:**');
  docs.push('```');
  docs.push(a11ySummary);
  docs.push('```');
  docs.push('');

  docs.push('**Artifacts:**');
  docs.push(`- Screenshot: [${state.name}.png](./visual-states/${state.name}.png)`);
  docs.push(`- A11y Tree: [${state.name}-a11y.json](./visual-states/${state.name}-a11y.json)`);
  docs.push(`- DOM Snapshot: [${state.name}.html](./visual-states/${state.name}.html)`);
  docs.push('');
  docs.push('---');
  docs.push('');

  await page.close();
}

/**
 * Set authentication tokens in browser
 */
async function setAuthTokens(page: Page) {
  const accessToken = process.env.TEST_ACCESS_TOKEN;
  const refreshToken = process.env.TEST_REFRESH_TOKEN;

  if (!accessToken || !refreshToken) {
    throw new Error('Auth tokens not available');
  }

  // Set Supabase auth in localStorage
  await page.addInitScript(({ accessToken, refreshToken }) => {
    const authData = {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: 3600,
      token_type: 'bearer',
      user: {
        id: 'test-user',
        email: 'test@example.com',
      },
    };

    localStorage.setItem(
      'sb-auth-token',
      JSON.stringify(authData)
    );
  }, { accessToken, refreshToken });
}

/**
 * Generate human-readable accessibility tree summary
 */
function generateA11ySummary(
  snapshot: any,
  depth: number = 0,
  maxDepth: number = 3
): string {
  if (!snapshot || depth > maxDepth) return '';

  const indent = '  '.repeat(depth);
  let summary = '';

  const role = snapshot.role || 'unknown';
  const name = snapshot.name ? ` "${snapshot.name}"` : '';
  const value = snapshot.value ? ` = "${snapshot.value}"` : '';

  summary += `${indent}${role}${name}${value}\n`;

  if (snapshot.children && snapshot.children.length > 0) {
    // Only show first few children if too many
    const childrenToShow = snapshot.children.slice(0, 5);
    childrenToShow.forEach((child: any) => {
      summary += generateA11ySummary(child, depth + 1, maxDepth);
    });

    if (snapshot.children.length > 5) {
      summary += `${indent}  ... ${snapshot.children.length - 5} more children\n`;
    }
  }

  return summary;
}

/**
 * Format name for display
 */
function formatName(name: string): string {
  return name
    .split('-')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

/**
 * Run the generator
 */
if (require.main === module) {
  generateVisualDocs().catch((error) => {
    console.error('❌ Failed to generate visual documentation:', error);
    process.exit(1);
  });
}

export { generateVisualDocs, VISUAL_STATES };
